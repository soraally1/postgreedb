# Sales Database Setup Instructions

## Overview
This PostgreSQL database contains a complete sales management system with customer data, product catalog, pricing, and transaction records.

## Database Structure

### Tables Created:
1. **master_produk** - Product catalog with codes, names, categories, and brands
2. **master_pelanggan** - Customer information with VIP/Regular levels
3. **master_harga_jual** - Pricing matrix based on customer levels and time periods
4. **transaksi_penjualan** - Sales transaction headers with status tracking
5. **detail_transaksi** - Individual line items for each transaction

## Setup Instructions

### 1. Database Creation
```sql
-- Connect to PostgreSQL and create database
CREATE DATABASE sales_db;
\c sales_db;
```

### 2. Run Setup Script
Execute the complete setup script:
```bash
psql -d sales_db -f sales_database_setup.sql
```

### 3. Run Query Examples
Execute the query examples:
```bash
psql -d sales_db -f sales_queries.sql
```

## Key Features Implemented

### ✅ Complete Database Schema
- All 5 tables with proper relationships
- Foreign key constraints
- Check constraints for data validation
- Indexes for performance optimization

### ✅ Sample Data Insertion
- 10 products across Smartphone and Laptop categories
- 10 customers with VIP/Regular levels
- 20 pricing records with customer level differentiation
- 20 sales transactions
- 28 transaction detail records

### ✅ Required Queries

#### 1. Customers Who Didn't Shop in Date Range
```sql
-- Find customers with no transactions between specific dates
SELECT mp.kode, mp.nama, mp.level_pelanggan, mp.asal_kota
FROM master_pelanggan mp
WHERE mp.kode NOT IN (
    SELECT DISTINCT tp.customer
    FROM transaksi_penjualan tp
    WHERE tp.tanggal BETWEEN '2024-01-20' AND '2024-01-25'
);
```

#### 2. Sales Quantity Summary by Brand
```sql
-- Summary of sales quantities grouped by product brand
SELECT 
    mp.brand,
    SUM(dt.qty) as total_quantity,
    COUNT(DISTINCT dt.nomor_penjualan) as total_transactions,
    SUM(dt.total_nilai) as total_sales_value
FROM detail_transaksi dt
JOIN master_produk mp ON dt.kode_produk = mp.kode
JOIN transaksi_penjualan tp ON dt.nomor_penjualan = tp.nomor_penjualan
GROUP BY mp.brand
ORDER BY total_quantity DESC;
```

#### 3. Transaction Status Management
```sql
-- Add status column and update random transactions
ALTER TABLE transaksi_penjualan 
ADD COLUMN status_penjualan VARCHAR(10) DEFAULT 'DONE' 
CHECK (status_penjualan IN ('CANCEL', 'DONE'));

-- Randomly set some transactions to CANCEL status
UPDATE transaksi_penjualan 
SET status_penjualan = 'CANCEL'
WHERE nomor_penjualan IN (
    SELECT nomor_penjualan 
    FROM transaksi_penjualan 
    ORDER BY RANDOM() 
    LIMIT 6
);
```

## Data Verification

### Record Counts
- **master_produk**: 10 records
- **master_pelanggan**: 10 records  
- **master_harga_jual**: 20 records
- **transaksi_penjualan**: 20 records
- **detail_transaksi**: 28 records

### Brand Distribution
- **Apple**: iPhone, MacBook (Premium products)
- **Samsung**: Galaxy series
- **Dell, ASUS, Lenovo, HP**: Laptop brands
- **Xiaomi, OnePlus, Google**: Smartphone brands

### Customer Levels
- **VIP**: 5 customers (50%) - Get better pricing
- **Regular**: 5 customers (50%) - Standard pricing

## Testing the Database

### 1. Verify Data Integrity
```sql
-- Check all foreign key relationships
SELECT COUNT(*) FROM detail_transaksi dt
LEFT JOIN transaksi_penjualan tp ON dt.nomor_penjualan = tp.nomor_penjualan
WHERE tp.nomor_penjualan IS NULL; -- Should return 0

-- Check pricing consistency
SELECT * FROM master_harga_jual mhj
LEFT JOIN master_produk mp ON mhj.kode_produk = mp.kode
WHERE mp.kode IS NULL; -- Should return 0
```

### 2. Performance Testing
```sql
-- Test query performance with indexes
EXPLAIN ANALYZE SELECT * FROM transaksi_penjualan WHERE tanggal BETWEEN '2024-01-15' AND '2024-01-25';
```

### 3. Business Logic Testing
```sql
-- Verify VIP customers get better prices
SELECT 
    mp.nama as customer,
    mp.level_pelanggan,
    pr.nama_produk,
    dt.harga as paid_price,
    mhj.harga as list_price
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.nomor_penjualan = tp.nomor_penjualan
JOIN master_pelanggan mp ON tp.customer = mp.kode
JOIN master_produk pr ON dt.kode_produk = pr.kode
JOIN master_harga_jual mhj ON pr.kode = mhj.kode_produk AND mp.level_pelanggan = mhj.level_pelanggan
ORDER BY pr.nama_produk, mp.level_pelanggan;
```

## Additional Analysis Queries

The `sales_queries.sql` file includes additional useful queries:
- Top selling products analysis
- Monthly sales trends
- Customer transaction patterns
- Sales performance by status
- Revenue analysis by customer level

## Next Steps

1. **Connect your application** to the database using the connection string
2. **Test all queries** in your PostgreSQL client
3. **Modify data** as needed for your specific use case
4. **Add more sample data** if needed for testing
5. **Create views** for commonly used query patterns

## Connection Example
```bash
# Connect using psql
psql -h localhost -d sales_db -U your_username

# Or using connection string
postgresql://username:password@localhost:5432/sales_db
```

The database is now ready for use with all the requested functionality implemented and tested!
