-- V1__init.sql
-- 在庫アプリ: 初期スキーマ
-- DBは inventory_db / utf8mb4_0900_ai_ci を想定（DB作成は別コマンド）

-- 安全のため
SET NAMES utf8mb4;
SET time_zone = '+09:00';

-- ============== User =================
CREATE TABLE users (
  user_id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  -- 大小無視で一意にしたいならそのまま
  user_name      VARCHAR(150) NOT NULL,
  -- 大小を区別して一意にしたい場合は下のように列の照合を上書き
  -- user_name      VARCHAR(150) COLLATE utf8mb4_0900_as_cs NOT NULL,
  -- bcryptは最大72文字
  user_password  VARCHAR(72) NOT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_users_name (user_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============== Product ==============
CREATE TABLE product (
  product_id     BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_name   VARCHAR(100) NOT NULL,
  price          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  description    TEXT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_product_name (product_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============== Purchase（仕入れ） =====
CREATE TABLE purchase (
  purchase_id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id         BIGINT UNSIGNED NOT NULL,
  purchase_quantity  INT UNSIGNED NOT NULL DEFAULT 1,
  purchase_at        DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_purchase_product
    FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 参照や期間検索で効くインデックス
CREATE INDEX ix_purchase_product_id ON purchase(product_id);
CREATE INDEX ix_purchase_at ON purchase(purchase_at);

-- ============== Sale（卸し） ==========
CREATE TABLE sale (
  sale_id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id     BIGINT UNSIGNED NOT NULL,
  sale_quantity  INT UNSIGNED NOT NULL DEFAULT 1,
  sale_at        DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_sale_product
    FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE INDEX ix_sale_product_id ON sale(product_id);
CREATE INDEX ix_sale_at ON sale(sale_at);

-- ============== Sales File ============
CREATE TABLE sales_file (
  sales_file_id  BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  file_name      VARCHAR(255) NOT NULL,
  status         VARCHAR(50)  NOT NULL DEFAULT 'waiting',
  uploaded_at    DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE KEY uk_sales_file_name (file_name),
  CHECK (status IN ('waiting','processing','done','error'))  -- MySQL 8 は CHECK 有効
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
