[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Dependency_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Dependency = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_T", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "B_REPORT_DEPENDENCY", Kind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"REPORT_DEPENDENCY_KEY", Int64.Type}, {"BUSINESS_DOMAIN_KEY", Int64.Type}, {"REPORT_KEY", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Merged queries" = Table.NestedJoin(#"Renamed Columns", {"Report Key"}, Report, {"Report Key"}, "Report", JoinKind.LeftOuter),
  #"Expanded Report" = Table.ExpandTableColumn(#"Merged queries", "Report", {"Report Name", "Frequency Day"}, {"Report Name", "Frequency Day"})
in
  #"Expanded Report";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Usage_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Usage = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_V", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "B_SOURCE_TABLE_USAGE", Kind = "View"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"LOAD_USAGE_KEY", Int64.Type}, {"SOURCE_TABLE_KEY", Int64.Type}, {"BUSINESS_DOMAIN_KEY", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) )
in
  #"Renamed Columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Business Domain_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Business Domain" = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_T", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "D_BUSINESS_DOMAIN", Kind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"BUSINESS_DOMAIN_KEY", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) )
in
  #"Renamed Columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Report_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Report = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_T", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "D_REPORT", Kind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"REPORT_KEY", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) )
in
  #"Renamed Columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Source Table_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Source Table" = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_V", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "D_SOURCE_TABLE", Kind = "View"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"SOURCE_TABLE_KEY", Int64.Type}, {"FREQUENCY_DAYS", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) )
in
  #"Renamed Columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Business Domain Process_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Business Domain Process" = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_T", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "F_BUSINESS_DOMAIN_PROCESS", Kind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"BUSINESS_DOMAIN_PROCESS_KEY", Int64.Type}, {"BUSINESS_DOMAIN_KEY", Int64.Type}, {"DATE_KEY", Int64.Type}, {"ROWS_INSERTED", Int64.Type}, {"ROWS_UPDATED", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) )
in
  #"Renamed Columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Staging Process_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "Staging Process Key", DestinationColumnName = "Staging Process Key"], [SourceColumnName = "Source Table Key", DestinationColumnName = "Source Table Key"], [SourceColumnName = "Date Key", DestinationColumnName = "Date Key"], [SourceColumnName = "Rows Inserted", DestinationColumnName = "Rows Inserted"], [SourceColumnName = "Rows Updated", DestinationColumnName = "Rows Updated"], [SourceColumnName = "Start Time", DestinationColumnName = "Start Time"], [SourceColumnName = "End Time", DestinationColumnName = "End Time"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"Staging Process" = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_T", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "F_STAGING_PROCESS", Kind = "Table"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"STAGING_PROCESS_KEY", Int64.Type}, {"SOURCE_TABLE_KEY", Int64.Type}, {"DATE_KEY", Int64.Type}, {"ROWS_INSERTED", Int64.Type}, {"ROWS_UPDATED", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) )
in
  #"Renamed Columns";
shared #"Business Domain Process_DataDestination" = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data],
  TableNavigation = Navigation_2{[Id = "Business Domain Process", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Source Table_DataDestination" = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data],
  TableNavigation = Navigation_2{[Id = "Source Table", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Report_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data],
  TableNavigation = Navigation_2{[Id = "Report", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Business Domain_DataDestination" = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data],
  TableNavigation = Navigation_2{[Id = "Business Domain", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Usage_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data],
  TableNavigation = Navigation_2{[Id = "Usage", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Dependency_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data],
  TableNavigation = Navigation_2{[Id = "Dependency", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
shared #"Staging Process_DataDestination" = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data],
  TableNavigation = Navigation_2{[Id = "Staging Process", ItemKind = "Table"]}[Data]
in
  TableNavigation;
[BindToDefaultDestination = true]
shared #"Readiness Domain" = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_V", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "V_READINESS", Kind = "View"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"BUSINESS_DOMAIN_KEY", Int64.Type}, {"SOURCE_TABLE_KEY", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Grouped rows" = Table.Group(#"Renamed Columns", {"Business Domain Key"}, {{"Business Domain Last Processed", each List.Max([Business Domain Last Processed Ts]), type nullable datetime}, {"Business Domain Freshness", each List.Max([Business Domain Freshness]), type nullable text}})
in
  #"Grouped rows";
[BindToDefaultDestination = true]
shared #"Readiness SourceTable" = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH", [Role = null, CreateNavigationProperties = null, ConnectionTimeout = null, CommandTimeout = null, Implementation = "2.0"]),
  #"Navigation 1" = Source{[Name = "EDW_PROD", Kind = "Database"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Name = "EDW_V", Kind = "Schema"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "V_READINESS", Kind = "View"]}[Data],
  #"Changed column type" = Table.TransformColumnTypes(#"Navigation 3", {{"BUSINESS_DOMAIN_KEY", Int64.Type}, {"SOURCE_TABLE_KEY", Int64.Type}}),
  #"Remove Underscores" = Table.TransformColumnNames(#"Changed column type",  each Text.Replace( _, "_", " " ) ),
  #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Grouped rows" = Table.Group(#"Renamed Columns", {"Business Domain Key", "Source Table Key"}, {{"Source Table Last Processed Ts", each List.Max([Source Table Last Processed Ts]), type nullable datetime}, {"Source Table Freshness", each List.Max([Source Table Freshness]), type nullable text}}),
  #"Filtered rows" = Table.SelectRows(#"Grouped rows", each ([Source Table Key] <> null))
in
  #"Filtered rows";
