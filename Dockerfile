# Слой сборки
FROM openjdk:17-jdk-slim AS builder

# Устанавливаем Git и Maven для сборки проекта
RUN apt-get update && apt-get install -y git maven && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .

# Сборка с fat JAR и нужным Main-Class
RUN mvn clean package spring-boot:repackage -DskipTests -Dlicense.skip=true

# Финальный рантайм-слой
FROM openjdk:17-jdk-slim

# Создаём пользователя thingsboard
RUN groupadd -r thingsboard && useradd -r -g thingsboard thingsboard

# Копируем артефакты
COPY --from=builder /build/application/target/thingsboard-*.jar /usr/share/thingsboard/thingsboard.jar
COPY --from=builder /build/application/target/conf /usr/share/thingsboard/conf

# Создаём простой скрипт запуска
RUN mkdir -p /usr/share/thingsboard/bin && \
    echo '#!/bin/bash\n\
set -e\n\
export JAVA_OPTS="${JAVA_OPTS:--Xms256M -Xmx1024M}"\n\
exec java $JAVA_OPTS -jar /usr/share/thingsboard/thingsboard.jar' \
    > /usr/share/thingsboard/bin/thingsboard.sh && \
    chmod +x /usr/share/thingsboard/bin/thingsboard.sh

RUN mkdir -p /data && chown -R thingsboard:thingsboard /data /usr/share/thingsboard

USER thingsboard
WORKDIR /usr/share/thingsboard

EXPOSE 8080
CMD ["bin/thingsboard.sh"]
