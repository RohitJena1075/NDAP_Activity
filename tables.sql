USE ndap_activity;  
-- =========================================
-- Database: ndap_activity
-- =========================================
CREATE DATABASE IF NOT EXISTS ndap_activity;
USE ndap_activity;

-- =========================================
-- 1) CATEGORIES TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NULL,
  icon VARCHAR(50) NULL,
  display_order INT UNSIGNED DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_categories_slug (slug),
  INDEX idx_categories_active (is_active),
  INDEX idx_categories_order (display_order, is_active)
) ENGINE=InnoDB;

-- =========================================
-- 2) DATASETS TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS datasets (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL UNIQUE,
  description TEXT NULL,
  summary VARCHAR(500) NULL,
  category_id INT UNSIGNED NULL,
  file_path VARCHAR(500) NULL,
  file_name VARCHAR(255) NULL,
  file_size BIGINT UNSIGNED NULL,
  file_type VARCHAR(50) NULL,
  source_organization VARCHAR(255) NULL,
  geographic_coverage VARCHAR(255) NULL,
  temporal_coverage VARCHAR(255) NULL,
  frequency VARCHAR(100) NULL,
  status ENUM('draft','active','inactive') DEFAULT 'active',
  is_featured BOOLEAN DEFAULT FALSE,
  upload_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  published_date DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_datasets_category FOREIGN KEY (category_id) REFERENCES categories(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_datasets_category (category_id),
  INDEX idx_datasets_status (status),
  INDEX idx_datasets_slug (slug),
  INDEX idx_datasets_featured (is_featured, status),
  FULLTEXT INDEX ft_datasets_search (title, description, summary)
) ENGINE=InnoDB;

-- =========================================
-- 3) SESSIONS TABLE
-- =========================================
CREATE TABLE IF NOT EXISTS sessions (
  id CHAR(36) PRIMARY KEY,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  last_activity DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================================
-- 4) DATASET_VIEWS TABLE (session-based)
-- =========================================
CREATE TABLE IF NOT EXISTS dataset_views (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  dataset_id INT UNSIGNED NOT NULL,
  view_type ENUM('list_view','detail_view','preview','search_result') DEFAULT 'detail_view',
  page_url VARCHAR(500) NULL,
  search_query VARCHAR(255) NULL,
  user_agent TEXT NULL,
  device_type ENUM('desktop','mobile','tablet') NULL,
  browser_name VARCHAR(50) NULL,
  viewed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  time_spent_seconds INT UNSIGNED NULL,
  CONSTRAINT fk_views_session FOREIGN KEY (session_id) REFERENCES sessions(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_views_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_views_session_time (session_id, viewed_at DESC),
  INDEX idx_views_dataset (dataset_id)
) ENGINE=InnoDB;

-- =========================================
-- 5) DOWNLOADS TABLE (session-based)
-- =========================================
CREATE TABLE IF NOT EXISTS downloads (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  dataset_id INT UNSIGNED NOT NULL,
  download_method ENUM('direct','api') DEFAULT 'direct',
  file_format VARCHAR(20) NULL,
  file_size_bytes BIGINT UNSIGNED NULL,
  download_status ENUM('requested','completed','failed') DEFAULT 'requested',
  error_message TEXT NULL,
  user_agent TEXT NULL,
  device_type ENUM('desktop','mobile','tablet') NULL,
  requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME NULL,
  CONSTRAINT fk_downloads_session FOREIGN KEY (session_id) REFERENCES sessions(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_downloads_dataset FOREIGN KEY (dataset_id) REFERENCES datasets(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_downloads_session_time (session_id, requested_at DESC),
  INDEX idx_downloads_status (download_status),
  INDEX idx_downloads_dataset (dataset_id)
) ENGINE=InnoDB;