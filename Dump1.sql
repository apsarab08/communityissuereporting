CREATE DATABASE  IF NOT EXISTS `communityissuereporting` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `communityissuereporting`;
-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: localhost    Database: communityissuereporting
-- ------------------------------------------------------
-- Server version	8.0.38

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Road Maintenance'),(2,'Street Lighting'),(3,'Waste Management'),(4,'Water Supply'),(5,'Public Safety'),(6,'Parks and Recreation'),(7,'Education'),(8,'Healthcare'),(17,'Road Maintenance'),(18,'Street Lighting'),(19,'Waste Management'),(20,'Water Supply'),(21,'Public Safety'),(22,'Parks and Recreation'),(23,'Education'),(24,'Healthcare');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `problem_id` int NOT NULL,
  `user_id` int NOT NULL,
  `comment_text` text NOT NULL,
  `comment_date` datetime NOT NULL,
  PRIMARY KEY (`comment_id`),
  KEY `problem_id` (`problem_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`problem_id`) REFERENCES `problems` (`problem_id`),
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` VALUES (10,6,4,'please clear waste soon','2024-07-16 21:09:41'),(11,7,6,'yeah soon please solve the issue','2024-07-16 22:03:04'),(12,6,6,'yes soon ','2024-07-16 22:03:29'),(13,7,4,'we are not able to walk .please solve the issue','2024-07-16 22:05:39'),(14,8,4,'yes please take this issue into consideration and work properly','2024-07-16 22:06:35'),(18,9,3,'we will clear it sooon\r\n','2024-07-18 17:45:21'),(19,8,3,'we will clear soon','2024-07-18 18:00:39'),(21,9,10,'we will solve soon','2024-07-21 19:36:15'),(32,9,14,'pls solve soon we are  not able to come to park recently\r\n','2024-08-05 20:10:05'),(35,23,22,'please make it as soon as possible','2024-08-07 15:19:25'),(40,29,36,'pleasse','2024-08-11 20:02:35'),(41,9,3,'please solve','2024-09-03 17:09:46');
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `issue_id` int NOT NULL,
  `message` text NOT NULL,
  `status` enum('read','unread') DEFAULT 'unread',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `user_id` (`user_id`),
  KEY `issue_id` (`issue_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`issue_id`) REFERENCES `problems` (`problem_id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (45,4,9,'The status of your reported issue 9 has been updated to Resolved.','unread','2024-08-10 06:25:43'),(52,14,28,'The status of your reported issue 28 has been updated to In Progress.','unread','2024-12-15 12:47:52');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `problems`
--

DROP TABLE IF EXISTS `problems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `problems` (
  `problem_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `category_id` int NOT NULL,
  `description` text NOT NULL,
  `location` varchar(255) NOT NULL,
  `image` text,
  `images` text,
  `status` varchar(50) NOT NULL,
  `reported_date` datetime NOT NULL,
  `resolved_date` datetime DEFAULT NULL,
  PRIMARY KEY (`problem_id`),
  KEY `user_id` (`user_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `problems_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `problems_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `problems`
--

LOCK TABLES `problems` WRITE;
/*!40000 ALTER TABLE `problems` DISABLE KEYS */;
INSERT INTO `problems` VALUES (6,2,3,'In our locality, improper waste disposal is becoming a major concern. Trash is frequently left uncollected, leading to unsightly and unsanitary conditions. Overflowing bins and scattered garbage are attracting pests and posing health risks to residents','vv puram',NULL,'was.jpg','Reported','2024-07-16 20:37:19',NULL),(7,5,1,'In our locality, the roads are in a state of disrepair. Numerous potholes and cracks pose serious safety hazards to drivers and pedestrians. Immediate action is required to repair these damages and ensure safe travel','Sakleshpura,Karnataka',NULL,'r1.jpg','In progress','2024-07-16 21:59:09','2024-07-18 17:45:37'),(8,6,1,'There is a shortage of qualified teachers in government schools, affecting the quality of education provided to students. Additional recruitment and training of teachers are essential to improve educational outcomes.','Chikkaballapura',NULL,'go.jpg','Reported','2024-07-16 22:02:30',NULL),(9,4,6,'The park in our locality is in need of regular maintenance. Overgrown grass, litter, and broken benches detract from its beauty and usability. Immediate attention is needed to ensure a clean and safe environment for visitors','srinagar',NULL,'park2.jpg','Resolved','2024-07-16 22:05:09','2024-08-09 19:53:49'),(12,5,1,'please provide street lights..its getting very difficult to walk and go out during  night','panchnalli',NULL,'broke.jpeg','we will solve soon','2024-07-18 18:05:26','2024-08-03 13:00:34'),(13,10,5,'provide safety measures to be taken','laggere',NULL,'broke.jpeg','Reported','2024-07-21 19:34:35',NULL),(17,14,1,'I am writing to urgently request that the authorities take immediate action to address the worsening potholes on Main Street. These hazards are causing significant damage to vehicles and posing serious safety risks to drivers and pedestrians. Prompt resolution of this issue is crucial to prevent accidents and ensure the safety of our community','laggere',NULL,'road2.jpg','Resolved','2024-08-05 19:53:09','2024-08-10 00:00:59'),(23,22,1,'please make proper roads','vv puram',NULL,'road2.jpg','In Progress','2024-08-07 15:18:48','2024-08-07 15:21:26'),(28,14,3,'I am writing to express my concern about the current waste management practices in our area. The accumulation of garbage and irregular collection schedules are causing significant inconvenience and health risks. Immediate action is needed to address these issues and improve waste management efficiency.','srinagar',NULL,'was.jpg','In Progress','2024-08-10 00:14:46',NULL),(29,36,1,'please make proper roads','laggere',NULL,'road2.jpg','Resolved','2024-08-11 20:01:55','2024-08-11 20:03:07');
/*!40000 ALTER TABLE `problems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `statusupdates`
--

DROP TABLE IF EXISTS `statusupdates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `statusupdates` (
  `update_id` int NOT NULL AUTO_INCREMENT,
  `problem_id` int NOT NULL,
  `status` varchar(50) NOT NULL,
  `update_date` datetime NOT NULL,
  `comments` text,
  `authority_id` int DEFAULT NULL,
  PRIMARY KEY (`update_id`),
  KEY `problem_id` (`problem_id`),
  KEY `authority_id` (`authority_id`),
  CONSTRAINT `statusupdates_ibfk_1` FOREIGN KEY (`problem_id`) REFERENCES `problems` (`problem_id`),
  CONSTRAINT `statusupdates_ibfk_2` FOREIGN KEY (`authority_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `statusupdates`
--

LOCK TABLES `statusupdates` WRITE;
/*!40000 ALTER TABLE `statusupdates` DISABLE KEYS */;
INSERT INTO `statusupdates` VALUES (1,7,'Resolved','2024-07-16 22:25:16',NULL,NULL),(4,9,'Resolved','2024-07-18 17:45:26',NULL,NULL),(5,7,'In progress','2024-07-18 17:45:37',NULL,NULL),(6,9,'In progress','2024-07-21 19:36:38',NULL,NULL),(7,9,'In progress','2024-07-22 20:43:41',NULL,NULL),(8,9,'Resolved','2024-08-03 12:38:14',NULL,NULL),(9,12,'Resolved','2024-08-03 12:38:35',NULL,NULL),(10,9,'In progress','2024-08-03 12:38:47',NULL,NULL),(12,12,'we will solve soon','2024-08-03 13:00:34',NULL,NULL),(14,23,'in progress','2024-08-07 15:21:26',NULL,NULL),(15,9,'in progress','2024-08-09 19:53:49',NULL,NULL),(16,17,'In progress','2024-08-09 19:54:01',NULL,NULL),(37,17,'jqwrjpoqi','2024-08-09 23:34:12',NULL,NULL),(38,17,'reported','2024-08-09 23:34:19',NULL,NULL),(39,17,'we will solve soon','2024-08-09 23:36:10',NULL,NULL),(40,17,'Resolved','2024-08-09 23:37:35',NULL,NULL),(41,17,'in progress','2024-08-10 00:00:59',NULL,NULL),(42,29,'In progress','2024-08-11 20:03:07',NULL,NULL);
/*!40000 ALTER TABLE `statusupdates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'Aishu','aishuu@gmail.com','scrypt:32768:8:1$bHdHRyfjRv8K2lN6$4c52351fdf900bb63228d34bce4ee5f99a8088dd9d96385dcdada59ab778431d8c588a77ab8a52f9d36563462265407ae954a0063c0fac7c792f1a8ce61769ac','resident'),(3,'Apsara','Appu@gmail.com','scrypt:32768:8:1$PwDYVZ8mw0KpYQdq$1a7f92705044639ee493e9fbc23eec93c2a701dd2072024ed7dd9eb3cd922f0f9a133a864b6e27df23b450d5ef90353d7a07d85f3d9fa4d79b82fb57c59e87df','authority'),(4,'Harshitha','harshi@gmail.com','scrypt:32768:8:1$136yWjeqei9RDVHA$480b33408e5109b5f5418bca71f29f00ec3daeffe05e1bcc75ca1c452a1db92fe6b7107657996f45279e07275da69bd894571f5850cdff5b474977262ba34e09','resident'),(5,'Bindu','bindu@gmail.com','scrypt:32768:8:1$fWCDxOP40A8KNc0q$70df2989189d9aa5df2f249b08400c93b6ecb0e4cb6bc20ad9785df75f050565d463d1786f3bd33930f880e1708af14619accf8710dcee8b2d34f155f2e38720','resident'),(6,'Chethanya.N','chethu@gmail.com','scrypt:32768:8:1$h4RGEuVaAGNiREOi$293f6da5c63729e246a35136d3885e3126b60ef69e3ecbf015fed37a0d2c72ded09c272f2362b1fbc4c66af5b5ed685f8814d0dbb5c338b165e1cc26c0d950e8','authority'),(8,'Geetha','geetha@gmail.com','scrypt:32768:8:1$sPcGKzr1Iqiy9X47$d4d047590fe22ca15f67e4c4acc09329a1eba481f3590ec8c84e96d5b18d585a0b4db3d8932c6d68e3620a4330327e0cb12b9fd1f64a46633629e1de48e940c6','authority'),(9,'Balakrishna','balu@gmail.com','scrypt:32768:8:1$1AiWwGxxuSBdzBfA$66bea8ec1610813da6a1dc8c166f9873e710aff1ef0e1071aa75602f340da5311c099c5823245c5c6620af80987929c8ad0ed4c76e1c6c50034cc98b39b19975','resident'),(10,'Deeksha','deekshu@gmail.com','scrypt:32768:8:1$C4azGJmpQgpzhlSR$b33f4a2df073cce6c9667eb471880e6478b619c87062b226a334a9f6267f1b3928cbdf8d3767b8e70aa9c8fcf38f0736e80392192af4e23ca900be17790279d5','authority'),(11,'gagana','gagana@gmail.com','scrypt:32768:8:1$X4CUCYdvrhTpw163$a9a714761e8c7be81da222e42d74ee141244bd6f96dba7d430f918fd486e3948ddd0303bb082d05ddb29205427ff526293217b6dff8001ab8ab6eee6d2297989','authority'),(13,'Suhas','suhaskj@yahoo.com','scrypt:32768:8:1$DzN6Ia9Jvopt2H4h$00b068a376d47b6daceb3de4fb12ec062e733898344658e47255bc00ffe0af7f4d3798af473f4a0f2cb5569e79c43c6f6e45b2dabf2aa9765689d5a029a2ec30','resident'),(14,'Dinku','dinku@gmail.com','scrypt:32768:8:1$CoPlCiszoZXzo0Lg$e32b88b053009b5d55440cad47b21fd0a2670f24c5ed4d89482325805ae0f187ae8170b1762d1568ee55ce5ec1748bee880ca87f5018070f3da03e076ea87e3c','resident'),(15,'harshi','harshithab2401@gmail.com','scrypt:32768:8:1$vwi0pjKlpdGkGppV$975fc0664e6b2c95c27bd32e66653c7c9fbce3c2906793f4ad4f2ed590c8ebfd8418a64b2aa8fbf0e11d6902f524f4f64d043690d0969f73e3a251dc3700b3a6','authority'),(17,'Isha','isha@gmail.com','scrypt:32768:8:1$aJEz3fqlBHsZJm4y$88f33cca6627129eeb2a8755a89ab922f04fe6bfad95f0f4ddaa7d933c7a5b36cc5ecb49802a40a4c3295b557d181832e2377ecb1b49fae4b8340c0e9e715012','authority'),(19,'Ekansh','ekansh@gmail.com','scrypt:32768:8:1$p2Pu5wp1pkIJ0qFI$ae25e201a0aafcaa59a0e50a87d0c58ea19c43ec1bd5bb476b1128f36000688b8f459f13e1bdbb6780392ead7dd2b197551448045185b787c92388c3a77a87b8','resident'),(21,'teju','teju@gmail.com','scrypt:32768:8:1$wlrpp4PRTkH6dDnL$d610458094149488738c2187dcfa859daf699eac32af9d4412f90dc2aad7fba08cb1e1cf1338a16d690ff8056f84bd9cd8653ebcd973eb2118cc094de196c107','resident'),(22,'harshitha','harshitha@gmail.com','scrypt:32768:8:1$X3crWOSF3YfPJxBz$be690bc7a63c67e0717f01105e822ca4159c47999a1c0ea6fd6dc1ca6dad2c600f8dc0c71face5fc756ec66da9219c111392baf4092ad13c40fb608a7974b06d','resident'),(25,'Admin','admin@example.com','appu','admin'),(27,'Apsara','admin@yahoo.com','scrypt:32768:8:1$zy18H89x9ntt824q$9640e96d37b629c0362698c94959b4dad5aa47e95a7022c0af20e29cbe5e438f3d8c9c930ec63301136d9b52af8f03ed26ca62190527810973c3bcc53609c7f6','Admin'),(28,'shreyas','shreyas@gmail.com','scrypt:32768:8:1$8g99IEDNd2sWAWzc$734bcf88a30823a554cd653d79e8ef6639edf7673903707e46e170a37b45122f5ee5744ce72182f2842f743d5fb45309daca645f8d73ef010855984432997eee','authority'),(29,'arsh','arsh@gmail.com','scrypt:32768:8:1$7cTl7PDLFHQlC5eS$1598d3b9eb44a7b15dad93822d67bb26277736bbf866e8937cbb6045b8dd03ec6512e77aead5714707ba12d16d1e664f7e1826319bd7821ffba4b2d81b41e4ff','resident'),(30,'afiya','afi@gmail.com','scrypt:32768:8:1$JVw4YtzNirUg8BKl$b8025462d2861847e77bae739bcd0a097ebf735ac469f29990701eab8f7e348e12471c113674d55cb43eaef8f935a86b57f4c5328718b8d9f2ae95ffd8eb1d3e','resident'),(31,'sree','sree@gmail.com','scrypt:32768:8:1$R5gUKtOAijxUtASb$a609a9938f6f1551bfd1787d97a0a18993f23d76ad70841f4fbe819aa19f4fbbb3a15ad47d06a64e965999561d7daa9dc14a3b87e6ccebb7d8f42f5a7e07d0ac','authority'),(36,'Sree raksha sp','sreees@gmail.com','scrypt:32768:8:1$Xy0cBJtUeIAJ0VSw$e405a564bc11391d427e981dfb196d56dd110d6b643896dcb168d9f6ed7339e3dc58af8b33af2b02a2ba9510e7c12a541b9f23fbbd03f8df5f5264213be530f0','Admin'),(39,'Apsara1','admin@appu.com','scrypt:32768:8:1$kahLA6pX3p49Nok4$6e7888f270f03101623481ac88bf6191dd7728aa93b7f9b4162e90acd36ef50510b5ce2f043fa00378dac2723f575648e27bc7cc49d805c3ee0940c373a30e42','Admin');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-02-05 14:58:42
