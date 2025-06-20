FROM openjdk:17-jdk-slim as builder

# Устанавливаем Git и Maven для сборки проекта
RUN apt-get update && apt-get install -y git maven && rm -rf /var/lib/apt/lists/*

# Клонируем проект внутрь образа (если билдим не локально)
# В твоём случае копируем с хоста
WORKDIR /build
COPY . .

# Собираем backend + UI без тестов
RUN mvn clean install -DskipTests -Dlicense.skip=true

# Финальный слой: чистый runtime
FROM openjdk:17-jdk-slim

# Создаём пользователя thingsboard
RUN groupadd -r thingsboard && useradd -r -g thingsboard thingsboard

# Копируем артефакты
COPY --from=builder /build/application/target/thingsboard-*.jar /usr/share/thingsboard/thingsboard.jar
COPY --from=builder /build/application/target/bin /usr/share/thingsboard/bin
COPY --from=builder /build/application/target/conf /usr/share/thingsboard/conf

# Готовим рабочие каталоги
RUN mkdir -p /data && chown -R thingsboard:thingsboard /data /usr/share/thingsboard

USER thingsboard
WORKDIR /usr/share/thingsboard

# Запуск через стандартный скрипт
CMD ["bin/thingsboard.sh", "start"]
