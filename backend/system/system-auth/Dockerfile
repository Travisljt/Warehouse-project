# syntax=docker/dockerfile:1.6

FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY backend /workspace/backend
WORKDIR /workspace/backend
RUN mvn -pl services/auth-service -am package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /workspace/backend/services/auth-service/target/auth-service-0.1.0-SNAPSHOT.jar app.jar
EXPOSE 9001
ENTRYPOINT ["java","-jar","/app/app.jar"]
FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /workspace
COPY pom.xml .
COPY common ./common
COPY services ./services
RUN mvn -pl services/auth-service -am package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=builder /workspace/services/auth-service/target/auth-service-0.1.0-SNAPSHOT.jar app.jar
EXPOSE 9001
ENTRYPOINT ["java","-jar","/app/app.jar"]

