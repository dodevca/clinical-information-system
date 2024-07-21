-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 21, 2024 at 08:35 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `klinik_final`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `hitungTotalBiaya` (IN `p_konsultasi_id` INT)   BEGIN
    DECLARE total_biaya DECIMAL(16, 2);
    
    SELECT 
        SUM(CASE WHEN kp.id_produk IS NOT NULL THEN p.harga_satuan * kp.jumlah ELSE 0 END) +
        SUM(CASE WHEN kt.id_treatment IS NOT NULL THEN t.harga ELSE 0 END) +
        SUM(CASE WHEN kl.id_laboratorium IS NOT NULL THEN l.harga ELSE 0 END)
    INTO total_biaya
    FROM 
        Konsultasi k
    LEFT JOIN 
        Konsultasi_Produk kp ON k.id_konsultasi = kp.id_konsultasi
    LEFT JOIN 
        Produk p ON kp.id_produk = p.id_produk
    LEFT JOIN 
        Konsultasi_Treatment kt ON k.id_konsultasi = kt.id_konsultasi
    LEFT JOIN 
        Treatment t ON kt.id_treatment = t.id_treatment
    LEFT JOIN 
        Konsultasi_Laboratorium kl ON k.id_konsultasi = kl.id_konsultasi
    LEFT JOIN 
        Laboratorium l ON kl.id_laboratorium = l.id_laboratorium
    WHERE 
        k.id_konsultasi = p_konsultasi_id
    GROUP BY 
        k.id_konsultasi;

    UPDATE Konsultasi
    SET total_harga = total_biaya
    WHERE id_konsultasi = p_konsultasi_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `hitungTotalKonsultasi` ()   BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM Konsultasi;
    SELECT total;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tambahStokProduk` (IN `p_id_produk` INT, IN `p_tambah_stok` INT, IN `p_harga_beli_baru` DECIMAL(16,2))   BEGIN
    DECLARE stok_lama INT;
    DECLARE harga_beli_lama DECIMAL(16, 2);
    DECLARE stok_baru INT;

    SELECT stok, harga_beli INTO stok_lama, harga_beli_lama
    FROM Produk
    WHERE id_produk = p_id_produk;

    SET stok_baru = stok_lama + p_tambah_stok;

    UPDATE Produk
    SET stok = stok_baru, 
        harga_beli = p_harga_beli_baru, 
        harga_jual = hitungHargaJual(p_harga_beli_baru)
    WHERE id_produk = p_id_produk;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updatePembayaran` (IN `p_id_konsultasi` INT, IN `p_metode_pembayaran` ENUM('CASH','DEBIT','QRIS'), IN `p_status_pembayaran` ENUM('LUNAS','BELUM LUNAS'))   BEGIN
    UPDATE Konsultasi
    SET metode_pembayaran = p_metode_pembayaran,
        status_pembayaran = p_status_pembayaran,
        tanggal_pembayaran = NOW()
    WHERE id_konsultasi = p_id_konsultasi;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `cekStatusPembayaran` (`p_id_konsultasi` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE status VARCHAR(20);
    SELECT status_pembayaran INTO status FROM Konsultasi WHERE id_konsultasi = p_id_konsultasi;
    RETURN status;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `hitungHargaJual` (`p_harga_beli` DECIMAL(16,2)) RETURNS DECIMAL(16,2)  BEGIN
    RETURN p_harga_beli * (120 / 100);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `hitungStokProduk` (`p_id_produk` INT) RETURNS INT(11)  BEGIN
    DECLARE stok_sisa INT;

    SELECT stok INTO stok_sisa
    FROM Produk
    WHERE id_produk = p_id_produk;

    RETURN stok_sisa;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `hitungUsia` (`p_tanggal_lahir` DATE) RETURNS INT(11)  BEGIN
    DECLARE usia INT;
    SET usia = TIMESTAMPDIFF(YEAR, p_tanggal_lahir, CURDATE());
    RETURN usia;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Dokter`
--

CREATE TABLE `Dokter` (
  `id_dokter` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `spesialis` varchar(100) NOT NULL,
  `jenkel` enum('P','L') NOT NULL,
  `telepon` varchar(20) DEFAULT NULL,
  `alamat` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Dokter`
--

INSERT INTO `Dokter` (`id_dokter`, `nama`, `spesialis`, `jenkel`, `telepon`, `alamat`) VALUES
(1, 'Dr. Sinyo', 'Umum', 'L', '0812345682', 'Jl. Setia Budi No. 1'),
(2, 'Dr. Bella', 'Penyakit Dalam', 'P', '0857654325', 'Jl. Thamrin No. 2'),
(3, 'Dr. Lefi', 'Anak', 'P', '0898765436', 'Jl. Sudirman No. 3'),
(4, 'Dr. Dedi', 'Bedah', 'L', '0812345683', 'Jl. Diponegoro No. 4'),
(5, 'Dr. Cici', 'Kulit & Kelamin', 'P', '0857654327', 'Jl. Sisingamangaraja No. 5'),
(6, 'Dr. Hasna', 'Jantung', 'P', '0898765438', 'Jl. Gatot Subroto No. 6'),
(7, 'Dr. Ilyaz', 'THT', 'L', '0812345684', 'Jl. Hatta No. 7'),
(8, 'Dr. Hani', 'Mata', 'P', '0857654329', 'Jl. Supriyadi No. 8'),
(9, 'Dr. Iki', 'Saraf', 'L', '0898765440', 'Jl. Proklamasi No. 9'),
(10, 'Dr. Rico', 'Gigi & Mulut', 'L', '0812345685', 'Jl. Merdeka Barat No. 10'),
(11, 'Dr. Ayra', 'Umum', 'L', NULL, NULL),
(12, 'Dr. Sayli', 'Umum', 'P', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `Konsultasi`
--

CREATE TABLE `Konsultasi` (
  `id_konsultasi` int(11) NOT NULL,
  `masalah` varchar(255) DEFAULT NULL,
  `total_harga` decimal(16,2) NOT NULL DEFAULT 0.00,
  `tanggal_konsultasi` datetime NOT NULL,
  `tanggal_pembayaran` datetime DEFAULT NULL,
  `metode_pembayaran` enum('CASH','DEBIT','QRIS') DEFAULT NULL,
  `status_pembayaran` enum('LUNAS','BELUM LUNAS') NOT NULL DEFAULT 'BELUM LUNAS',
  `id_dokter` int(11) NOT NULL,
  `id_pasien` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Konsultasi`
--

INSERT INTO `Konsultasi` (`id_konsultasi`, `masalah`, `total_harga`, `tanggal_konsultasi`, `tanggal_pembayaran`, `metode_pembayaran`, `status_pembayaran`, `id_dokter`, `id_pasien`) VALUES
(1, 'Sakit Kepala', 349000.00, '2024-06-01 10:00:00', '2024-06-01 10:30:00', 'CASH', 'LUNAS', 11, 1),
(2, 'Batuk dan Pilek', 510000.00, '2024-06-02 11:00:00', NULL, NULL, 'BELUM LUNAS', 12, 2),
(3, 'Demam Tinggi', 200000.00, '2024-06-03 09:00:00', '2024-06-03 09:30:00', 'DEBIT', 'LUNAS', 11, 3),
(4, 'Nyeri Perut', 450000.00, '2024-06-04 14:00:00', NULL, NULL, 'BELUM LUNAS', 1, 4),
(5, 'Gatal-gatal', 0.00, '2024-06-05 15:30:00', '2024-06-05 16:00:00', 'QRIS', 'LUNAS', 12, 5),
(6, 'Sakit Gigi', 0.00, '2024-06-06 18:00:00', '2024-06-06 08:30:00', 'CASH', 'LUNAS', 11, 6),
(7, 'Alergi Makanan', 50000.00, '2024-06-07 05:00:00', NULL, NULL, 'BELUM LUNAS', 1, 7),
(8, 'Infeksi Telinga', 525000.00, '2024-06-09 13:00:00', '2024-06-08 12:30:00', 'DEBIT', 'LUNAS', 12, 8),
(9, 'Gangguan Tidur', 170000.00, '2024-06-09 23:00:00', NULL, NULL, 'BELUM LUNAS', 11, 9),
(10, 'Kontrol Diabetes', 465000.00, '2024-06-10 06:00:00', '2024-06-10 11:30:00', 'QRIS', 'LUNAS', 1, 10),
(11, 'Kembung', 600000.00, '2024-06-26 17:50:08', NULL, NULL, 'BELUM LUNAS', 11, 2);

--
-- Triggers `Konsultasi`
--
DELIMITER $$
CREATE TRIGGER `after_konsultasi_insert` AFTER INSERT ON `Konsultasi` FOR EACH ROW BEGIN
    INSERT INTO Log (aksi, tabel, waktu, deskripsi)
    VALUES ('INSERT', 'Konsultasi', NOW(), CONCAT('Konsultasi ID: ', NEW.id_konsultasi));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_konsultasi_update` AFTER UPDATE ON `Konsultasi` FOR EACH ROW BEGIN
    INSERT INTO Log (aksi, tabel, waktu, deskripsi)
    VALUES ('UPDATE', 'Konsultasi', NOW(), CONCAT('Konsultasi ID: ', NEW.id_konsultasi));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Konsultasi_Laboratorium`
--

CREATE TABLE `Konsultasi_Laboratorium` (
  `id_laboratorium` int(11) DEFAULT NULL,
  `id_konsultasi` int(11) DEFAULT NULL,
  `hasil` text DEFAULT NULL,
  `tanggal` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Konsultasi_Laboratorium`
--

INSERT INTO `Konsultasi_Laboratorium` (`id_laboratorium`, `id_konsultasi`, `hasil`, `tanggal`) VALUES
(9, 1, '185 mg/d185 mg/dL', '2024-06-01 10:30:00'),
(14, 1, 'Positif', '2024-06-01 10:30:00'),
(4, 2, NULL, '2024-06-02 11:30:00'),
(2, 3, NULL, '2024-06-03 09:30:00'),
(11, 4, NULL, '2024-06-04 11:30:00'),
(13, 5, NULL, '2024-06-05 16:00:00'),
(8, 8, NULL, '2024-06-08 12:30:00'),
(15, 10, NULL, '2024-06-10 11:30:00'),
(11, 11, NULL, '2024-06-27 17:51:16'),
(12, 11, NULL, '2024-06-27 17:51:16');

--
-- Triggers `Konsultasi_Laboratorium`
--
DELIMITER $$
CREATE TRIGGER `after_konsultasi_laboratorium_insert` AFTER INSERT ON `Konsultasi_Laboratorium` FOR EACH ROW BEGIN
    CALL hitungTotalBiaya(NEW.id_konsultasi);
    
    INSERT INTO Log (aksi, tabel, waktu, deskripsi)
    VALUES ('INSERT', 'Konsultasi_Laboratorium', NOW(), CONCAT('Menambahkan laboratorium pada konsultasi ID: ', NEW.id_konsultasi));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Konsultasi_Produk`
--

CREATE TABLE `Konsultasi_Produk` (
  `id_produk` int(11) DEFAULT NULL,
  `id_konsultasi` int(11) DEFAULT NULL,
  `jumlah` int(11) NOT NULL,
  `catatan` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Konsultasi_Produk`
--

INSERT INTO `Konsultasi_Produk` (`id_produk`, `id_konsultasi`, `jumlah`, `catatan`) VALUES
(27, 1, 1, '3x1'),
(29, 5, 2, 'Gunakan plester luka sesuai instruksi'),
(34, 5, 1, NULL),
(35, 7, 1, NULL),
(38, 8, 1, NULL),
(39, 10, 1, NULL),
(33, 11, 1, '2 x 1');

--
-- Triggers `Konsultasi_Produk`
--
DELIMITER $$
CREATE TRIGGER `after_konsultasi_produk_insert` AFTER INSERT ON `Konsultasi_Produk` FOR EACH ROW BEGIN
    CALL hitungTotalBiaya(NEW.id_konsultasi);
    
    UPDATE Produk
    SET stok = stok - NEW.jumlah
    WHERE id_produk = NEW.id_produk;
    
    INSERT INTO Log (aksi, tabel, waktu, deskripsi)
    VALUES ('INSERT', 'Konsultasi_Produk', NOW(), CONCAT('Menambahkan produk pada konsultasi ID: ', NEW.id_konsultasi, '. Jumlah : ', NEW.jumlah));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Konsultasi_Treatment`
--

CREATE TABLE `Konsultasi_Treatment` (
  `id_treatment` int(11) DEFAULT NULL,
  `id_konsultasi` int(11) DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `tanggal` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Konsultasi_Treatment`
--

INSERT INTO `Konsultasi_Treatment` (`id_treatment`, `id_konsultasi`, `catatan`, `tanggal`) VALUES
(1, 1, 'Lakukan pemeriksaan fisik lengkap', '2024-06-01 10:30:00'),
(5, 2, 'Lakukan imunisasi anak sesuai jadwal', '2024-06-02 10:30:00'),
(3, 3, 'Lakukan pemeriksaan tumbuh kembang anak', '2024-06-03 09:30:00'),
(4, 4, 'Lakukan pengobatan hipertensi sesuai rekomendasi dokter', '2024-06-04 13:30:00'),
(6, 5, 'Lakukan terapi jerawat secara berkala', '2024-06-05 16:00:00'),
(8, 8, 'Lakukan pengobatan infeksi telinga sesuai resep dokter', '2024-06-08 12:30:00'),
(9, 9, 'Lakukan terapi sinusitis sesuai anjuran dokter', '2024-06-09 15:30:00'),
(10, 10, 'Lakukan evaluasi risiko penyakit jantung secara menyeluruh', '2024-06-10 11:30:00'),
(1, 11, NULL, '2024-06-26 12:55:49');

--
-- Triggers `Konsultasi_Treatment`
--
DELIMITER $$
CREATE TRIGGER `after_konsultasi_treatment_insert` AFTER INSERT ON `Konsultasi_Treatment` FOR EACH ROW BEGIN
    CALL hitungTotalBiaya(NEW.id_konsultasi);
    
    INSERT INTO Log (aksi, tabel, waktu, deskripsi)
    VALUES ('INSERT', 'Konsultasi_Treatment', NOW(), CONCAT('Menambahkan treatment pada konsultasi ID: ', NEW.id_konsultasi));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Laboratorium`
--

CREATE TABLE `Laboratorium` (
  `id_laboratorium` int(11) NOT NULL,
  `jenis` varchar(100) NOT NULL,
  `harga` decimal(16,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Laboratorium`
--

INSERT INTO `Laboratorium` (`id_laboratorium`, `jenis`, `harga`) VALUES
(1, 'Tes Darah Lengkap', 500000.00),
(2, 'Urinalisis', 100000.00),
(3, 'Tes Serologi', 200000.00),
(4, 'Pemeriksaan Kultur', 300000.00),
(5, 'Patologi Anatomi', 400000.00),
(6, 'Tes Darah Lengkap', 150000.00),
(7, 'Tes Urin', 100000.00),
(8, 'Tes Gula Darah', 75000.00),
(9, 'Tes Kolesterol', 85000.00),
(10, 'Tes Asam Urat', 80000.00),
(11, 'Tes Fungsi Hati', 200000.00),
(12, 'Tes Fungsi Ginjal', 180000.00),
(13, 'Tes HIV', 250000.00),
(14, 'Tes Kehamilan', 50000.00),
(15, 'Tes Hemoglobin', 70000.00);

--
-- Triggers `Laboratorium`
--
DELIMITER $$
CREATE TRIGGER `before_laboratorium_insert` BEFORE INSERT ON `Laboratorium` FOR EACH ROW BEGIN
	DECLARE exist INT;
    
    SELECT COUNT(*) INTO exist
    FROM Laboratorium
    WHERE jenis = NEW.jenis;

	IF exist > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Laboratorium sudah ada';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Log`
--

CREATE TABLE `Log` (
  `id_log` int(11) NOT NULL,
  `aksi` varchar(10) DEFAULT NULL,
  `tabel` varchar(50) DEFAULT NULL,
  `waktu` datetime DEFAULT NULL,
  `deskripsi` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Log`
--

INSERT INTO `Log` (`id_log`, `aksi`, `tabel`, `waktu`, `deskripsi`) VALUES
(1, 'INSERT', 'Konsultasi', '2024-06-26 17:50:27', 'Konsultasi ID: 11'),
(2, 'UPDATE', 'Konsultasi', '2024-06-26 17:51:53', 'Konsultasi ID: 11'),
(3, 'INSERT', 'Konsultasi_Laboratorium', '2024-06-26 17:51:53', 'Menambahkan laboratorium pada konsultasi ID: 11'),
(4, 'UPDATE', 'Konsultasi', '2024-06-26 17:52:31', 'Konsultasi ID: 11'),
(5, 'INSERT', 'Konsultasi_Laboratorium', '2024-06-26 17:52:31', 'Menambahkan laboratorium pada konsultasi ID: 11'),
(7, 'UPDATE', 'Konsultasi', '2024-06-26 17:53:58', 'Konsultasi ID: 11'),
(8, 'INSERT', 'Konsultasi_Produk', '2024-06-26 17:53:58', 'Menambahkan produk pada konsultasi ID: 11. Jumlah : 1'),
(9, 'UPDATE', 'Konsultasi', '2024-06-26 17:56:07', 'Konsultasi ID: 11'),
(10, 'INSERT', 'Konsultasi_Treatment', '2024-06-26 17:56:07', 'Menambahkan treatment pada konsultasi ID: 11'),
(11, 'UPDATE', 'Konsultasi', '2024-07-02 20:10:57', 'Konsultasi ID: 5');

-- --------------------------------------------------------

--
-- Table structure for table `Pasien`
--

CREATE TABLE `Pasien` (
  `id_pasien` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `tanggal_lahir` date NOT NULL,
  `jenkel` enum('P','L') NOT NULL,
  `telepon` varchar(20) DEFAULT NULL,
  `alamat` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Pasien`
--

INSERT INTO `Pasien` (`id_pasien`, `nama`, `tanggal_lahir`, `jenkel`, `telepon`, `alamat`) VALUES
(1, 'Ahmad Supriyadi', '1985-04-12', 'L', '081234567890', 'Jl. Merdeka No. 123, Jakarta'),
(2, 'Siti Aminah', '1990-07-25', 'P', '081345678901', 'Jl. Sudirman No. 45, Bandung'),
(3, 'Budi Santoso', '1978-09-30', 'L', '081456789012', 'Jl. Gatot Subroto No. 67, Surabaya'),
(4, 'Rina Marlina', '1982-12-05', 'P', '081567890123', 'Jl. Diponegoro No. 89, Yogyakarta'),
(5, 'Taufik Hidayat', '1995-03-15', 'L', '081678901234', 'Jl. Ahmad Yani No. 101, Semarang'),
(6, 'Dewi Sartika', '1988-01-20', 'P', '081789012345', 'Jl. RA Kartini No. 11, Medan'),
(7, 'Hendro Wibowo', '1975-06-10', 'L', '081890123456', 'Jl. Pahlawan No. 13, Palembang'),
(8, 'Maya Sari', '1992-11-25', 'P', '081901234567', 'Jl. MH Thamrin No. 24, Malang'),
(9, 'Andi Prasetyo', '1983-08-30', 'L', '082012345678', 'Jl. Sisingamangaraja No. 56, Makassar'),
(10, 'Nurul Huda', '1991-05-14', 'P', '082123456789', 'Jl. Kebon Jeruk No. 78, Bali'),
(11, 'Rahmat Hidayat', '1986-03-23', 'L', '082234567890', 'Jl. Pemuda No. 90, Lampung'),
(12, 'Sri Wahyuni', '1989-09-12', 'P', '082345678901', 'Jl. Juanda No. 101, Bogor'),
(13, 'Eka Saputra', '1993-12-03', 'L', '082456789012', 'Jl. HOS Cokroaminoto No. 45, Padang'),
(14, 'Lina Marlina', '1984-11-15', 'P', '082567890123', 'Jl. Sutomo No. 67, Pontianak'),
(15, 'Yusuf Maulana', '1979-07-20', 'L', '082678901234', 'Jl. Adi Sucipto No. 89, Balikpapan'),
(16, 'Agus Setiawan', '2020-03-21', 'L', '082789012345', 'Jl. Merdeka No. 123, Jakarta'),
(17, 'Sari Indah', '2019-07-10', 'P', '082890123456', 'Jl. Sudirman No. 45, Bandung'),
(18, 'Rama Wijaya', '2021-01-18', 'L', '082901234567', 'Jl. Gatot Subroto No. 67, Surabaya'),
(19, 'Dewi Anggraini', '2020-11-05', 'P', '082012345678', 'Jl. Diponegoro No. 89, Yogyakarta'),
(20, 'Hana Pratiwi', '2019-09-22', 'P', '082123456789', 'Jl. Ahmad Yani No. 101, Semarang'),
(21, 'Rizki Pratama', '2007-04-10', 'L', '082234567890', 'Jl. RA Kartini No. 11, Medan'),
(22, 'Putri Aulia', '2008-06-15', 'P', '082345678901', 'Jl. Pahlawan No. 13, Palembang'),
(23, 'Fajar Nugroho', '2006-08-19', 'L', '082456789012', 'Jl. MH Thamrin No. 24, Malang'),
(24, 'Salsabila Nabila', '2009-02-28', 'P', '082567890123', 'Jl. Sisingamangaraja No. 56, Makassar'),
(25, 'Farhan Akbar', '2008-10-25', 'L', '082678901234', 'Jl. Kebon Jeruk No. 78, Bali');

-- --------------------------------------------------------

--
-- Table structure for table `Produk`
--

CREATE TABLE `Produk` (
  `id_produk` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `jenis` enum('Obat','Alat Medis','Bahan Habis Pakai','Suplemen','Lainnya') NOT NULL,
  `satuan` varchar(100) NOT NULL,
  `harga_satuan` decimal(16,2) DEFAULT NULL,
  `harga_beli` decimal(16,2) NOT NULL,
  `tanggal_beli` date NOT NULL,
  `masa_berlaku` date DEFAULT NULL,
  `stok` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Produk`
--

INSERT INTO `Produk` (`id_produk`, `nama`, `deskripsi`, `jenis`, `satuan`, `harga_satuan`, `harga_beli`, `tanggal_beli`, `masa_berlaku`, `stok`) VALUES
(27, 'Obat Ibuprofen 200 mg', 'Obat pereda nyeri dan inflamasi', 'Obat', 'Tablet', 7000.00, 5000.00, '2024-06-12', '2026-06-12', 100),
(28, 'Obat Loratadine 10 mg', 'Antihistamin untuk alergi', 'Obat', 'Tablet', 8000.00, 6000.00, '2024-06-12', '2025-12-12', 50),
(29, 'Plester Luka', 'Untuk menutup luka kecil', 'Alat Medis', 'Kotak', 5000.00, 4000.00, '2024-06-13', '2025-06-13', 200),
(30, 'Alkohol 70%', 'Untuk desinfeksi', 'Alat Medis', 'Botol', 20000.00, 15000.00, '2024-06-13', '2026-06-13', 80),
(31, 'Masker Medis', 'Masker sekali pakai', 'Alat Medis', 'Kotak', 50000.00, 40000.00, '2024-06-14', '2025-12-14', 300),
(32, 'Obat Cetirizine 10 mg', 'Antihistamin untuk alergi', 'Obat', 'Tablet', 6000.00, 5000.00, '2024-06-10', '2024-05-10', 0),
(33, 'Vitamin C 500 mg', 'Suplemen untuk meningkatkan daya tahan tubuh', 'Suplemen', 'Tablet', 10000.00, 8000.00, '2024-06-09', '2024-06-01', 10),
(34, 'Kasa Steril', 'Untuk menutup luka', 'Alat Medis', 'Kantong', 8000.00, 6000.00, '2024-06-08', '2024-05-31', 0),
(35, 'Termometer Digital', 'Untuk mengukur suhu tubuh', 'Alat Medis', 'Unit', 50000.00, 40000.00, '2024-06-14', NULL, 150),
(36, 'Salep Betamethasone', 'Obat untuk mengatasi inflamasi kulit', 'Obat', 'Tube', 20000.00, 15000.00, '2024-06-15', NULL, 120),
(37, 'Obat Asam Mefenamat 500 mg', 'Obat pereda nyeri', 'Obat', 'Tablet', 9000.00, 7000.00, '2024-06-15', '2025-12-15', 100),
(38, 'Glukometer', 'Untuk mengukur kadar gula darah', 'Alat Medis', 'Unit', 300000.00, 250000.00, '2024-06-16', '2026-06-16', 30),
(39, 'Antiseptik Cair', 'Untuk membersihkan luka', 'Alat Medis', 'Botol', 15000.00, 12000.00, '2024-06-16', '2025-06-16', 90),
(40, 'Paracetamol', 'Meredakan demam dan nyeri', 'Obat', 'Kaplet', 9600.00, 8000.00, '2024-06-26', '2024-11-26', 34);

--
-- Triggers `Produk`
--
DELIMITER $$
CREATE TRIGGER `before_produk_insert` BEFORE INSERT ON `Produk` FOR EACH ROW BEGIN
	DECLARE exist INT;
    
    SELECT COUNT(*) INTO exist
    FROM Produk
    WHERE nama = NEW.nama;

	IF exist > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produk sudah ada';
   	ELSE
    	SET NEW.harga_satuan = hitungHargaJual(NEW.harga_beli);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_produk_update` BEFORE UPDATE ON `Produk` FOR EACH ROW BEGIN
    IF NEW.stok < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stok tidak boleh negatif';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Shift`
--

CREATE TABLE `Shift` (
  `id_shift` int(11) NOT NULL,
  `hari` enum('senin','selasa','rabu','kamis','jumat','sabtu','minggu') NOT NULL,
  `jam` enum('00:00-08:00','08:00-16:00','16:00-00:00') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Shift`
--

INSERT INTO `Shift` (`id_shift`, `hari`, `jam`) VALUES
(1, 'senin', '00:00-08:00'),
(2, 'senin', '08:00-16:00'),
(3, 'senin', '16:00-00:00'),
(4, 'selasa', '00:00-08:00'),
(5, 'selasa', '08:00-16:00'),
(6, 'selasa', '16:00-00:00'),
(7, 'rabu', '00:00-08:00'),
(8, 'rabu', '08:00-16:00'),
(9, 'rabu', '16:00-00:00'),
(10, 'kamis', '00:00-08:00'),
(11, 'kamis', '08:00-16:00'),
(12, 'kamis', '16:00-00:00'),
(13, 'jumat', '00:00-08:00'),
(14, 'jumat', '08:00-16:00'),
(15, 'jumat', '16:00-00:00'),
(16, 'sabtu', '00:00-08:00'),
(17, 'sabtu', '08:00-16:00'),
(18, 'sabtu', '16:00-00:00'),
(19, 'minggu', '00:00-08:00'),
(20, 'minggu', '08:00-16:00'),
(21, 'minggu', '16:00-00:00');

-- --------------------------------------------------------

--
-- Table structure for table `Shift_Dokter`
--

CREATE TABLE `Shift_Dokter` (
  `id_dokter` int(11) NOT NULL,
  `id_shift` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Shift_Dokter`
--

INSERT INTO `Shift_Dokter` (`id_dokter`, `id_shift`) VALUES
(1, 1),
(2, 1),
(11, 2),
(4, 2),
(12, 3),
(6, 3),
(7, 4),
(11, 4),
(1, 5),
(10, 5),
(5, 6),
(12, 6),
(1, 7),
(4, 7),
(5, 8),
(12, 8),
(7, 9),
(11, 9),
(12, 10),
(10, 10),
(1, 11),
(2, 11),
(11, 12),
(4, 12),
(1, 13),
(6, 13),
(7, 14),
(12, 14),
(11, 15),
(10, 15),
(1, 16),
(2, 16),
(3, 17),
(11, 17),
(12, 18),
(6, 18),
(7, 19),
(1, 19),
(9, 20),
(12, 20),
(11, 21),
(8, 21);

-- --------------------------------------------------------

--
-- Table structure for table `Treatment`
--

CREATE TABLE `Treatment` (
  `id_treatment` int(11) NOT NULL,
  `jenis` varchar(100) NOT NULL,
  `harga` decimal(16,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `Treatment`
--

INSERT INTO `Treatment` (`id_treatment`, `jenis`, `harga`) VALUES
(1, 'Pemeriksaan Fisik', 100000.00),
(2, 'Imunisasi Anak', 200000.00),
(3, 'Pemeriksaan Tumbuh Kembang Anak', 100000.00),
(4, 'Pengobatan Hipertensi', 250000.00),
(5, 'Terapi Jerawat', 210000.00),
(6, 'Pengobatan Eksim', 240000.00),
(7, 'Pemeriksaan Mata', 100000.00),
(8, 'Pengobatan Infeksi Telinga', 150000.00),
(9, 'Terapi Sinusitis', 170000.00),
(10, 'Evaluasi Risiko Penyakit Jantung', 380000.00),
(11, 'Penanganan Sakit Kepala dan Migrain', 150000.00),
(12, 'Penjahitan Luka', 200000.00),
(13, 'Pembersihan Gigi', 300000.00),
(14, 'Penambalan Gigi', 100000.00),
(15, 'Pengobatan Infeksi Saluran Pernapasan', 150000.00);

--
-- Triggers `Treatment`
--
DELIMITER $$
CREATE TRIGGER `before_treatment_insert` BEFORE INSERT ON `Treatment` FOR EACH ROW BEGIN
	DECLARE exist INT;
    
    SELECT COUNT(*) INTO exist
    FROM Treatment
    WHERE jenis = NEW.jenis;

	IF exist > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Treatment sudah ada';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_detail_konsultasi`
-- (See below for the actual view)
--
CREATE TABLE `v_detail_konsultasi` (
`id_konsultasi` int(11)
,`masalah` varchar(255)
,`tanggal_konsultasi` datetime
,`tanggal_pembayaran` datetime
,`metode_pembayaran` enum('CASH','DEBIT','QRIS')
,`status_pembayaran` enum('LUNAS','BELUM LUNAS')
,`id_dokter` int(11)
,`id_pasien` int(11)
,`nama_pasien` varchar(100)
,`nama_dokter` varchar(100)
,`total_biaya_lab` decimal(38,2)
,`total_biaya_produk` decimal(48,2)
,`total_biaya_treatment` decimal(38,2)
,`total_biaya_treatment_full` decimal(49,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_detail_treatment`
-- (See below for the actual view)
--
CREATE TABLE `v_detail_treatment` (
`id_konsultasi` int(11)
,`masalah` varchar(255)
,`tanggal_konsultasi` datetime
,`treatment` varchar(100)
,`harga` decimal(16,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_dokter_shift`
-- (See below for the actual view)
--
CREATE TABLE `v_dokter_shift` (
`id_dokter` int(11)
,`nama` varchar(100)
,`spesialis` varchar(100)
,`shift` varchar(18)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_konsultasi_belum_lunas`
-- (See below for the actual view)
--
CREATE TABLE `v_konsultasi_belum_lunas` (
`id_konsultasi` int(11)
,`masalah` varchar(255)
,`tanggal_konsultasi` datetime
,`dokter` varchar(100)
,`pasien` varchar(100)
);

-- --------------------------------------------------------

--
-- Structure for view `v_detail_konsultasi`
--
DROP TABLE IF EXISTS `v_detail_konsultasi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_detail_konsultasi`  AS SELECT `k`.`id_konsultasi` AS `id_konsultasi`, `k`.`masalah` AS `masalah`, `k`.`tanggal_konsultasi` AS `tanggal_konsultasi`, `k`.`tanggal_pembayaran` AS `tanggal_pembayaran`, `k`.`metode_pembayaran` AS `metode_pembayaran`, `k`.`status_pembayaran` AS `status_pembayaran`, `k`.`id_dokter` AS `id_dokter`, `k`.`id_pasien` AS `id_pasien`, `p`.`nama` AS `nama_pasien`, `d`.`nama` AS `nama_dokter`, sum(`l`.`harga`) AS `total_biaya_lab`, coalesce(sum(`pr`.`harga_satuan` * `kp`.`jumlah`),0) AS `total_biaya_produk`, coalesce(sum(`t`.`harga`),0) AS `total_biaya_treatment`, coalesce(sum(`t`.`harga`),0) + coalesce(sum(`l`.`harga`),0) + coalesce(sum(`pr`.`harga_satuan` * `kp`.`jumlah`),0) AS `total_biaya_treatment_full` FROM ((((((((`konsultasi` `k` join `pasien` `p` on(`k`.`id_pasien` = `p`.`id_pasien`)) join `dokter` `d` on(`k`.`id_dokter` = `d`.`id_dokter`)) left join `konsultasi_laboratorium` `kl` on(`k`.`id_konsultasi` = `kl`.`id_konsultasi`)) left join `laboratorium` `l` on(`kl`.`id_laboratorium` = `l`.`id_laboratorium`)) left join `konsultasi_produk` `kp` on(`k`.`id_konsultasi` = `kp`.`id_konsultasi`)) left join `produk` `pr` on(`kp`.`id_produk` = `pr`.`id_produk`)) left join `konsultasi_treatment` `kt` on(`k`.`id_konsultasi` = `kt`.`id_konsultasi`)) left join `treatment` `t` on(`kt`.`id_treatment` = `t`.`id_treatment`)) GROUP BY `k`.`id_konsultasi` ;

-- --------------------------------------------------------

--
-- Structure for view `v_detail_treatment`
--
DROP TABLE IF EXISTS `v_detail_treatment`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_detail_treatment`  AS SELECT `k`.`id_konsultasi` AS `id_konsultasi`, `k`.`masalah` AS `masalah`, `k`.`tanggal_konsultasi` AS `tanggal_konsultasi`, `t`.`jenis` AS `treatment`, `t`.`harga` AS `harga` FROM ((`konsultasi` `k` join `konsultasi_treatment` `kt` on(`k`.`id_konsultasi` = `kt`.`id_konsultasi`)) join `treatment` `t` on(`kt`.`id_treatment` = `t`.`id_treatment`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_dokter_shift`
--
DROP TABLE IF EXISTS `v_dokter_shift`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_dokter_shift`  AS SELECT `d`.`id_dokter` AS `id_dokter`, `d`.`nama` AS `nama`, `d`.`spesialis` AS `spesialis`, concat(`s`.`hari`,' ',`s`.`jam`) AS `shift` FROM (`dokter` `d` left join `shift` `s` on(`d`.`id_dokter` = `s`.`id_shift`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_konsultasi_belum_lunas`
--
DROP TABLE IF EXISTS `v_konsultasi_belum_lunas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_konsultasi_belum_lunas`  AS SELECT `k`.`id_konsultasi` AS `id_konsultasi`, `k`.`masalah` AS `masalah`, `k`.`tanggal_konsultasi` AS `tanggal_konsultasi`, `d`.`nama` AS `dokter`, `p`.`nama` AS `pasien` FROM ((`konsultasi` `k` join `dokter` `d` on(`k`.`id_dokter` = `d`.`id_dokter`)) join `pasien` `p` on(`k`.`id_pasien` = `p`.`id_pasien`)) WHERE `k`.`status_pembayaran` = 'BELUM LUNAS' ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Dokter`
--
ALTER TABLE `Dokter`
  ADD PRIMARY KEY (`id_dokter`);

--
-- Indexes for table `Konsultasi`
--
ALTER TABLE `Konsultasi`
  ADD PRIMARY KEY (`id_konsultasi`) USING BTREE;

--
-- Indexes for table `Laboratorium`
--
ALTER TABLE `Laboratorium`
  ADD PRIMARY KEY (`id_laboratorium`);

--
-- Indexes for table `Log`
--
ALTER TABLE `Log`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `Pasien`
--
ALTER TABLE `Pasien`
  ADD PRIMARY KEY (`id_pasien`);

--
-- Indexes for table `Produk`
--
ALTER TABLE `Produk`
  ADD PRIMARY KEY (`id_produk`);

--
-- Indexes for table `Shift`
--
ALTER TABLE `Shift`
  ADD PRIMARY KEY (`id_shift`);

--
-- Indexes for table `Treatment`
--
ALTER TABLE `Treatment`
  ADD PRIMARY KEY (`id_treatment`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Konsultasi`
--
ALTER TABLE `Konsultasi`
  MODIFY `id_konsultasi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `Laboratorium`
--
ALTER TABLE `Laboratorium`
  MODIFY `id_laboratorium` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `Log`
--
ALTER TABLE `Log`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `Pasien`
--
ALTER TABLE `Pasien`
  MODIFY `id_pasien` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `Produk`
--
ALTER TABLE `Produk`
  MODIFY `id_produk` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `Shift`
--
ALTER TABLE `Shift`
  MODIFY `id_shift` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `Treatment`
--
ALTER TABLE `Treatment`
  MODIFY `id_treatment` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
