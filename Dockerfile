FROM ubuntu:20.04
MAINTAINER silentvalidator@gmail.com

COPY . /runmassa
ENV PATH /runmassa/massa-client/:/runmassa/massa-node:$PATH
ENV PASSWORD="password"
ENV IP="none"
# Set the working directory for massa-node
WORKDIR /runmassa
EXPOSE 31244
EXPOSE 31245


RUN apt-get update -y && apt-get install curl screen jq -y
RUN chmod +x /runmassa/run.sh
RUN chmod +x /runmassa/healthcheck.sh
RUN chmod +x /runmassa/clearlogs.sh  # Make the new script executable
RUN mkdir -p /runmassa/data
ENTRYPOINT ["sh","-c","/runmassa/clearlogs.sh & /runmassa/run.sh $IP $PASSWORD"]

HEALTHCHECK --interval=30s --timeout=10s \
  CMD /runmassa/healthcheck.sh $PASSWORD
