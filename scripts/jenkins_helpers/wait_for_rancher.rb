#!/usr/bin/env ruby

# Uses the Rancher API to figure out when a deploy is completed

require 'net/http'
require 'uri'
require 'json'

# Variables
@stack_name = ARGV[0]
unless @stack_name
  puts 'Missing stack name argument!'
  puts '  Usage: wait_for_rancher <stack> [retries|12] [retry interval|5]'
  exit 1
end
@max_retries = Integer(ARGV[1] || 12)
@retry_interval = Integer(ARGV[2] || 5)
unless @max_retries.is_a?(Integer) && @retry_interval.is_a?(Integer)
  puts 'Invalid argument(s)!'
  puts '  Usage: wait_for_rancher <stack> [retries|12] [retry interval|5]'
  exit 1
end

@rancher_access_key = ENV['RANCHER_ACCESS_KEY']
@rancher_secret_key = ENV['RANCHER_SECRET_KEY']
@rancher_project_id = ENV['RANCHER_PROJ']
@vpc = ENV['VPC'] || 'ebus'
@rancher_url = "http://rancher.#{@vpc}.swaws/v2-beta/projects/#{@rancher_project_id}"


# Execution
def stacks
  stack_url = URI(@rancher_url + '/stacks')
  request = Net::HTTP::Get.new(stack_url)
  request.basic_auth @rancher_access_key, @rancher_secret_key
  request['Accept'] = 'application/json'

  response = Net::HTTP.start(stack_url.hostname, stack_url.port) do |http|
    http.request(request)
  end

  JSON.parse(response.body)['data']
end

def stack_id_from_name(name)
  stacks.select { |s| s['name'] == @stack_name }.first['id']
end

def services_for_stack(stack_id)
  stack_services_url = URI(@rancher_url + '/stacks/' + stack_id.to_s + '/services')
  request = Net::HTTP::Get.new(stack_services_url)
  request.basic_auth @rancher_access_key, @rancher_secret_key
  request['Accept'] = 'application/json'

  response = Net::HTTP.start(stack_services_url.hostname, stack_services_url.port) do |http|
    http.request(request)
  end

  data = JSON.parse(response.body)['data']
  data.map do |service|
    {
      'id' => service['id'],
      'name' => service['name'],
      'state' => service['state']
    }
  end
end

def filtered_services(services)
  done_states = ['active', 'updated', 'upgraded']
  services.select { |s| !done_states.include? s['state'] }
end

# putting it all together
def updating_services
  begin
    filtered_services(services_for_stack(stack_id_from_name(@stack_name)))
  rescue Errno::EINVAL, SocketError
    sleep 0.5
    updating_services
  end
end

@checks = 0
until updating_services.size == 0
  raise 'Too Many Retries' if @checks > @max_retries
  print '.'
  sleep @retry_interval
  @checks += 1
end

puts "\nLooks like Rancher is done upgrading the services in '#{@stack_name}'."
