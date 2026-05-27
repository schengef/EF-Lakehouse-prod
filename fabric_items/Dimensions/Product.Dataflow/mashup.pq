[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared Product = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
    SQLStatement = 
    "
    SELECT * FROM EDW_PROD.EDW_V.D_PRODUCT_NEW
    ",
    NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery, each Text.Replace(_, "_", " ")),
    #"Renamed Columns" = Table.TransformColumnNames(#"Remove Underscores", each Text.Proper(_)),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Product Key", Int32.Type}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type", each true),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Identity", "Is Current","Hierarchy"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Material Group Clone", "Material Clone"}, {"Material Group Family", "Material Family"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns1", {{"Can Retail Price", Currency.Type}, {"Can Selling Price Dtc", Currency.Type}, {"Can Standard Cost", Currency.Type}, {"Can Wholesale Price", Currency.Type}, {"Class Code Mi9", Int64.Type}, {"Department Code Mi9", Int64.Type}, {"Division Code Mi9", Int64.Type}, {"Fabric Col Min", Int64.Type}, {"Fabric Ord Min", Int64.Type}, {"Gbp Retail Price", Currency.Type}, {"Gbp Standard Cost", Currency.Type}, {"Gbp Wholesale Price", Currency.Type}, {"Price Tier Sort", Int64.Type}, {"Production Landed Cost", Currency.Type}, {"Production Retail Markup Percent", Percentage.Type}, {"Production Wholesale Markup Percent", Percentage.Type}, {"Retail Price", Currency.Type}, {"Standard Cost", Currency.Type}, {"Us Selling Price Dtc", Currency.Type}, {"Usc Selling Price Dtc", Currency.Type}, {"Wholesale Price", Currency.Type}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "Style Number and Color Code NRF", each Text.From([Style Number]) & "-" & Text.From([Color Code Nrf])), {{"Style Number and Color Code NRF", type text}})
in
    #"Added custom";
[BindToDefaultDestination = true]
shared #"Product (Current)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
    SQLStatement = 
    "
    SELECT * FROM EDW_PROD.EDW_V.D_PRODUCT_CURRENT_NEW 

    ",
    NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery, each Text.Replace(_, "_", " ")),
    #"Renamed Columns" = Table.TransformColumnNames(#"Remove Underscores", each Text.Proper(_)),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"Product Key", Int32.Type}}),
    #"Filtered Rows" = Table.SelectRows(#"Changed Type", each true),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows",{"Identity","Hierarchy"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Material Group Clone", "Material Clone"}, {"Material Group Family", "Material Family"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns1", {{"Can Retail Price", Currency.Type}, {"Can Selling Price Dtc", Currency.Type}, {"Can Standard Cost", Currency.Type}, {"Can Wholesale Price", Currency.Type}, {"Class Code Mi9", Int64.Type}, {"Department Code Mi9", Int64.Type}, {"Division Code Mi9", Int64.Type}, {"Fabric Col Min", Int64.Type}, {"Fabric Ord Min", Int64.Type}, {"Gbp Retail Price", Currency.Type}, {"Gbp Standard Cost", Currency.Type}, {"Gbp Wholesale Price", Currency.Type}, {"Price Tier Sort", Int64.Type}, {"Production Landed Cost", Currency.Type}, {"Production Retail Markup Percent", Percentage.Type}, {"Production Wholesale Markup Percent", Percentage.Type}, {"Retail Price", Currency.Type}, {"Standard Cost", Currency.Type}, {"Us Selling Price Dtc", Currency.Type}, {"Usc Selling Price Dtc", Currency.Type}, {"Wholesale Price", Currency.Type}}),
 #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "Style Number and Color Code NRF", each Text.From([Style Number]) & "-" & Text.From([Color Code Nrf])), {{"Style Number and Color Code NRF", type text}})
in
    #"Added custom";
