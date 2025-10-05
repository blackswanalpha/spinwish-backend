# Stage 1: Build the .jar
FROM maven:latest AS build

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests

COPY ./pom.xml /app/pom.xml

COPY ./src /app/src

# Stage 2: Run the .jar
FROM openjdk:21-jdk-slim

WORKDIR /app

COPY --from=build /app/target/backend-0.0.1-SNAPSHOT.jar /app/backend.jar

EXPOSE 8080

CMD ["java", "-jar", "/app/backend.jar"]