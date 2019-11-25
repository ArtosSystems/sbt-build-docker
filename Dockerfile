#
# Scala, sbt and docker Dockerfile
#
# inspired by https://github.com/hseeberger/scala-sbt
#
ARG BASE_IMAGE_TAG
FROM openjdk:${BASE_IMAGE_TAG:-11.0.5-stretch}

# Env variables
ARG SCALA_VERSION
ENV SCALA_VERSION ${SCALA_VERSION:-2.13.1}
ARG SBT_VERSION
ENV SBT_VERSION ${SBT_VERSION:-1.2.8}

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /usr/share && \
  mv /usr/share/scala-$SCALA_VERSION /usr/share/scala && \
  chown -R root:root /usr/share/scala && \
  chmod -R 755 /usr/share/scala && \
  ln -s /usr/share/scala/bin/scala /usr/local/bin/scala

# Add and use user sbtuser
#RUN groupadd --gid 1001 sbtuser && useradd --gid 1001 --uid 1001 sbtuser --shell /bin/bash
#RUN chown -R sbtuser:sbtuser /opt
#RUN mkdir /home/sbtuser && chown -R sbtuser:sbtuser /home/sbtuser
#RUN mkdir /logs && chown -R sbtuser:sbtuser /logs
#USER sbtuser

## Switch working directory
#WORKDIR /home/sbtuser

# Prepare sbt (warm cache) (TODO: Martin suggested adding a dummy project to already load dependencies)
RUN \
  sbt sbtVersion && \
  mkdir -p project && \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties && \
  echo "case object Temp" > Temp.scala && \
  sbt compile && \
  rm -r project && rm build.sbt && rm Temp.scala && rm -r target

# Install docker (needed for sbt-native-packager -push
RUN \
  apt-get update && \
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
  add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) \
     stable" && \
  apt-get update && \
    apt-get -y install docker-ce

WORKDIR /root

ENTRYPOINT ["sbt"]

