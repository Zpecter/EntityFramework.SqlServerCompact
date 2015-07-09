
SET QUOTED_IDENTIFIER ON
GO

/* Set DATEFORMAT so that the date strings are interpreted correctly regardless of
   the default DATEFORMAT on the server.
*/
SET DATEFORMAT mdy
GO

SET ANSI_NULLS ON
GO

USE "E2E"
GO

if exists (select * from sysobjects where id = object_id('dbo.AllDataTypes') and sysstat & 0xf = 3)
	DROP TABLE "dbo"."AllDataTypes"
GO

if exists (select * from sysobjects where id = object_id('dbo.PropertyConfiguration') and sysstat & 0xf = 3)
	DROP TABLE "dbo"."PropertyConfiguration"
GO

if exists (select * from sysobjects where id = object_id('[dbo].[Test Spaces Keywords Table]') and sysstat & 0xf = 3)
	DROP TABLE "dbo"."Test Spaces Keywords Table"
GO

if exists (select * from sysobjects where id = object_id('dbo.OneToManyDependent') and sysstat & 0xf = 3)
	drop table "dbo"."OneToManyDependent"
GO

if exists (select * from sysobjects where id = object_id('dbo.OneToManyPrincipal') and sysstat & 0xf = 3)
	drop table "dbo"."OneToManyPrincipal"
GO

if exists (select * from sysobjects where id = object_id('dbo.OneToOneDependent') and sysstat & 0xf = 3)
	drop table "dbo"."OneToOneDependent"
GO

if exists (select * from sysobjects where id = object_id('dbo.OneToOnePrincipal') and sysstat & 0xf = 3)
	drop table "dbo"."OneToOnePrincipal"
GO

if exists (select * from sysobjects where id = object_id('dbo.OneToOneSeparateFKDependent') and sysstat & 0xf = 3)
	drop table "dbo"."OneToOneSeparateFKDependent"
GO

if exists (select * from sysobjects where id = object_id('dbo.OneToOneSeparateFKPrincipal') and sysstat & 0xf = 3)
	drop table "dbo"."OneToOneSeparateFKPrincipal"
GO

if exists (select * from sysobjects where id = object_id('dbo.TableWithUnmappablePrimaryKeyColumn') and sysstat & 0xf = 3)
	drop table "dbo"."TableWithUnmappablePrimaryKeyColumn"
GO

if exists (select * from sysobjects where id = object_id('dbo.ReferredToByTableWithUnmappablePrimaryKeyColumn') and sysstat & 0xf = 3)
	drop table "dbo"."ReferredToByTableWithUnmappablePrimaryKeyColumn"
GO

if exists (select * from sysobjects where id = object_id('dbo.SelfReferencing') and sysstat & 0xf = 3)
	drop table "dbo"."SelfReferencing"
GO

CREATE TABLE "dbo"."AllDataTypes"(
	"AllDataTypesID" "int" PRIMARY KEY,
	"bigintColumn" "bigint" NOT NULL,
	"bitColumn" "bit" NOT NULL,
	"decimalColumn" "decimal" NOT NULL,
	"intColumn" "int" NOT NULL,
	"moneyColumn" "money" NOT NULL,
	"numericColumn" "numeric" NOT NULL,
	"smallintColumn" "smallint" NOT NULL,
	"tinyintColumn" "tinyint" NOT NULL,
	"floatColumn" "float" NOT NULL,
	"realColumn" "real" NULL,
	"datetimeColumn" "datetime" NULL,
	"ncharColumn" "nchar" NULL,
	"ntextColumn" "ntext" NULL,
	"nvarcharColumn" "nvarchar" NULL,
	"binaryColumn" "binary" NULL,
	"imageColumn" "image" NULL,
	"varbinaryColumn" "varbinary" NULL,
	"timestampColumn" "timestamp" NULL,
	"uniqueidentifierColumn" "uniqueidentifier" NULL,
)

GO

CREATE TABLE "dbo"."PropertyConfiguration"(
	"PropertyConfigurationID" "tinyint" IDENTITY(1, 1) PRIMARY KEY, -- tests error message about tinyint identity columns
	"WithDateDefaultExpression" "datetime2" NOT NULL DEFAULT (getdate()),
	"WithGuidDefaultExpression" "uniqueidentifier" NOT NULL DEFAULT (newsequentialid()),
	"WithDefaultValue" "int" NOT NULL DEFAULT ((-1)),
	"WithMoneyDefaultValue" "money" NOT NULL DEFAULT ((0.00)),
	"A" "int" NOT NULL,
	"B" "int" NOT NULL,
	"TimestampColumn" "timestamp" NOT NULL,
)

GO

