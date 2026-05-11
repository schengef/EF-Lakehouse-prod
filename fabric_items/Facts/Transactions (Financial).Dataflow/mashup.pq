[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared #"Transactions (Financial)" = let

    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
 SELECT T.*,
CASE 
        WHEN T.ORIGINAL_STORE_KEY IS NULL 
        THEN T.STORE_KEY 
        ELSE T.ORIGINAL_STORE_KEY 
    END AS Original_Store_Key_DTC, S.CHANNEL_KEY as ORIGINAL_CHANNEL_KEY,
CASE WHEN T.ORDER_TYPE = 'LIQ' THEN '3RD PARTY'
    WHEN T.ORDER_TYPE = 'DRS' THEN 'DROP SHIP'
    WHEN T.ORDER_TYPE ='REO' AND LEFT(P.Fes_Code,1) = 'F' THEN 'FASHION REORDER'
    WHEN T.ORDER_TYPE <> 'DRS' AND T.ORDER_TYPE <> 'LIQ'AND left(P.Fes_Code,1)= 'E'THEN 'QR'
    ELSE 'FASHION INITIALS'
    END AS DASHBOARD_ORDER_TYPE, PC.MARK_TYPE, PC.POS_PRESENT, PC.SELLING_PRICE, C.CURRENCY,
    CASE WHEN P.DEPARTMENT_CODE_MI9>89 THEN 1 END AS DTC_MISC_FLAG,
     COALESCE(
        CASE
            WHEN C.CURRENCY = 'CAD' THEN P.CAN_STANDARD_COST
            WHEN C.CURRENCY = 'GBP' THEN P.GBP_STANDARD_COST
            ELSE P.STANDARD_COST
        END,
        CASE
            WHEN S.DIVSION_DESCRIPTION = 'Company Stores' THEN P.COST_AVERAGE_WEIGHTED_COMPANY
            WHEN S.REGION_DESCRIPTION = 'Northwest Canada Stores' THEN P.COST_AVERAGE_WEIGHTED_CANADA
            ELSE P.COST_AVERAGE_WEIGHTED_US
         END
    ) AS Currency_Based_Cost
    
,Currency_Based_Cost*Quantity as Total_Cost
FROM EDW_PROD.EDW_V.F_TRANSACTION T
LEFT OUTER JOIN EDW_V.D_PRODUCT_CURRENT_NEW  P ON T.PRODUCT_KEY = P.PRODUCT_KEY
LEFT OUTER JOIN EDW_T.D_PRICE_CATEGORIZATION PC ON T.PRICE_CATEGORIZATION_KEY = PC.PRICE_CATEGORIZATION_KEY
LEFT OUTER JOIN EDW_T.D_CURRENCY C ON T.CURRENCY_KEY = C.CURRENCY_KEY 
LEFT OUTER JOIN EDW_V.D_STORE S ON 
    CASE 
        WHEN T.ORIGINAL_STORE_KEY IS NULL
        THEN T.STORE_KEY 
        ELSE T.ORIGINAL_STORE_KEY 
    END = S.STORE_KEY
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),



    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"Transaction Nk","Original Store Key","Upc","Transaction Key", "Cashier", "Etl Row Created Ts","Etl Row Updated Ts"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Original Store Key Dtc", "Original Store Key"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns1", {{"Transaction Date Key", Int64.Type}, {"Store Key", Int64.Type}, {"Channel Key", Int64.Type}, {"Employee Key", Int64.Type}, {"Customer Key", Int64.Type}, {"Product Key", Int64.Type}, {"Delivery Key", Int64.Type}, {"Quantity", Int64.Type}, {"Price Categorization Key", Int64.Type}, {"Order Categorization Key", Int64.Type}, {"Currency Key", Int64.Type}, {"Original Store Key", Int64.Type}, {"Original Channel Key", Int64.Type}, {"Dtc Misc Flag", Int64.Type}, {"Allocated Store Key", Int64.Type}, {"Total Cost", Currency.Type}, {"Currency Based Cost", Currency.Type}, {"Calc Returned Amt", Currency.Type}, {"Discount Amount", Currency.Type}, {"Tax Amount", Currency.Type}, {"Net Price", Currency.Type}, {"Total Price", Currency.Type}, {"Unit Retail Price", Currency.Type}})
in
    #"Changed column type";
