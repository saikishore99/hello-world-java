#FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5

#MAINTAINER Muhammad Edwin < edwin at redhat dot com >

#LABEL BASE_IMAGE="registry.access.redhat.com/ubi8/ubi-minimal:8.5"
#LABEL JAVA_VERSION="11"

#RUN microdnf install --nodocs java-11-openjdk-headless && microdnf clean all

#WORKDIR /work/
#COPY target/*.jar /work/application.jar

#EXPOSE 8080
#CMD ["java", "-jar", "application.jar"]

# === Stage 1: Build ===
FROM maven:3.8-openjdk-11-slim AS build

# Set work directory in container
WORKDIR /build

# Copy pom.xml and download dependencies first (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the entire project and build it
COPY . .
RUN mvn package -DskipTests

# === Stage 2: Runtime ===
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5

MAINTAINER Muhammad Edwin <edwin at redhat dot com>

LABEL BASE_IMAGE="registry.access.redhat.com/ubi8/ubi-minimal:8.5" \
      JAVA_VERSION="11"

# Install Java
RUN microdnf install --nodocs java-11-openjdk-headless && microdnf clean all

# Set working directory
WORKDIR /work

# Copy jar from the build stage
COPY --from=build /build/target/*.jar /work/application.jar

EXPOSE 8080

# Run the app
CMD ["java", "-jar", "application.jar"]
