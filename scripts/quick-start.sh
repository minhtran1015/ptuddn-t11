#!/bin/bash

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║     HƯỚNG DẪN NHANH - KAFKA CLUSTER VỚI SPRING BOOT         ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${YELLOW}📋 CÁC BƯỚC THỰC HIỆN:${NC}\n"

echo -e "${GREEN}1. Khởi động Kafka Cluster (3 nodes):${NC}"
echo -e "   ${BLUE}docker-compose up -d${NC}"
echo -e "   Đợi 30 giây để cluster khởi động hoàn toàn\n"

echo -e "${GREEN}2. Build và chạy Producer Service (Terminal 1):${NC}"
echo -e "   ${BLUE}cd producer-service${NC}"
echo -e "   ${BLUE}mvn clean install${NC}"
echo -e "   ${BLUE}mvn spring-boot:run${NC}\n"

echo -e "${GREEN}3. Build và chạy Consumer Service (Terminal 2):${NC}"
echo -e "   ${BLUE}cd consumer-service${NC}"
echo -e "   ${BLUE}mvn clean install${NC}"
echo -e "   ${BLUE}mvn spring-boot:run${NC}\n"

echo -e "${GREEN}4. Kiểm tra Leader:${NC}"
echo -e "   ${BLUE}./scripts/check-leader.sh${NC}\n"

echo -e "${GREEN}5. Test gửi/nhận messages:${NC}"
echo -e "   ${BLUE}./scripts/test-messages.sh${NC}\n"

echo -e "${GREEN}6. Test Failover (dừng leader):${NC}"
echo -e "   ${BLUE}./scripts/test-failover.sh${NC}\n"

echo -e "${YELLOW}📡 API ENDPOINTS:${NC}\n"
echo -e "Producer: ${GREEN}http://localhost:8081${NC}"
echo -e "  POST /api/users - Gửi user data"
echo -e "  GET  /api/users/health - Health check\n"

echo -e "Consumer: ${GREEN}http://localhost:8082${NC}"
echo -e "  GET  /api/users/received - Xem messages đã nhận"
echo -e "  GET  /api/users/health - Health check\n"

echo -e "${YELLOW}🔧 DOCKER COMMANDS:${NC}\n"
echo -e "Xem logs:     ${BLUE}docker logs -f kafka-1${NC}"
echo -e "Stop broker:  ${BLUE}docker stop kafka-1${NC}"
echo -e "Start broker: ${BLUE}docker start kafka-1${NC}"
echo -e "Dọn dẹp:      ${BLUE}docker-compose down -v${NC}\n"

echo -e "${YELLOW}📚 Chi tiết xem file README.md${NC}\n"
