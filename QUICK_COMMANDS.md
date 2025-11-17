# HƯỚNG DẪN NHANH - KAFKA CLUSTER TEST

## 🚀 Chạy Test Đầy Đủ

```bash
./scripts/run-full-test.sh
```

## 📋 Các Lệnh Thường Dùng

### Khởi động Kafka Cluster
```bash
docker-compose up -d
```

### Khởi động Spring Boot Services
```bash
./scripts/start-services.sh
```

### Kiểm tra Leader
```bash
./scripts/check-leader.sh
```

### Test Gửi/Nhận Messages
```bash
./scripts/test-messages.sh
```

### Test Failover (Dừng Leader)
```bash
./scripts/test-failover.sh
```

## 🔧 Quản Lý Kafka Cluster

### Xem trạng thái containers
```bash
docker-compose ps
```

### Xem logs
```bash
docker logs -f kafka-1
docker logs -f kafka-2
docker logs -f kafka-3
```

### Dừng một broker
```bash
docker stop kafka-1  # hoặc kafka-2, kafka-3
```

### Khởi động lại broker
```bash
docker start kafka-1
```

### Dừng toàn bộ
```bash
docker-compose down
```

### Xóa dữ liệu và khởi động lại
```bash
docker-compose down -v
docker-compose up -d
```

## 📡 Test API Thủ Công

### Gửi message
```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "name": "Test User",
    "email": "test@example.com",
    "phone": "0123456789",
    "address": "Ha Noi"
  }'
```

### Xem messages đã nhận
```bash
curl http://localhost:8082/api/users/received | python3 -m json.tool
```

### Health check
```bash
curl http://localhost:8081/api/users/health
curl http://localhost:8082/api/users/health
```

## 📊 Xem Thông Tin Kafka

### Danh sách topics
```bash
docker exec kafka-1 kafka-topics --list --bootstrap-server localhost:9092
```

### Chi tiết topic
```bash
docker exec kafka-1 kafka-topics --describe --topic user-topic --bootstrap-server localhost:9092
```

### Xem consumer group
```bash
docker exec kafka-1 kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --describe --group user-consumer-group
```

### Đọc messages từ topic
```bash
docker exec kafka-1 kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic user-topic \
  --from-beginning
```

## 📝 Files Quan Trọng

- `README.md` - Hướng dẫn chi tiết
- `TEST_REPORT.md` - Báo cáo kết quả test
- `docker-compose.yml` - Cấu hình Kafka Cluster
- `scripts/` - Các script tiện ích

## 🐛 Troubleshooting

### Consumer không nhận messages
```bash
# Xem logs
tail -f consumer.log

# Restart consumer
pkill -f "consumer-service.*spring-boot:run"
cd consumer-service && mvn spring-boot:run
```

### Kafka không kết nối được
```bash
# Restart Kafka cluster
docker-compose restart
```

### Port đã được sử dụng
```bash
# Tìm process đang dùng port
lsof -i :8081
lsof -i :8082

# Kill process
kill -9 <PID>
```

## ✅ Kiểm Tra Nhanh

```bash
# Kiểm tra tất cả services đang chạy
echo "Kafka:" && docker ps | grep kafka | wc -l
echo "Producer:" && curl -s http://localhost:8081/api/users/health
echo "Consumer:" && curl -s http://localhost:8082/api/users/health
```

## 📚 Tài Liệu Tham Khảo

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Spring for Apache Kafka](https://spring.io/projects/spring-kafka)
- [Confluent Platform](https://docs.confluent.io/)
