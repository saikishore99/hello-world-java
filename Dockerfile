#FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5

#MAINTAINER Muhammad Edwin < edwin at redhat dot com >

#LABEL BASE_IMAGE="registry.access.redhat.com/ubi8/ubi-minimal:8.5"
#LABEL JAVA_VERSION="11"

#RUN microdnf install --nodocs java-11-openjdk-headless && microdnf clean all

#WORKDIR /work/
#COPY target/*.jar /work/application.jar

#EXPOSE 8080
#CMD ["java", "-jar", "application.jar"]

FROM maven:3.8.7-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

#stage2 : create the final image
FROM tomcat:9.0
COPY --from=build /app/target/hello-world-java.war /usr/local/tomcat/webapps


