-------------------------------------------------
-- Enterprise Architect Schema Script 
-- DBMS:     MS SQL Server  
-- VERSION:  2005, 2008                        
-- CREATED:  21/1/2010 			
-- EA BUILD: 852	  
-------------------------------------------------
PRINT 'Dropping existing tables...'
GO
IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_attribute]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_attribute]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_attributeconstraints]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_attributeconstraints]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_attributetag]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_attributetag]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_authors]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_authors]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_cardinality]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_cardinality]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_category]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_category]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_clients]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_clients]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_complexitytypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_complexitytypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_connector]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_connector]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_connectorconstraint]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_connectorconstraint]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_connectortag]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_connectortag]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_connectortypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_connectortypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_constants]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_constants]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_constrainttypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_constrainttypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_datatypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_datatypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_diagram]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_diagram]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_diagramlinks]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_diagramlinks]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_diagramobjects]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_diagramobjects]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_diagramtypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_diagramtypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_document]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_document]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_ecf]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_ecf]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_efforttypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_efforttypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_files]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_files]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_genopt]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_genopt]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_glossary]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_glossary]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_html]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_html]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_image]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_image]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_implement]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_implement]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_issues]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_issues]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_lists]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_lists]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_mainttypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_mainttypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_method]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_method]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_metrictypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_metrictypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_object]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_object]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectconstraint]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectconstraint]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objecteffort]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objecteffort]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectfiles]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectfiles]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectmetrics]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectmetrics]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectproblems]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectproblems]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectproperties]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectproperties]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectrequires]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectrequires]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectresource]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectresource]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectrisks]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectrisks]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objectscenarios]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objectscenarios]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objecttests]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objecttests]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objecttrx]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objecttrx]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_objecttypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_objecttypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_ocf]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_ocf]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_operation]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_operation]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_operationparams]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_operationparams]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_operationposts]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_operationposts]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_operationpres]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_operationpres]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_operationtag]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_operationtag]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_package]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_package]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_palette]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_palette]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_paletteitem]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_paletteitem]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_phase]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_phase]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_primitives]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_primitives]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_problemtypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_problemtypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_projectroles]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_projectroles]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_propertytypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_propertytypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_requiretypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_requiretypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_resources]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_resources]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_risktypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_risktypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_roleconstraint]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_roleconstraint]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_rtf]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_rtf]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_rtfreport]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_rtfreport]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_rules]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_rules]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_scenariotypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_scenariotypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_script]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_script]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_secgroup]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_secgroup]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_secgrouppermission]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_secgrouppermission]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_seclocks]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_seclocks]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_secpermission]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_secpermission]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_secpolicies]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_secpolicies]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_secuser]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_secuser]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_secusergroup]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_secusergroup]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_secuserpermission]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_secuserpermission]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_snapshot]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_snapshot]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_statustypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_statustypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_stereotypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_stereotypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_taggedvalue]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_taggedvalue]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_tasks]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_tasks]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_tcf]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_tcf]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_template]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_template]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_testclass]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_testclass]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_testplans]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_testplans]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_testtypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_testtypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_trxtypes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_trxtypes]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_umlpattern]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_umlpattern]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_version]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_version]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_xref]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_xref]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_xrefsystem]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_xrefsystem]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[t_xrefuser]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[t_xrefuser]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usysOldTables]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[usysOldTables]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usysQueries]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[usysQueries]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usysTables]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[usysTables]
GO

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[usys_system]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[usys_system]
GO
----------------------------------------------------------------------------------------------------
PRINT 'Creating tables...'
PRINT '- table t_attribute...'
GO
CREATE TABLE [dbo].[t_attribute]
(
	[Object_ID] 	  [int] NULL CONSTRAINT [DF_attribute_Object_ID]  DEFAULT 0,
	[Name] 			  [nvarchar](255) NULL,
	[Scope] 		  [nvarchar](50) NULL,
	[Stereotype] 	  [nvarchar](50) NULL,
	[Containment] 	  [nvarchar](50) NULL,
	[IsStatic] 		  [int] NULL CONSTRAINT [DF_attribute_IsStatic]        DEFAULT 0,
	[IsCollection] 	  [int] NULL CONSTRAINT [DF_attribute_IsCollection]    DEFAULT 0,
	[IsOrdered] 	  [int] NULL CONSTRAINT [DF_attribute_IsOrdered]  	 DEFAULT 0,
	[AllowDuplicates] [int] NULL CONSTRAINT [DF_attribute_AllowDuplicates] DEFAULT 0,
	[LowerBound] 	  [nvarchar](50) NULL,
	[UpperBound] 	  [nvarchar](50) NULL,
	[Container] 	  [nvarchar](50) NULL,
	[Notes] 		  [ntext] NULL,
	[Derived] 		  [nvarchar](1) NULL,
	[ID] 			  [int] IDENTITY(1,1) NOT NULL,
	[Pos] 			  [int] NULL,
	[GenOption] 	  [ntext] NULL,
	[Length] 		  [int] NULL,
	[Precision] 	  [int] NULL,
	[Scale] 		  [int] NULL,
	[Const] 		  [int] NULL,
	[Style] 		  [nvarchar](255) NULL,
	[Classifier] 	  [nvarchar](50) NULL,
	[Default] 		  [ntext] NULL,
	[Type] 			  [nvarchar](255) NULL,
	[ea_guid] 		  [nvarchar](50) NULL,
	[StyleEx] 		  [ntext] NULL,
 	CONSTRAINT [PK_attribute] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)
)
GO
PRINT '  - indexes for t_attribute...'
GO
CREATE NONCLUSTERED INDEX [IX_attribute_Classifier] ON [dbo].[t_attribute] 
(
	[Classifier] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_attribute_Type] ON [dbo].[t_attribute] 
(
	[Type] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_attribute_Name] ON [dbo].[t_attribute] 
(
	[Name] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_attribute_Object_ID] ON [dbo].[t_attribute] 
