FROM azul/zulu-openjdk-alpine:17.0.3 AS builder
WORKDIR /app
COPY . .
RUN ./gradlew build

FROM azul/zulu-openjdk-alpine:17.0.3-jre
COPY --from=builder /app/build/libs/*.jar /app/
WORKDIR /app
# RUN addgroup -S demo && adduser -S demouser -G demo
# USER demouser
ENTRYPOINT ["java", "-jar", "demo.jar"]
# EXPOSE 8080