CREATE TABLE "dbo"."Test Spaces Keywords Table"(
	"Test Spaces Keywords TableID" "int" PRIMARY KEY,
	"abstract" "int" NOT NULL,
	"class" "int" NULL,
	"volatile" "int" NOT NULL,
	"Spaces In Column" "int" NULL,
	"Tabs	In	Column" "int" NOT NULL,
	"@AtSymbolAtStartOfColumn" "int" NULL,
	"@Multiple@At@Symbols@In@Column" "int" NOT NULL,
	"Commas,In,Column" "int" NULL,
	"$Dollar$Sign$Column" "int" NOT NULL,
	"!Exclamation!Mark!Column" "int" NULL,
	"""Double""Quotes""Column" "int" NULL,
	"\Backslashes\In\Column" "int" NULL,
)

GO

CREATE TABLE "SelfReferencing" (
	"SelfReferencingID" "int" PRIMARY KEY ,
	"Name" nvarchar (20) NOT NULL ,
	"Description" nvarchar (100) NOT NULL ,
	"SelfReferenceFK" "int" NULL ,
	CONSTRAINT "FK_SelfReferencing" FOREIGN KEY 
	(
		"SelfReferenceFK"
	) REFERENCES "dbo"."SelfReferencing" (
		"SelfReferencingID"
	)
)

GO

CREATE TABLE "OneToManyPrincipal" (
"OneToManyPrincipalID1" "int" ,
"OneToManyPrincipalID2" "int" ,
"Other" nvarchar (20) NOT NULL ,
	CONSTRAINT "PK_OneToManyPrincipal" PRIMARY KEY  CLUSTERED 
	(
		"OneToManyPrincipalID1", "OneToManyPrincipalID2"
	)
)

GO

CREATE TABLE "OneToManyDependent" (
"OneToManyDependentID1" "int" ,
"OneToManyDependentID2" "int" ,
"SomeDependentEndColumn" nvarchar (20) NOT NULL ,
"OneToManyDependentFK2" "int" NULL , -- deliberately put FK columns in other order to make sure we get correct order in key
"OneToManyDependentFK1" "int" NULL ,
	CONSTRAINT "PK_OneToManyDependent" PRIMARY KEY  CLUSTERED 
	(
		"OneToManyDependentID1", "OneToManyDependentID2"
	),
	CONSTRAINT "FK_OneToManyDependent" FOREIGN KEY 
	(
		"OneToManyDependentFK1", "OneToManyDependentFK2"
	) REFERENCES "dbo"."OneToManyPrincipal" (
		"OneToManyPrincipalID1", "OneToManyPrincipalID2"
	)
)

GO

CREATE TABLE "OneToOnePrincipal" (
"OneToOnePrincipalID1" "int" ,
"OneToOnePrincipalID2" "int" ,
"SomeOneToOnePrincipalColumn" nvarchar (20) NOT NULL ,
	CONSTRAINT "PK_OneToOnePrincipal" PRIMARY KEY  CLUSTERED 
	(
		"OneToOnePrincipalID1", "OneToOnePrincipalID2"
	)
)

GO

CREATE TABLE "OneToOneDependent" (
"OneToOneDependentID1" "int" ,
"OneToOneDependentID2" "int" ,
"SomeDependentEndColumn" nvarchar (20) NOT NULL ,
	CONSTRAINT "PK_OneToOneDependent" PRIMARY KEY  CLUSTERED 
	(
		"OneToOneDependentID1", "OneToOneDependentID2"
	),
	CONSTRAINT "FK_OneToOneDependent" FOREIGN KEY 
	(
		"OneToOneDependentID1", "OneToOneDependentID2"
	) REFERENCES "dbo"."OneToOnePrincipal" (
		"OneToOnePrincipalID1", "OneToOnePrincipalID2"
	),
)

GO

CREATE TABLE "OneToOneSeparateFKPrincipal" (
"OneToOneSeparateFKPrincipalID1" "int" ,
"OneToOneSeparateFKPrincipalID2" "int" ,
"SomeOneToOneSeparateFKPrincipalColumn" nvarchar (20) NOT NULL ,
	CONSTRAINT "PK_OneToOneSeparateFKPrincipal" PRIMARY KEY  CLUSTERED 
	(
		"OneToOneSeparateFKPrincipalID1", "OneToOneSeparateFKPrincipalID2"
	)
)

GO

CREATE TABLE "OneToOneSeparateFKDependent" (
"OneToOneSeparateFKDependentID1" "int" ,
"OneToOneSeparateFKDependentID2" "int" ,
"SomeDependentEndColumn" nvarchar (20) NOT NULL ,
"OneToOneSeparateFKDependentFK1" "int" NULL ,
"OneToOneSeparateFKDependentFK2" "int" NULL ,
	CONSTRAINT "PK_OneToOneSeparateFKDependent" PRIMARY KEY  CLUSTERED 
	(
		"OneToOneSeparateFKDependentID1", "OneToOneSeparateFKDependentID2"
	),
	CONSTRAINT "FK_OneToOneSeparateFKDependent" FOREIGN KEY 
	(
		"OneToOneSeparateFKDependentFK1", "OneToOneSeparateFKDependentFK2"
	) REFERENCES "dbo"."OneToOneSeparateFKPrincipal" (
		"OneToOneSeparateFKPrincipalID1", "OneToOneSeparateFKPrincipalID2"
	),
	CONSTRAINT "UK_OneToOneSeparateFKDependent" UNIQUE
	(
		"OneToOneSeparateFKDependentFK1", "OneToOneSeparateFKDependentFK2"
	)
)

GO
