#!/bin/bash

# Màu sắc cho output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "TEST GỬI VÀ NHẬN MESSAGE"
echo "==========================================${NC}"

# Gửi một số message mẫu
echo -e "\n${YELLOW}Đang gửi 5 test messages...${NC}\n"

for i in {1..5}; do
    echo -e "${GREEN}Gửi message $i...${NC}"
    curl -X POST http://localhost:8081/api/users \
      -H "Content-Type: application/json" \
      -d "{
        \"id\": $i,
        \"name\": \"User $i\",
        \"email\": \"user$i@example.com\",
        \"phone\": \"012345678$i\",
        \"address\": \"Address $i, District $i, City\"
      }"
    echo ""
    sleep 1
done

# Đợi consumer xử lý
echo -e "\n${YELLOW}Đợi consumer xử lý messages...${NC}"
sleep 5

# Kiểm tra messages đã nhận
echo -e "\n${YELLOW}Kiểm tra messages đã nhận ở Consumer:${NC}"
RESPONSE=$(curl -s http://localhost:8082/api/users/received)
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"

echo -e "\n${GREEN}✓ Test hoàn tất!${NC}"
