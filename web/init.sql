CREATE TABLE IF NOT EXISTS `urls` (
  `steamid` varchar(64) NOT NULL,
  `url` varchar(512) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `urls`
 ADD PRIMARY KEY (`steamid`);
