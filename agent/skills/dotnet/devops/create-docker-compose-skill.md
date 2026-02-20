---
name: create-docker-compose-skill
description: 建立 Docker Compose 結構
version: 1.0.0
---

# Create Docker Compose Skill

建立基礎容器環境。

---

## 建立 docker-compose.yml

```yaml
version: '3.9'

services:
  app:
    build: .
    ports:
      - "5000:8080"

  seq:
    image: datalust/seq
    ports:
      - "5341:80"
```

---

## 注意事項

- 不要在容器內寫死連線字串
- 使用環境變數

---

## Changelog

### 1.0.0
- Initial version