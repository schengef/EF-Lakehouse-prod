[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared #"Transactions (Account POS)" = let

    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*,
PC.MARK_TYPE
from EDW_V.F_WHOLESALE_RETAIL_POS T
LEFT OUTER JOIN EDW_T.D_PRICE_CATEGORIZATION PC ON T.PRICE_CATEGORIZATION_KEY = PC.PRICE_CATEGORIZATION_KEY

    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),



    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns",{"Week Ending Date Key", "Wholesale Account Key", "Store Number", "Store Key", "Product Key", "Sales Units", "Sales Dollars", "Currency Code", "Currency Key", "Oh Units", "Oh Dollars", "Mark Type","Delivery Key"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Other Columns", {{"Wholesale Account Key", Int64.Type}, {"Store Key", Int64.Type}, {"Product Key", Int64.Type}, {"Sales Units", Int64.Type}, {"Currency Key", Int64.Type}, {"Oh Units", Int64.Type}, {"Delivery Key", Int64.Type}, {"Oh Dollars", Currency.Type}, {"Sales Dollars", Currency.Type}, {"Week Ending Date Key", Int64.Type}})
in
    #"Changed column type";
[BindToDefaultDestination = true]
shared #"Transactions (Account MIX)" = let

    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*
from EDW_V.V_WHOLESALE_RETAIL_MIX T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),



    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"Week Ending Date", "Source System"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Channel Key", Int64.Type}, {"Currency Key", Int64.Type}, {"Store Key", Int64.Type}, {"Week Ending Date Key", Int64.Type}, {"Sales Dollars", Currency.Type}})
in
    #"Changed column type";
[BindToDefaultDestination = true]
shared #"Transactions (Account FIN)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*
from EDW_V.F_WHOLESALE_RETAIL_FIN T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),



    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"Wholesale Retail Fin Key", "Wholesale Retail Fin Nk", "Week Ending Date", "Tpid", "Currency Code", "Etl Row Created Ts", "Etl Source System Cd"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Receipt Dollars", Currency.Type}, {"Md Dollars", Currency.Type}, {"Oh Dollars", Currency.Type}, {"Sales Dollars", Currency.Type}, {"Currency Key", Int64.Type}, {"Store Key", Int64.Type}, {"Wholesale Account Key", Int64.Type}, {"Week Ending Date Key", Int64.Type}})
in
    #"Changed column type";
