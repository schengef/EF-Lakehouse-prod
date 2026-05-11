[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared #"Order Categorization" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
    SQLStatement = 
    "
    SELECT O.*
    FROM EDW_PROD.EDW_T.D_ORDER_CATEGORIZATION O
    ",
    NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),

    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery, each Text.Replace(_, "_", " ")),
    #"Renamed Columns" = Table.TransformColumnNames(#"Remove Underscores", each Text.Proper(_)),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"Etl Row Created Ts", "Etl Row Updated Ts", "Etl Source System Cd"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Order Categorization Key", Int64.Type}})
in
    #"Changed column type";
[BindToDefaultDestination = true]
shared #"Account Group Join" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
    SQLStatement = 
    "
    SELECT S.ACCOUNT_GROUP,
    FROM EDW_PROD.EDW_V.D_STORE S
    GROUP BY S.ACCOUNT_GROUP
    ",
    NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),

    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery, each Text.Replace(_, "_", " ")),
    #"Renamed Columns" = Table.TransformColumnNames(#"Remove Underscores", each Text.Proper(_)),
    #"Filtered Rows" = Table.SelectRows(#"Renamed Columns", each [Account Group] <> null and [Account Group] <> "")
in
    #"Filtered Rows";
[BindToDefaultDestination = true]
shared #"Order Type Join" = let
  Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
  EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
  SQLStatement = "#(lf)    SELECT #(lf)    CASE WHEN T.ORDER_TYPE = 'LIQ' THEN '3RD PARTY'#(lf)    WHEN T.ORDER_TYPE = 'DRS' THEN 'DROP SHIP'#(lf)    WHEN T.ORDER_TYPE ='REO' AND LEFT(P.Fes_Code,1) = 'F' THEN 'FASHION REORDER'#(lf)    WHEN T.ORDER_TYPE <> 'DRS' AND T.ORDER_TYPE <> 'LIQ'AND left(P.Fes_Code,1)= 'E'THEN 'QR'#(lf)    ELSE 'FASHION INITIALS'#(lf)    END AS DASHBOARD_ORDER_TYPE#(lf)    from EDW_PROD.EDW_V.F_TRANSACTION T#(lf)    LEFT OUTER JOIN EDW_V.D_PRODUCT P ON T.PRODUCT_KEY = P.PRODUCT_KEY#(lf)    Group by DASHBOARD_ORDER_TYPE#(lf)    ",
  NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
  #"Renamed columns" = Table.RenameColumns(NativeQuery, {{"DASHBOARD_ORDER_TYPE", "Order Type"}}),
  #"Inserted conditional column" = Table.AddColumn(#"Renamed columns", "Order Type Sort", each if [Order Type] = "3RD PARTY" then 5 else if [Order Type] = "DROP SHOP" then 4 else if [Order Type] = "FASHION INITIALS" then 1 else if [Order Type] = "FASHION REORDER" then 2 else if [Order Type] = "QR" then 3 else 6),
  #"Changed column type" = Table.TransformColumnTypes(#"Inserted conditional column", {{"Order Type Sort", Int64.Type}})
in
  #"Changed column type";
[BindToDefaultDestination = true]
shared #"Currency Selector" = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WCg12UXAqTUlPLVHQcMvMS8xLTtVU0lEyAmKnUBd315D4EP94oCKlWB2IYt/8vJKMnEoU1cZA7OvvF+LhE4ms3NkRq9kmKGYDFcEVYzPbFNVsmHJ3pwCFyNTEIpBqX09LkEozkEpPy/hIV8cgiGKgIrBin/zkxBygrCEQK8XGAgA=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [#"Currency Selection" = _t, Sort = _t, #"Conversion Type" = _t])
in
  Source;
