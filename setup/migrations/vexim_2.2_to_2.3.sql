--
-- MySQL script to upgrade Vexim database schema from Vexim 2.2RC1, 2.2 and 2.2.1 to Vexim 2.3
--


--
-- Table: `domains`
--
ALTER TABLE `domains` ENGINE=InnoDB;
ALTER TABLE `domains` CONVERT TO CHARACTER SET utf8;
ALTER TABLE `domains` DROP COLUMN `complexpass`;

--
-- Table: `users`
--
ALTER TABLE `users` ENGINE=InnoDB;
ALTER TABLE `users` CONVERT TO CHARACTER SET utf8;
ALTER TABLE `users` DROP COLUMN `clear`;
ALTER TABLE `users` MODIFY COLUMN `crypt` varchar(255) DEFAULT NULL;
ALTER TABLE `users` DROP COLUMN `on_complexpass`;
ALTER TABLE `users` MODIFY COLUMN `vacation` varchar(1024) DEFAULT NULL;
ALTER TABLE `users` ADD COLUMN `spam_drop` bool NOT NULL DEFAULT '0' AFTER `on_vacation`;
ALTER TABLE `users` ADD KEY `fk_users_domain_id_idx` (`domain_id`);
ALTER TABLE `users` ADD CONSTRAINT `fk_users_domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table: `blocklists`
--
ALTER TABLE `blocklists` ENGINE=InnoDB;
ALTER TABLE `blocklists` CONVERT TO CHARACTER SET utf8;
ALTER TABLE `blocklists` ADD KEY `fk_blocklists_domain_id_idx` (`domain_id`);
ALTER TABLE `blocklists` ADD KEY `fk_blocklists_user_id_idx` (`user_id`);
ALTER TABLE `blocklists` ADD CONSTRAINT `fk_blocklists_domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `blocklists` ADD CONSTRAINT `fk_blocklists_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table: `domainalias`
--
ALTER TABLE `domainalias` ENGINE=InnoDB;
ALTER TABLE `domainalias` CONVERT TO CHARACTER SET utf8;
ALTER TABLE `domainalias` ADD KEY `fk_domainalias_domain_id_idx` (`domain_id`);
ALTER TABLE `domainalias` ADD CONSTRAINT `fk_domainalias_domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table: `groups`
--
ALTER TABLE `groups` ENGINE=InnoDB;
ALTER TABLE `groups` CONVERT TO CHARACTER SET utf8;
ALTER TABLE `groups` MODIFY COLUMN `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
ALTER TABLE `groups` ADD KEY `fk_groups_domain_id_idx` (`domain_id`);
ALTER TABLE `groups` ADD CONSTRAINT `fk_groups_domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`domain_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Table: `group_contents`
--
ALTER TABLE `group_contents` ENGINE=InnoDB;
ALTER TABLE `group_contents` CONVERT TO CHARACTER SET utf8;
ALTER TABLE `group_contents` MODIFY COLUMN `group_id` int(10) UNSIGNED NOT NULL;
ALTER TABLE `group_contents` MODIFY COLUMN `member_id` int(10) UNSIGNED NOT NULL;
ALTER TABLE `group_contents` ADD UNIQUE INDEX `group_member` (`group_id`, `member_id`);
ALTER TABLE `group_contents` ADD KEY `fk_group_contents_member_id_idx` (`member_id`);
ALTER TABLE `group_contents` ADD KEY `fk_group_contents_group_id_idx` (`group_id`);
ALTER TABLE `group_contents` ADD CONSTRAINT `fk_group_contents_group_id` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `group_contents` ADD CONSTRAINT `fk_group_contents_member_id` FOREIGN KEY (`member_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Uncomment this section if you used the Schirmacher-patch: https://www.schirmacher.de/display/INFO/improved+Vexim+frontend+and+bug+fixes
--
-- UPDATE `users` SET spam_drop=1 WHERE movedelete=2;
-- ALTER TABLE `users` DROP COLUMN `movedelete`;
-- ALTER TABLE `users` DROP COLUMN `on_rewritesubject`;
