[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared #"Budget (Channel)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.CHANNEL, T.DATE_KEY,T.CUSTOMER_TYPE,T.ORDER_TYPE,T.MEASURE,T.CURRENCY_KEY,T.BUDGET_VALUE,T.CURRENCY_CODE,
CASE WHEN T.CUSTOMER_TYPE='US THIRD PARTY' AND T.ORDER_TYPE='INITIALS MAINLINE' THEN '3RD PARTY'
    WHEN T.ORDER_TYPE='INITIALS QR' THEN 'QR'
    WHEN T.ORDER_TYPE='REORDERS QR' THEN 'QR'
    WHEN T.ORDER_TYPE='REORDERS MAINLINE' THEN 'FASHION REORDER'
    WHEN T.ORDER_TYPE='INITIALS MAINLINE' THEN 'FASHION INITIALS'
    WHEN T.ORDER_TYPE='INITIALS EXCLUSIVES' THEN 'FASHION INITIALS'
    WHEN T.ORDER_TYPE='DROP SHIP MAINLINE' THEN 'DROP SHIP'
    WHEN T.ORDER_TYPE='DROP SHIP QR' THEN 'DROP SHIP'
    WHEN T.ORDER_TYPE='RETURNS' then 'FASHION INITIALS'
    WHEN T.ORDER_TYPE='RTV DISCOUNT OFFSET' then 'FASHION INITIALS'
END AS DASHBOARD_ORDER_TYPE

from EDW_V.F_BUDGET T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns", {{"Budget Value", Currency.Type}, {"Currency Key", Int64.Type}, {"Date Key", Int64.Type}}),
  #"Removed columns" = Table.RemoveColumns(#"Changed column type", {"Currency Code"})
in
    #"Removed columns";
[BindToDefaultDestination = true]
shared #"Forecast (Channel)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
            "
select T.CHANNEL, T.DATE_KEY,T.CUSTOMER_TYPE,T.ORDER_TYPE,T.MEASURE,T.CURRENCY_KEY,T.FORECAST_VALUE,T.CURRENCY_CODE,
CASE WHEN T.CUSTOMER_TYPE='US THIRD PARTY' AND T.ORDER_TYPE='INITIALS MAINLINE' THEN '3RD PARTY'
    WHEN T.ORDER_TYPE='INITIALS QR' THEN 'QR'
    WHEN T.ORDER_TYPE='REORDERS QR' THEN 'QR'
    WHEN T.ORDER_TYPE='REORDERS MAINLINE' THEN 'FASHION REORDER'
    WHEN T.ORDER_TYPE='INITIALS MAINLINE' THEN 'FASHION INITIALS'
    WHEN T.ORDER_TYPE='INITIALS EXCLUSIVES' THEN 'FASHION INITIALS'
    WHEN T.ORDER_TYPE='DROP SHIP MAINLINE' THEN 'DROP SHIP'
    WHEN T.ORDER_TYPE='DROP SHIP QR' THEN 'DROP SHIP'
    WHEN T.ORDER_TYPE='RETURNS' then 'FASHION INITIALS'
    WHEN T.ORDER_TYPE='RTV DISCOUNT OFFSET' then 'FASHION INITIALS'
END AS DASHBOARD_ORDER_TYPE

from EDW_V.F_FORECAST T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns", {{"Forecast Value", Currency.Type}, {"Currency Key", Int64.Type}, {"Date Key", Int64.Type}}),
  #"Removed columns" = Table.RemoveColumns(#"Changed column type", {"Currency Code"})
in
    #"Removed columns";
[BindToDefaultDestination = true]
shared #"Budget (Inventory)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*,
from EDW_V.F_INVENTORY_BUDGET T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns",{"Category", "Subcategory", "Date Key", "Inventory Budget Value", "Currency Code", "Currency Key"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Other Columns",{{"Date Key", Int32.Type}}),
  #"Removed columns" = Table.RemoveColumns(#"Changed Type", {"Currency Code"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed columns", {{"Inventory Budget Value", Currency.Type}, {"Currency Key", Int64.Type}})
in
    #"Changed column type";
[BindToDefaultDestination = true]
shared #"Plan (Wholesale Retail)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*
from EDW_V.F_WHOLESALE_RETAIL_PLAN T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns",{  "Account Code", "Wholesale Account Key", "Department", "Type", "Date Key", "Plan Value", "Currency Key"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Other Columns", {{"Plan Value", Currency.Type}, {"Currency Key", Int64.Type}, {"Date Key", Int64.Type}, {"Wholesale Account Key", Int64.Type}})
in
    #"Changed column type";
[BindToDefaultDestination = true]
shared #"Budget (DTC-Store)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.STORE_KEY,T.DATE_KEY,T.MEASURE,T.BUDGET_STORE_VALUE,T.CURRENCY_CODE
from EDW_V.F_BUDGET_STORE T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns", {{"Budget Store Value", Currency.Type}, {"Date Key", Int64.Type}, {"Store Key", Int64.Type}})
in
    #"Changed column type";
[BindToDefaultDestination = true]
shared #"Forecast (DTC-Store)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.STORE_KEY,T.DATE_KEY,T.MEASURE,T.FORECAST_STORE_VALUE,T.CURRENCY_CODE
from EDW_V.F_FORECAST_STORE T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns", {{"Forecast Store Value", Currency.Type}, {"Date Key", Int64.Type}, {"Store Key", Int64.Type}})
in
    #"Changed column type";
[BindToDefaultDestination = true]
shared #"Additional DSF Metrics" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*
from EDW_V.F_DTC_ADDL_METRICS T
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Removed columns" = Table.RemoveColumns(#"Renamed Columns", {"Week", "Year", "Dtc Addl Metrics Key"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed columns", {{"Week Ending Date Key", Int64.Type}}),
  #"Renamed columns 1" = Table.RenameColumns(#"Changed column type", {{"Scenario", "Budget or Forecast"}})
in
    #"Renamed columns 1";
