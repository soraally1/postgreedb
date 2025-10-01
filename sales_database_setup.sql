-- =====================================================
-- SALES DATABASE SETUP FOR POSTGRESQL
-- =====================================================

-- Create database (run this separately if needed)
-- CREATE DATABASE sales_db;
-- \c sales_db;

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS detail_transaksi CASCADE;
DROP TABLE IF EXISTS transaksi_penjualan CASCADE;
DROP TABLE IF EXISTS master_harga_jual CASCADE;
DROP TABLE IF EXISTS master_pelanggan CASCADE;
DROP TABLE IF EXISTS master_produk CASCADE;

-- =====================================================
-- 1. CREATE TABLES
-- =====================================================

-- Master Produk
CREATE TABLE master_produk (
    kode VARCHAR(10) PRIMARY KEY,
    nama_produk VARCHAR(100) NOT NULL,
    kategori VARCHAR(50) NOT NULL,
    brand VARCHAR(50) NOT NULL
);

-- Master Pelanggan
CREATE TABLE master_pelanggan (
    kode VARCHAR(10) PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    level_pelanggan VARCHAR(20) NOT NULL CHECK (level_pelanggan IN ('VIP', 'Reguler')),
    asal_kota VARCHAR(50) NOT NULL
);

-- Master Harga Jual
CREATE TABLE master_harga_jual (
    id SERIAL PRIMARY KEY,
    kode_produk VARCHAR(10) NOT NULL,
    harga DECIMAL(15,2) NOT NULL,
    level_pelanggan VARCHAR(20) NOT NULL CHECK (level_pelanggan IN ('VIP', 'Reguler')),
    periode_awal DATE NOT NULL,
    periode_akhir DATE NOT NULL,
    FOREIGN KEY (kode_produk) REFERENCES master_produk(kode)
);

-- Transaksi Penjualan
CREATE TABLE transaksi_penjualan (
    nomor_penjualan VARCHAR(10) PRIMARY KEY,
    tanggal DATE NOT NULL,
    customer VARCHAR(10) NOT NULL,
    nama_kasir VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer) REFERENCES master_pelanggan(kode)
);

-- Detail Transaksi Penjualan
CREATE TABLE detail_transaksi (
    id SERIAL PRIMARY KEY,
    nomor_penjualan VARCHAR(10) NOT NULL,
    urut_item INTEGER NOT NULL,
    kode_produk VARCHAR(10) NOT NULL,
    qty INTEGER NOT NULL,
    harga DECIMAL(15,2) NOT NULL,
    diskon DECIMAL(15,2) DEFAULT 0,
    total_nilai DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (nomor_penjualan) REFERENCES transaksi_penjualan(nomor_penjualan),
    FOREIGN KEY (kode_produk) REFERENCES master_produk(kode),
    UNIQUE(nomor_penjualan, urut_item)
);

-- =====================================================
-- 2. INSERT SAMPLE DATA
-- =====================================================

-- Insert Master Produk
INSERT INTO master_produk (kode, nama_produk, kategori, brand) VALUES
('PRD001', 'iPhone 15 Pro', 'Smartphone', 'Apple'),
('PRD002', 'Samsung Galaxy S24', 'Smartphone', 'Samsung'),
('PRD003', 'MacBook Air M2', 'Laptop', 'Apple'),
('PRD004', 'Dell XPS 13', 'Laptop', 'Dell'),
('PRD005', 'Xiaomi Redmi Note 12', 'Smartphone', 'Xiaomi'),
('PRD006', 'ASUS ROG Strix', 'Laptop', 'ASUS'),
('PRD007', 'OnePlus 11', 'Smartphone', 'OnePlus'),
('PRD008', 'Lenovo ThinkPad X1', 'Laptop', 'Lenovo'),
('PRD009', 'Google Pixel 8', 'Smartphone', 'Google'),
('PRD010', 'HP Pavilion', 'Laptop', 'HP');

