# Stage 1: Build
FROM maven:3.8.6-openjdk-8 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run
FROM openjdk:8-jre-alpine
WORKDIR /app
RUN mkdir -p /data
COPY --from=build /app/target/attestationhubserver.war ./app.war
EXPOSE 9090
CMD ["java", "-jar", "app.war"]
