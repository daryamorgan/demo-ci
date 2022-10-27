FROM azul/zulu-openjdk-alpine:17.0.3 AS builder
WORKDIR /app
COPY . .
RUN ./gradlew build

FROM azul/zulu-openjdk-alpine:17.0.3-jre
COPY --from=builder /app/build/libs/*.jar /app/
WORKDIR /app
RUN addgroup -S javauser && adduser -S javauser -G javauser
RUN chown -R javauser:javauser /app
USER javauser
ENTRYPOINT ["java", "-jar", "demo.jar"]
EXPOSE 8080
