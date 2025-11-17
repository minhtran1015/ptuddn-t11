#!/bin/bash

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "🚀 KHỞI ĐỘNG PRODUCER VÀ CONSUMER SERVICES"
echo "==========================================${NC}\n"

# Dừng các process cũ
echo -e "${YELLOW}Dừng các process cũ...${NC}"
pkill -f "producer-service.*spring-boot:run" 2>/dev/null
pkill -f "consumer-service.*spring-boot:run" 2>/dev/null
sleep 2

# Khởi động Producer
echo -e "\n${GREEN}1. Khởi động Producer Service (port 8081)...${NC}"
cd producer-service
nohup mvn spring-boot:run > ../producer.log 2>&1 &
PRODUCER_PID=$!
echo "Producer PID: $PRODUCER_PID"
cd ..

# Đợi 15 giây
echo -e "${YELLOW}Đợi Producer khởi động (15 giây)...${NC}"
sleep 15

# Kiểm tra Producer
for i in {1..5}; do
    if curl -s http://localhost:8081/api/users/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Producer Service đã sẵn sàng!${NC}"
        break
    fi
    if [ $i -eq 5 ]; then
        echo -e "${RED}❌ Producer không khởi động được!${NC}"
        exit 1
    fi
    echo "Đợi thêm 3 giây..."
    sleep 3
done

# Khởi động Consumer
echo -e "\n${GREEN}2. Khởi động Consumer Service (port 8082)...${NC}"
cd consumer-service
nohup mvn spring-boot:run > ../consumer.log 2>&1 &
CONSUMER_PID=$!
echo "Consumer PID: $CONSUMER_PID"
cd ..

# Đợi 15 giây
echo -e "${YELLOW}Đợi Consumer khởi động (15 giây)...${NC}"
sleep 15

# Kiểm tra Consumer
for i in {1..5}; do
    if curl -s http://localhost:8082/api/users/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Consumer Service đã sẵn sàng!${NC}"
        break
    fi
    if [ $i -eq 5 ]; then
        echo -e "${RED}❌ Consumer không khởi động được!${NC}"
        echo -e "${YELLOW}Xem log: tail -f consumer.log${NC}"
        exit 1
    fi
    echo "Đợi thêm 3 giây..."
    sleep 3
done

echo -e "\n${BLUE}=========================================="
echo "✅ CẢ HAI SERVICES ĐÃ SẴN SÀNG!"
echo "==========================================${NC}"
echo -e "${GREEN}Producer:${NC} http://localhost:8081"
echo -e "${GREEN}Consumer:${NC} http://localhost:8082"
echo -e "\n${YELLOW}Xem logs:${NC}"
echo "  tail -f producer.log"
echo "  tail -f consumer.log"
echo -e "\n${YELLOW}Dừng services:${NC}"
echo "  pkill -f \"spring-boot:run\""