(
	[Object_ID] ASC
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_attribute_ea_guid] ON [dbo].[t_attribute] 
(
	[ea_guid] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_attributeconstraints...'
GO
CREATE TABLE [dbo].[t_attributeconstraints]
(
	[Object_ID]  [int] NULL CONSTRAINT [DF_attributeconstraints_Object_ID] DEFAULT 0,
	[Constraint] [nvarchar](255) NOT NULL,
	[AttName] 	 [nvarchar](255) NULL,
	[Type] 		 [nvarchar](255) NULL,
	[Notes] 	 [ntext] NULL,
	[ID] 		 [int] NOT NULL,
	CONSTRAINT [PK_attributeconstraints] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC,
		[Constraint] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_attributetag...'
GO
CREATE TABLE [dbo].[t_attributetag]
(
	[PropertyID] [int] IDENTITY(1,1) NOT NULL,
	[ElementID]  [int] NULL,
	[Property] 	 [nvarchar](255) NULL,
	[VALUE] 	 [nvarchar](255) NULL,
	[NOTES] 	 [ntext] NULL,
	[ea_guid] 	 [nvarchar](40) NULL,
	CONSTRAINT [PK_attributetag] PRIMARY KEY CLUSTERED 
	(
		[PropertyID] ASC
	)
) 
GO
PRINT '  - indexes for t_attributetag...'
GO
CREATE NONCLUSTERED INDEX [IX_attributetag_ElementID] ON [dbo].[t_attributetag] 
(
	[ElementID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_attributetag_VALUE] ON [dbo].[t_attributetag] 
(
	[VALUE] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_authors...'
GO
CREATE TABLE [dbo].[t_authors]
(
	[AuthorName] [nvarchar](255) NOT NULL,
	[Roles] 	 [nvarchar](255) NULL,
	[Notes] 	 [nvarchar](255) NULL,
 	CONSTRAINT [PK_authors] PRIMARY KEY CLUSTERED 
	(
		[AuthorName] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_cardinality...'
GO
CREATE TABLE [dbo].[t_cardinality]
(
	[Cardinality] [nvarchar](50) NOT NULL,
 	CONSTRAINT [PK_cardinality] PRIMARY KEY CLUSTERED 
	(
		[Cardinality] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_category...'
GO
CREATE TABLE [dbo].[t_category]
(
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[Name] 		 [nvarchar](255) NULL,
	[Type] 		 [nvarchar](255) NULL,
	[NOTES] 	 [ntext] NULL,
 	CONSTRAINT [PK_category] PRIMARY KEY CLUSTERED 
	(
		[CategoryID] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_clients...'
GO
CREATE TABLE [dbo].[t_clients]
(
	[Name] 		   [nvarchar](255) NOT NULL,
	[Organisation] [nvarchar](255) NULL,
	[Phone1] 	   [nvarchar](50) NULL,
	[Phone2] 	   [nvarchar](50) NULL,
	[Mobile] 	   [nvarchar](50) NULL,
	[Fax] 		   [nvarchar](50) NULL,
	[Email] 	   [nvarchar](50) NULL,
	[Roles] 	   [nvarchar](255) NULL,
	[Notes] 	   [nvarchar](255) NULL,
 	CONSTRAINT [PK_clients] PRIMARY KEY CLUSTERED 
	(
		[Name] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_complexitytypes...'
GO
CREATE TABLE [dbo].[t_complexitytypes]
(
	[Complexity] 	[nvarchar](50) NOT NULL,
	[NumericWeight] [int] NULL CONSTRAINT [DF_complexitytypes_NumericWeight]  DEFAULT 0,
 	CONSTRAINT [PK_complexitytypes] PRIMARY KEY CLUSTERED 
	(
		[Complexity] ASC
	)
)
GO
PRINT '  - indexes for t_complexitytypes...'
GO
CREATE NONCLUSTERED INDEX [IX_complexitytypes_NumericWeight] ON [dbo].[t_complexitytypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_connector...'
GO
CREATE TABLE [dbo].[t_connector]
(
	[Connector_ID] 		[int] IDENTITY(1,1) NOT NULL,
	[Name] 				[nvarchar](255) NULL,
	[Direction] 		[nvarchar](50) NULL,
	[Notes] 			[ntext] NULL,
	[Connector_Type] 	[nvarchar](50) NULL,
	[SubType] 			[nvarchar](50) NULL,
	[SourceCard] 		[nvarchar](50) NULL,
	[SourceAccess] 		[nvarchar](50) NULL,
	[SourceElement] 	[nvarchar](50) NULL,
	[DestCard] 			[nvarchar](50) NULL,
	[DestAccess] 		[nvarchar](50) NULL,
	[DestElement] 		[nvarchar](50) NULL,
	[SourceRole] 		[nvarchar](50) NULL,
	[SourceRoleType] 	[nvarchar](50) NULL,
	[SourceRoleNote] 	[ntext] NULL,
	[SourceContainment] [nvarchar](50) NULL,
	[SourceIsAggregate]	[int] NULL CONSTRAINT [DF_connector_SourcIsAggregate] DEFAULT 0,
	[SourceIsOrdered] 	[int] NULL CONSTRAINT [DF_connector_SourceIsOrdered]  DEFAULT 0,
	[SourceQualifier] 	[nvarchar](50) NULL,
	[DestRole] 			[nvarchar](255) NULL,
	[DestRoleType] 		[nvarchar](50) NULL,
	[DestRoleNote] 		[ntext] NULL,
	[DestContainment] 	[nvarchar](50) NULL,
	[DestIsAggregate] 	[int] NULL CONSTRAINT [DF_connector_DestIsAggregate] DEFAULT 0,
	[DestIsOrdered] 	[int] NULL CONSTRAINT [DF_connector_DestIsOrdered]   DEFAULT 0,
	[DestQualifier] 	[nvarchar](50) NULL,
	[Start_Object_ID] 	[int] NULL CONSTRAINT [DF_connector_Start_Object_ID] DEFAULT 0,
	[End_Object_ID] 	[int] NULL CONSTRAINT [DF_connector_End_Object_ID]   DEFAULT 0,
	[Top_Start_Label] 	[nvarchar](50) NULL,
	[Top_Mid_Label] 	[nvarchar](50) NULL,
	[Top_End_Label] 	[nvarchar](50) NULL,
	[Btm_Start_Label] 	[nvarchar](50) NULL,
	[Btm_Mid_Label] 	[nvarchar](50) NULL,
	[Btm_End_Label] 	[nvarchar](50) NULL,
	[Start_Edge] 		[int] NULL CONSTRAINT [DF_connector_Start_Edge] DEFAULT 0,
	[End_Edge] 			[int] NULL CONSTRAINT [DF_connector_End_Edge]  	DEFAULT 0,
	[PtStartX] 			[int] NULL CONSTRAINT [DF_connector_PtStartX]  	DEFAULT 0,
	[PtStartY] 			[int] NULL CONSTRAINT [DF_connector_PtStartY]  	DEFAULT 0,
	[PtEndX] 			[int] NULL CONSTRAINT [DF_connector_PtEndX]  	DEFAULT 0,
	[PtEndY] 			[int] NULL CONSTRAINT [DF_connector_PtEndY]  	DEFAULT 0,
	[SeqNo] 			[int] NULL CONSTRAINT [DF_connector_SeqNo]  	DEFAULT 0,
	[HeadStyle] 		[int] NULL CONSTRAINT [DF_connector_HeadStyle]  DEFAULT 0,
	[LineStyle] 		[int] NULL CONSTRAINT [DF_connector_LineStyle]  DEFAULT 0,
	[RouteStyle] 		[int] NULL CONSTRAINT [DF_connector_RouteStyle] DEFAULT 0,
	[IsBold] 			[int] NULL CONSTRAINT [DF_connector_IsBold]  	DEFAULT 0,
	[LineColor] 		[int] NULL CONSTRAINT [DF_connector_LineColor]  DEFAULT 0,
	[Stereotype] 		[nvarchar](50) NULL,
	[VirtualInheritance][nvarchar](1) NULL,
	[LinkAccess] 		[nvarchar](50) NULL,
	[PDATA1] 			[nvarchar](255) NULL,
	[PDATA2] 			[ntext] NULL,
	[PDATA3] 			[nvarchar](255) NULL,
	[PDATA4] 			[nvarchar](255) NULL,
	[PDATA5] 			[ntext] NULL,
	[DiagramID] 		[int] NULL CONSTRAINT [DF_connector_DiagramID]  DEFAULT 0,
	[ea_guid] 			[nvarchar](40) NULL,
	[SourceConstraint] 	[nvarchar](255) NULL,
	[DestConstraint] 	[nvarchar](255) NULL,
	[SourceIsNavigable] [int] NOT NULL CONSTRAINT [DF_connector_SourcIsNavigable] DEFAULT 0,
	[DestIsNavigable] 	[int] NOT NULL CONSTRAINT [DF_connector_DestIsNavigable]  DEFAULT 0,
	[IsRoot] 			[int] NOT NULL CONSTRAINT [DF_connector_IsRoot]  		  DEFAULT 0,
	[IsLeaf] 			[int] NOT NULL CONSTRAINT [DF_connector_IsLeaf]  		  DEFAULT 0,
	[IsSpec] 			[int] NOT NULL CONSTRAINT [DF_connector_IsSpec]  		  DEFAULT 0,
	[SourceChangeable]  [nvarchar](12) NULL,
	[DestChangeable]    [nvarchar](12) NULL,
	[SourceTS] 			[nvarchar](12) NULL,
	[DestTS] 			[nvarchar](12) NULL,
	[StateFlags] 		[nvarchar](255) NULL,
	[ActionFlags] 		[nvarchar](255) NULL,
	[IsSignal] 			[int] NOT NULL CONSTRAINT [DF_connector_IsSignal]   DEFAULT 0,
	[IsStimulus] 		[int] NOT NULL CONSTRAINT [DF_connector_IsStimulus] DEFAULT 0,
	[DispatchAction] 	[nvarchar](255) NULL,
	[Target2] 			[int] NULL,
	[StyleEx] 			[ntext] NULL,
	[SourceStereotype] 	[nvarchar](255) NULL,
	[DestStereotype] 	[nvarchar](255) NULL,
	[SourceStyle] 		[ntext] NULL,
	[DestStyle] 		[ntext] NULL,
	[EventFlags] 		[nvarchar](255) NULL,
 	CONSTRAINT [PK_connector] PRIMARY KEY CLUSTERED 
	(
		[Connector_ID] ASC
	)
)
GO
PRINT '  - indexes for t_connector...'
GO
CREATE NONCLUSTERED INDEX [IX_connector_Connector_Type] ON [dbo].[t_connector] 
(
	[Connector_Type] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_connector_DiagramID] ON [dbo].[t_connector] 
(
	[DiagramID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_connector_End_Object_ID] ON [dbo].[t_connector] 
(
	[End_Object_ID] ASC
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_connector_ea_guid] ON [dbo].[t_connector] 
(
	[ea_guid] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_connector_End_Object_ID_Connector_ID] ON [dbo].[t_connector] 
(
	[End_Object_ID] ASC,
	[Connector_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_connector_seqno] ON [dbo].[t_connector] 
(
	[SeqNo] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_connector_Start_Object_ID_Connector_ID] ON [dbo].[t_connector] 
(
	[Start_Object_ID] ASC,
	[Connector_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_connector_Start_Object_ID] ON [dbo].[t_connector] 
(
	[Start_Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_connectorconstraint...'
GO
CREATE TABLE [dbo].[t_connectorconstraint]
(
	[ConnectorID] 	 [int] NOT NULL CONSTRAINT [DF_connectorconstrait_ConnectorID] DEFAULT 0,
	[Constraint] 	 [nvarchar](255) NOT NULL,
	[ConstraintType] [nvarchar](50) NULL,
	[Notes] 		 [ntext] NULL,
 	CONSTRAINT [PK_connectorconstraint] PRIMARY KEY CLUSTERED 
	(
		[ConnectorID] ASC,
		[Constraint] ASC
	)
)
GO
PRINT '  - indexes for t_connectorconstraint...'
GO
CREATE NONCLUSTERED INDEX [IX_connectorconstraint_Constraint] ON [dbo].[t_connectorconstraint] 
(
	[Constraint] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_connectorconstraint_ConnectorID] ON [dbo].[t_connectorconstraint] 
(
	[ConnectorID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_connectortag...'
GO
CREATE TABLE [dbo].[t_connectortag]
(
	[PropertyID] [int] IDENTITY(1,1) NOT NULL,
	[ElementID]  [int] NULL,
	[Property]   [nvarchar](255) NULL,
	[VALUE] 	 [nvarchar](255) NULL,
	[NOTES] 	 [ntext] NULL,
	[ea_guid] 	 [nvarchar](40) NULL,
 	CONSTRAINT [PK_connectortag] PRIMARY KEY CLUSTERED 
	(
		[PropertyID] ASC
	)
)
GO
PRINT '  - indexes for t_connectortag...'
GO
CREATE NONCLUSTERED INDEX [ElementKey] ON [dbo].[t_connectortag] 
(
	[ElementID] ASC
)
GO
CREATE NONCLUSTERED INDEX [ix_connectortag_property] ON [dbo].[t_connectortag] 
(
	[Property] ASC
)
GO
CREATE NONCLUSTERED INDEX [ix_connectortag_value] ON [dbo].[t_connectortag] 
(
	[VALUE] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_connectortypes...'
GO
CREATE TABLE [dbo].[t_connectortypes]
(
	[Connector_Type] [nvarchar](50) NOT NULL,
	[Description] 	 [nvarchar](50) NULL,
 	CONSTRAINT [PK_connectortypes] PRIMARY KEY CLUSTERED 
	(
		[Connector_Type] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_constants...'
GO
CREATE TABLE [dbo].[t_constants]
(
	[ConstantName]  [nvarchar](50) NOT NULL,
	[ConstantValue] [nvarchar](255) NULL,
 	CONSTRAINT [PK_constants] PRIMARY KEY CLUSTERED 
	(
		[ConstantName] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_constrainttypes...'
GO
CREATE TABLE [dbo].[t_constrainttypes]
(
	[Constraint]  [nvarchar](16) NOT NULL,
	[Description] [nvarchar](50) NULL,
	[Notes] 	  [ntext] NULL,
 	CONSTRAINT [PK_constrainttypes] PRIMARY KEY CLUSTERED 
	(
		[Constraint] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_datatypes...'
GO
CREATE TABLE [dbo].[t_datatypes]
(
	[Type] [nvarchar](50) NULL,
	[ProductName]  [nvarchar](50) NULL,
	[DataType] 	   [nvarchar](50) NULL,
	[Size] 		   [int] NULL,
	[MaxLen] 	   [int] NULL,
	[MaxPrec] 	   [int] NULL,
	[MaxScale] 	   [int] NULL CONSTRAINT [DF_datatyps_MaxScale]  DEFAULT 0,
	[DefaultLen]   [int] NULL,
	[DefaultPrec]  [int] NULL,
	[DefaultScale] [int] NULL,
	[User] 		   [int] NULL,
	[PDATA1] 	   [nvarchar](255) NULL,
	[PDATA2] 	   [nvarchar](255) NULL,
	[PDATA3] 	   [nvarchar](255) NULL,
	[PDATA4] 	   [nvarchar](255) NULL,
	[HasLength]    [nvarchar](50) NULL,
	[GenericType]  [nvarchar](255) NULL,
	[DatatypeID]   [int] IDENTITY(1,1) NOT NULL,
 	CONSTRAINT [PK_datatypes] PRIMARY KEY CLUSTERED 
	(
		[DatatypeID] ASC
	)
)
GO
PRINT '  - indexes for t_datatypes...'
GO
CREATE NONCLUSTERED INDEX [IX_datatype_ProductName] ON [dbo].[t_datatypes] 
(
	[ProductName] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_datatype_DataType] ON [dbo].[t_datatypes] 
(
	[DataType] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_diagram...'
GO
CREATE TABLE [dbo].[t_diagram]
(
	[Diagram_ID] 		  [int] IDENTITY(1,1) NOT NULL,
	[Package_ID] 		  [int] NULL CONSTRAINT [DF_diagram_Package_ID]  DEFAULT 1,
	[ParentID] 			  [int] NULL CONSTRAINT [DF_diagram_ParentID]  DEFAULT 0,
	[Diagram_Type] 		  [nvarchar](50) NULL,
	[Name] 				  [nvarchar](255) NULL,
	[Version] 			  [nvarchar](50) NULL CONSTRAINT [DF_diagram_Version]  DEFAULT '1.0',
	[Author] 			  [nvarchar](255) NULL,
	[ShowDetails] 		  [int] NULL CONSTRAINT [DF_diagram_ShowDetails]  DEFAULT 0,
	[Notes] 			  [ntext] NULL,
	[Stereotype] 		  [nvarchar](50) NULL,
	[AttPub] 			  [int] NOT NULL CONSTRAINT [DF_diagram_AttPub]  DEFAULT 1,
	[AttPri] 			  [int] NOT NULL CONSTRAINT [DF_diagram_AttPri]  DEFAULT 1,
	[AttPro] 			  [int] NOT NULL CONSTRAINT [DF_diagram_AttPro]  DEFAULT 1,
	[Orientation] 		  [nvarchar](1) NULL CONSTRAINT [DF_diagram_Orientation]  DEFAULT 'P',
	[cx] 				  [int] NULL CONSTRAINT [DF_diagram_cx]  DEFAULT 0,
	[cy] 				  [int] NULL CONSTRAINT [DF_diagram_cy]  DEFAULT 0,
	[Scale] 			  [int] NULL CONSTRAINT [DF_diagram_Scale]  DEFAULT 100,
	[CreatedDate] 		  [datetime] NULL CONSTRAINT [DF_diagram_CreatedDate]  DEFAULT (CONVERT([datetime],CONVERT([varchar],getdate(),(1)),(1))),
	[ModifiedDate] 		  [datetime] NULL CONSTRAINT [DF_diagram_ModifiedDate]  DEFAULT (CONVERT([datetime],CONVERT([varchar],getdate(),(1)),(1))),
	[HTMLPath] 			  [nvarchar](255) NULL,
	[ShowForeign] 		  [int] NOT NULL CONSTRAINT [DF_diagram_ShowForeign]  DEFAULT 1,
	[ShowBorder] 		  [int] NOT NULL CONSTRAINT [DF_diagram_ShowBorder]  DEFAULT 1,
	[ShowPackageContents] [int] NOT NULL CONSTRAINT [DF_diagram_ShowPackageContents]  DEFAULT 1,
	[PDATA] 			  [nvarchar](255) NULL,
	[Locked] 			  [int] NOT NULL CONSTRAINT [DF_diagram_Locked]  DEFAULT 0,
	[ea_guid] 			  [nvarchar](40) NULL,
	[TPos] 				  [int] NULL,
	[Swimlanes] 		  [nvarchar](255) NULL,
	[StyleEx] 			  [ntext] NULL,
 	CONSTRAINT [PK_diagram] PRIMARY KEY CLUSTERED 
	(
		[Diagram_ID] ASC
	)
)
GO
PRINT '  - indexes for t_diagram...'
GO
CREATE NONCLUSTERED INDEX [IX_diagram_Diagram_Type] ON [dbo].[t_diagram] 
(
	[Diagram_Type] ASC
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_diagram_ea_guid] ON [dbo].[t_diagram] 
(
	[ea_guid] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_diagram_Package_ID] ON [dbo].[t_diagram] 
(
	[Package_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_diagram_ParentID] ON [dbo].[t_diagram] 
(
	[ParentID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_diagramlinks...'
GO
CREATE TABLE [dbo].[t_diagramlinks]
(
	[DiagramID]   [int] NULL,
	[ConnectorID] [int] NULL,
	[Geometry]    [ntext] NULL,
	[Style] 	  [nvarchar](255) NULL,
	[Hidden] 	  [int] NOT NULL CONSTRAINT [DF_diagramlinks_Hidden]  DEFAULT 0,
	[Path] 		  [nvarchar](255) NULL,
	[Instance_ID] [int] IDENTITY(1,1) NOT NULL,
 	CONSTRAINT [PK_diagramlinks] PRIMARY KEY CLUSTERED 
	(
		[Instance_ID] ASC
	)
)
GO
PRINT '  - indexes for t_diagramlinks...'
GO
CREATE NONCLUSTERED INDEX [ConnectorID] ON [dbo].[t_diagramlinks] 
(
	[ConnectorID] ASC
)
GO
CREATE NONCLUSTERED INDEX [DiagramID] ON [dbo].[t_diagramlinks] 
(
	[DiagramID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_diagramobjects...'
GO
CREATE TABLE [dbo].[t_diagramobjects]
(
	[Diagram_ID]  [int] NULL CONSTRAINT [DF_diagramobjects_Diagram_ID]  DEFAULT 0,
	[Object_ID]   [int] NULL CONSTRAINT [DF_diagramobjects_Object_ID]  DEFAULT 0,
	[RectTop] 	  [int] NULL CONSTRAINT [DF_diagramobjects_RectTop]  DEFAULT 0,
	[RectLeft]    [int] NULL CONSTRAINT [DF_diagramobjects_RectLeft]  DEFAULT 0,
	[RectRight]   [int] NULL CONSTRAINT [DF_diagramobjects_RectRight]  DEFAULT 0,
	[RectBottom]  [int] NULL CONSTRAINT [DF_diagramobjects_RectBottom]  DEFAULT 0,
	[Sequence] 	  [int] NULL CONSTRAINT [DF_diagramobjects_Sequence]  DEFAULT 0,
	[ObjectStyle] [nvarchar](255) NULL,
	[Instance_ID] [int] IDENTITY(1,1) NOT NULL,
 	CONSTRAINT [PK_diagramobjects] PRIMARY KEY CLUSTERED 
	(
		[Instance_ID] ASC
	)
)
GO
PRINT '  - indexes for t_diagramobjects...'
GO
CREATE NONCLUSTERED INDEX [IX_diagramobjects_Diagram_ID] ON [dbo].[t_diagramobjects] 
(
	[Diagram_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_diagramobjects_Object_ID] ON [dbo].[t_diagramobjects] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_diagramtypes...'
GO
CREATE TABLE [dbo].[t_diagramtypes]
(
	[Diagram_Type] [nvarchar](50) NOT NULL,
	[Name] 		   [nvarchar](255) NULL,
	[Package_ID]   [int] NULL CONSTRAINT [DF_diagramtypes_Package_ID]  DEFAULT 0,
 	CONSTRAINT [PK_diagramtypes] PRIMARY KEY CLUSTERED 
	(
		[Diagram_Type] ASC
	)
)
GO
PRINT '  - indexes for t_diagramtypes...'
GO
CREATE NONCLUSTERED INDEX [IX_diagramtypes_Package_ID] ON [dbo].[t_diagramtypes] 
(
	[Package_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_document...'
GO
CREATE TABLE [dbo].[t_document]
(
	[DocID] 	  [nvarchar](40) NOT NULL,
	[DocName] 	  [nvarchar](100) NOT NULL,
	[Notes] 	  [nvarchar](255) NULL,
	[Style] 	  [nvarchar](255) NULL,
	[ElementID]   [nvarchar](40) NOT NULL,
	[ElementType] [nvarchar](50) NOT NULL,
	[StrContent]  [ntext] NULL,
	[BinContent]  [image] NULL,
	[DocType] 	  [nvarchar](100) NULL,
	[Author] 	  [nvarchar](255) NULL,
	[Version] 	  [nvarchar](50) NULL,
	[IsActive] 	  [int] NULL CONSTRAINT [DF_document_IsActive]  DEFAULT 1,
	[Sequence]    [int] NULL CONSTRAINT [DF_document_Sequence]  DEFAULT 0,
	[DocDate] 	  [datetime] NULL,
 	CONSTRAINT [PK_document] PRIMARY KEY CLUSTERED 
	(
		[DocID] ASC
	)
)
GO
PRINT '  - indexes for t_document...'
GO
CREATE NONCLUSTERED INDEX [IX_document_ElementID] ON [dbo].[t_document] 
(
	[ElementID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_ecf...'
GO
CREATE TABLE [dbo].[t_ecf]
(
	[ECFID] 	  [nvarchar](12) NOT NULL,
	[Description] [nvarchar](50) NULL,
	[Weight] 	  [float] NULL CONSTRAINT [DF_ecf_Weight]  DEFAULT 1,
	[Value] 	  [float] NULL CONSTRAINT [DF_ecf_Value]  DEFAULT 0,
	[Notes] 	  [nvarchar](255) NULL,
 	CONSTRAINT [PK_ecf] PRIMARY KEY CLUSTERED 
	(
		[ECFID] ASC
	)
)
GO
PRINT '  - indexes for t_ecf...'
GO
CREATE NONCLUSTERED INDEX [IX_ecf_Weight] ON [dbo].[t_ecf] 
(
	[Weight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_efforttypes...'
GO
CREATE TABLE [dbo].[t_efforttypes]
(
	[EffortType] 	[nvarchar](12) NOT NULL,
	[Description] 	[nvarchar](255) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_efforttypes_NumerWeight]  DEFAULT 0,
	[Notes] 		[nvarchar](255) NULL,
 	CONSTRAINT [PK_efforttypes] PRIMARY KEY CLUSTERED 
	(
		[EffortType] ASC
	)
)
GO
PRINT '  - indexes for t_efforttypes...'
GO
CREATE NONCLUSTERED INDEX [NumericWeight] ON [dbo].[t_efforttypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_files...'
GO
CREATE TABLE [dbo].[t_files]
(
	[FileID] 	[nvarchar](50) NOT NULL,
	[AppliesTo] [nvarchar](50) NOT NULL,
	[Category] 	[nvarchar](100) NOT NULL,
	[Name] 		[nvarchar](150) NOT NULL,
	[File] 		[nvarchar](255) NULL,
	[Notes] 	[ntext] NULL,
	[FileDate] 	[datetime] NULL,
	[FileSize] 	[int] NULL,
 	CONSTRAINT [PK_files] PRIMARY KEY CLUSTERED 
	(
		[FileID] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_genopt...'
GO
CREATE TABLE [dbo].[t_genopt]
(
	[AppliesTo] [nvarchar](12) NULL,
	[Option]    [ntext] NULL
)
GO
CREATE CLUSTERED INDEX [AppliesTo] ON [dbo].[t_genopt] 
(
	[AppliesTo] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_glossary...'
GO
CREATE TABLE [dbo].[t_glossary]
(
	[Term] 		 [nvarchar](255) NULL,
	[Type] 		 [nvarchar](255) NULL,
	[Meaning] 	 [ntext] NULL,
	[GlossaryID] [int] IDENTITY(1,1) NOT NULL,
 	CONSTRAINT [PK_glossary] PRIMARY KEY CLUSTERED 
	(
		[GlossaryID] ASC
	)
) 
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_html...'
GO
CREATE TABLE [dbo].[t_html]
(
	[Type] 	   [nvarchar](50) NULL,
	[Template] [ntext] NULL
)
GO
CREATE CLUSTERED INDEX [htmlType] ON [dbo].[t_html] 
(
	[Type] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_image...'
GO
CREATE TABLE [dbo].[t_image]
(
	[ImageID] [int] IDENTITY(1,1) NOT NULL,
	[Name] 	  [nvarchar](255) NULL,
	[Type] 	  [nvarchar](255) NULL,
	[Image]   [image] NULL,
 	CONSTRAINT [PK_image] PRIMARY KEY CLUSTERED 
	(
		[ImageID] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_implement...'
GO
CREATE TABLE [dbo].[t_implement]
(
	[Type] [nvarchar](50) NULL
)
GO
CREATE CLUSTERED INDEX [implementType] ON [dbo].[t_implement] 
(
	[Type] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_issues...'
GO
CREATE TABLE [dbo].[t_issues]
(
	[Issue] 	   [nvarchar](255) NULL,
	[IssueDate]    [datetime] NULL,
	[Owner] 	   [nvarchar](255) NULL,
	[Status] 	   [nvarchar](50) NULL,
	[Notes] 	   [ntext] NULL,
	[Resolver] 	   [nvarchar](255) NULL,
	[DateResolved] [datetime] NULL,
	[Resolution]   [ntext] NULL,
	[IssueID] 	   [int] IDENTITY(1,1) NOT NULL,
	[Category] 	   [nvarchar](255) NULL,
	[Priority] 	   [nvarchar](50) NULL,
	[Severity] 	   [nvarchar](50) NULL,
	[IssueType]    [nvarchar](100) NULL,
 	CONSTRAINT [PK_issues] PRIMARY KEY CLUSTERED 
	(
		[IssueID] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_lists...'
GO
CREATE TABLE [dbo].[t_lists]
(
	[ListID]   [nvarchar](50) NOT NULL,
	[Category] [nvarchar](100) NOT NULL,
	[Name] 	   [nvarchar](150) NOT NULL,
	[NVal] 	   [int] NULL,
	[Notes]    [ntext] NULL,
 	CONSTRAINT [PK_lists] PRIMARY KEY CLUSTERED 
	(
		[ListID] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_mainttypes...'
GO
CREATE TABLE [dbo].[t_mainttypes]
(
	[MaintType] 	[nvarchar](12) NOT NULL,
	[Description] 	[nvarchar](50) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_mainttypes_NumericWeight]  DEFAULT 1,
	[Notes] 		[nvarchar](255) NULL,
 	CONSTRAINT [PK_mainttypes] PRIMARY KEY CLUSTERED 
	(
		[MaintType] ASC
	)
)
GO
PRINT '  - indexes for t_mainttypes...'
GO
CREATE NONCLUSTERED INDEX [IX_mainttypes_NumericWeight] ON [dbo].[t_mainttypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_method...'
GO
CREATE TABLE [dbo].[t_method]
(
	[Object_ID] [int] NOT NULL CONSTRAINT [DF_method_Object_ID]  DEFAULT 0,
	[Name] 		[nvarchar](255) NOT NULL,
	[Scope] 	[nvarchar](50) NULL,
	[Type] 		[nvarchar](50) NULL,
 	CONSTRAINT [PK_method] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[Name] ASC
	)
)
GO
PRINT '  - indexes for t_method...'
GO
CREATE NONCLUSTERED INDEX [IX_method_Object_ID] ON [dbo].[t_method] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_metrictypes...'
GO
CREATE TABLE [dbo].[t_metrictypes]
(
	[Metric] 		[nvarchar](12) NOT NULL,
	[Description] 	[nvarchar](50) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_metrictypes_NumerWeight]  DEFAULT 1,
	[Notes] 		[nvarchar](255) NULL,
 	CONSTRAINT [PK_metrictypes] PRIMARY KEY CLUSTERED 
	(
		[Metric] ASC
	)
)
GO
PRINT '  - indexes for t_metrictypes...'
GO
CREATE NONCLUSTERED INDEX [IX_metrictypes_NumericWeight] ON [dbo].[t_metrictypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_object...'
GO
CREATE TABLE [dbo].[t_object]
(
	[Object_ID] 	  [int] IDENTITY(1,1) NOT NULL,
	[Object_Type] 	  [nvarchar](255) NULL,
	[Diagram_ID] 	  [int] NULL CONSTRAINT [DF_object_Diagram_ID]  DEFAULT 0,
	[Name] 		      [nvarchar](255) NULL,
	[Alias] 		  [nvarchar](255) NULL,
	[Author] 		  [nvarchar](255) NULL,
	[Version] 		  [nvarchar](50) NULL CONSTRAINT [DF_object_Version]  DEFAULT '1.0',
	[Note] 			  [ntext] NULL,
	[Package_ID] 	  [int] NULL CONSTRAINT [DF_object_Package_ID]  DEFAULT 0,
	[Stereotype] 	  [nvarchar](255) NULL,
	[NType] 		  [int] NULL CONSTRAINT [DF_object_NType]  DEFAULT 0,
	[Complexity] 	  [nvarchar](50) NULL CONSTRAINT [DF_object_Complexity]  DEFAULT '2',
	[Effort] 		  [int] NULL CONSTRAINT [DF_object_Effort]  DEFAULT 0,
	[Style] 		  [nvarchar](255) NULL,
	[Backcolor] 	  [int] NULL CONSTRAINT [DF_object_Backcolor]  DEFAULT 0,
	[BorderStyle] 	  [int] NULL CONSTRAINT [DF_object_BorderStyle]  DEFAULT 0,
	[BorderWidth] 	  [int] NULL CONSTRAINT [DF_object_BorderWidth]  DEFAULT 0,
	[Fontcolor] 	  [int] NULL CONSTRAINT [DF_object_Fontcolor]  DEFAULT 0,
	[Bordercolor] 	  [int] NULL CONSTRAINT [DF_object_Bordercolor]  DEFAULT 0,
	[CreatedDate] 	  [datetime] NULL CONSTRAINT [DF_object_CreatedDate]  DEFAULT (CONVERT([datetime],CONVERT([varchar],getdate(),(1)),(1))),
	[ModifiedDate] 	  [datetime] NULL CONSTRAINT [DF_object_ModifiedDate]  DEFAULT (CONVERT([datetime],CONVERT([varchar],getdate(),(1)),(1))),
	[Status] 		  [nvarchar](50) NULL,
	[Abstract] 		  [nvarchar](1) NULL,
	[Tagged] 		  [int] NULL CONSTRAINT [DF_object_Tagged]  DEFAULT 0,
	[PDATA1] 		  [nvarchar](255) NULL,
	[PDATA2] 		  [ntext] NULL,
	[PDATA3] 		  [ntext] NULL,
	[PDATA4] 		  [ntext] NULL,
	[PDATA5] 		  [nvarchar](255) NULL,
	[Concurrency] 	  [nvarchar](50) NULL,
	[Visibility] 	  [nvarchar](50) NULL,
	[Persistence] 	  [nvarchar](50) NULL,
	[Cardinality] 	  [nvarchar](50) NULL,
	[GenType] 		  [nvarchar](50) NULL,
	[GenFile] 		  [nvarchar](255) NULL,
	[Header1] 		  [ntext] NULL,
	[Header2] 		  [ntext] NULL,
	[Phase] 		  [nvarchar](50) NULL,
	[Scope] 		  [nvarchar](25) NULL,
	[GenOption] 	  [ntext] NULL,
	[GenLinks] 		  [ntext] NULL,
	[Classifier] 	  [int] NULL,
	[ea_guid] 		  [nvarchar](40) NULL,
	[ParentID] 		  [int] NULL,
	[RunState] 		  [ntext] NULL,
	[Classifier_guid] [nvarchar](40) NULL,
	[TPos] 			  [int] NULL,
	[IsRoot] 		  [int] NOT NULL CONSTRAINT [DF_object_IsRoot]  DEFAULT 0,
	[IsLeaf] 		  [int] NOT NULL CONSTRAINT [DF_object_IsLeaf]  DEFAULT 0,
	[IsSpec] 		  [int] NOT NULL CONSTRAINT [DF_object_IsSpec]  DEFAULT 0,
	[IsActive] 		  [int] NOT NULL CONSTRAINT [DF_object_IsActive]  DEFAULT 0,
	[StateFlags] 	  [nvarchar](255) NULL,
	[PackageFlags] 	  [nvarchar](255) NULL,
	[Multiplicity] 	  [nvarchar](50) NULL,
	[StyleEx] 		  [ntext] NULL,
	[EventFlags] 	  [ntext] NULL,
	[ActionFlags] 	  [nvarchar](255) NULL,
 	CONSTRAINT [PK_object] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC
	)
)
GO
PRINT '  - indexes for t_object...'
GO
CREATE NONCLUSTERED INDEX [IX_object_Classifier] ON [dbo].[t_object] 
(
	[Classifier] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_object_Classifier-guid] ON [dbo].[t_object] 
(
	[Classifier_guid] ASC
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_object_ea_guid] ON [dbo].[t_object] 
(
	[ea_guid] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_object_Name] ON [dbo].[t_object] 
(
	[Name] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_object_Object_Type] ON [dbo].[t_object] 
(
	[Object_Type] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_object_PkgID_PDATA1_Classifier] ON [dbo].[t_object] 
(
	[Package_ID] ASC,
	[PDATA1] ASC,
	[Classifier] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_object_NType] ON [dbo].[t_object] 
(
	[NType] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_object_Package_ID] ON [dbo].[t_object] 
(
	[Package_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_object_PDATA1] ON [dbo].[t_object] 
(
	[PDATA1] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_object_ParentID] ON [dbo].[t_object] 
(
	[ParentID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectconstraint...'
GO
CREATE TABLE [dbo].[t_objectconstraint]
(
	[Object_ID] 	 [int] NOT NULL CONSTRAINT [DF_objectconstraint_Object_ID]  DEFAULT 0,
	[Constraint] 	 [nvarchar](255) NOT NULL,
	[ConstraintType] [nvarchar](30) NOT NULL,
	[Weight] 		 [float] NULL CONSTRAINT [DF_objectconstraint_Weight]  DEFAULT 0,
	[Notes] 		 [ntext] NULL,
	[Status] 		 [nvarchar](50) NULL,
 	CONSTRAINT [PK_objectconstraint] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[ConstraintType] ASC,
		[Constraint] ASC
	)
)
GO
PRINT '  - indexes for t_objectconstraint...'
GO
CREATE NONCLUSTERED INDEX [IX_objectconstraint_Constraint] ON [dbo].[t_objectconstraint] 
(
	[Constraint] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_objectconstraint_ObjectID] ON [dbo].[t_objectconstraint] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objecteffort...'
GO
CREATE TABLE [dbo].[t_objecteffort]
(
	[Object_ID]  [int] NOT NULL CONSTRAINT [DF_objecteffort_Object_ID]  DEFAULT 0,
	[Effort] 	 [nvarchar](255) NOT NULL,
	[EffortType] [nvarchar](12) NULL,
	[EValue] 	 [float] NULL CONSTRAINT [DF_objecteffort_EValue]  DEFAULT 0,
	[Notes] 	 [ntext] NULL,
 	CONSTRAINT [PK_objecteffort] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[Effort] ASC
	)
)
GO
PRINT '  - indexes for t_objecteffort...'
GO
CREATE NONCLUSTERED INDEX [IX_objecteffort_Object_ID] ON [dbo].[t_objecteffort] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectfiles...'
GO
CREATE TABLE [dbo].[t_objectfiles]
(
	[Object_ID] [int] NOT NULL CONSTRAINT [DF_objectfiles_Object_ID]  DEFAULT 0,
	[FileName] 	[nvarchar](255) NOT NULL,
	[Type] 	   	[nvarchar](50) NULL,
	[Note] 	   	[ntext] NULL,
	[FileSize] 	[nvarchar](255) NULL,
	[FileDate] 	[nvarchar](255) NULL,
 	CONSTRAINT [PK_objectfiles] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[FileName] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectmetrics...'
GO
CREATE TABLE [dbo].[t_objectmetrics]
(
	[Object_ID]  [int] NOT NULL CONSTRAINT [DF_objectmetrics_Object_ID]  DEFAULT 0,
	[Metric] 	 [nvarchar](255) NOT NULL,
	[MetricType] [nvarchar](12) NULL,
	[EValue] 	 [float] NULL CONSTRAINT [DF_objectmetrics_EValue]  DEFAULT 1,
	[Notes] 	 [ntext] NULL,
 	CONSTRAINT [PK_objectmetrics] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[Metric] ASC
	)
)
GO
PRINT '  - indexes for t_objectmetrics...'
GO
CREATE NONCLUSTERED INDEX [IX_objectmetrics_MetricType] ON [dbo].[t_objectmetrics] 
(
	[MetricType] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_objectmetrics_Object_ID] ON [dbo].[t_objectmetrics] 
(
	[Object_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_objectmetrics_Metric] ON [dbo].[t_objectmetrics] 
(
	[Metric] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectproblems...'
GO
CREATE TABLE [dbo].[t_objectproblems]
(
	[Object_ID] 	[int] NOT NULL CONSTRAINT [DF_objectproblems_Object_ID]  DEFAULT 0,
	[Problem] 		[varchar](255) NOT NULL,
	[ProblemType] 	[varchar](255) NOT NULL,
	[DateReported] 	[datetime] NULL,
	[Status] 		[nvarchar](50) NULL,
	[ProblemNotes] 	[ntext] NULL,
	[ReportedBy] 	[nvarchar](255) NULL,
	[ResolvedBy] 	[nvarchar](255) NULL,
	[DateResolved] 	[datetime] NULL,
	[Version] 		[nvarchar](50) NULL,
	[ResolverNotes] [ntext] NULL,
	[Priority] 		[nvarchar](50) NULL,
	[Severity] 		[nvarchar](50) NULL,
 	CONSTRAINT [PK_objectproblems] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[ProblemType] ASC,
		[Problem] ASC
	)
)
GO
PRINT '  - indexes for t_objectproblems...'
GO
CREATE NONCLUSTERED INDEX [IX_objectproblems_Object_ID] ON [dbo].[t_objectproblems] 
(
	[Object_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_objectproblems_Problem] ON [dbo].[t_objectproblems] 
(
	[Problem] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectproperties...'
GO
CREATE TABLE [dbo].[t_objectproperties]
(
	[PropertyID] [int] IDENTITY(1,1) NOT NULL,
	[Object_ID]  [int] NULL CONSTRAINT [DF_objectproperties_Object_ID]  DEFAULT 0,
	[Property]   [nvarchar](255) NULL,
	[Value] 	 [nvarchar](255) NULL,
	[Notes] 	 [ntext] NULL,
	[ea_guid] 	 [nvarchar](40) NULL,
 	CONSTRAINT [PK_objectproperties] PRIMARY KEY CLUSTERED 
	(
		[PropertyID] ASC
	)
)
GO
PRINT '  - indexes for t_objectproblems...'
GO
CREATE NONCLUSTERED INDEX [IX_objectproperties_Object_ID] ON [dbo].[t_objectproperties] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectrequires...'
GO
CREATE TABLE [dbo].[t_objectrequires]
(
	[ReqID] 	  [int] IDENTITY(1,1) NOT NULL,
	[Object_ID]   [int] NULL CONSTRAINT [DF_objectrequires_Object_ID]  DEFAULT 0,
	[Requirement] [nvarchar](255) NULL,
	[ReqType] 	  [nvarchar](255) NULL,
	[Status] 	  [nvarchar](50) NULL,
	[Notes] 	  [ntext] NULL,
	[Stability]   [nvarchar](50) NULL,
	[Difficulty]  [nvarchar](50) NULL,
	[Priority]    [nvarchar](50) NULL,
	[LastUpdate]  [datetime] NULL CONSTRAINT [DF_objectrequires_LastUpdate]  DEFAULT (getdate()),
 	CONSTRAINT [PK_objectrequires] PRIMARY KEY CLUSTERED 
	(
		[ReqID] ASC
	)
)
GO
PRINT '  - indexes for t_objectrequires...'
GO
CREATE NONCLUSTERED INDEX [IX_objectrequires_Object_ID] ON [dbo].[t_objectrequires] 
(
	[Object_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_objectrequires_Requirement] ON [dbo].[t_objectrequires] 
(
	[Requirement] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectresource...'
GO
CREATE TABLE [dbo].[t_objectresource]
(
	[Object_ID] 	  [int] NOT NULL CONSTRAINT [DF_objectresource_Object_ID]  DEFAULT 0,
	[Resource] 		  [varchar](255) NOT NULL,
	[Role] 			  [varchar](255) NOT NULL,  
	[Time] 			  [float] NULL CONSTRAINT [DF_objectresource_Time]  DEFAULT 0,
	[Notes] 		  [ntext] NULL,
	[PercentComplete] [smallint] NULL CONSTRAINT [DF_objectresource_PercentComplete]  DEFAULT 0,
	[DateStart] 	  [datetime] NULL,
	[DateEnd] 		  [datetime] NULL,
	[History] 		  [ntext] NULL,
	[ExpectedHours]   [int] NULL,
	[ActualHours] 	  [int] NULL,
 	CONSTRAINT [PK_objectresource] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[Resource] ASC,
		[Role] ASC
	)
)
GO
PRINT '  - indexes for t_objectresource...'
GO
CREATE NONCLUSTERED INDEX [IX_objectresource_Object_ID] ON [dbo].[t_objectresource] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectrisks...'
GO
CREATE TABLE [dbo].[t_objectrisks]
(
	[Object_ID] [int] NOT NULL CONSTRAINT [DF_objectrisks_Object_ID]  DEFAULT 0,
	[Risk] 	    [nvarchar](255) NOT NULL,
	[RiskType]  [nvarchar](12) NULL,
	[EValue]    [float] NULL CONSTRAINT [DF_objectrisks_EValue]  DEFAULT 0,
	[Notes]     [ntext] NULL,
 	CONSTRAINT [PK_objectrisks] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[Risk] ASC
	)
)
GO
PRINT '  - indexes for t_objectrisks...'
GO
CREATE NONCLUSTERED INDEX [IX_objectrisks_Object_ID] ON [dbo].[t_objectrisks] 
(
	[Object_ID] ASC
)
GO	
----------------------------------------------------------------------------------------------------
PRINT '- table t_objectscenarios...'
GO
CREATE TABLE [dbo].[t_objectscenarios]
(
	[Object_ID]    [int] NOT NULL CONSTRAINT [DF_objectscenarios_Object_ID]  DEFAULT 0,
	[Scenario] 	   [nvarchar](255) NOT NULL,
	[ScenarioType] [nvarchar](12) NULL,
	[EValue] 	   [float] NULL CONSTRAINT [DF_objectscenarios_EValue]  DEFAULT 0,
	[Notes] 	   [ntext] NULL,
	[XMLContent]   [ntext] NULL,
	[ea_guid] 	   [nvarchar](40) NULL,
 	CONSTRAINT [PK_objectscenarios] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[Scenario] ASC
	)
)
GO
PRINT '  - indexes for t_objectscenarios...'
GO
CREATE NONCLUSTERED INDEX [IX_objectscenarios_ObjID_EVal_Scenario] ON [dbo].[t_objectscenarios] 
(
	[Object_ID] ASC,
	[EValue] ASC,
	[Scenario] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_objectscenarios_Object_ID] ON [dbo].[t_objectscenarios] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objecttests...'
GO
CREATE TABLE [dbo].[t_objecttests]
(
	[Object_ID] 		 [int] NOT NULL CONSTRAINT [DF_objecttests_Object_ID]  DEFAULT 0,
	[Test] 				 [nvarchar](255) NOT NULL,
	[TestClass] 		 [int] NOT NULL CONSTRAINT [DF_objecttests_TestClass]  DEFAULT 0,
	[TestType] 			 [nvarchar](50) NULL,
	[Notes] 			 [ntext] NULL,
	[InputData] 		 [ntext] NULL,
	[AcceptanceCriteria] [ntext] NULL,
	[Status] 			 [nvarchar](32) NULL,
	[DateRun] 			 [datetime] NULL CONSTRAINT [DF_objecttests_DateRun]  DEFAULT (getdate()),
	[Results] 			 [ntext] NULL,
	[RunBy] 			 [nvarchar](255) NULL,
	[CheckBy] 			 [nvarchar](255) NULL,
 	CONSTRAINT [PK_objecttests] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[Test] ASC,
		[TestClass] ASC
	)
)
GO
PRINT '  - indexes for t_objecttests...'
GO
CREATE NONCLUSTERED INDEX [IX_objecttests_Object_ID] ON [dbo].[t_objecttests] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objecttrx...'
GO
CREATE TABLE [dbo].[t_objecttrx]
(
	[Object_ID] [int] NOT NULL CONSTRAINT [DF_objecttrx_Object_ID]  DEFAULT 0,
	[TRX] 	  	[nvarchar](255) NOT NULL,
	[TRXType] 	[nvarchar](12) NOT NULL,
	[Weight]  	[float] NULL CONSTRAINT [DF_objecttrx_Weight]  DEFAULT 0,
	[Notes]   	[ntext] NULL,
 	CONSTRAINT [PK_objecttrx] PRIMARY KEY CLUSTERED 
	(
		[Object_ID] ASC,
		[TRXType] ASC,
		[TRX] ASC
	)
)
GO
PRINT '  - indexes for t_objecttrx...'
GO
CREATE NONCLUSTERED INDEX [IX_objecttrx__TRX] ON [dbo].[t_objecttrx] 
(
	[TRX] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_objecttrx_Object_ID] ON [dbo].[t_objecttrx] 
(
	[Object_ID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_objecttypes...'
GO
CREATE TABLE [dbo].[t_objecttypes]
(
	[Object_Type]  [nvarchar](50) NOT NULL,
	[Description]  [nvarchar](255) NULL,
	[DesignObject] [int] NOT NULL CONSTRAINT [DF_objecttypes_DesignObject]  DEFAULT 0,
	[ImageID] 	   [int] NULL CONSTRAINT [DF_objecttypes_ImageID]  DEFAULT 0,
 	CONSTRAINT [PK_objecttypes] PRIMARY KEY CLUSTERED 
	(
		[Object_Type] ASC
	)
)
GO
PRINT '  - indexes for t_objecttypes...'
GO
CREATE NONCLUSTERED INDEX [IX_objecttypes_ImageID] ON [dbo].[t_objecttypes] 
(
	[ImageID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_ocf...'
GO
CREATE TABLE [dbo].[t_ocf]
(
	[ObjectType] 	   [nvarchar](50) NULL,
	[ComplexityWeight] [float] NULL CONSTRAINT [DF_ocf_ComplexityWeight]  DEFAULT 0
)
GO
CREATE CLUSTERED INDEX [ocfObjectType] ON [dbo].[t_ocf] 
(
	[ObjectType] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_operation...'
GO
CREATE TABLE [dbo].[t_operation]
(
	[OperationID]  [int] IDENTITY(1,1) NOT NULL,
	[Object_ID]    [int] NULL CONSTRAINT [DF_operation_Object_ID]  DEFAULT 0,
	[Name] 		   [nvarchar](255) NULL,
	[Scope] 	   [nvarchar](50) NULL,
	[Type] 		   [nvarchar](255) NULL,
	[ReturnArray]  [nvarchar](1) NULL,
	[Stereotype]   [nvarchar](50) NULL,
	[IsStatic] 	   [nvarchar](1) NULL,
	[Concurrency]  [nvarchar](50) NULL,
	[Notes] 	   [ntext] NULL,
	[Behaviour]    [ntext] NULL,
	[Abstract] 	   [nvarchar](1) NULL,
	[GenOption]    [ntext] NULL,
	[Synchronized] [nvarchar](1) NULL,
	[Pos] 		   [int] NULL,
	[Const] 	   [int] NULL,
	[Style] 	   [nvarchar](255) NULL,
	[Pure] 		   [int] NOT NULL CONSTRAINT [DF_operation_Pure]  DEFAULT 0,
	[Throws] 	   [nvarchar](255) NULL,
	[Classifier]   [nvarchar](50) NULL,
	[Code] 		   [ntext] NULL,
	[IsRoot] 	   [int] NOT NULL CONSTRAINT [DF_operation_IsRoot]  DEFAULT 0,
	[IsLeaf] 	   [int] NOT NULL CONSTRAINT [DF_operation_IsLeaf]  DEFAULT 0,
	[IsQuery] 	   [int] NOT NULL CONSTRAINT [DF_operation_IsQuery]  DEFAULT 0,
	[StateFlags]   [nvarchar](255) NULL,
	[ea_guid] 	   [nvarchar](50) NULL,
	[StyleEx] 	   [ntext] NULL,
 	CONSTRAINT [PK_operation] PRIMARY KEY CLUSTERED 
	(
		[OperationID] ASC
	)
)
GO
PRINT '  - indexes for t_operation...'
GO
CREATE NONCLUSTERED INDEX [IX_operation_Classifier] ON [dbo].[t_operation] 
(
	[Classifier] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_operation_Name] ON [dbo].[t_operation] 
(
	[Name] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_operation_Object_ID] ON [dbo].[t_operation] 
(
	[Object_ID] ASC
)
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_operation_ea_guid] ON [dbo].[t_operation] 
(
	[ea_guid] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_operationparams...'
GO
CREATE TABLE [dbo].[t_operationparams]
(
	[OperationID][int] NOT NULL CONSTRAINT [DF_operation_OperationID]  DEFAULT 0,
	[Name] 		 [nvarchar](255) NOT NULL,
	[Type] 		 [nvarchar](255) NULL,
	[Default] 	 [nvarchar](255) NULL,
	[Notes] 	 [ntext] NULL,
	[Pos] 		 [int] NULL,
	[Const] 	 [int] NOT NULL CONSTRAINT [DF_operation_Const]  DEFAULT 0,
	[Style] 	 [nvarchar](255) NULL,
	[Kind] 		 [nvarchar](12) NULL,
	[Classifier] [nvarchar](50) NULL,
	[ea_guid] 	 [nvarchar](50) NULL,
	[StyleEx] 	 [ntext] NULL,
 	CONSTRAINT [PK_operationparams] PRIMARY KEY CLUSTERED 
	(
		[OperationID] ASC,
		[Name] ASC
	)
)
GO
PRINT '  - indexes for t_operationparams...'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_operationparams_ea_guid] ON [dbo].[t_operationparams] 
(
	[ea_guid] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_operationparams_OperationID] ON [dbo].[t_operationparams] 
(
	[OperationID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_operationparams_OpID_Pos] ON [dbo].[t_operationparams] 
(
	[OperationID] ASC,
	[Pos] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_operationposts...'
GO
CREATE TABLE [dbo].[t_operationposts]
(
	[OperationID] 	[int] NOT NULL CONSTRAINT [DF_operationposts_OperationID]  DEFAULT 0,
	[PostCondition] [nvarchar](255) NOT NULL,
	[Type] 			[nvarchar](255) NULL,
	[Notes] 		[ntext] NULL,
 	CONSTRAINT [PK_operationposts] PRIMARY KEY CLUSTERED 
	(
		[OperationID] ASC,
		[PostCondition] ASC
	)
)
GO
PRINT '  - indexes for t_operationposts...'
GO
CREATE NONCLUSTERED INDEX [IX_operationposts_OperationID] ON [dbo].[t_operationposts] 
(
	[OperationID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_operationpres...'
GO
CREATE TABLE [dbo].[t_operationpres]
(
	[OperationID]  [int] NOT NULL CONSTRAINT [DF_operationpres_OperationID]  DEFAULT 0,
	[PreCondition] [nvarchar](255) NOT NULL,
	[Type] 		   [nvarchar](50) NULL,
	[Notes] 	   [ntext] NULL,
 	CONSTRAINT [PK_operationpres] PRIMARY KEY CLUSTERED 
	(
		[OperationID] ASC,
		[PreCondition] ASC
	)
)
GO
PRINT '  - indexes for t_operationpres...'
GO
CREATE NONCLUSTERED INDEX [IX_operationpres_OperationID] ON [dbo].[t_operationpres] 
(
	[OperationID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_operationtag...'
GO
CREATE TABLE [dbo].[t_operationtag]
(
	[PropertyID] [int] IDENTITY(1,1) NOT NULL,
	[ElementID]  [int] NULL,
	[Property] 	 [nvarchar](255) NULL,
	[VALUE] 	 [nvarchar](255) NULL,
	[NOTES] 	 [ntext] NULL,
	[ea_guid] 	 [nvarchar](40) NULL,
 	CONSTRAINT [PK_operationtag] PRIMARY KEY CLUSTERED 
	(
		[PropertyID] ASC
	)
)
GO
PRINT '  - indexes for t_operationtag...'
GO
CREATE NONCLUSTERED INDEX [IX_operationtag_ElementID] ON [dbo].[t_operationtag] 
(
	[ElementID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_operationtag_VALUE] ON [dbo].[t_operationtag] 
(
	[VALUE] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_package...'
GO
CREATE TABLE [dbo].[t_package]
(
	[Package_ID]   [int] IDENTITY(1,1) NOT NULL,
	[Name] 		   [nvarchar](255) NULL,
	[Parent_ID]    [int] NULL CONSTRAINT [DF_package_ParentID]  DEFAULT 0,
	[CreatedDate]  [datetime] NULL CONSTRAINT [DF_package_CreatedDate]  DEFAULT (CONVERT([datetime],CONVERT([varchar],getdate(),(1)),(1))),
	[ModifiedDate] [datetime] NULL CONSTRAINT [DF_package_ModifiedDate]  DEFAULT (CONVERT([datetime],CONVERT([varchar],getdate(),(1)),(1))),
	[Notes] 	   [ntext] NULL,
	[ea_guid] 	   [nvarchar](40) NULL,
	[XMLPath] 	   [nvarchar](255) NULL,
	[IsControlled] [int] NOT NULL CONSTRAINT [DF_package_IsControlled]  DEFAULT 0,
	[LastLoadDate] [datetime] NULL,
	[LastSaveDate] [datetime] NULL,
	[Version] 	   [nvarchar](50) NULL,
	[Protected]    [int] NOT NULL CONSTRAINT [DF_package_Protected]  DEFAULT 0,
	[PkgOwner] 	   [nvarchar](255) NULL,
	[UMLVersion]   [nvarchar](50) NULL,
	[UseDTD] 	   [int] NOT NULL CONSTRAINT [DF_package_UseDTD]  DEFAULT 0,
	[LogXML] 	   [int] NOT NULL CONSTRAINT [DF_package_LogXML]  DEFAULT 0,
	[CodePath] 	   [nvarchar](255) NULL,
	[Namespace]    [nvarchar](50) NULL,
	[TPos] 		   [int] NULL,
	[PackageFlags] [nvarchar](255) NULL,
	[BatchSave]    [int] NULL,
	[BatchLoad]    [int] NULL,
 	CONSTRAINT [PK_package] PRIMARY KEY CLUSTERED 
	(
		[Package_ID] ASC
	)
)
GO
PRINT '  - indexes for t_package...'
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_package_ea_guid] ON [dbo].[t_package] 
(
	[ea_guid] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_package_ParentID] ON [dbo].[t_package] 
(
	[Parent_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_package_Name] ON [dbo].[t_package] 
(
	[Name] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_palette...'
GO
CREATE TABLE [dbo].[t_palette]
(
	[PaletteID] [int] IDENTITY(1,1) NOT NULL,
	[Name] 		[nvarchar](255) NULL,
	[Type] 		[nvarchar](255) NULL
)
GO
CREATE CLUSTERED INDEX [ix_paletteID] ON [dbo].[t_palette] 
(
	[PaletteID] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_paletteitem...'
GO
CREATE TABLE [dbo].[t_paletteitem]
(
	[PaletteID] [int] NULL,
	[ItemID] 	[int] NULL
)
GO
CREATE CLUSTERED INDEX [ix_paletteItem] ON [dbo].[t_paletteitem] 
(
	[PaletteID] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_phase...'
GO
CREATE TABLE [dbo].[t_phase]
(
	[PhaseID] 	   [varchar](40) NOT NULL,
	[PhaseName]    [varchar](100) NOT NULL,
	[PhaseNotes]   [ntext] NULL,
	[PhaseStyle]   [varchar](255) NULL,
	[StartDate]    [datetime] NULL,
	[EndDate] 	   [datetime] NULL,
	[PhaseContent] [ntext] NULL,
 	CONSTRAINT [PK_phase] PRIMARY KEY CLUSTERED 
	(
		[PhaseID] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_primitives...'
GO
CREATE TABLE [dbo].[t_primitives]
(
	[Datatype] 	  [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NULL,
 	CONSTRAINT [PK_primitives] PRIMARY KEY CLUSTERED 
	(
		[Datatype] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_problemtypes...'
GO
CREATE TABLE [dbo].[t_problemtypes]
(
	[ProblemType] 	[nvarchar](12) NOT NULL,
	[Description] 	[nvarchar](255) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_problemtypes_NumericWeight]  DEFAULT 1,
	[Notes] 		[nvarchar](255) NULL,
 	CONSTRAINT [PK_problemtypes] PRIMARY KEY CLUSTERED 
	(
		[ProblemType] ASC
	)
)
GO
PRINT '  - indexes for t_problemtypes...'
GO
CREATE NONCLUSTERED INDEX [IX_problemtypes_NumericWeight] ON [dbo].[t_problemtypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_projectroles...'
GO
CREATE TABLE [dbo].[t_projectroles]
(
	[Role] 		  [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[Notes] 	  [ntext] NULL,
 	CONSTRAINT [PK_projectroles] PRIMARY KEY CLUSTERED 
	(
		[Role] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_propertytypes...'
GO
CREATE TABLE [dbo].[t_propertytypes]
(
	[Property] 	  [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NULL,
	[Notes] 	  [ntext] NULL,
 	CONSTRAINT [PK_propertytypes] PRIMARY KEY CLUSTERED 
	(
		[Property] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_requiretypes...'
GO
CREATE TABLE [dbo].[t_requiretypes]
(
	[Requirement] 	[nvarchar](12) NOT NULL,
	[Description] 	[nvarchar](50) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_requiretypes_NumericWeight]  DEFAULT 1,
	[Notes] 		[nvarchar](255) NULL,
 	CONSTRAINT [PK_requiretypes] PRIMARY KEY CLUSTERED 
	(
		[Requirement] ASC
	)
)
GO
PRINT '  - indexes for t_requiretypes...'
GO
CREATE NONCLUSTERED INDEX [IX_requiretypes_NumericWeight] ON [dbo].[t_requiretypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_requiretypes...'
GO
CREATE TABLE [dbo].[t_resources](
	[Name] 			[nvarchar](255) NOT NULL,
	[Organisation]  [nvarchar](255) NULL,
	[Phone1] 		[nvarchar](50) NULL,
	[Phone2] 		[nvarchar](50) NULL,
	[Mobile] 		[nvarchar](50) NULL,
	[Fax] 			[nvarchar](50) NULL,
	[Email] 		[nvarchar](255) NULL,
	[Roles] 		[nvarchar](255) NULL,
	[Notes] 		[nvarchar](255) NULL,
 	CONSTRAINT [PK_resources] PRIMARY KEY CLUSTERED 
	(
		[Name] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_risktypes...'
GO
CREATE TABLE [dbo].[t_risktypes]
(
	[Risk] 			[nvarchar](12) NOT NULL,
	[Description] 	[nvarchar](50) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_risktypes_NumericWeight]  DEFAULT 0,
	[Notes] 		[nvarchar](255) NULL,
 	CONSTRAINT [PK_risktypes] PRIMARY KEY CLUSTERED 
	(
		[Risk] ASC
	)
)
GO
PRINT '  - indexes for t_risktypes...'
GO
CREATE NONCLUSTERED INDEX [IX_risktypes_NumericWeight] ON [dbo].[t_risktypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_roleconstraint...'
GO
CREATE TABLE [dbo].[t_roleconstraint]
(
	[ConnectorID] 	 [int] NOT NULL CONSTRAINT [DF_roleconstraint_ConnectorID]  DEFAULT 0,
	[Constraint] 	 [nvarchar](255) NOT NULL,
	[ConnectorEnd] 	 [nvarchar](50) NOT NULL,
	[ConstraintType] [nvarchar](12) NOT NULL,
	[Notes] 		 [ntext] NULL,
 	CONSTRAINT [PK_roleconstraint] PRIMARY KEY CLUSTERED 
	(
		[ConnectorID] ASC,
		[Constraint] ASC,
		[ConnectorEnd] ASC,
		[ConstraintType] ASC
	)
)
GO
PRINT '  - indexes for t_roleconstraint...'
GO
CREATE NONCLUSTERED INDEX [IX_roleconstraint_Constraint] ON [dbo].[t_roleconstraint] 
(
	[Constraint] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_roleconstraint__ConnectorID] ON [dbo].[t_roleconstraint] 
(
	[ConnectorID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_rtf...'
GO
CREATE TABLE [dbo].[t_rtf]
(
	[Type] 		[nvarchar](50) NULL,
	[Template]  [ntext] NULL
)
GO
CREATE CLUSTERED INDEX [rtfType] ON [dbo].[t_rtf] 
(
	[Type] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_rtfreport...'
GO
CREATE TABLE [dbo].[t_rtfreport]
(
	[TemplateID] 	  [nvarchar](200) NOT NULL,
	[RootPackage] 	  [int] NULL CONSTRAINT [DF_rtfreport_RootPackage]  DEFAULT 0,
	[Filename] 		  [nvarchar](255) NULL,
	[Details] 		  [int] NOT NULL CONSTRAINT [DF_rtfreport_Details]  DEFAULT 0,
	[ProcessChildren] [int] NOT NULL CONSTRAINT [DF_rtfreport_ProcessChildren]  DEFAULT 0,
	[ShowDiagrams] 	  [int] NOT NULL CONSTRAINT [DF_rtfreport_ShowDiagams]  DEFAULT 0,
	[Heading] 		  [nvarchar](255) NULL,
	[Requirements] 	  [int] NOT NULL CONSTRAINT [DF_rtfreport_Requirements]  DEFAULT 0,
	[Associations] 	  [int] NOT NULL CONSTRAINT [DF_rtfreport_Associations]  DEFAULT 0,
	[Scenarios] 	  [int] NOT NULL CONSTRAINT [DF_rtfreport_Scenarios]  DEFAULT 0,
	[ChildDiagrams]   [int] NOT NULL CONSTRAINT [DF_rtfreport_ChildDiagrams]  DEFAULT 0,
	[Attributes] 	  [int] NOT NULL CONSTRAINT [DF_rtfreport_Attributes]  DEFAULT 0,
	[Methods] 		  [int] NOT NULL CONSTRAINT [DF_rtfreport_Methods]  DEFAULT 0,
	[ImageType] 	  [int] NULL CONSTRAINT [DF_rtfreport_ImageType]  DEFAULT 0,
	[Paging] 		  [int] NOT NULL CONSTRAINT [DF_rtfreport_Paging]  DEFAULT 0,
	[Intro] 		  [ntext] NULL,
	[Resources] 	  [int] NOT NULL CONSTRAINT [DF_rtfreport_Resources]  DEFAULT 1,
	[Constraints] 	  [int] NOT NULL CONSTRAINT [DF_rtfreport_Constraints]  DEFAULT 1,
	[Tagged] 		  [int] NOT NULL CONSTRAINT [DF_rtfreport_Tagged]  DEFAULT 0,
	[ShowTag] 		  [int] NOT NULL CONSTRAINT [DF_rtfreport_ShowTag]  DEFAULT 0,
	[ShowAlias] 	  [int] NOT NULL CONSTRAINT [DF_rtfreport_ShowAlias]  DEFAULT 0,
	[PDATA1] 		  [nvarchar](255) NULL,
	[PDATA2] 		  [nvarchar](255) NULL,
	[PDATA3] 		  [nvarchar](255) NULL,
	[PDATA4] 		  [ntext] NULL,
 	CONSTRAINT [PK_rtfreport] PRIMARY KEY CLUSTERED 
	(
		[TemplateID] ASC
	)
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_rules...'
GO
CREATE TABLE [dbo].[t_rules]
(
	[RuleID]     [nvarchar](50) NOT NULL,
	[RuleName]   [nvarchar](255) NOT NULL,
	[RuleType]   [nvarchar](255) NOT NULL,
	[RuleActive] [int] NULL,
	[ErrorMsg]   [nvarchar](255) NULL,
	[Flags]      [nvarchar](255) NULL,
	[RuleOCL]    [ntext] NULL,
	[RuleXML]    [ntext] NULL,
	[Notes]      [ntext] NULL,
    CONSTRAINT [PK_rules] PRIMARY KEY CLUSTERED 
    (
    	[RuleID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_scenariotypes...'
GO
CREATE TABLE [dbo].[t_scenariotypes]
(
	[ScenarioType]  [nvarchar](12) NOT NULL,
	[Description]   [nvarchar](50) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_scenariotypes_NumericWeight]  DEFAULT 1,
	[Notes]         [nvarchar](255) NULL,
    CONSTRAINT [PK_scenariotypes] PRIMARY KEY CLUSTERED 
    (
    	[ScenarioType] ASC
    )
)    
GO
PRINT '  - indexes for t_scenariotypes...'
GO
CREATE NONCLUSTERED INDEX [IX_scenariotypes_NumericWeight] ON [dbo].[t_scenariotypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_script...'
GO
CREATE TABLE [dbo].[t_script]
(
	[ScriptID]       [int] IDENTITY(1,1) NOT NULL,
	[ScriptCategory] [nvarchar](100) NULL,
	[ScriptName]     [nvarchar](150) NULL,
	[ScriptAuthor]   [nvarchar](255) NULL,
	[Notes]          [ntext] NULL,
	[Script]         [ntext] NULL
)
GO
CREATE CLUSTERED INDEX [ix_scriptID] ON [dbo].[t_script] 
(
	[ScriptID] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_secgroup...'
GO
CREATE TABLE [dbo].[t_secgroup]
(
	[GroupID]     [nvarchar](40) NOT NULL,
	[GroupName]   [nvarchar](32) NOT NULL,
	[Description] [nvarchar](100) NULL,
    CONSTRAINT [PK_secgroup] PRIMARY KEY CLUSTERED 
    (
    	[GroupID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_secgrouppermission...'
GO
CREATE TABLE [dbo].[t_secgrouppermission]
(
	[GroupID]      [nvarchar](40) NOT NULL,
	[PermissionID] [int] NOT NULL,
    CONSTRAINT [PK_secgrouppermission] PRIMARY KEY CLUSTERED 
    (
    	[GroupID] ASC,
    	[PermissionID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_seclocks...'
GO
CREATE TABLE [dbo].[t_seclocks]
(
	[UserID]     [nvarchar](40) NOT NULL,
	[GroupID]    [nvarchar](40) NULL,
	[EntityType] [nvarchar](32) NOT NULL,
	[EntityID]   [nvarchar](40) NOT NULL,
	[Timestamp]  [datetime] NOT NULL,
	[LockType]   [nvarchar](255) NULL,
    CONSTRAINT [PK_seclocks] PRIMARY KEY CLUSTERED 
    (
    	[EntityID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_secpermission...'
GO
CREATE TABLE [dbo].[t_secpermission]
(
	[PermissionID]   [int] NOT NULL,
	[PermissionName] [nvarchar](50) NOT NULL,
    CONSTRAINT [PK_secpermission] PRIMARY KEY CLUSTERED 
    (
    	[PermissionID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_secpolicies...'
GO
CREATE TABLE [dbo].[t_secpolicies]
(
	[Property] [nvarchar](100) NOT NULL,
	[Value]    [nvarchar](255) NOT NULL,
    CONSTRAINT [PK_secpolicies] PRIMARY KEY CLUSTERED 
    (
    	[Property] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_secuser...'
GO
CREATE TABLE [dbo].[t_secuser]
(
	[UserID]     [nvarchar](40) NOT NULL,
	[UserLogin]  [nvarchar](32) NOT NULL,
	[FirstName]  [nvarchar](50) NOT NULL,
	[Surname]    [nvarchar](50) NOT NULL,
	[Department] [nvarchar](50) NULL,
	[Password]   [nvarchar](12) NULL,
    CONSTRAINT [PK_secuser] PRIMARY KEY CLUSTERED 
    (
    	[UserID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_secusergroup...'
GO
CREATE TABLE [dbo].[t_secusergroup]
(
	[UserID]  [nvarchar](40) NOT NULL,
	[GroupID] [nvarchar](40) NOT NULL,
    CONSTRAINT [PK_secusergroup] PRIMARY KEY CLUSTERED 
    (
    	[UserID] ASC,
    	[GroupID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_secuserpermission...'
GO
CREATE TABLE [dbo].[t_secuserpermission]
(
	[UserID]       [nvarchar](40) NOT NULL,
	[PermissionID] [int] NOT NULL,
    CONSTRAINT [PK_secuserpermission] PRIMARY KEY CLUSTERED 
    (
    	[UserID] ASC,
    	[PermissionID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_snapshot...'
GO
CREATE TABLE [dbo].[t_snapshot]
(
	[SnapshotID]   [nvarchar](40) NOT NULL,
	[SeriesID]     [nvarchar](40) NULL,
	[Position]     [int] NOT NULL,
	[SnapshotName] [nvarchar](100) NOT NULL,
	[Notes]        [ntext] NULL,
	[Style]        [nvarchar](255) NULL,
	[ElementID]    [nvarchar](40) NULL,
	[ElementType]  [nvarchar](50) NOT NULL,
	[StrContent]   [ntext] NULL,
	[BinContent1]  [image] NULL,
	[BinContent2]  [image] NULL,
    CONSTRAINT [PK_snapshot] PRIMARY KEY CLUSTERED 
    (
    	[SnapshotID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_statustypes...'
GO
CREATE TABLE [dbo].[t_statustypes]
(
	[Status]      [nvarchar](50) NULL,
	[Description] [nvarchar](50) NULL
)
GO
CREATE CLUSTERED INDEX [ix_statusType] ON [dbo].[t_statustypes] 
(
	[Status] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_stereotypes...'
GO
CREATE TABLE [dbo].[t_stereotypes]
(
	[Stereotype]  [varchar](255) NOT NULL,
	[AppliesTo]   [varchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[MFEnabled]   [int] NOT NULL CONSTRAINT [DF_stereotypes_MFEnabled]  DEFAULT 0,
	[MFPath]      [nvarchar](255) NULL,
	[Metafile]    [image] NULL,
	[Style]       [ntext] NULL,
	[ea_guid]     [nvarchar](50) NULL,
	[VisualType]  [varchar](100) NULL,
    CONSTRAINT [PK_stereotypes] PRIMARY KEY CLUSTERED 
    (
    	[AppliesTo] ASC,
    	[Stereotype] ASC
    )
)
GO
PRINT '  - indexes for t_stereotypes...'
GO
CREATE NONCLUSTERED INDEX [IX_stereotypes_Stereotype] ON [dbo].[t_stereotypes] 
(
	[Stereotype] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_taggedvalue...'
GO
CREATE TABLE [dbo].[t_taggedvalue]
(
	[PropertyID] [nvarchar](40) NOT NULL,
	[ElementID]  [nvarchar](40) NULL,
	[BaseClass]  [nvarchar](100) NOT NULL,
	[TagValue]   [ntext] NULL,
	[Notes]      [ntext] NULL,
    CONSTRAINT [PK_taggedvalue] PRIMARY KEY CLUSTERED 
    (
    	[PropertyID] ASC
    )
)
GO
PRINT '  - indexes for t_scenariotypes...'
GO
CREATE NONCLUSTERED INDEX [IX_taggedvalue_ElementID] ON [dbo].[t_taggedvalue] 
(
	[ElementID] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_tasks...'
GO
CREATE TABLE [dbo].[t_tasks]
(
	[TaskID]     [int] IDENTITY(1,1) NOT NULL,
	[Name]       [nvarchar](255) NULL,
	[TaskType]   [nvarchar](255) NULL,
	[NOTES]      [ntext] NULL,
	[Priority]   [nvarchar](255) NULL,
	[Status]     [nvarchar](255) NULL,
	[Owner]      [nvarchar](255) NULL,
	[StartDate]  [datetime] NULL,
	[EndDate]    [datetime] NULL,
	[Phase]      [nvarchar](50) NULL,
	[History]    [ntext] NULL,
	[Percent]    [int] NULL,
	[TotalTime]  [int] NULL,
	[ActualTime] [int] NULL,
	[AssignedTo] [nvarchar](100) NULL,
    CONSTRAINT [PK_tasks] PRIMARY KEY CLUSTERED 
    (
    	[TaskID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_tcf...'
GO
CREATE TABLE [dbo].[t_tcf]
(
	[TCFID]       [nvarchar](12) NOT NULL,
	[Description] [nvarchar](50) NULL,
	[Weight]      [float] NULL CONSTRAINT [DF__t_tcf__Weight__7C1A6C5A]  DEFAULT ((1)),
	[Value]       [float] NULL CONSTRAINT [DF__t_tcf__Value__7D0E9093]  DEFAULT ((0)),
	[Notes]       [nvarchar](255) NULL,
    CONSTRAINT [PK_tcf] PRIMARY KEY CLUSTERED 
    (
    	[TCFID] ASC
    )
)
GO
PRINT '  - indexes for t_tcf...'
GO
CREATE NONCLUSTERED INDEX [IX_tcf_Weight] ON [dbo].[t_tcf] 
(
	[Weight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_template...'
GO
CREATE TABLE [dbo].[t_template]
(
	[TemplateID]   [nvarchar](40) NOT NULL,
	[TemplateType] [nvarchar](50) NOT NULL,
	[TemplateName] [nvarchar](100) NOT NULL,
	[Notes]        [nvarchar](255) NULL,
	[Style]        [nvarchar](255) NULL,
	[Template]     [ntext] NULL,
    CONSTRAINT [PK_template] PRIMARY KEY CLUSTERED 
    (
    	[TemplateID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_testclass...'
GO
CREATE TABLE [dbo].[t_testclass]
(
	[TestClass]   [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NULL,
    CONSTRAINT [PK_testclass] PRIMARY KEY CLUSTERED 
    (
    	[TestClass] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_testplans...'
GO
CREATE TABLE [dbo].[t_testplans]
(
	[PlanID]   [nvarchar](50) NOT NULL,
	[Category] [nvarchar](100) NOT NULL,
	[Name]     [nvarchar](150) NOT NULL,
	[Author]   [nvarchar](255) NOT NULL,
	[Notes]    [ntext] NULL,
	[TestPlan] [ntext] NOT NULL,
    CONSTRAINT [PK_testplans] PRIMARY KEY CLUSTERED 
    (
    	[PlanID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_testtypes...'
GO
CREATE TABLE [dbo].[t_testtypes]
(
	[TestType]      [nvarchar](12) NOT NULL,
	[Description]   [nvarchar](50) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_testtypes_NumericWeight]  DEFAULT 1,
	[Notes]         [nvarchar](255) NULL,
    CONSTRAINT [PK_testtypes] PRIMARY KEY CLUSTERED 
    (
    	[TestType] ASC
    )
)
GO
PRINT '  - indexes for t_testtypes...'
GO
CREATE NONCLUSTERED INDEX [IX_testtypes_NumericWeight] ON [dbo].[t_testtypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_trxtypes...'
GO
CREATE TABLE [dbo].[t_trxtypes]
(
	[Description]   [nvarchar](50) NULL,
	[NumericWeight] [float] NULL CONSTRAINT [DF_trxtypes_NumericWeight]  DEFAULT 1,
	[Notes]         [ntext] NULL,
	[TRX]           [nvarchar](255) NULL,
	[TRX_ID]        [int] IDENTITY(1,1) NOT NULL,
	[Style]         [ntext] NULL,
    CONSTRAINT [PK_trxtypes] PRIMARY KEY CLUSTERED 
    (
    	[TRX_ID] ASC
    )
)
GO
PRINT '  - indexes for t_trxtypes...'
GO
CREATE NONCLUSTERED INDEX [IX_trxtypes_NumericWeight] ON [dbo].[t_trxtypes] 
(
	[NumericWeight] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_umlpattern...'
GO
CREATE TABLE [dbo].[t_umlpattern]
(
	[PatternID]       [int] IDENTITY(1,1) NOT NULL,
	[PatternCategory] [nvarchar](100) NULL,
	[PatternName]     [nvarchar](150) NULL,
	[Style]           [nvarchar](250) NULL,
	[Notes]           [ntext] NULL,
	[PatternXML]      [ntext] NULL,
	[Version]         [nvarchar](50) NULL,
    CONSTRAINT [PK_umlpattern] PRIMARY KEY CLUSTERED 
    (
    	[PatternID] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_version...'
GO
CREATE TABLE [dbo].[t_version]
(
	[ElementID] [nvarchar](50) NOT NULL,
	[VersionID] [nvarchar](255) NOT NULL,
	[ElementType] [nvarchar](100) NULL,
	[Flags] [nvarchar](255) NULL,
	[ExternalFile] [nvarchar](255) NULL,
	[Notes] [nvarchar](255) NULL,
	[Owner] [nvarchar](255) NULL,
	[VersionDate] [datetime] NULL,
	[Branch] [nvarchar](255) NULL,
	[ElementXML] [ntext] NULL,
    CONSTRAINT [PK_t_version] PRIMARY KEY CLUSTERED 
    (
    	[ElementID] ASC,
    	[VersionID] ASC
    )
)
GO
PRINT '  - indexes for t_version...'
GO
CREATE NONCLUSTERED INDEX [IX_version_eLEMENTid] ON [dbo].[t_version] 
(
	[ElementID] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table t_xref...'
GO
CREATE TABLE [dbo].[t_xref]
(
	[XrefID]      [nvarchar](255) NOT NULL,
	[Name]        [nvarchar](255) NULL,
	[Type]        [nvarchar](255) NULL,
	[Visibility]  [nvarchar](255) NULL,
	[Namespace]   [nvarchar](255) NULL,
	[Requirement] [nvarchar](255) NULL,
	[Constraint]  [nvarchar](255) NULL,
	[Behavior]    [nvarchar](255) NULL,
	[Partition]   [nvarchar](255) NULL,
	[Description] [ntext] NULL,
	[Client]      [nvarchar](255) NULL,
	[Supplier]    [nvarchar](255) NULL,
	[Link]        [nvarchar](255) NULL,
    CONSTRAINT [PK_xref] PRIMARY KEY CLUSTERED 
    (
    	[XrefID] ASC
    )
)
GO
PRINT '  - indexes for t_xref...'
GO
CREATE NONCLUSTERED INDEX [IX_xref_Client] ON [dbo].[t_xref] 
(
	[Client] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_xref_Nme] ON [dbo].[t_xref] 
(
	[Name] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_xref_Supplier] ON [dbo].[t_xref] 
(
	[Supplier] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_xref_Type] ON [dbo].[t_xref] 
(
	[Type] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_xrefsystem...'
GO
CREATE TABLE [dbo].[t_xrefsystem]
(
	[XrefID]      [nvarchar](255) NOT NULL,
	[Name]        [nvarchar](255) NULL,
	[Type]        [nvarchar](255) NULL,
	[Visibility]  [nvarchar](255) NULL,
	[Namespace]   [nvarchar](255) NULL,
	[Requirement] [nvarchar](255) NULL,
	[Constraint]  [nvarchar](255) NULL,
	[Behavior]    [nvarchar](255) NULL,
	[Partition]   [nvarchar](255) NULL,
	[Description] [ntext] NULL,
	[Client]      [nvarchar](255) NULL,
	[Supplier]    [nvarchar](255) NULL,
	[Link]        [nvarchar](255) NULL,
	[ToolID]      [nvarchar](50) NULL,
    CONSTRAINT [PK_xrefsystem] PRIMARY KEY CLUSTERED 
    (
    	[XrefID] ASC
    )
)
GO
PRINT '  - indexes for t_xrefsystem...'
GO
CREATE NONCLUSTERED INDEX [IX_xrefsystem_Client] ON [dbo].[t_xrefsystem] 
(
	[Client] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_xrefsystem_Supplier] ON [dbo].[t_xrefsystem] 
(
	[Supplier] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_xrefsystem_Type] ON [dbo].[t_xrefsystem] 
(
	[Type] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table t_xrefuser...'
GO
CREATE TABLE [dbo].[t_xrefuser]
(
	[XrefID]      [nvarchar](255) NOT NULL,
	[Name]        [nvarchar](255) NULL,
	[Type]        [nvarchar](255) NULL,
	[Visibility]  [nvarchar](255) NULL,
	[Namespace]   [nvarchar](255) NULL,
	[Requirement] [nvarchar](255) NULL,
	[Constraint]  [nvarchar](255) NULL,
	[Behavior]    [nvarchar](255) NULL,
	[Partition]   [nvarchar](255) NULL,
	[Description] [ntext] NULL,
	[Client]      [nvarchar](255) NULL,
	[Supplier]    [nvarchar](255) NULL,
	[Link]        [nvarchar](255) NULL,
	[ToolID]      [nvarchar](50) NULL,
    CONSTRAINT [PK_xrefuser] PRIMARY KEY CLUSTERED 
    (
    	[XrefID] ASC
    )
)
GO
PRINT '  - indexes for t_xrefuser...'
GO
CREATE NONCLUSTERED INDEX [IX_xrefuser_Client] ON [dbo].[t_xrefuser] 
(
	[Client] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_xrefuser_Supplier] ON [dbo].[t_xrefuser] 
(
	[Supplier] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_xrefuser_Type] ON [dbo].[t_xrefuser] 
(
	[Type] ASC
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table usysTables...'
GO
CREATE TABLE [dbo].[usysTables]
(
	[TableName]   [nvarchar](50) NOT NULL,
	[RelOrder]    [int] NULL CONSTRAINT [DF_usysTables_RelOrder]  DEFAULT 0,
	[DisplayName] [nvarchar](50) NULL,
	[FromVer]     [nvarchar](50) NULL,
	[ToVer]       [nvarchar](50) NULL,
    CONSTRAINT [PK_usysTables] PRIMARY KEY CLUSTERED 
    (
    	[TableName] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table usys_system...'
GO
CREATE TABLE [dbo].[usys_system]
(
	[Property] [nvarchar](50) NOT NULL,
	[Value]    [nvarchar](50) NULL,
    CONSTRAINT [PK_usys_system] PRIMARY KEY CLUSTERED 
    (
    	[Property] ASC
    )
)
GO
----------------------------------------------------------------------------------------------------
PRINT '- table usysOldTables...'
GO
CREATE TABLE [dbo].[usysOldTables]
(
	[TableName] [nvarchar](50) NULL,
	[NewName]   [nvarchar](50) NULL,
	[RelOrder]  [int] NULL CONSTRAINT [DF_usysOldTables_RelOrder]  DEFAULT 0,
	[FixCode]   [int] NOT NULL CONSTRAINT [DF_usysOldTables_FixCode]  DEFAULT 0
)
GO
CREATE CLUSTERED INDEX [ix_usysOldTables] ON [dbo].[usysOldTables] 
(
	[TableName] ASC
)
----------------------------------------------------------------------------------------------------
PRINT '- table usysQueries...'
GO
CREATE TABLE [dbo].[usysQueries]
(
	[QueryName] [nvarchar](50) NULL,
	[NewName]   [nvarchar](50) NULL,
	[FixCode]   [int] NOT NULL CONSTRAINT [DF_usysQueries_FixCode]  DEFAULT 0
)
GO
CREATE CLUSTERED INDEX [ix_usysQueries] ON [dbo].[usysQueries] 
(
	[QueryName] ASC
)
----------------------------------------------------------------------------------------------------
PRINT 'Done!'
GO
----------------------------------------------------------------------------------------------------
