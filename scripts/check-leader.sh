#!/bin/bash

echo "=========================================="
echo "Kiểm tra trạng thái Kafka Cluster"
echo "=========================================="

# Màu sắc cho output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Kiểm tra topic
echo -e "\n${YELLOW}1. Danh sách các topics:${NC}"
docker exec kafka-1 kafka-topics --list --bootstrap-server localhost:9092

# Kiểm tra chi tiết topic user-topic
echo -e "\n${YELLOW}2. Chi tiết topic 'user-topic':${NC}"
docker exec kafka-1 kafka-topics --describe --topic user-topic --bootstrap-server localhost:9092

# Kiểm tra metadata của cluster
echo -e "\n${YELLOW}3. Metadata của Kafka Cluster:${NC}"
docker exec kafka-1 kafka-metadata --bootstrap-server localhost:9092 --describe --all 2>/dev/null || \
docker exec kafka-1 kafka-broker-api-versions --bootstrap-server localhost:9092

# Kiểm tra leader cho từng partition
echo -e "\n${YELLOW}4. Leader của từng partition:${NC}"
docker exec kafka-1 kafka-topics --describe --topic user-topic --bootstrap-server localhost:9092 | grep "Leader"

# Hiển thị thông tin chi tiết về leader
echo -e "\n${GREEN}=========================================="
echo "Tóm tắt Leader Information"
echo "==========================================${NC}"

docker exec kafka-1 kafka-topics --describe --topic user-topic --bootstrap-server localhost:9092 | \
awk '/Partition:/{
    partition=$2; 
    leader=$4; 
    replicas=$6; 
    isr=$8;
    printf "Partition %s: Leader=Broker-%s, Replicas=[%s], ISR=[%s]\n", partition, leader, replicas, isr
}'

echo -e "\n${GREEN}Chú thích:${NC}"
echo "- Leader: Broker đang làm leader cho partition đó"
echo "- Replicas: Danh sách các broker có replica"
echo "- ISR (In-Sync Replicas): Các replica đang đồng bộ với leader"
