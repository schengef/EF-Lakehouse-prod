[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared #"Transactions (External POS)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*,
PC.MARK_TYPE,
CASE WHEN C.CURRENCY='CAD' then P.CAN_STANDARD_COST else P.STANDARD_COST end  as Currency_Based_Unit_Cost,Currency_Based_Unit_Cost*T.OH_UNITS as ON_HAND_COST,Currency_Based_Unit_Cost*T.SALES_UNITS as SALES_COST,P.RETAIL_PRICE*T.OH_UNITS as ON_HAND_RETAIL, S.WHOLESALE_ACCOUNT_KEY
from EDW_V.V_EXTERNAL_TRANSACTIONS_POS T
LEFT OUTER JOIN EDW_T.D_PRICE_CATEGORIZATION PC ON T.PRICE_CATEGORIZATION_KEY = PC.PRICE_CATEGORIZATION_KEY
LEFT OUTER JOIN EDW_V.D_PRODUCT P ON T.PRODUCT_KEY = P.PRODUCT_KEY
LEFT OUTER JOIN EDW_T.D_CURRENCY C ON T.CURRENCY_KEY = C.CURRENCY_KEY 
LEFT OUTER JOIN EDW_T.D_STORE S ON T.STORE_KEY = S.STORE_KEY 
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"Week Ending Date","Source System"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Week Ending Date Key", Int64.Type}, {"Store Key", Int64.Type}, {"Product Key", Int64.Type}, {"Sales Units", Int64.Type}, {"Oh Units", Int64.Type}, {"Currency Key", Int64.Type}, {"Price Categorization Key", Int64.Type}, {"Delivery Key", Int64.Type}, {"Channel Key", Int64.Type}, {"Wholesale Account Key", Int64.Type}, {"Sales Dollars", Currency.Type}, {"Currency Based Unit Cost", Currency.Type}, {"On Hand Cost", Currency.Type}, {"Sales Cost", Currency.Type}, {"On Hand Retail", Currency.Type}})
in
    #"Changed column type";
