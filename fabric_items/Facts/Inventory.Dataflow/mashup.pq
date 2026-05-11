[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared Inventory = let

    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*, PC.MARK_TYPE,T.UNITS_ON_HAND*P.STANDARD_COST as COST_ON_HAND,T.UNITS_ON_HAND*P.RETAIL_PRICE as RETAIL_ON_HAND, cast(T.EFFECTIVE_START_DATE as DATE) AS START_DATE, cast(T.EFFECTIVE_END_DATE as DATE) AS END_DATE,CASE WHEN P.DEPARTMENT_CODE_MI9>89 THEN 1 END AS DTC_MISC_FLAG, 
from EDW_V.F_INVENTORY_ON_HAND T
LEFT OUTER JOIN EDW_V.D_PRODUCT P ON T.PRODUCT_KEY = P.PRODUCT_KEY
LEFT OUTER JOIN EDW_T.D_PRICE_CATEGORIZATION PC ON T.PRICE_CATEGORIZATION_KEY = PC.PRICE_CATEGORIZATION_KEY
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),



    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"Inventory On Hand Key", "Md5 Checksum", "Md5 Nk", "Etl Row Created Ts", "Etl Source System Cd","Effective Start Date","Effective End Date", "Etl Row Updated Ts"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Units On Hand", Int64.Type}, {"Store Key", Int64.Type}, {"Warehouse Key", Int64.Type}, {"Channel Key", Int64.Type}, {"Product Key", Int64.Type}, {"Delivery Key", Int64.Type}, {"Price Categorization Key", Int64.Type}, {"Dtc Misc Flag", Int64.Type}, {"Cost On Hand", Currency.Type}, {"Retail On Hand", Currency.Type}})
in
    #"Changed column type";
