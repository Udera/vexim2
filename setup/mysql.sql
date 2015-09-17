-- Password for siteadmin is CHANGE. SHA512 is used by default, other
-- crypting schemes can be found at the end of this file
--
-- Database: `vexim`
--

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
-- Uncomment (and adjust as necessary) the following statements if you haven't created
-- a database yet and want this script to do it for you.
-- Make sure to at least change the password!
--
-- CREATE DATABASE /*!32312 IF NOT EXISTS*/ `vexim` /*!40100 DEFAULT CHARACTER SET utf8 */;
-- GRANT SELECT,INSERT,DELETE,UPDATE ON `vexim`.* to "vexim"@"localhost"
--       IDENTIFIED BY 'PASSWORD';
-- FLUSH PRIVILEGES;
-- USE `vexim`;

--
-- Table: `domains`
--

DROP TABLE IF EXISTS `domains`;
CREATE TABLE `domains` (
  `domain_id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `domain` varchar(64) NOT NULL DEFAULT '',
  `maildir` varchar(128) NOT NULL DEFAULT '',
  `uid` smallint(5) unsigned NOT NULL DEFAULT '65534',
  `gid` smallint(5) unsigned NOT NULL DEFAULT '65534',
  `max_accounts` int(10) unsigned NOT NULL DEFAULT '0',
  `quotas` int(10) unsigned NOT NULL DEFAULT '0',
  `type` varchar(5) DEFAULT NULL,
  `avscan` tinyint(1) NOT NULL DEFAULT '0',
  `blocklists` tinyint(1) NOT NULL DEFAULT '0',
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `mailinglists` tinyint(1) NOT NULL DEFAULT '0',
  `maxmsgsize` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `pipe` tinyint(1) NOT NULL DEFAULT '0',
  `spamassassin` tinyint(1) NOT NULL DEFAULT '0',
  `sa_tag` smallint(5) unsigned NOT NULL DEFAULT '0',
  `sa_refuse` smallint(5) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`domain_id`),
  UNIQUE KEY `domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table: `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `domain_id` mediumint(8) unsigned NOT NULL,
  `localpart` varchar(192) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `crypt` varchar(255) DEFAULT NULL,
  `uid` smallint(5) unsigned NOT NULL DEFAULT '65534',
  `gid` smallint(5) unsigned NOT NULL DEFAULT '65534',
  `smtp` varchar(255) DEFAULT NULL,
  `pop` varchar(255) DEFAULT NULL,
  `type` enum('local','alias','catch','fail','piped','admin','site') NOT NULL DEFAULT 'local',
  `admin` tinyint(1) NOT NULL DEFAULT '0',
  `on_avscan` tinyint(1) NOT NULL DEFAULT '0',
  `on_blocklist` tinyint(1) NOT NULL DEFAULT '0',
  `on_forward` tinyint(1) NOT NULL DEFAULT '0',
  `on_piped` tinyint(1) NOT NULL DEFAULT '0',
  `on_spamassassin` tinyint(1) NOT NULL DEFAULT '0',
  `on_vacation` tinyint(1) NOT NULL DEFAULT '0',
  `spam_drop` tinyint(1) NOT NULL DEFAULT '0',
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `flags` varchar(16) DEFAULT NULL,
  `forward` varchar(255) DEFAULT NULL,
  `unseen` tinyint(1) DEFAULT '0',
  `maxmsgsize` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `quota` int(10) unsigned NOT NULL DEFAULT '0',
  `realname` varchar(255) DEFAULT NULL,
  `sa_tag` smallint(5) unsigned NOT NULL DEFAULT '0',
  `sa_refuse` smallint(5) unsigned NOT NULL DEFAULT '0',
  `tagline` varchar(255) DEFAULT NULL,
  `vacation` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`localpart`,`domain_id`),
  KEY `local` (`localpart`),
  KEY `fk_users_domain_id_idx` (`domain_id`),
  CONSTRAINT `fk_users_domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table: `blocklists`
--

DROP TABLE IF EXISTS `blocklists`;
CREATE TABLE `blocklists` (
  `block_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `domain_id` mediumint(8) unsigned NOT NULL,
  `user_id` int(10) unsigned DEFAULT NULL,
  `blockhdr` varchar(192) NOT NULL DEFAULT '',
  `blockval` varchar(192) NOT NULL DEFAULT '',
  `color` varchar(8) NOT NULL DEFAULT '',
  PRIMARY KEY (`block_id`),
  KEY `fk_blocklists_domain_id_idx` (`domain_id`),
  KEY `fk_blocklists_user_id_idx` (`user_id`),
  CONSTRAINT `fk_blocklists_domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_blocklists_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table: `domainalias`
--

DROP TABLE IF EXISTS `domainalias`;
CREATE TABLE `domainalias` (
  `domain_id` mediumint(8) unsigned NOT NULL,
  `alias` varchar(64) DEFAULT NULL,
  KEY `fk_domainalias_domain_id_idx` (`domain_id`),
  CONSTRAINT `fk_domainalias_domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table: `groups`
--

DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `domain_id` mediumint(8) unsigned NOT NULL,
  `name` varchar(64) NOT NULL,
  `is_public` char(1) NOT NULL DEFAULT 'Y',
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_name` (`domain_id`,`name`),
  KEY `fk_groups_domain_id_idx` (`domain_id`),
  CONSTRAINT `fk_groups_domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table: `group_contents`
--

DROP TABLE IF EXISTS `group_contents`;
CREATE TABLE `group_contents` (
  `group_id` mediumint(8) unsigned NOT NULL,
  `member_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`group_id`,`member_id`),
  KEY `fk_group_contents_member_id_idx` (`member_id`),
  KEY `fk_group_contents_group_id_idx` (`group_id`),
  CONSTRAINT `fk_group_contents_group_id` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_group_contents_member_id` FOREIGN KEY (`member_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Add initial domain: admin
--

LOCK TABLES `domains` WRITE;
/*!40000 ALTER TABLE `domains` DISABLE KEYS */;
INSERT INTO `domains` (`domain_id`, `domain`) VALUES ('1', 'admin');
/*!40000 ALTER TABLE `domains` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Add initial user: siteadmin
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (user_id, domain_id, localpart, username, crypt, type, admin, realname)
       VALUES ('1', '1', 'siteadmin', 'siteadmin', '$6$uR.EiB1dj5rrvwMF$Qh5LgdjOZavKXwhi9IF0Yuzu7qxsG.dLTTB8e./55ZRNfBuZVLnfUSOEXa0oWT6174myO.WYkOy83HYWAKPbK/', 'site', '1', 'SiteAdmin');

-- fix password when using bcrypt (on *BSD only) encrypted password:
-- UPDATE `vexim`.`users` SET `crypt` = '$2a$10$KKtb78YkexNl4Ik3RymPEObqTsk/ivneEHl/Q5TsDpRBGyYjOl33G'
--   WHERE `user_id` = '1' LIMIT 1 ;

-- fix password when using clear password:
-- UPDATE `vexim`.`users` SET `crypt` = 'CHANGE'
--   WHERE `user_id` = '1' LIMIT 1 ;

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
