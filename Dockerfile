FROM openjdk:17-jdk-slim

# Создаём пользователя
RUN groupadd -r thingsboard && useradd -r -g thingsboard thingsboard

# Копируем fat JAR и конфиги
COPY application/target/thingsboard-4.0.1-boot.jar /usr/share/thingsboard/thingsboard.jar
COPY application/target/conf /usr/share/thingsboard/conf

# Скрипт запуска
RUN mkdir -p /usr/share/thingsboard/bin && \
    echo '#!/bin/bash\n\
set -e\n\
export JAVA_OPTS="${JAVA_OPTS:--Xms256M -Xmx1024M}"\n\
exec java $JAVA_OPTS -jar /usr/share/thingsboard/thingsboard.jar' \
    > /usr/share/thingsboard/bin/thingsboard.sh && \
    chmod +x /usr/share/thingsboard/bin/thingsboard.sh

# Права и рабочая среда
RUN mkdir -p /data && chown -R thingsboard:thingsboard /data /usr/share/thingsboard
USER thingsboard
WORKDIR /usr/share/thingsboard

EXPOSE 8080
CMD ["bin/thingsboard.sh"]
