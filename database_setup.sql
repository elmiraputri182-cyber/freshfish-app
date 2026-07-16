-- ========================================================
-- SCRIPT DATABASE: PENGELOLAAN AKUN ADMIN FRESH FISH
-- ========================================================

-- 1. Membuat tabel 'users' jika belum ada
CREATE TABLE IF NOT EXISTS users (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'agen', 'pembeli') NOT NULL,
    nama_lengkap VARCHAR(100),
    no_telp VARCHAR(20),
    alamat TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Membuat Akun Admin Pertama Kali (INSERT)
-- Catatan: Ganti 'admin@freshfish.com' dan 'admin123' dengan data Anda sendiri.
-- Jika sudah ada akun admin, perintah ini akan diabaikan karena menggunakan 'INSERT IGNORE'.
INSERT IGNORE INTO users (username, password, role, nama_lengkap, no_telp, alamat) 
VALUES (
    'admin@freshfish.com', 
    MD5('admin123'), 
    'admin', 
    'Administrator Utama', 
    '081234567890', 
    'Bengkalis'
);

-- 3. Memperbarui Akun Admin yang Sudah Ada (UPDATE)
-- Jalankan query ini kapan pun Anda ingin memperbarui email atau password admin.
-- Ganti nilai di bawah ini sesuai keinginan Anda:
UPDATE users 
SET 
    username = 'admin@freshfish.com',   -- Masukkan email admin baru Anda di sini
    password = MD5('admin123'),          -- Masukkan password admin baru Anda di sini
    nama_lengkap = 'Administrator Utama',
    no_telp = '081234567890'
WHERE role = 'admin';

-- ========================================================
-- 4. Membuat Tabel 'master_ikan' untuk Daftar Nama Ikan Standar
-- ========================================================
CREATE TABLE IF NOT EXISTS master_ikan (
    id_master INT AUTO_INCREMENT PRIMARY KEY,
    nama_ikan VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
