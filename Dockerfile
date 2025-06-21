FROM openjdk:17-jdk-slim

# Создаём пользователя
RUN groupadd -r thingsboard && useradd -r -g thingsboard thingsboard

# Копируем fat JAR (исполняемый)
COPY application/target/thingsboard-4.0.1-boot.jar /usr/share/thingsboard/thingsboard.jar

# Делаем .jar исполняемым
RUN chmod +x /usr/share/thingsboard/thingsboard.jar && \
    mkdir -p /data && \
    chown -R thingsboard:thingsboard /data /usr/share/thingsboard

# Переходим под пользователя
USER thingsboard
WORKDIR /usr/share/thingsboard

EXPOSE 8080

# Запускаем исполняемый .jar напрямую
CMD ["/usr/share/thingsboard/thingsboard.jar"]
