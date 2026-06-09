
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `descricao` text,
  `taxasId` int DEFAULT NULL,
  `group_id` bigint NOT NULL,
  `amount_water` decimal(10,2) NOT NULL DEFAULT '0.00',
  `amount_partner` decimal(10,2) NOT NULL DEFAULT '0.00',
  `has_hydrometer` tinyint(1) DEFAULT '0',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `deleted_at` datetime(6) DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `deleted_by` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_category_name_group_id_unique` (`name`,`group_id`),
  KEY `FK271F6B9AA011B865` (`taxasId`),
  KEY `FKbhtsh2dou8s17lpwx7b1784x0` (`group_id`),
  KEY `idx_categoriasocio_nome` (`name`),
  KEY `index_category_on_deleted_at` (`deleted_at`),
  CONSTRAINT `FK271F6B9AA011B865` FOREIGN KEY (`taxasId`) REFERENCES `taxa` (`id`),
  CONSTRAINT `FKbhtsh2dou8s17lpwx7b1784x0` FOREIGN KEY (`group_id`) REFERENCES `subcategory` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `conta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conta` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dataGerada` datetime DEFAULT NULL,
  `data_pagamento` datetime DEFAULT NULL,
  `data_vencimento` datetime NOT NULL,
  `observacoes` text,
  `id_endereco_pessoa` int NOT NULL,
  `amount_partner` decimal(10,2) DEFAULT '0.00',
  `amount_water` decimal(10,2) DEFAULT '0.00',
  `SocioExclusivo` bit(1) NOT NULL DEFAULT b'0',
  `data_referente` date DEFAULT NULL,
  `versao` bigint DEFAULT '1',
  `paid_by_pix` tinyint(1) DEFAULT NULL,
  `paid_with_alternative_bill` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK5A7376F50A7B5D2` (`id_endereco_pessoa`),
  KEY `idx_conta_id_data` (`id_endereco_pessoa`,`data_referente`),
  KEY `idx_invoice_period_desc` (`data_referente` DESC,`id_endereco_pessoa`),
  CONSTRAINT `FK5A7376F50A7B5D2` FOREIGN KEY (`id_endereco_pessoa`) REFERENCES `link` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=257653 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `contaslog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contaslog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dataPag` datetime DEFAULT NULL,
  `dataVence` datetime DEFAULT NULL,
  `horaRegristro` datetime DEFAULT NULL,
  `idNumeroSocio` int DEFAULT NULL,
  `idOriginal` int DEFAULT NULL,
  `observacoes` text,
  `taxaRelogio` decimal(19,2) DEFAULT NULL,
  `taxaSocio` int DEFAULT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `usuarioAlteracao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `endereco`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `endereco` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tipo` varchar(255) NOT NULL,
  `nome` varchar(255) NOT NULL,
  `descricao` text,
  PRIMARY KEY (`id`),
  KEY `idx_address_type_name` (`tipo`,`nome`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `endereco_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `endereco_view` (
  `id` int DEFAULT NULL,
  `nome` varchar(511) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `flyway_schema_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flyway_schema_history` (
  `installed_rank` int NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(20) NOT NULL,
  `script` varchar(1000) NOT NULL,
  `checksum` int DEFAULT NULL,
  `installed_by` varchar(100) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`),
  KEY `flyway_schema_history_s_idx` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `hibernate_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hibernate_sequence` (
  `next_val` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `hidrometro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hidrometro` (
  `idhidrometro` int NOT NULL AUTO_INCREMENT,
  `Consumo` double DEFAULT NULL,
  `idconta` int NOT NULL,
  `consumo_inicial` double NOT NULL,
  `consumo_final` double NOT NULL,
  PRIMARY KEY (`idhidrometro`),
  UNIQUE KEY `idconta` (`idconta`),
  KEY `FKF3FD0019D45F0A2C` (`idconta`),
  KEY `idx_hidrometro_conta` (`idconta`),
  CONSTRAINT `FKF3FD0019D45F0A2C` FOREIGN KEY (`idconta`) REFERENCES `conta` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48953 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `id_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `id_sequences` (
  `seq_name` varchar(50) NOT NULL,
  `seq_value` bigint NOT NULL DEFAULT '1',
  PRIMARY KEY (`seq_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `link` (
  `id` int NOT NULL AUTO_INCREMENT,
  `numero` varchar(45) DEFAULT NULL,
  `id_endereco` int NOT NULL,
  `id_pessoa` int NOT NULL,
  `datamatricula` date DEFAULT NULL,
  `id_categoria_socio` int NOT NULL,
  `inativo` bit(1) NOT NULL DEFAULT b'0',
  `socio_exclusivo` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_active_number` (`id_endereco`,`numero`,((case when (`inativo` = 0) then 1 else NULL end))),
  KEY `FK80ECBCB0E2CAEDC0` (`id_pessoa`),
  KEY `FK80ECBCB0F1E3C984` (`id_endereco`),
  KEY `fk_categoriaSocio_idx` (`id_categoria_socio`),
  KEY `FK80ECBCB09D0D13A6` (`id_categoria_socio`),
  KEY `idx_end_pessoa_fk` (`id_pessoa`,`id_endereco`,`id_categoria_socio`),
  CONSTRAINT `FK80ECBCB09D0D13A6` FOREIGN KEY (`id_categoria_socio`) REFERENCES `category` (`id`),
  CONSTRAINT `FK80ECBCB0E2CAEDC0` FOREIGN KEY (`id_pessoa`) REFERENCES `person` (`id`),
  CONSTRAINT `FK80ECBCB0F1E3C984` FOREIGN KEY (`id_endereco`) REFERENCES `endereco` (`id`),
  CONSTRAINT `fk_categoriaSocio` FOREIGN KEY (`id_categoria_socio`) REFERENCES `category` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3065 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `parametro_coleta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parametro_coleta` (
  `ide_parametro_coleta` int unsigned NOT NULL AUTO_INCREMENT,
  `ide_tipo_parametro` int unsigned NOT NULL,
  `exigido` varchar(45) NOT NULL,
  `analisado` varchar(45) NOT NULL,
  `conformidade` varchar(45) NOT NULL,
  `data` date NOT NULL,
  PRIMARY KEY (`ide_parametro_coleta`),
  KEY `idx_parametro_coleta` (`data`)
) ENGINE=InnoDB AUTO_INCREMENT=640 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `sobrenome` varchar(255) DEFAULT NULL,
  `cpf` varchar(255) DEFAULT NULL,
  `apelido` varchar(255) DEFAULT NULL,
  `bairro` varchar(255) DEFAULT NULL,
  `cep` varchar(255) DEFAULT NULL,
  `cidade` varchar(255) DEFAULT NULL,
  `dataNasc` datetime DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `nomeMae` varchar(255) DEFAULT NULL,
  `nomePai` varchar(255) DEFAULT NULL,
  `numeroEndereco` varchar(255) DEFAULT NULL,
  `numeroMatricula` int DEFAULT NULL,
  `observacoes` text,
  `rgEmissao` date DEFAULT NULL,
  `rgExpedidor` varchar(255) DEFAULT NULL,
  `rgNumero` varchar(255) DEFAULT NULL,
  `sexo` varchar(255) DEFAULT NULL,
  `status` bit(1) DEFAULT NULL,
  `telefone` varchar(255) DEFAULT NULL,
  `uf` varchar(255) DEFAULT NULL,
  `idEndereco` int DEFAULT NULL,
  `cnpj` varchar(255) DEFAULT NULL,
  `partner_number` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKC4E40FA7F1E3C984` (`idEndereco`),
  KEY `idx_pessoa_nome_sobrenome_id` (`name`,`sobrenome`,`id`),
  KEY `idx_pessoa_nome_id` (`name`,`id`),
  CONSTRAINT `FKC4E40FA7F1E3C984` FOREIGN KEY (`idEndereco`) REFERENCES `endereco` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2377 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `role_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_model` (
  `id` bigint NOT NULL,
  `authority` varchar(255) DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FKjjvp9pd7q7sfs1tj0gu5lid7x` (`user_id`),
  CONSTRAINT `FKjjvp9pd7q7sfs1tj0gu5lid7x` FOREIGN KEY (`user_id`) REFERENCES `user_model` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `socio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `socio` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dataAprovacao` datetime DEFAULT NULL,
  `dataMatricula` datetime NOT NULL,
  `dataVence` date DEFAULT NULL,
  `numeroSocio` int NOT NULL,
  `observacao` text,
  `idCategoriaSocio` int NOT NULL,
  `pessoa_id` int NOT NULL,
  `SocioExclusivo` bit(1) DEFAULT b'0',
  `carneDiferenciado` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idPessoa` (`pessoa_id`),
  KEY `FK68884ED9D0D13A6` (`idCategoriaSocio`),
  KEY `FK68884EDE2CAEDC0` (`pessoa_id`),
  CONSTRAINT `FK68884ED9D0D13A6` FOREIGN KEY (`idCategoriaSocio`) REFERENCES `category` (`id`),
  CONSTRAINT `FK68884EDE2CAEDC0` FOREIGN KEY (`pessoa_id`) REFERENCES `person` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2369 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `subcategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subcategory` (
  `id` bigint NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `taxa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taxa` (
  `id` int NOT NULL AUTO_INCREMENT,
  `descricao` varchar(255) DEFAULT NULL,
  `nome` varchar(255) NOT NULL,
  `observacao` text,
  `valor` decimal(19,2) NOT NULL,
  `valor_socio` decimal(10,2) DEFAULT NULL,
  `valor_outros` decimal(19,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `taxasconta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taxasconta` (
  `idtaxasConta` int NOT NULL AUTO_INCREMENT,
  `contaid` int NOT NULL,
  `taxaid` int NOT NULL,
  `BitTeste` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`idtaxasConta`),
  KEY `FK65E35472AA5C0BC2` (`contaid`),
  KEY `FK65E35472C6F1071E` (`taxaid`),
  CONSTRAINT `FK65E35472AA5C0BC2` FOREIGN KEY (`contaid`) REFERENCES `conta` (`id`),
  CONSTRAINT `FK65E35472C6F1071E` FOREIGN KEY (`taxaid`) REFERENCES `taxa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tipo_parametro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_parametro` (
  `ide_tipo_parametro` int unsigned NOT NULL AUTO_INCREMENT,
  `nom_parametro` varchar(45) NOT NULL,
  PRIMARY KEY (`ide_tipo_parametro`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_model` (
  `id` bigint NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_asi811mgonyf7p7aj2tl97a91` (`username`),
  KEY `idx_user_login` (`username`,`password`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

