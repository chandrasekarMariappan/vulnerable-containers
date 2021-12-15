FROM docker.io/library/openjdk:11

ADD src/target/http-server-0.0.1-SNAPSHOT.jar /http-server.jar
ENTRYPOINT [ "/usr/local/openjdk-11/bin/java", "-jar", "/http-server.jar" ]
CMD []

