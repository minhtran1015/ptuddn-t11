# Hệ Thống Spring Boot với Kafka Cluster

Dự án này triển khai 2 ứng dụng Spring Boot trao đổi dữ liệu JSON thông qua Kafka Cluster gồm 3 nodes, có khả năng failover tự động khi leader node bị dừng.

## 📋 Mục Lục

- [Kiến Trúc Hệ Thống](#kiến-trúc-hệ-thống)
- [Yêu Cầu](#yêu-cầu)
- [Cài Đặt](#cài-đặt)
- [Khởi Động Hệ Thống](#khởi-động-hệ-thống)
- [Kiểm Tra Leader](#kiểm-tra-leader)
- [Test Failover](#test-failover)
- [API Endpoints](#api-endpoints)
- [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)

## 🏗️ Kiến Trúc Hệ Thống

```
┌─────────────────────┐
│  Producer Service   │
│   (Port: 8081)      │
│  Spring Boot App    │
└──────────┬──────────┘
           │
           │ JSON Messages
           ↓
┌──────────────────────────────────────────┐
│         Kafka Cluster (3 Nodes)          │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │ Kafka-1 │ │ Kafka-2 │ │ Kafka-3 │   │
│  │  :9092  │ │  :9093  │ │  :9094  │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│         Leader Election & Replication    │
└──────────────────────────────────────────┘
           │
           │ JSON Messages
           ↓
┌─────────────────────┐
│  Consumer Service   │
│   (Port: 8082)      │
│  Spring Boot App    │
└─────────────────────┘
```

### Đặc Điểm Kafka Cluster:

- **3 Kafka Brokers**: kafka-1, kafka-2, kafka-3
- **Replication Factor**: 3 (mỗi partition có 3 bản sao)
- **Min In-Sync Replicas**: 2 (cần ít nhất 2 replica đồng bộ)
- **Partitions**: 3 partitions cho topic `user-topic`
- **High Availability**: Tự động failover khi leader bị dừng

## 📦 Yêu Cầu

- Java 17+
- Maven 3.6+
- Docker & Docker Compose
- curl (để test API)
- jq (optional, để format JSON output)

## 🚀 Cài Đặt

### 1. Clone Repository

```bash
cd /Users/trandinhquangminh/Codespace/ptuddn-t11
```

### 2. Khởi Động Kafka Cluster

```bash
# Khởi động Zookeeper và 3 Kafka brokers
docker-compose up -d

# Kiểm tra trạng thái containers
docker-compose ps

# Xem logs
docker-compose logs -f
```

Đợi khoảng 30 giây để Kafka cluster khởi động hoàn toàn.

### 3. Build và Chạy Spring Boot Applications

#### Terminal 1 - Producer Service:

```bash
cd producer-service
mvn clean install
mvn spring-boot:run
```

#### Terminal 2 - Consumer Service:

```bash
cd consumer-service
mvn clean install
mvn spring-boot:run
```

## 🔍 Kiểm Tra Leader

Để kiểm tra broker nào đang là leader cho các partitions:

```bash
chmod +x scripts/*.sh
./scripts/check-leader.sh
```

Output sẽ hiển thị:
- Danh sách topics
- Chi tiết về topic `user-topic`
- Leader của từng partition
- Thông tin về ISR (In-Sync Replicas)

Example output:
```
Partition 0: Leader=Broker-1, Replicas=[1,2,3], ISR=[1,2,3]
Partition 1: Leader=Broker-2, Replicas=[2,3,1], ISR=[2,3,1]
Partition 2: Leader=Broker-3, Replicas=[3,1,2], ISR=[3,1,2]
```

## 🧪 Test Gửi/Nhận Messages

### Test Cơ Bản:

```bash
./scripts/test-messages.sh
```

Script này sẽ:
1. Gửi 5 test messages đến Producer
2. Đợi Consumer xử lý
3. Hiển thị tất cả messages đã nhận

### Test Thủ Công:

#### Gửi message qua Producer:

```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "name": "Nguyen Van A",
    "email": "nguyenvana@example.com",
    "phone": "0123456789",
    "address": "123 Le Loi, Q1, TP.HCM"
  }'
```

#### Kiểm tra messages đã nhận ở Consumer:

```bash
curl http://localhost:8082/api/users/received | jq
```

## 🔥 Test Failover - Dừng Leader Node

### Automatic Test:

```bash
./scripts/test-failover.sh
```

Script này sẽ tự động:
1. ✅ Kiểm tra leader hiện tại
2. 📤 Gửi test message trước khi dừng leader
3. ⏸️ Dừng Kafka leader
4. ⏱️ Đợi leader election (10 giây)
5. ✅ Kiểm tra leader mới
6. 📊 Kiểm tra ISR
7. 📤 Gửi test message sau khi leader bị dừng
8. ✅ Xác nhận hệ thống vẫn hoạt động

### Manual Test:

#### Bước 1: Kiểm tra leader hiện tại

```bash
./scripts/check-leader.sh
```

Giả sử Broker-2 là leader của Partition 0.

#### Bước 2: Dừng leader

```bash
docker stop kafka-2
```

#### Bước 3: Đợi và kiểm tra lại leader

```bash
# Đợi 10 giây
sleep 10

# Kiểm tra leader mới
./scripts/check-leader.sh
```

Bạn sẽ thấy Broker-1 hoặc Broker-3 được bầu làm leader mới.

#### Bước 4: Test gửi message

```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 999,
    "name": "Test After Failover",
    "email": "test@failover.com",
    "phone": "0999999999",
    "address": "Failover Test"
  }'
```

✅ **Kết quả**: Hệ thống vẫn hoạt động bình thường!

#### Bước 5: Khởi động lại leader cũ

```bash
docker start kafka-2
```

## 📡 API Endpoints

### Producer Service (Port 8081)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/users` | Gửi user data đến Kafka |
| GET | `/api/users/health` | Health check |

#### Example Request:

```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "0123456789",
    "address": "123 Main St"
  }'
```

### Consumer Service (Port 8082)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users/received` | Lấy danh sách users đã nhận |
| GET | `/api/users/health` | Health check |

#### Example Request:

```bash
curl http://localhost:8082/api/users/received
```

## 📁 Cấu Trúc Thư Mục

```
ptuddn-t11/
├── docker-compose.yml           # Kafka Cluster configuration
├── README.md                    # This file
├── scripts/
│   ├── check-leader.sh         # Kiểm tra leader
│   ├── test-failover.sh        # Test failover tự động
│   └── test-messages.sh        # Test gửi/nhận messages
├── producer-service/
│   ├── pom.xml
│   └── src/main/
│       ├── java/com/example/producer/
│       │   ├── ProducerServiceApplication.java
│       │   ├── config/KafkaTopicConfig.java
│       │   ├── controller/UserController.java
│       │   ├── model/User.java
│       │   └── service/KafkaProducerService.java
│       └── resources/
│           └── application.properties
└── consumer-service/
    ├── pom.xml
    └── src/main/
        ├── java/com/example/consumer/
        │   ├── ConsumerServiceApplication.java
        │   ├── controller/UserController.java
        │   ├── model/User.java
        │   └── service/KafkaConsumerService.java
        └── resources/
            └── application.properties
```

## 🔧 Cấu Hình Quan Trọng

### Kafka Producer (Producer Service)

```properties
spring.kafka.producer.acks=all  # Đợi tất cả replicas xác nhận
spring.kafka.producer.retries=3 # Retry 3 lần nếu lỗi
```

### Kafka Consumer (Consumer Service)

```properties
spring.kafka.consumer.auto-offset-reset=earliest  # Đọc từ đầu nếu chưa có offset
spring.kafka.consumer.group-id=user-consumer-group
```

### Kafka Cluster (docker-compose.yml)

```yaml
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3  # 3 bản sao
KAFKA_MIN_INSYNC_REPLICAS: 2               # Tối thiểu 2 replica đồng bộ
KAFKA_DEFAULT_REPLICATION_FACTOR: 3        # Replication mặc định
```

## 🐛 Troubleshooting

### Kafka không khởi động được:

```bash
# Xóa volumes và khởi động lại
docker-compose down -v
docker-compose up -d
```

### Không kết nối được Kafka:

```bash
# Kiểm tra Kafka logs
docker logs kafka-1
docker logs kafka-2
docker logs kafka-3

# Kiểm tra network
docker network inspect ptuddn-t11_kafka-network
```

### Consumer không nhận được messages:

```bash
# Kiểm tra consumer logs
docker logs consumer-service

# Kiểm tra consumer group
docker exec kafka-1 kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --describe --group user-consumer-group
```

## 📊 Monitoring

### Xem Kafka logs:

```bash
docker logs -f kafka-1
docker logs -f kafka-2
docker logs -f kafka-3
```

### Kiểm tra consumer offset:

```bash
docker exec kafka-1 kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --describe --group user-consumer-group
```

### Xem messages trong topic:

```bash
docker exec kafka-1 kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic user-topic \
  --from-beginning
```

## 🎯 Kết Luận

Hệ thống này chứng minh:

✅ **High Availability**: Kafka cluster có thể tiếp tục hoạt động khi 1 node bị dừng

✅ **Automatic Failover**: Leader election tự động diễn ra trong vài giây

✅ **Data Replication**: Dữ liệu được replicate trên 3 nodes

✅ **No Data Loss**: Với `acks=all` và `min.insync.replicas=2`, không bị mất dữ liệu

## 📝 Câu Hỏi Thường Gặp

**Q: Tại sao cần 3 Kafka brokers?**  
A: Để đảm bảo high availability và fault tolerance. Với 3 brokers, hệ thống có thể hoạt động khi 1 broker bị dừng.

**Q: Leader election mất bao lâu?**  
A: Thường trong vòng 5-10 giây.

**Q: Có mất dữ liệu khi leader bị dừng không?**  
A: Không, vì cấu hình `acks=all` đảm bảo message được ghi vào tất cả in-sync replicas.

**Q: Có thể scale thêm broker không?**  
A: Có, chỉ cần thêm cấu hình broker mới vào `docker-compose.yml`.

## 👥 Author

Tran Dinh Quang Minh

## 📄 License

MIT License
