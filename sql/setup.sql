-- MySQL dump 10.13  Distrib 5.6.34, for osx10.12 (x86_64)
--
-- Host: localhost    Database: flying
-- ------------------------------------------------------
-- Server version	5.6.34

--
-- Table structure for table `aircraft`
--

DROP TABLE IF EXISTS `aircraft`;
CREATE TABLE `aircraft` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `abbrev` tinytext,
  `faa_abbrev` tinytext,
  `cateogry` tinytext,
  `class` tinytext,
  `engines` tinyint(3) unsigned DEFAULT NULL,
  `hp` smallint(5) DEFAULT NULL,
  `flaps` tinyint(1) DEFAULT NULL,
  `retr` tinyint(1) DEFAULT NULL,
  `cpp` tinyint(1) DEFAULT NULL,
  `sim` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=latin1;

--
-- Table structure for table `logbook`
--

DROP TABLE IF EXISTS `logbook`;
CREATE TABLE `logbook` (
  `bkpgln` varchar(50) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `aircraft` varchar(100) NOT NULL DEFAULT '',
  `tailnum` varchar(100) NOT NULL DEFAULT '',
  `poe` varchar(100) NOT NULL DEFAULT '',
  `time_out` time DEFAULT NULL,
  `pod` varchar(100) NOT NULL DEFAULT '',
  `time_in` time DEFAULT NULL,
  `stops` varchar(255) DEFAULT NULL,
  `inst_app` int(11) DEFAULT NULL,
  `landings` int(11) DEFAULT NULL,
  `nitelndgs` int(11) DEFAULT NULL,
  `nav` decimal(7,1) DEFAULT NULL,
  `se_retrgear` decimal(7,1) DEFAULT NULL,
  `a_sel` decimal(7,1) DEFAULT NULL,
  `a_mel` decimal(7,1) DEFAULT NULL,
  `xc` decimal(7,1) DEFAULT NULL,
  `day` decimal(7,1) DEFAULT NULL,
  `night` decimal(7,1) DEFAULT NULL,
  `act_inst` decimal(7,1) DEFAULT NULL,
  `sim_inst` decimal(7,1) DEFAULT NULL,
  `simulator` decimal(7,1) DEFAULT NULL,
  `dualrecd` decimal(7,1) DEFAULT NULL,
  `pic` decimal(7,1) DEFAULT NULL,
  `p2` decimal(7,1) DEFAULT NULL,
  `duration` decimal(7,1) DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`bkpgln`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
