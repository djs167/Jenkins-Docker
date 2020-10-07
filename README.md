# Sherwin Jenkins -> Docker 

This creates a custom Jenkins image (from the official Jenkins dockerhub  image), adding in the ability to do Docker and Ruby things.

Included in this repository are a `Dockerfile` for building the new image and a `docker-compose.ci.yml` file for launching it in your local.

Instructions to run in local:

Step 1: Build Master Image:

```sh
docker build -f Dockerfile -t jenkins-master .
```

Step 2: Build Agent Image:

```sh
docker build -f Dockerfile-agent -t jenkins-agent .
```

Step 3: Run the following:
```sh
docker-compose -f docker-compose.ci.yml up -d
```

To stop the containers run
```sh
docker-compose -f docker-compose.ci.yml down
```

Once the service is up you can access jenkins locally at localhost:8080 
with the default user/password as admin/admin.

In order to create a job pointing it to local git repository please use file:////workspace/git/<REPO NAME> as we are mounting root/git folder to both the images (Assuming that is where git root folder is, if that is not the case please change it in `docker-compose.ci.yml`)

	eg: file:////workspace/git/sw-pcg-microservices-integration-tests