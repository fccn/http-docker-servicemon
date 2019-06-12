# Docker service monitor

[![Build Status](https://dev.azure.com/pcosta-fccn/Docker%20base%20images/_apis/build/status/fccn.http-docker-servicemon?branchName=master)](https://dev.azure.com/pcosta-fccn/Docker%20base%20images/_build/latest?definitionId=7&branchName=master)

Simple HTTP server written in python that monitors the deployment of multiple instances of a service in a swarm. It checks if all instances of the service are properly running.

It uses the [docker SDK for python](https://docker-py.readthedocs.io) to list the service tasks and check their state. The results are presented in a web page and are refreshed on a given timer.

There are three possible outcomes for the monitoring:
- When the all instances of the service are running

```
OK:
- my_service[running] - started
- my_service[running] - started

```

- When not all instances of the service are running

```
FAIL: not all services are started [1/2]:
- my_service[running] - started
- my_service[starting] - starting

```

- When the service is not running

```
ERROR: service is stopped

```

## Installing and running

You can get the latest version of this server from [Docker Hub](https://hub.docker.com/r/stvfccn/http-docker-servicemon) by running ```docker pull stvfccn/http-docker-servicemon```.

Use the following sample configuration to deploy this monitor as a service in your swarm:

```yaml
version: '3.4'
services:
  monitor:
    image: stvfccn/http-docker-servicemon
    environment:
      PORT: 8000
      SERVICE_NAME: portainer
    ports:
      - target: 8000
        published: 8000
        protocol: tcp
        mode: host
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.role == manager]
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

This configuration would be monitoring *my-service* and presenting the monitorization results on http://localhost:8000. Make sure to define the environment vars **PORT** and **SERVICE_NAME** to your designated port and service.

### Building the image

This project contains a Dockerfile with all the required tools to run the HTTP server. To build the image you need to have docker installed. A makefile is provided along with the project to facilitate building and publishing of the images. You can set up configurations such as the image name a default enviroment vars in the *deploy.env* file.

To build the image run ```make image```. To run the image with default parameters (as defined in deploy.env) run ```make run```. For more information on what it is possible to do ```make help```.

## Author

Paulo Costa

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/fccn/http-docker-servicemon/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
