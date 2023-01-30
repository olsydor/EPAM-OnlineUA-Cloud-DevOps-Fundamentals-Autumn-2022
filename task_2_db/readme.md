## [Task2 Data Base Administration](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/tree/master/m4/task4.1#readme) 

### PART 1

1. I installed MySQL server on VM
```
sudo apt install mysql-server

set security options

sudo mysql_secure_installation

sudo mysql

SELECT user,authentication_string,plugin,host FROM mysql.user;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```
![Installed MySQL on VM](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_1.jpg)
```
FLUSH PRIVILEGES;

CREATE USER 'olsydor'@'localhost' IDENTIFIED BY '12345678';

GRANT ALL PRIVILEGES ON *.* TO 'olsydor'@'localhost' WITH GRANT OPTION;
```

Test our MySQL instalation

```
systemctl status mysql.service
```
```
   ● mysql.service - MySQL Community Server
      Loaded: loaded (/lib/systemd/system/mysql.service; enabled; vendor preset: en
      Active: active (running) since Wed 2018-04-23 21:21:25 UTC; 30min ago
   Main PID: 3754 (mysqld)
      Tasks: 28
      Memory: 142.3M
         CPU: 1.994s
      CGroup: /system.slice/mysql.service
            └─3754 /usr/sbin/mysqld
```

4. I create DB
```
CREATE DATABASE Vehicle;

and create the tables

CREATE TABLE VEHICLE (vehicle_id INT(50), make_id INT(50), model_id INT(50), year YEAR);

CREATE TABLE MODEL (model_id INT(50), model_name VARCHAR(50), first_prod_year YEAR);

CREATE TABLE MAKE (make_id INT(50), make_name  VARCHAR(50), country INT(50));

CREATE TABLE COLOR (color_id INT(50), name VARCHAR(50), code INT(50));
```
![Tables](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_3.jpg)


5. I fill in tables
```
INSERT INTO VEHICLE (vehicle_id, make_id, model_id, year)
VALUES 
(1,15,23,2016), 
(2,16,24,2017), 
(3,17,25,2018);

INSERT INTO MODEL (model_id, model_name, first_prod_year) VALUES ('23','Compass','2014'), ('24','Renegade','2015'), ('25','Cheroke','2016');
```

I mistake and must Modify column datatype 

```
ALTER TABLE MAKE MODIFY COLUMN country tinytext;

INSERT INTO MAKE (make_id, make_name, country)
VALUES (1,'MexicoDEPT','Mexico'), (2,'OhioDept','USA'), (3,'DetroitDEPT','USA');

INSERT INTO COLOR (color_id, name, code) VALUES 
('1','black','11'), 
('2','white','22'), 
('3','grey','33');
```

6. I construct and execute  
```
SELECT operator with WHERE, GROUP BY and ORDER BY.
```
![SELECT](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_6.jpg)
```
SELECT model_id, model_name, first_prod_year FROM MODEL;

SELECT * FROM MAKE WHERE MAKE_ID = 1;
```
![WHERE](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_6_1.jpg)
```
SELECT * FROM MAKE ORDER BY country;

SELECT COUNT(make_id), Country FROM MAKE GROUP BY Country ORDER BY COUNT(make_id) DESC;
```

7. I Execute another DDL DML, DCL, SQL queries.
```
DDL
GRANT
GRANT SELECT, INSERT, UPDATE, DELETE ON MAKE TO olsydor;

REVOKE
REVOKE DELETE ON MAKE FROM olsydor;


DML
BEGIN TRANSACTION
CREATE TABLE TESTTABLE (id INT);  
BEGIN TRANSACTION;  
       INSERT INTO TESTTABLE TEST1(1);  
       INSERT INTO TESTTABLE TEST2(2);  
ROLLBACK;

TCL
BEGIN TRANSACTION;   
DELETE FROM MAKE  
    WHERE make_id = 3;   
COMMIT TRANSACTION;  
```

8. Create DB user with different privileges
```
CREATE USER 'olsydor_insert'@'localhost' IDENTIFIED BY '12345678';
```

I allow this user INSERT rights to table  VEHICLE.MODEL
```
GRANT INSERT ON VEHICLE.MODEL TO 'olsydor_insert'@'localhost';

INSERT INTO MODEL (model_id, model_name, first_prod_year) VALUES ('26','Grand Cherokee','2018');
```
![new_user](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_8.jpg)


9.  If i switch to main MySQL DB "mysql" with "olsydor_insert" user. I see the  error message 
```
"ERROR 1044 (42000): Access denied for user 'olsydor_insert'@'localhost' to database 'mysql'"
```
... and i don't make the SELECT request to any tables fron this DB

### PART 2

10.  Сreate  VEHICLE DB backup
```
mysql> SELECT user, host FROM mysql.user;

mysql> drop user 'backup'@'localhost';

CREATE USER 'backup'@'localhost' IDENTIFIED BY '12345678';
GRANT SELECT, LOCK TABLES, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup'@'localhost';
```
![WHERE](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_p2_10.jpg)
```
mkdir /mysqlbackup
sudo chown -R mysql:mysql mysqlbackup

mysql> exit

sudo -s
mysqldump --user=backup -p --no-tablespaces VEHICLE > /mysqlbackup/VEHICLE.sql
```
upload dump from mysql server with "transfer.sh" curl -i -F filedata=@VEHICLE.sql https://transfer.sh/ https://transfer.sh/9GMdDV/VEHICLE.sql  It's unsecure but fast and easy

11. 
```
drop database VEHICLE;

create database VEHICLE;
use VEHICLE;
source home/olsydor/mysqlbackup/VEHICLE.sql
```

13. I restore my local DB to RDS AWS 
14. And connect to DB hosted on RDS
15. Execute select operator

![WHERE](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_p2_15.jpg)

16. Create the dump RDS AWS DB

![WHERE](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_p2_16.jpg)

### PART 3

I create an Amazom DynamoDB table enter data to DB and query data from DB with scan and Query functions.

![WHERE](https://github.com/olsydor/DevOps_online_Ivano-Frankivsk_2021Q4/blob/master/m4/task4.1/prntscr/task4.1_p3_19.jpg)




Source my DB for example 
```
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
```