-- Insert Master Pelanggan
INSERT INTO master_pelanggan (kode, nama, level_pelanggan, asal_kota) VALUES
('CUST001', 'Ahmad Wijaya', 'VIP', 'Jakarta'),
('CUST002', 'Siti Nurhaliza', 'Reguler', 'Bandung'),
('CUST003', 'Budi Santoso', 'VIP', 'Surabaya'),
('CUST004', 'Dewi Kartika', 'Reguler', 'Medan'),
('CUST005', 'Rizki Pratama', 'VIP', 'Yogyakarta'),
('CUST006', 'Maya Sari', 'Reguler', 'Semarang'),
('CUST007', 'Agus Setiawan', 'VIP', 'Makassar'),
('CUST008', 'Indah Permata', 'Reguler', 'Palembang'),
('CUST009', 'Fajar Nugroho', 'VIP', 'Denpasar'),
('CUST010', 'Lina Marlina', 'Reguler', 'Balikpapan');

-- Insert Master Harga Jual
INSERT INTO master_harga_jual (kode_produk, harga, level_pelanggan, periode_awal, periode_akhir) VALUES
('PRD001', 15000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD001', 16000000, 'Reguler', '2024-01-01', '2024-12-31'),
('PRD002', 12000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD002', 13000000, 'Reguler', '2024-01-01', '2024-12-31'),
('PRD003', 18000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD003', 19000000, 'Reguler', '2024-01-01', '2024-12-31'),
('PRD004', 15000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD004', 16000000, 'Reguler', '2024-01-01', '2024-12-31'),
('PRD005', 3000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD005', 3200000, 'Reguler', '2024-01-01', '2024-12-31'),
-- Additional prices for missing products (estimated based on pattern)
('PRD006', 12000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD006', 12500000, 'Reguler', '2024-01-01', '2024-12-31'),
('PRD007', 8000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD007', 8500000, 'Reguler', '2024-01-01', '2024-12-31'),
('PRD008', 14000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD008', 14500000, 'Reguler', '2024-01-01', '2024-12-31'),
('PRD009', 10000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD009', 10500000, 'Reguler', '2024-01-01', '2024-12-31'),
('PRD010', 8000000, 'VIP', '2024-01-01', '2024-12-31'),
('PRD010', 8500000, 'Reguler', '2024-01-01', '2024-12-31');

-- Insert Transaksi Penjualan
INSERT INTO transaksi_penjualan (nomor_penjualan, tanggal, customer, nama_kasir) VALUES
('TRX001', '2024-01-15', 'CUST001', 'Kasir A'),
('TRX002', '2024-01-16', 'CUST002', 'Kasir B'),
('TRX003', '2024-01-17', 'CUST003', 'Kasir A'),
('TRX004', '2024-01-18', 'CUST004', 'Kasir C'),
('TRX005', '2024-01-19', 'CUST005', 'Kasir B'),
('TRX006', '2024-01-20', 'CUST006', 'Kasir A'),
('TRX007', '2024-01-21', 'CUST007', 'Kasir C'),
('TRX008', '2024-01-22', 'CUST008', 'Kasir B'),
('TRX009', '2024-01-23', 'CUST009', 'Kasir A'),
('TRX010', '2024-01-24', 'CUST010', 'Kasir C'),
('TRX011', '2024-01-25', 'CUST001', 'Kasir B'),
('TRX012', '2024-01-25', 'CUST003', 'Kasir A'),
('TRX013', '2024-01-26', 'CUST005', 'Kasir C'),
('TRX014', '2024-01-26', 'CUST007', 'Kasir B'),
('TRX015', '2024-01-27', 'CUST002', 'Kasir A'),
('TRX016', '2024-01-27', 'CUST009', 'Kasir C'),
('TRX017', '2024-01-28', 'CUST004', 'Kasir B'),
('TRX018', '2024-01-28', 'CUST006', 'Kasir A'),
('TRX019', '2024-01-29', 'CUST008', 'Kasir C'),
('TRX020', '2024-01-29', 'CUST010', 'Kasir B');

-- Insert Detail Transaksi Penjualan
INSERT INTO detail_transaksi (nomor_penjualan, urut_item, kode_produk, qty, harga, diskon, total_nilai) VALUES
('TRX001', 1, 'PRD001', 1, 15000000, 500000, 14500000),
('TRX002', 1, 'PRD005', 2, 3000000, 100000, 5900000),
('TRX003', 1, 'PRD003', 1, 18000000, 1000000, 17000000),
('TRX003', 2, 'PRD001', 1, 15000000, 500000, 14500000),
('TRX004', 1, 'PRD002', 1, 12000000, 0, 12000000),
('TRX005', 1, 'PRD004', 1, 15000000, 750000, 14250000),
('TRX006', 1, 'PRD007', 1, 8000000, 200000, 7800000),
('TRX007', 1, 'PRD006', 1, 12000000, 500000, 11500000),
('TRX007', 2, 'PRD009', 1, 10000000, 300000, 9700000),
('TRX008', 1, 'PRD010', 1, 8000000, 0, 8000000),
('TRX009', 1, 'PRD008', 1, 14000000, 1000000, 13000000),
('TRX010', 1, 'PRD003', 1, 19000000, 500000, 18500000),
('TRX011', 1, 'PRD002', 1, 13000000, 0, 13000000),
('TRX011', 2, 'PRD005', 1, 3200000, 200000, 3000000),
('TRX012', 1, 'PRD001', 1, 16000000, 1000000, 15000000),
('TRX012', 2, 'PRD007', 1, 8000000, 0, 8000000),
('TRX013', 1, 'PRD004', 1, 16000000, 500000, 15500000),
('TRX014', 1, 'PRD006', 1, 12000000, 1000000, 11000000),
('TRX014', 2, 'PRD009', 1, 10000000, 500000, 9500000),
('TRX015', 1, 'PRD010', 1, 8000000, 0, 8000000),
('TRX016', 1, 'PRD003', 1, 19000000, 1500000, 17500000),
('TRX016', 2, 'PRD001', 1, 16000000, 0, 16000000),
('TRX017', 1, 'PRD005', 2, 3200000, 200000, 6000000),
('TRX018', 1, 'PRD008', 1, 14000000, 1000000, 13000000),
('TRX018', 2, 'PRD002', 1, 13000000, 0, 13000000),
('TRX019', 1, 'PRD007', 1, 8000000, 0, 8000000),
('TRX020', 1, 'PRD004', 1, 16000000, 1000000, 15000000),
('TRX020', 2, 'PRD006', 1, 12000000, 500000, 11500000);

-- =====================================================
-- 3. CREATE INDEXES FOR BETTER PERFORMANCE
-- =====================================================

CREATE INDEX idx_transaksi_tanggal ON transaksi_penjualan(tanggal);
CREATE INDEX idx_transaksi_customer ON transaksi_penjualan(customer);
CREATE INDEX idx_detail_produk ON detail_transaksi(kode_produk);
CREATE INDEX idx_harga_produk_level ON master_harga_jual(kode_produk, level_pelanggan);

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check data counts
SELECT 'master_produk' as table_name, COUNT(*) as record_count FROM master_produk
UNION ALL
SELECT 'master_pelanggan', COUNT(*) FROM master_pelanggan
UNION ALL
SELECT 'master_harga_jual', COUNT(*) FROM master_harga_jual
UNION ALL
SELECT 'transaksi_penjualan', COUNT(*) FROM transaksi_penjualan
UNION ALL
SELECT 'detail_transaksi', COUNT(*) FROM detail_transaksi;

-- Database setup completed successfully!
SELECT 'Database setup completed successfully!' as status;
