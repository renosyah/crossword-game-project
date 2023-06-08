-- MariaDB dump 10.19  Distrib 10.10.2-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: tts_db
-- ------------------------------------------------------
-- Server version	10.10.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `rank_table`
--

DROP TABLE IF EXISTS `rank_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rank_table` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` text DEFAULT NULL,
  `player_name` text DEFAULT NULL,
  `player_avatar` text DEFAULT NULL,
  `player_email` text DEFAULT NULL,
  `rank_level` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rank_table`
--

LOCK TABLES `rank_table` WRITE;
/*!40000 ALTER TABLE `rank_table` DISABLE KEYS */;
INSERT INTO `rank_table` VALUES
(1,'1','Renosyah 1','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',69),
(2,'2','Renosyah 2','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',64),
(3,'3','Renosyah 3','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',72),
(4,'4','Renosyah 4','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',12),
(5,'5','Renosyah 5','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',18),
(6,'6','Renosyah 6','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',22),
(7,'7','Renosyah 7','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',24),
(8,'8','Renosyah 8','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',11),
(9,'9','Renosyah 9','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',44),
(10,'10','Renosyah 10','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',61),
(11,'11','Renosyah 11','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',43),
(12,'12','Renosyah 12','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',44),
(13,'13','Renosyah 13','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',42),
(14,'14','Renosyah 14','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',49),
(15,'15','Renosyah 15','https://lh3.googleusercontent.com/a/AAcHTteOdz1U8TR4M3oUPh4yvT-9sKsu2YNj5WfSQMn1=s96-c','renosyahdev@gmail.com',33),
/*!40000 ALTER TABLE `rank_table` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-06-08 14:08:22
