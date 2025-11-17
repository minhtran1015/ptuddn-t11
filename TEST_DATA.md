# Sample JSON Data for Testing

## Single User

```json
{
  "id": 1,
  "name": "Nguyen Van A",
  "email": "nguyenvana@example.com",
  "phone": "0901234567",
  "address": "123 Le Loi, Quan 1, TP.HCM"
}
```

## Multiple Users for Batch Testing

### User 1
```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "name": "Nguyen Van A",
    "email": "nguyenvana@example.com",
    "phone": "0901234567",
    "address": "123 Le Loi, Quan 1, TP.HCM"
  }'
```

### User 2
```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 2,
    "name": "Tran Thi B",
    "email": "tranthib@example.com",
    "phone": "0902345678",
    "address": "456 Nguyen Hue, Quan 1, TP.HCM"
  }'
```

### User 3
```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 3,
    "name": "Le Van C",
    "email": "levanc@example.com",
    "phone": "0903456789",
    "address": "789 Hai Ba Trung, Quan 3, TP.HCM"
  }'
```

### User 4
```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 4,
    "name": "Pham Thi D",
    "email": "phamthid@example.com",
    "phone": "0904567890",
    "address": "321 Vo Van Tan, Quan 3, TP.HCM"
  }'
```

### User 5
```bash
curl -X POST http://localhost:8081/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": 5,
    "name": "Hoang Van E",
    "email": "hoangvane@example.com",
    "phone": "0905678901",
    "address": "654 Tran Hung Dao, Quan 5, TP.HCM"
  }'
```
