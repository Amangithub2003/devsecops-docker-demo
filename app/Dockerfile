# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml ./
RUN mvn -q -B dependency:go-offline || true
COPY src ./src
RUN mvn -q -B clean package -DskipTests

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre-jammy
# Run as non-root -- Trivy/SAST checks flag root containers
RUN useradd --uid 10001 --create-home appuser
USER 10001
WORKDIR /app
COPY --from=build /workspace/target/demo-app.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
