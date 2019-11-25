# sbt-build-docker

Docker file used to build our scala applications. This `Dockerfile`:
- is based on openjdk image
- install sbt
- install scala
- install docker (docker in docker)
- makes sbt the ENTRYPOINT
