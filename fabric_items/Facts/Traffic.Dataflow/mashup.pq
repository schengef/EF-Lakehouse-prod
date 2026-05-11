[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared Traffic = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_"&"PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*,S.CHANNEL_KEY
from EDW_V.F_TRAFFIC T
LEFT OUTER JOIN EDW_V.D_STORE S ON T.STORE_KEY = S.STORE_KEY",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns",{"Store Key", "Date Key", "Visits","Channel Key"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Other Columns",{{"Store Key", Int64.Type}, {"Date Key", Int64.Type}, {"Visits", Int64.Type}, {"Channel Key", Int64.Type}})
in
    #"Changed Type";
