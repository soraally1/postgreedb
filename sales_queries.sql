-- =====================================================
-- SALES DATABASE QUERIES
-- =====================================================

-- =====================================================
-- QUERY 1: Customers who didn't shop in specific date range
-- =====================================================

-- Example: Find customers who didn't shop between 2024-01-20 and 2024-01-25
SELECT 
    mp.kode,
    mp.nama,
    mp.level_pelanggan,
    mp.asal_kota,
    'No transactions in specified period' as status
FROM master_pelanggan mp
WHERE mp.kode NOT IN (
    SELECT DISTINCT tp.customer
    FROM transaksi_penjualan tp
    WHERE tp.tanggal BETWEEN '2024-01-20' AND '2024-01-25'
)
ORDER BY mp.nama;

-- More flexible version with parameters (replace @start_date and @end_date)
/*
-- For PostgreSQL with parameters:
PREPARE customer_no_shop_query (DATE, DATE) AS
SELECT 
    mp.kode,
    mp.nama,
    mp.level_pelanggan,
    mp.asal_kota,
    CONCAT('No transactions between ', $1, ' and ', $2) as status
FROM master_pelanggan mp
WHERE mp.kode NOT IN (
    SELECT DISTINCT tp.customer
    FROM transaksi_penjualan tp
    WHERE tp.tanggal BETWEEN $1 AND $2
)
ORDER BY mp.nama;

-- Execute with: EXECUTE customer_no_shop_query('2024-01-20', '2024-01-25');
*/

-- =====================================================
-- QUERY 2: Sales quantity summary by Brand
-- =====================================================

SELECT 
    mp.brand,
    SUM(dt.qty) as total_quantity,
    COUNT(DISTINCT dt.nomor_penjualan) as total_transactions,
    COUNT(DISTINCT dt.kode_produk) as products_sold,
    SUM(dt.total_nilai) as total_sales_value,
    AVG(dt.qty) as avg_quantity_per_transaction,
    MIN(tp.tanggal) as first_sale_date,
    MAX(tp.tanggal) as last_sale_date
FROM detail_transaksi dt
JOIN master_produk mp ON dt.kode_produk = mp.kode
JOIN transaksi_penjualan tp ON dt.nomor_penjualan = tp.nomor_penjualan
GROUP BY mp.brand
ORDER BY total_quantity DESC, total_sales_value DESC;

-- Detailed version with product breakdown per brand
SELECT 
    mp.brand,
    mp.nama_produk,
    mp.kategori,
    SUM(dt.qty) as quantity_sold,
    COUNT(dt.nomor_penjualan) as times_sold,
    SUM(dt.total_nilai) as total_value,
    AVG(dt.harga) as avg_selling_price,
    AVG(dt.diskon) as avg_discount
FROM detail_transaksi dt
JOIN master_produk mp ON dt.kode_produk = mp.kode
JOIN transaksi_penjualan tp ON dt.nomor_penjualan = tp.nomor_penjualan
GROUP BY mp.brand, mp.nama_produk, mp.kategori
ORDER BY mp.brand, quantity_sold DESC;

-- =====================================================
-- QUERY 3: Add status_penjualan column and update data
-- =====================================================

-- Add status_penjualan column to transaksi_penjualan table
ALTER TABLE transaksi_penjualan 
ADD COLUMN status_penjualan VARCHAR(10) DEFAULT 'DONE' 
CHECK (status_penjualan IN ('CANCEL', 'DONE'));

-- Update random transactions to have different statuses
-- First, set all to DONE as default
UPDATE transaksi_penjualan SET status_penjualan = 'DONE';

-- Update some random transactions to CANCEL (approximately 30% of transactions)
UPDATE transaksi_penjualan 
SET status_penjualan = 'CANCEL'
WHERE nomor_penjualan IN (
    SELECT nomor_penjualan 
    FROM transaksi_penjualan 
    ORDER BY RANDOM() 
    LIMIT 6  -- This will cancel 6 out of 20 transactions (30%)
);

-- =====================================================
-- VERIFICATION AND ANALYSIS QUERIES
-- =====================================================

-- Check status distribution
SELECT 
    status_penjualan,
    COUNT(*) as transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transaksi_penjualan), 2) as percentage
FROM transaksi_penjualan
GROUP BY status_penjualan
ORDER BY transaction_count DESC;

-- Sales summary by status
SELECT 
    tp.status_penjualan,
    COUNT(DISTINCT tp.nomor_penjualan) as transaction_count,
    SUM(dt.qty) as total_quantity,
    SUM(dt.total_nilai) as total_sales_value,
    AVG(dt.total_nilai) as avg_transaction_value
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.nomor_penjualan = dt.nomor_penjualan
GROUP BY tp.status_penjualan
ORDER BY total_sales_value DESC;

-- Customer analysis with transaction status
SELECT 
    mp.nama as customer_name,
    mp.level_pelanggan,
    mp.asal_kota,
    COUNT(CASE WHEN tp.status_penjualan = 'DONE' THEN 1 END) as completed_transactions,
    COUNT(CASE WHEN tp.status_penjualan = 'CANCEL' THEN 1 END) as cancelled_transactions,
    COUNT(*) as total_transactions,
    SUM(CASE WHEN tp.status_penjualan = 'DONE' THEN dt.total_nilai ELSE 0 END) as completed_sales_value
FROM master_pelanggan mp
JOIN transaksi_penjualan tp ON mp.kode = tp.customer
JOIN detail_transaksi dt ON tp.nomor_penjualan = dt.nomor_penjualan
GROUP BY mp.kode, mp.nama, mp.level_pelanggan, mp.asal_kota
ORDER BY completed_sales_value DESC;

-- =====================================================
-- ADDITIONAL USEFUL QUERIES
-- =====================================================

-- Top selling products
SELECT 
    mp.kode,
    mp.nama_produk,
    mp.brand,
    mp.kategori,
    SUM(dt.qty) as total_sold,
    SUM(dt.total_nilai) as total_revenue,
    COUNT(DISTINCT tp.customer) as unique_customers
FROM master_produk mp
JOIN detail_transaksi dt ON mp.kode = dt.kode_produk
JOIN transaksi_penjualan tp ON dt.nomor_penjualan = tp.nomor_penjualan
WHERE tp.status_penjualan = 'DONE'
GROUP BY mp.kode, mp.nama_produk, mp.brand, mp.kategori
ORDER BY total_sold DESC, total_revenue DESC;

-- Monthly sales trend
SELECT 
    EXTRACT(YEAR FROM tp.tanggal) as year,
    EXTRACT(MONTH FROM tp.tanggal) as month,
    COUNT(DISTINCT tp.nomor_penjualan) as transaction_count,
    SUM(dt.qty) as total_quantity,
    SUM(dt.total_nilai) as total_sales,
    COUNT(DISTINCT tp.customer) as unique_customers
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.nomor_penjualan = dt.nomor_penjualan
WHERE tp.status_penjualan = 'DONE'
GROUP BY EXTRACT(YEAR FROM tp.tanggal), EXTRACT(MONTH FROM tp.tanggal)
ORDER BY year, month;
