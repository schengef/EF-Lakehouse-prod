[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared Delivery = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
    SQLStatement = 
    "
    SELECT D.*, 
    CASE 
        WHEN D.DELIVERY_MONTH='Jan' THEN 1
        WHEN D.DELIVERY_MONTH='Feb' THEN 2
        WHEN D.DELIVERY_MONTH='Mar' THEN 3
        WHEN D.DELIVERY_MONTH='Apr' THEN 4
        WHEN D.DELIVERY_MONTH='May' THEN 5
        WHEN D.DELIVERY_MONTH='Jun' THEN 6
        WHEN D.DELIVERY_MONTH='Jul' THEN 7
        WHEN D.DELIVERY_MONTH='Aug' THEN 8
        WHEN D.DELIVERY_MONTH='Sep' THEN 9
        WHEN D.DELIVERY_MONTH='Oct' THEN 10
        WHEN D.DELIVERY_MONTH='Nov' THEN 11
        WHEN D.DELIVERY_MONTH='Dec' THEN 12
    END AS MONTH_SORT,
    CASE 
        WHEN MONTH_SORT<7 THEN CONCAT('SPRING ',D.DELIVERY_YEAR)
        WHEN MONTH_SORT>6 THEN CONCAT('FALL ',D.DELIVERY_YEAR)
    END AS SEASON,
    CASE
        WHEN MONTH_SORT<7 THEN CONCAT(D.DELIVERY_YEAR,1)
        WHEN MONTH_SORT>6 THEN CONCAT(D.DELIVERY_YEAR,2)
    END AS SEASON_SORT
    FROM EDW_PROD.EDW_V.V_DELIVERY D
    ",
    NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery, each Text.Replace(_, "_", " ")),
    #"Renamed Columns" = Table.TransformColumnNames(#"Remove Underscores", each Text.Proper(_)),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns", {{"Delivery Key", Int64.Type}, {"Delivery Code Key", Int64.Type}, {"Month Sort", Int64.Type}, {"Season Sort", Int64.Type}, {"Wholesale Account Key", Int64.Type}})
in
    #"Changed column type";
