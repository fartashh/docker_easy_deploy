# Easy deploy with docker

![](https://cloud.githubusercontent.com/assets/7381033/8637640/365d526e-28ce-11e5-868c-0fa950225176.png)

This is a demo of doing a blue-green deploy of a simple web application using Reids, Mongodb, Nginx and [Docker](https://github.com/docker/docker) of course.



# Requirements

- Working copy of Docker.

# Notice
- Run chmod +x for mongodb/docker-entrypoint.sh and redis/docker-entrypoint.sh
- Inorder to use Docker hub you need to uncomment line 57 and 118 in deploy.sh

After that, you should be ready to rock and roll.

# Usage

Build All Docker images from Docker files (nginx, redis, mongodb, and app server):

``` 
./deploy.sh build
```



Run Docker containers of Redis, Mongodb and nginx images:

``` 
./deploy.sh up 
```

Deploy the app:

``` 
./deploy.sh deploy 
```

Each deploy will be tagged by timestamp.

What if you deployed and broke everything with terrible code?

No problem.  Just rollback to a known image tag:

``` 
./deploy.sh rollback Thu_Nov_13_22_49_34_UTC_2014 
```


# Architecture

This demo is single-host, but the concepts could be applied to a multi-host
setup with some additional elbow grease (and service discovery).

Two instances of a cherrypy (Python) application running in containers sit behind a
load balancer (Nginx).  One exposes the application on the host's
`localhost:7800`, the other exposes the application on the host's
`localhost:7801`.  They are connected to a container running Redis and Mongodb using Docker
links.  

# Reference
[awsapp](https://github.com/nathanleclaire/awsapp)
