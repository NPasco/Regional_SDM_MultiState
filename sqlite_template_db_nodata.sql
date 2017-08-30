BEGIN TRANSACTION;
CREATE TABLE tblPrepStats 
( "SciName" TEXT,
	"CommName" TEXT,
	"ElemCode" TEXT REFERENCES lkpSpecies(CODE),
	"RandomPtFile" TEXT,
	"date" TEXT,
	"time" TEXT,
	"Loc_Use" TEXT 
);
CREATE TABLE `tblModelRuns` (
	`modelRunName`	TEXT,
	`CODE`	TEXT REFERENCES lkpSpecies(CODE),
	`modelBeginTime` TEXT,
	`modelEndTime` TEXT,
	`modeller` TEXT,
	`modelCompName`	TEXT,
	`rVersion`	TEXT,
	`internalComments` TEXT,
	PRIMARY KEY(`modelRunName`)
);
CREATE TABLE "tblCutoffs" (
	`ID`	INTEGER,
	`modelRunName` TEXT REFERENCES tblModelRuns(`modelRunName`),
	`ElemCode`	TEXT,
	`dateTime`	TEXT,
	`cutCode`	TEXT,
	`cutValue`	REAL,
	`capturedEOs`	INTEGER,
	`capturedPolys`	INTEGER,
	`capturedPts`	INTEGER,
	primary key (`modelRunName`,`cutCode`)
);
CREATE TABLE `tblCustomModelComments` (
	`ID`	INTEGER,
	`date`	TEXT,
	`speciesCode`	TEXT,
	`comments`	TEXT,
	`modelRunName`	TEXT REFERENCES tblModelRuns(`modelRunName`),
	PRIMARY KEY(`modelRunName`)
);
CREATE TABLE "mapDataSourcesToSpp" (
	`DataSourcesToSpeciesID`	INTEGER NOT NULL,
	`DataSourcesID`	INTEGER,
	`EstID`	INTEGER,
	`DataSourcesCode`	TEXT REFERENCES lkpDataSources(DataSourcesCode),
	`CODE`	TEXT REFERENCES lkpSpecies(CODE),
	PRIMARY KEY(`DataSourcesToSpeciesID`)
);
CREATE TABLE "lkpThresholdTypes" (
	`ID`	INTEGER,
	`cutCode`	TEXT,
	`cutFullName`	TEXT,
	`cutDescription`	TEXT,
	`cutCitationShort`	TEXT,
	`cutCitationFull`	TEXT,
	`sortOrder`	INTEGER,
	PRIMARY KEY(`ID`)
);
CREATE TABLE "lkpSpecies" (
	`CODE`	TEXT NOT NULL,
	`EST_ID`	INTEGER,
	`TAXGRP`	TEXT,
	`SCIEN_NAME`	TEXT,
	`COMMONNAME`	TEXT,
	`ELCODE_BCD`	TEXT,
	`ELEMTYPE`	TEXT,
	`GRANK`	TEXT,
	`SRANK`	TEXT,
	`FEDSTATUS`	TEXT,
	`VASTATUS`	TEXT,
	`TRRC`	BOOLEAN,
	`SALCC`	BOOLEAN,
	`REG5`	BOOLEAN,
	`COMMENTS`	TEXT,
	`MODTYPE`	TEXT,
	`NUMPOLYS`	TEXT,
	`NUMFLINES`	TEXT,
	`ModelerID`	INTEGER,
	`ModelerName`	TEXT,
	PRIMARY KEY(`CODE`),
	FOREIGN KEY(`MODTYPE`) REFERENCES `lkpModtype`(`MODTYPE`),
	FOREIGN KEY(`ModelerID`) REFERENCES `lkpModelers`(`ModelerID`)
);
CREATE TABLE lkpModtype (
	MODTYPE CHARACTER(1) primary key,
	MODTYPE_desc text
);
CREATE TABLE "lkpModelers" (
	`ModelerID`	INTEGER NOT NULL,
	`ProgramName`	TEXT,
	`FullOrganizationName`	TEXT,
	`City`	TEXT,
	`State`	TEXT,
	PRIMARY KEY(`ModelerID`)
);
CREATE TABLE "lkpEnvVarsAqua" (
	`fullName`	TEXT,
	`gridName`	TEXT,
	`description`	TEXT,
	`dataType`	TEXT,
	`multiplier`	TEXT,
	`windowShape`	TEXT,
	`windowSize`	TEXT,
	`derivedFrom`	TEXT,
	`originalSource`	TEXT,
	`comments`	TEXT,
	`distToGrid`	INTEGER,
	`correlatedVarGroupings`	INTEGER,
	`use_A`	INTEGER,
	PRIMARY KEY(`gridName`)
);
CREATE TABLE "lkpEnvVars" (
	`fullName`	TEXT,
	`gridName`	TEXT,
	`description`	TEXT,
	`dataType`	TEXT,
	`multiplier`	TEXT,
	`windowShape`	TEXT,
	`windowSize`	TEXT,
	`derivedFrom`	TEXT,
	`originalSource`	TEXT,
	`comments`	TEXT,
	`distToGrid`	INTEGER,
	`correlatedVarGroupings`	INTEGER,
	`use_T`	INTEGER,
	`use_K`	INTEGER,
	`use_B`	INTEGER,
	`use_S`	INTEGER,
	PRIMARY KEY(`gridName`)
);
CREATE TABLE "lkpDataSources" (
	`DataSourcesID`	INTEGER NOT NULL,
	`ProgramName`	TEXT,
	`State`	TEXT,
	`DataProvidedDate`	TEXT,
	`DataSourcesCode`	TEXT,
	PRIMARY KEY(`DataSourcesID`)
);
CREATE VIEW latestModelRun AS
SELECT a.modelRunName modelRunName, a.CODE species_code,
	a.ct total_model_runs,
	b.COMMONNAME common_name, 
	datetime(modelEndTime, 'unixepoch', 'localtime') as modelEndTime
FROM
	(SELECT * FROM
	(SELECT CODE, count(CODE) ct, max(modelEndTime) as modelEndTime from tblModelRuns
	group by CODE) JOIN
	tblModelRuns
	USING (CODE, modelEndTime)) a,
	lkpSpecies b
WHERE
	a.CODE = b.CODE;
COMMIT;
