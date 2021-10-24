-- --------------------------------------------------------
-- Host:                         bootcamp-tht.sre.wize.mx
-- Server version:               8.0.20 - Source distribution
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for bootcamp_tht
DROP DATABASE IF EXISTS `bootcamp_tht`;
CREATE DATABASE IF NOT EXISTS `bootcamp_tht`;
USE `bootcamp_tht`;

-- Dumping structure for table bootcamp_tht.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `username` varchar(20) NOT NULL,
  `password` varchar(200) DEFAULT NULL,
  `salt` varchar(20) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table bootcamp_tht.users: ~3 rows (approximately)
DELETE FROM `users`;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`username`, `password`, `salt`, `role`) VALUES
	('admin', '15e24a16abfc4eef5faeb806e903f78b188c30e4984a03be4c243312f198d1229ae8759e98993464cf713e3683e891fb3f04fbda9cc40f20a07a58ff4bb00788', 'F^S%QljSfV', 'admin'),
	('bob', '2c9dab627bd73b6c4be5612ff77f18fa69fa7c2a71ecedb45dcec45311bea736e320462c6e8bfb2421ed112cfe54fac3eb9ff464f3904fe7cc915396b3df36f0', 'F^S%QljSfV', 'viewer'),
	('noadmin', '89155af89e8a34dcbde088c72c3f001ac53486fcdb3946b1ed3fde8744ac397d99bf6f44e005af6f6944a1f7ed6bd0e2dd09b8ea3bcfd3e8862878d1709712e5', 'KjvFUC#K*i', 'editor'),
	('antonio', 'f3e9abade494fcb01bd207abc89dab2eb0ce2d83aae57a234a05190b06a677c6a22885e0069414285e52983e1f3d212308a8496ef37c6673328dbf6317ff2814', 'ew.qCjqXA/Hw', 'viewer');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
