[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared #"Inventory Movement" = let

    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
    SELECT i.*,p.Retail_Price  ,p.Standard_Cost
FROM EDW_PROD.EDW_V.F_INVENTORY_MOVEMENT   i
left join EDW_PROD.EDW_V.D_PRODUCT p
on i.PRODUCT_KEY= p.PRODUCT_KEY
--WHERE i.MOVEMENT_TYPE='PURCHASE ORDER'
    ",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),



    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns", {{"Inventory Movement Key", Int64.Type}, {"Send Store Key", Int64.Type}, {"Send Warehouse Key", Int64.Type}, {"Receive Store Key", Int64.Type}, {"Receive Warehouse Key", Int64.Type}, {"Product Key", Int64.Type}, {"Movement Date Key", Int64.Type}, {"Receive Location", Int64.Type}, {"Upc", Int64.Type}, {"Movement No", Int64.Type}, {"Units", Int64.Type}, {"Retail Price", Int64.Type}})
in
    #"Changed column type";
