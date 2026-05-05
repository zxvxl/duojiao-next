#!/bin/bash
# 清空商品相关数据（保留订单记录）
# 用法：在服务器上 deploy/ 目录下执行
#   docker compose exec api sh -c "cd /app/db && cp dujiao.db dujiao.db.backup.\$(date +%Y%m%d%H%M%S)"
#   sqlite3 data/db/dujiao.db < clear_products.sql

set -e

DB_FILE="${1:-./data/db/dujiao.db}"

echo "=== 当前商品数据统计 ==="
sqlite3 "$DB_FILE" "SELECT 'products', count(*) FROM products UNION ALL SELECT 'product_skus', count(*) FROM product_skus UNION ALL SELECT 'product_mappings', count(*) FROM product_mappings UNION ALL SELECT 'sku_mappings', count(*) FROM sku_mappings UNION ALL SELECT 'post_products', count(*) FROM post_products UNION ALL SELECT 'member_level_prices', count(*) FROM member_level_prices UNION ALL SELECT 'cart_items', count(*) FROM cart_items UNION ALL SELECT 'categories', count(*) FROM categories;"

echo ""
echo "=== 开始备份数据库 ==="
cp "$DB_FILE" "${DB_FILE}.backup.$(date +%Y%m%d%H%M%S)"
echo "备份完成: ${DB_FILE}.backup.$(date +%Y%m%d%H%M%S)"

echo ""
echo "=== 开始清理商品数据 ==="

sqlite3 "$DB_FILE" <<'SQL'
PRAGMA foreign_keys = ON;

-- 1. 购物车（FK -> products, product_skus）
DELETE FROM cart_items;
DELETE FROM cart_items WHERE deleted_at IS NOT NULL;

-- 2. 会员等级价格（FK -> products, product_skus）
DELETE FROM member_level_prices;
DELETE FROM member_level_prices WHERE deleted_at IS NOT NULL;

-- 3. SKU映射（FK -> product_mappings, product_skus）
DELETE FROM sku_mappings;
DELETE FROM sku_mappings WHERE deleted_at IS NOT NULL;

-- 4. 商品映射（FK -> products）
DELETE FROM product_mappings;
DELETE FROM product_mappings WHERE deleted_at IS NOT NULL;

-- 5. 文章关联商品（FK -> products）
DELETE FROM post_products;

-- 6. 商品SKU（FK -> products）
DELETE FROM product_skus;
DELETE FROM product_skus WHERE deleted_at IS NOT NULL;

-- 7. 商品主表
DELETE FROM products;
DELETE FROM products WHERE deleted_at IS NOT NULL;

-- 8. 分类（如不需要清空，注释掉下面两行）
-- DELETE FROM categories;
-- DELETE FROM categories WHERE deleted_at IS NOT NULL;
SQL

echo ""
echo "=== 清理后数据统计 ==="
sqlite3 "$DB_FILE" "SELECT 'products', count(*) FROM products UNION ALL SELECT 'product_skus', count(*) FROM product_skus UNION ALL SELECT 'product_mappings', count(*) FROM product_mappings UNION ALL SELECT 'sku_mappings', count(*) FROM sku_mappings UNION ALL SELECT 'post_products', count(*) FROM post_products UNION ALL SELECT 'member_level_prices', count(*) FROM member_level_prices UNION ALL SELECT 'cart_items', count(*) FROM cart_items UNION ALL SELECT 'categories', count(*) FROM categories;"

echo ""
echo "=== 清理完成 ==="
