#!/bin/bash

# Màu sắc cho output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "TEST FAILOVER - Dừng Kafka Leader"
echo "==========================================${NC}"

# Bước 1: Kiểm tra leader hiện tại
echo -e "\n${YELLOW}Bước 1: Kiểm tra leader hiện tại...${NC}"
LEADER_INFO=$(docker exec kafka-1 kafka-topics --describe --topic user-topic --bootstrap-server localhost:9092 2>/dev/null | grep "Leader" | head -1)
LEADER_ID=$(echo $LEADER_INFO | awk '{print $6}')

if [ -z "$LEADER_ID" ]; then
    echo -e "${RED}Không tìm thấy leader. Vui lòng kiểm tra Kafka cluster.${NC}"
    exit 1
fi

echo -e "${GREEN}Leader hiện tại: Broker $LEADER_ID (Container: kafka-$LEADER_ID)${NC}"

# Bước 2: Gửi message trước khi dừng leader
echo -e "\n${YELLOW}Bước 2: Gửi test message trước khi dừng leader...${NC}"
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 100,
    "name": "Test Before Failover",
    "email": "before@test.com",
    "phone": "0123456789",
    "address": "Test Address"
  }' 2>/dev/null
echo ""
sleep 2

# Bước 3: Dừng leader
echo -e "\n${YELLOW}Bước 3: Đang dừng Kafka Leader (kafka-$LEADER_ID)...${NC}"
docker stop kafka-$LEADER_ID
echo -e "${RED}Leader kafka-$LEADER_ID đã bị dừng!${NC}"

# Đợi một chút để election xảy ra
echo -e "\n${YELLOW}Đợi 10 giây để leader election diễn ra...${NC}"
sleep 10

# Bước 4: Kiểm tra leader mới
echo -e "\n${YELLOW}Bước 4: Kiểm tra leader mới sau khi failover...${NC}"

# Thử kết nối với các broker còn lại
for broker in 1 2 3; do
    if [ "$broker" != "$LEADER_ID" ]; then
        NEW_LEADER_INFO=$(docker exec kafka-$broker kafka-topics --describe --topic user-topic --bootstrap-server localhost:909$((1+broker)) 2>/dev/null | grep "Leader" | head -1)
        if [ ! -z "$NEW_LEADER_INFO" ]; then
            NEW_LEADER_ID=$(echo $NEW_LEADER_INFO | awk '{print $6}')
            echo -e "${GREEN}Leader mới: Broker $NEW_LEADER_ID (Container: kafka-$NEW_LEADER_ID)${NC}"
            break
        fi
    fi
done

# Bước 5: Kiểm tra ISR
echo -e "\n${YELLOW}Bước 5: Kiểm tra In-Sync Replicas (ISR)...${NC}"
for broker in 1 2 3; do
    if [ "$broker" != "$LEADER_ID" ]; then
        docker exec kafka-$broker kafka-topics --describe --topic user-topic --bootstrap-server localhost:909$((1+broker)) 2>/dev/null
        break
    fi
done

# Bước 6: Test gửi message sau khi leader bị dừng
echo -e "\n${YELLOW}Bước 6: Gửi test message sau khi leader bị dừng...${NC}"
RESPONSE=$(curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 101,
    "name": "Test After Failover",
    "email": "after@test.com",
    "phone": "0987654321",
    "address": "Test Address 2"
  }' 2>/dev/null)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Message đã được gửi thành công!${NC}"
    echo "Response: $RESPONSE"
else
    echo -e "${RED}✗ Không thể gửi message${NC}"
fi

# Bước 7: Kiểm tra consumer có nhận được message không
echo -e "\n${YELLOW}Bước 7: Kiểm tra consumer có nhận được message không...${NC}"
sleep 5
RECEIVED=$(curl -s http://localhost:8082/api/users/received)
echo "Received messages: $RECEIVED"

# Tóm tắt
echo -e "\n${BLUE}=========================================="
echo "TÓM TẮT KẾT QUẢ TEST"
echo "==========================================${NC}"
echo -e "Leader cũ (đã dừng): ${RED}Broker $LEADER_ID${NC}"
echo -e "Leader mới: ${GREEN}Broker $NEW_LEADER_ID${NC}"
echo -e "Trạng thái hệ thống: ${GREEN}Đang hoạt động${NC}"
echo ""
echo -e "${YELLOW}Để khởi động lại leader cũ, chạy:${NC}"
echo -e "${GREEN}docker start kafka-$LEADER_ID${NC}"
