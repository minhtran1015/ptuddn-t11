#!/bin/bash

# Script chạy lại toàn bộ test từ đầu

echo "🚀 BẮT ĐẦU TEST KAFKA CLUSTER"
echo "======================================"
echo ""

# 1. Khởi động Kafka Cluster
echo "1️⃣  Khởi động Kafka Cluster (3 nodes)..."
docker-compose up -d
echo "   Đợi 30 giây..."
sleep 30
echo "   ✅ Done"
echo ""

# 2. Kiểm tra containers
echo "2️⃣  Kiểm tra containers:"
docker-compose ps
echo ""

# 3. Khởi động services
echo "3️⃣  Khởi động Producer & Consumer Services..."
./scripts/start-services.sh
echo ""

# 4. Kiểm tra leader
echo "4️⃣  Kiểm tra Leader:"
docker exec kafka-1 kafka-topics --describe --topic user-topic --bootstrap-server kafka-1:29092 2>/dev/null | grep "Partition:" | awk '{printf "   Partition %s: Leader = Broker-%s\n", $4, $6}'
echo ""

# 5. Test gửi messages
echo "5️⃣  Test gửi messages..."
./scripts/test-messages.sh
echo ""

# 6. Hỏi người dùng có muốn test failover không
echo "6️⃣  Bạn có muốn test FAILOVER (dừng leader) không? (y/n)"
read -r answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    echo ""
    echo "🔥 BẮT ĐẦU TEST FAILOVER..."
    ./scripts/test-failover.sh
fi

echo ""
echo "✅ HOÀN TẤT!"
echo ""
echo "📚 Xem báo cáo chi tiết: TEST_REPORT.md"
