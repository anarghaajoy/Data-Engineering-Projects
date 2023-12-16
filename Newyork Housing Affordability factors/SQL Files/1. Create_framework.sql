-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema depa_final
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `depa_final` ;

-- -----------------------------------------------------
-- Schema depa_final
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `depa_final` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `depa_final` ;

-- -----------------------------------------------------
-- Table `depa_final`.`bbl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `depa_final`.`bbl` ;

CREATE TABLE IF NOT EXISTS `depa_final`.`bbl` (
  `bbl_id` INT NOT NULL AUTO_INCREMENT,
  `bbl` DOUBLE DEFAULT NULL,
  `community_board` VARCHAR(45) NULL DEFAULT NULL,
  `council_district` INT NULL DEFAULT NULL,
  `census_tract` INT NULL DEFAULT NULL,
  `nta` VARCHAR(150) NULL DEFAULT NULL,
  PRIMARY KEY (`bbl_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci
AUTO_INCREMENT = 1;


-- -----------------------------------------------------
-- Table `depa_final`.`address`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `depa_final`.`address` ;

CREATE TABLE IF NOT EXISTS `depa_final`.`address` (
  `address_id` INT NOT NULL AUTO_INCREMENT,
  `number` VARCHAR(45) NULL DEFAULT NULL,
  `street` VARCHAR(150) NULL DEFAULT NULL,
  `borough` VARCHAR(45) NULL DEFAULT NULL,
  `latitude` DOUBLE NULL,
  `longitude` DOUBLE NULL,
  `zipcode` INT NULL,
  `bbl_id` INT NULL,
  PRIMARY KEY (`address_id`),
  CONSTRAINT `fk_address_bbl1`
    FOREIGN KEY (`bbl_id`)
    REFERENCES `depa_final`.`bbl` (`bbl_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci
AUTO_INCREMENT = 1;

CREATE INDEX `fk_address_bbl1_idx` ON `depa_final`.`address` (`bbl_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `depa_final`.`project`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `depa_final`.`project` ;

CREATE TABLE IF NOT EXISTS `depa_final`.`project` (
  `project_uid` INT NOT NULL AUTO_INCREMENT,
  `project_id` INT DEFAULT NULL,
  `project_name` VARCHAR(60) NULL DEFAULT NULL,
  `project_start_date` DATE NULL DEFAULT NULL,
  `project_completion_date` DATE NULL DEFAULT NULL,
  `reporting_construction_type` VARCHAR(45) NULL DEFAULT NULL,
  `extended_affordability_only` VARCHAR(45) NULL DEFAULT NULL,
  `prevailing_wage_status` VARCHAR(45) NULL DEFAULT NULL,
  `extremely_low_income_units` INT NULL DEFAULT NULL,
  `very_low_units` INT NULL DEFAULT NULL,
  `low_income_units` INT NULL DEFAULT NULL,
  `moderate_income_units` INT NULL DEFAULT NULL,
  `middle_income_units` INT NULL DEFAULT NULL,
  `other_income_units` INT NULL DEFAULT NULL,
  `studio_units` INT NULL DEFAULT NULL,
  `br_1_units` INT NULL DEFAULT NULL,
  `br_2_units` INT NULL DEFAULT NULL,
  `br_3_units` INT NULL DEFAULT NULL,
  `br_4_units` INT NULL DEFAULT NULL,
  `br_5_units` INT NULL DEFAULT NULL,
  `br_6_plus_units` INT NULL DEFAULT NULL,
  `unknown_br_units` INT NULL DEFAULT NULL,
  `rental_units` INT NULL DEFAULT NULL,
  `homeownership_units` INT NULL DEFAULT NULL,
  `Affordable_marketrate_units` INT NULL DEFAULT NULL,
  PRIMARY KEY (`project_uid`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci
AUTO_INCREMENT =1;


-- -----------------------------------------------------
-- Table `depa_final`.`building`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `depa_final`.`building` ;

CREATE TABLE IF NOT EXISTS `depa_final`.`building` (
  `building_id` INT NOT NULL,
  `building_completion_date` DATETIME NULL,
  `project_uid` INT NOT NULL,
  `address_id` INT NOT NULL,
  PRIMARY KEY (`building_id`, `address_id`),
  CONSTRAINT `fk_building_project1`
    FOREIGN KEY (`project_uid`)
    REFERENCES `depa_final`.`project` (`project_uid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_building_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `depa_final`.`address` (`address_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_building_project1_idx` ON `depa_final`.`building` (`project_uid` ASC) VISIBLE;

CREATE INDEX `fk_building_address1_idx` ON `depa_final`.`building` (`address_id` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `depa_final`.`schoolcrime`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `depa_final`.`schoolcrime` ;

CREATE TABLE IF NOT EXISTS `depa_final`.`schoolcrime` (
  `school_name_id` INT NOT NULL AUTO_INCREMENT,
  `building_code` VARCHAR(45) NULL,
  `address_id` INT NULL,
  `school_name` VARCHAR(150) NULL,
  `schoolyear` VARCHAR(45) NULL,
  `no_of_schools` INT NULL,
  `major_crimes` INT NULL,
  `other_crimes` INT NULL,
  `non_criminal_crimes` INT NULL,
  `property_crimes` INT NULL,
  `violent_crimes` INT NULL,
  `engroup_A` VARCHAR(45) NULL,
  `rangeA` VARCHAR(45) NULL,
  `bbl_id` INT NULL,
  PRIMARY KEY (`school_name_id`),
  CONSTRAINT `fk_schoolcrime_bbl1`
    FOREIGN KEY (`bbl_id`)
    REFERENCES `depa_final`.`bbl` (`bbl_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
 CONSTRAINT `fk_schoolcrime_address`
    FOREIGN KEY (`address_id`)
    REFERENCES `depa_final`.`address` (`address_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1;

CREATE INDEX `fk_schoolcrime_bbl1_idx` ON `depa_final`.`schoolcrime` (`bbl_id` ASC) VISIBLE;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
