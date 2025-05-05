#FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5

#MAINTAINER Muhammad Edwin < edwin at redhat dot com >

#LABEL BASE_IMAGE="registry.access.redhat.com/ubi8/ubi-minimal:8.5"
#LABEL JAVA_VERSION="11"

#RUN microdnf install --nodocs java-11-openjdk-headless && microdnf clean all

#WORKDIR /work/
#COPY target/*.jar /work/application.jar

#EXPOSE 8080
#CMD ["java", "-jar", "application.jar"]

# ----- Stage 1: Build -----
FROM maven:3.8-openjdk-11 AS builder

WORKDIR /app

# Copy project files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# ----- Stage 2: Runtime -----
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5

LABEL maintainer="Muhammad Edwin <edwin@redhat.com>"
LABEL BASE_IMAGE="registry.access.redhat.com/ubi8/ubi-minimal:8.5"
LABEL JAVA_VERSION="11"

# Install OpenJDK headless
RUN microdnf install --nodocs java-11-openjdk-headless && microdnf clean all

# Create non-root user for security
RUN useradd -r -u 1001 appuser

WORKDIR /work

# Copy the JAR from the builder stage
COPY --from=builder /app/target/*.jar /work/application.jar

# Set user permissions
RUN chown -R appuser /work
USER appuser

EXPOSE 8080

CMD ["java", "-jar", "application.jar"]




