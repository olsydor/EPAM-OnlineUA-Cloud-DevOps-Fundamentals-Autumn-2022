-- MySQL dump 10.13  Distrib 5.7.36, for Linux (x86_64)
--
-- Host: localhost    Database: VEHICLE
-- ------------------------------------------------------
-- Server version	5.7.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `COLOR`
--

DROP TABLE IF EXISTS `COLOR`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `COLOR` (
  `color_id` int(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `code` int(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COLOR`
--

LOCK TABLES `COLOR` WRITE;
/*!40000 ALTER TABLE `COLOR` DISABLE KEYS */;
INSERT INTO `COLOR` VALUES (1,'black',11),(2,'white',22),(3,'grey',33);
/*!40000 ALTER TABLE `COLOR` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MAKE`
--

DROP TABLE IF EXISTS `MAKE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MAKE` (
  `make_id` int(50) DEFAULT NULL,
  `make_name` varchar(50) DEFAULT NULL,
  `country` tinytext
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MAKE`
--

LOCK TABLES `MAKE` WRITE;
/*!40000 ALTER TABLE `MAKE` DISABLE KEYS */;
/*!40000 ALTER TABLE `MAKE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MODEL`
--

DROP TABLE IF EXISTS `MODEL`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MODEL` (
  `model_id` int(50) DEFAULT NULL,
  `model_name` varchar(50) DEFAULT NULL,
  `first_prod_year` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MODEL`
--

LOCK TABLES `MODEL` WRITE;
/*!40000 ALTER TABLE `MODEL` DISABLE KEYS */;
INSERT INTO `MODEL` VALUES (23,'Compass',2014),(24,'Renegade',2015),(25,'Cheroke',2016),(23,'Compass',2014),(24,'Renegade',2015),(25,'Cheroke',2016),(26,'Grand Cherokee',2018);
/*!40000 ALTER TABLE `MODEL` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `VEHICLE`
--

DROP TABLE IF EXISTS `VEHICLE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `VEHICLE` (
  `vehicle_id` int(50) DEFAULT NULL,
  `make_id` int(50) DEFAULT NULL,
  `model_id` int(50) DEFAULT NULL,
  `year` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `VEHICLE`
--

LOCK TABLES `VEHICLE` WRITE;
/*!40000 ALTER TABLE `VEHICLE` DISABLE KEYS */;
INSERT INTO `VEHICLE` VALUES (1,15,23,2016),(2,16,24,2017),(3,17,25,2018);
/*!40000 ALTER TABLE `VEHICLE` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-12-14 22:50:57
