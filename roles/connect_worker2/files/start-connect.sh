#!/bin/bash

# Kafka Confluent 설치 경로
export CONFLUENT_HOME="/engn/confluent"

# 서버 이름 (JVM 식별용)
export SERVER_NAME="Connect-worker2"

# Kafka Connect 설정 파일 경로
export PROPERTIES_FILE="${CONFLUENT_HOME}/properties/connect-worker.properties"

# 로그 디렉토리 경로
export LOG_DIR="/log/connect-worker"

# Java 설치 경로 (Java 11 사용)
export JAVA_HOME="/home/ubuntu/jdk-17.0.8+7"
export PATH="$JAVA_HOME/bin:$PATH"

######################################################################

# 메모리 설정 (t3.micro 환경에 최적화)
export KAFKA_HEAP_OPTS="-Xms512m -Xmx1G"

# JVM 성능 최적화 옵션 (필요 최소)
export KAFKA_JVM_PERFORMANCE_OPTS="-XX:+UseG1GC -XX:MaxGCPauseMillis=20"

# JVM 시스템 프로퍼티 설정
KAFKA_OPTS="${KAFKA_OPTS} -D${SERVER_NAME}"
KAFKA_OPTS="${KAFKA_OPTS} -D${SERVER_NAME} -javaagent:/home/ubuntu/monitoring/jmx_prometheus_javaagent-0.20.0.jar=1236:/home/ubuntu/monitoring/kafka_connect.yml"
export KAFKA_OPTS

# GC 로그 옵션 활성화
export GC_LOG_ENABLED="true"

# JMX 설정 (선택 사항)
export KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

# log4j 설정 파일 경로
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:${CONFLUENT_HOME}/properties/connect-worker-log4j.properties"

# 클래스패스 설정 (필요 시)
export CLASSPATH="${CLASSPATH}:${CONFLUENT_HOME}/share/java/kafka-connect-replicator/*"

# 프로세스 중복 실행 방지
PID="$(pgrep -xa java | grep ${PROPERTIES_FILE} | grep ${SERVER_NAME} | awk '{print $1}')"
if [ -n "${PID}" ]; then
  echo "[ERROR] ${SERVER_NAME} (pid ${PID}) is already running!"
  exit 1
fi

# 로그 디렉토리 생성
mkdir -p "${LOG_DIR}"

# Kafka Connect 분산 모드 기동 (백그라운드 실행)
nohup "${CONFLUENT_HOME}/bin/connect-distributed" "${PROPERTIES_FILE}" \
  > "${LOG_DIR}/connect-distributed.out" 2>&1 &

# REST interface 가 올라올 때까지 대기
echo "Waiting for Kafka Connect REST at http://localhost:8083..."
until curl -s http://localhost:8083/connectors >/dev/null 2>&1; do
  sleep 3
  echo -n "."
done

echo "Kafka Connect worker is up and running!"

echo "Kafka Connect log output:"
tail -n 30 "${LOG_DIR}/connect-distributed.out"


```
