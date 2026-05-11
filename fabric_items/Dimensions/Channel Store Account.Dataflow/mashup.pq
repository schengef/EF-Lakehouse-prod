[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared Store = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
    SQLStatement = 
    "
 SELECT S.*, CAST(NULLIF(S.LATITUDE, '') AS DECIMAL(12,9)) as Latitude_Num,  CAST(NULLIF(S.Longitude, '') AS DECIMAL(12,9)) as Longitude_Num,
           C.CHANNEL_NAME, C.SUB_CHANNEL_NAME, C.CHANNEL_FORMAT, C.CHANNEL_GEOGRAPHY,
           CASE
            WHEN S.FINANCE_CHANNEL='Digital' then 1
            WHEN S.FINANCE_CHANNEL='Full Price US Stores' then 2
            WHEN S.FINANCE_CHANNEL='Canada' then 4
            WHEN S.FINANCE_CHANNEL='Renew Digital' then 5
            WHEN S.FINANCE_CHANNEL='Renew Stores' then 6
            WHEN S.FINANCE_CHANNEL='Company Stores' then 3
            WHEN S.FINANCE_CHANNEL='WHOLESALE US FULL PRICE' then 7
            WHEN S.FINANCE_CHANNEL='WHOLESALE US SPECIALTY' then 8
            WHEN S.FINANCE_CHANNEL='WHOLESALE INTERNATIONAL' then 9
            WHEN S.FINANCE_CHANNEL='WHOLESALE CANADA' then 10
            WHEN S.FINANCE_CHANNEL='WHOLESALE 3RD PARTY' then 11
            WHEN S.FINANCE_CHANNEL='Digital' then 12
            END AS FINANCE_CHANNEL_SORT,CONCAT(S.STORE_ID,' - ',S.STORE_NAME) as STORE_NAME_AND_NUM
    FROM EDW_PROD.EDW_V.D_STORE S
    LEFT OUTER JOIN EDW_V.D_CHANNEL C ON S.CHANNEL_KEY = C.CHANNEL_KEY
    ",
    NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),

    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery, each Text.Replace(_, "_", " ")),
    #"Renamed Columns" = Table.TransformColumnNames(#"Remove Underscores", each Text.Proper(_)),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns",{"Store Key", "Account Name", "Account Code", "Account Group", "Dc Id", "Store Id", "Edi Store Id", "Wholesale Account Key", "Store Name", "Store Type", "Store Type Description", "Channel Key", "Finance Channel", "Address1", "Address2", "City", "State", "Country", "Zip Code", "Store Open Date", "Store Close Date", "Store Status", "Store Size Selling Area", "Store Size Backroom Area", "Store Manager First Name", "Store Manager Last Name", "Chain Code", "Chain Description", "Divsion Code", "Divsion Description", "Region Code", "Region Description", "Channel Name", "Sub Channel Name", "Channel Format", "Channel Geography","Finance Channel Sort","Store Name And Num","Latitude Num","Longitude Num"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Other Columns",{{"Channel Format", "Store Channel Format"}, {"Finance Channel", "Store Finance Channel"}, {"Sub Channel Name", "Store Subchannel Name"}, {"Channel Geography", "Store Channel Geography"}, {"Channel Name", "Store Channel Name"}, {"Divsion Description", "Division Description"}, {"Divsion Code", "Division Code"},{"Latitude Num","Latitude"},{"Longitude Num","Longitude"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns1",{"Store Size Backroom Area", "Store Manager First Name", "Store Manager Last Name", "Chain Code"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Store Key", Int64.Type}, {"Wholesale Account Key", Int64.Type}, {"Channel Key", Int64.Type}, {"Division Code", Int64.Type}, {"Region Code", Int64.Type}, {"Finance Channel Sort", Int64.Type}, {"Store Size Selling Area", Int64.Type}}),
  #"Marked key columns" = Table.AddKey(#"Changed column type", {"Store Key"}, false)
in
    #"Marked key columns";
[BindToDefaultDestination = true]
shared #"Store (DTC Allocated)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
    SQLStatement = 
    "
 SELECT S.*, CAST(NULLIF(S.LATITUDE, '') AS DECIMAL(12,9)) as Latitude_Num,  CAST(NULLIF(S.Longitude, '') AS DECIMAL(12,9)) as Longitude_Num,
           C.CHANNEL_NAME, C.SUB_CHANNEL_NAME, C.CHANNEL_FORMAT, C.CHANNEL_GEOGRAPHY,
           CASE
            WHEN S.FINANCE_CHANNEL='Digital' then 1
            WHEN S.FINANCE_CHANNEL='Full Price US Stores' then 2
            WHEN S.FINANCE_CHANNEL='Canada' then 4
            WHEN S.FINANCE_CHANNEL='Renew Digital' then 5
            WHEN S.FINANCE_CHANNEL='Renew Stores' then 6
            WHEN S.FINANCE_CHANNEL='Company Stores' then 3
            WHEN S.FINANCE_CHANNEL='WHOLESALE US FULL PRICE' then 7
            WHEN S.FINANCE_CHANNEL='WHOLESALE US SPECIALTY' then 8
            WHEN S.FINANCE_CHANNEL='WHOLESALE INTERNATIONAL' then 9
            WHEN S.FINANCE_CHANNEL='WHOLESALE CANADA' then 10
            WHEN S.FINANCE_CHANNEL='WHOLESALE 3RD PARTY' then 11
            WHEN S.FINANCE_CHANNEL='Digital' then 12
            END AS FINANCE_CHANNEL_SORT,CONCAT(S.STORE_ID,' - ',S.STORE_NAME) as STORE_NAME_AND_NUM
    FROM EDW_PROD.EDW_V.D_STORE S
    LEFT OUTER JOIN EDW_V.D_CHANNEL C ON S.CHANNEL_KEY = C.CHANNEL_KEY
    ",
    NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),

    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery, each Text.Replace(_, "_", " ")),
    #"Renamed Columns" = Table.TransformColumnNames(#"Remove Underscores", each Text.Proper(_)),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns",{"Store Key", "Account Name", "Account Code", "Account Group", "Dc Id", "Store Id", "Edi Store Id", "Wholesale Account Key", "Store Name", "Store Type", "Store Type Description", "Channel Key", "Finance Channel", "Address1", "Address2", "City", "State", "Country", "Zip Code", "Store Open Date", "Store Close Date", "Store Status", "Store Size Selling Area", "Store Size Backroom Area", "Store Manager First Name", "Store Manager Last Name", "Chain Code", "Chain Description", "Divsion Code", "Divsion Description", "Region Code", "Region Description", "Channel Name", "Sub Channel Name", "Channel Format", "Channel Geography","Finance Channel Sort","Store Name And Num","Latitude Num","Longitude Num"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Other Columns",{{"Channel Format", "Allocated Channel Format"}, {"Finance Channel", "Allocated Finance Channel"}, {"Sub Channel Name", "Allocated Subchannel Name"}, {"Channel Geography", "Allocated Channel Geography"}, {"Channel Name", "Allocated Channel Name"}, {"Divsion Description", "Division Description"}, {"Divsion Code", "Division Code"},{"Latitude Num","Latitude"},{"Longitude Num","Longitude"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns1",{"Store Size Backroom Area", "Store Manager First Name", "Store Manager Last Name", "Chain Code"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Store Key", Int64.Type}, {"Wholesale Account Key", Int64.Type}, {"Channel Key", Int64.Type}, {"Division Code", Int64.Type}, {"Region Code", Int64.Type}, {"Finance Channel Sort", Int64.Type},{"Store Size Selling Area", Int64.Type}}),
  #"Marked key columns" = Table.AddKey(#"Changed column type", {"Store Key"}, false)
in
    #"Marked key columns";
[BindToDefaultDestination = true]
shared #"Store (DTC Original)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com", "REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD", Kind="Database"]}[Data],
    SQLStatement = 
    "
 SELECT S.*, CAST(NULLIF(S.LATITUDE, '') AS DECIMAL(12,9)) as Latitude_Num,  CAST(NULLIF(S.Longitude, '') AS DECIMAL(12,9)) as Longitude_Num,
           C.CHANNEL_NAME, C.SUB_CHANNEL_NAME, C.CHANNEL_FORMAT, C.CHANNEL_GEOGRAPHY,
           CASE
            WHEN S.FINANCE_CHANNEL='Digital' then 1
            WHEN S.FINANCE_CHANNEL='Full Price US Stores' then 2
            WHEN S.FINANCE_CHANNEL='Canada' then 4
            WHEN S.FINANCE_CHANNEL='Renew Digital' then 5
            WHEN S.FINANCE_CHANNEL='Renew Stores' then 6
            WHEN S.FINANCE_CHANNEL='Company Stores' then 3
            WHEN S.FINANCE_CHANNEL='WHOLESALE US FULL PRICE' then 7
            WHEN S.FINANCE_CHANNEL='WHOLESALE US SPECIALTY' then 8
            WHEN S.FINANCE_CHANNEL='WHOLESALE INTERNATIONAL' then 9
            WHEN S.FINANCE_CHANNEL='WHOLESALE CANADA' then 10
            WHEN S.FINANCE_CHANNEL='WHOLESALE 3RD PARTY' then 11
            WHEN S.FINANCE_CHANNEL='Digital' then 12
            END AS FINANCE_CHANNEL_SORT,CONCAT(S.STORE_ID,' - ',S.STORE_NAME) as STORE_NAME_AND_NUM
    FROM EDW_PROD.EDW_V.D_STORE S
    LEFT OUTER JOIN EDW_V.D_CHANNEL C ON S.CHANNEL_KEY = C.CHANNEL_KEY
    ",
    NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),

    #"Remove Underscores" = Table.TransformColumnNames(NativeQuery, each Text.Replace(_, "_", " ")),
    #"Renamed Columns" = Table.TransformColumnNames(#"Remove Underscores", each Text.Proper(_)),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns",{"Store Key", "Account Name", "Account Code", "Account Group", "Dc Id", "Store Id", "Edi Store Id", "Wholesale Account Key", "Store Name", "Store Type", "Store Type Description", "Channel Key", "Finance Channel", "Address1", "Address2", "City", "State", "Country", "Zip Code", "Store Open Date", "Store Close Date", "Store Status", "Store Size Selling Area", "Store Size Backroom Area", "Store Manager First Name", "Store Manager Last Name", "Chain Code", "Chain Description", "Divsion Code", "Divsion Description", "Region Code", "Region Description", "Channel Name", "Sub Channel Name", "Channel Format", "Channel Geography","Finance Channel Sort","Store Name And Num","Latitude Num","Longitude Num"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Other Columns",{{"Channel Format", "Original Channel Format"}, {"Finance Channel", "Original Finance Channel"}, {"Sub Channel Name", "Original Subchannel Name"}, {"Channel Geography", "Original Channel Geography"}, {"Channel Name", "Original Channel Name"}, {"Divsion Description", "Division Description"}, {"Divsion Code", "Division Code"},{"Latitude Num","Latitude"},{"Longitude Num","Longitude"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns1",{"Store Size Backroom Area", "Store Manager First Name", "Store Manager Last Name", "Chain Code"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Store Key", Int64.Type}, {"Wholesale Account Key", Int64.Type}, {"Channel Key", Int64.Type}, {"Division Code", Int64.Type}, {"Region Code", Int64.Type}, {"Finance Channel Sort", Int64.Type},{"Store Size Selling Area", Int64.Type}}),
  #"Marked key columns" = Table.AddKey(#"Changed column type", {"Store Key"}, false)
in
    #"Marked key columns";
[BindToDefaultDestination = true]
shared Channel = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    REPORTING_PROD_WH = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    EDW_V_Schema = REPORTING_PROD_WH{[Name="EDW_V",Kind="Schema"]}[Data],
    D_CHANNEL_View = EDW_V_Schema{[Name="D_CHANNEL",Kind="View"]}[Data],
    #"Remove Underscores" = Table.TransformColumnNames(D_CHANNEL_View,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Filtered Rows" = Table.SelectRows(#"Renamed Columns", each ([Channel Active] <> "No")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows",{"Channel Key", "Channel Name", "Sub Channel Name", "Channel Format", "Channel Geography"}),
    #"Added Conditional Column" = Table.AddColumn(#"Removed Other Columns", "Finance Channel", each if [Channel Key] = 2020101 then "Digital" else if [Channel Key] = 2020201 then "Full Price US Stores" else if [Channel Key] = 2020202 then "Canada" else if [Channel Key] = 2030101 then "Renew Digital" else if [Channel Key] = 2030201 then "Renew Stores" else if [Channel Key] = 2040201 then "Company Stores" else if [Channel Key] = 1010202 then "WHOLESALE CANADA" else if [Channel Key] = 1010203 then "WHOLESALE INTERNATIONAL" else if [Channel Key] = 1010301 then "WHOLESALE US FULL PRICE" else if [Channel Key] = 1010201 then "WHOLESALE US SPECIALTY" else if [Channel Key] = 1010101 then "WHOLESALE 3RD PARTY" else "N/A"),
    #"Added Conditional Column1" = Table.AddColumn(#"Added Conditional Column", "Sort", each if [Channel Key] = 2020101 then 1 else if [Channel Key] = 2020201 then 2 else if [Channel Key] = 2040201 then 3 else if [Channel Key] = 2020202 then 4 else if [Channel Key] = 2030201 then 5 else if [Channel Key] = 2030101 then 6 else if [Channel Key] = 1010301 then 7 else if [Channel Key] = 1010201 then 8 else if [Channel Key] = 1010101 then 9 else if [Channel Key] = 1010202 then 10 else if [Channel Key] = 1010203 then 11 else null),
    #"Added Conditional Column2" = Table.AddColumn(#"Added Conditional Column1", "Finance Channel (Product Dashboard)", each if [Channel Key] = 2020202 then "Canada" else if [Channel Key] = 2020101 then "Digital" else if [Channel Key] = 2020201 then "US Stores" else if [Channel Key] = 1010101 then "eCommerce" else if [Channel Key] = 1010201 then "Stores" else if [Channel Key] = 2030101 then "Renew Digital" else if [Channel Key] = 2030201 then "Renew Stores" else if [Channel Key] = 2040201 then "Company Stores" else "Exclude"),
#"Added Conditional Column3" = Table.AddColumn(#"Added Conditional Column2", "Finance Channel (Product Dashboard) Sort", each if [Channel Key] = 2020202 then 4 else if [Channel Key] = 2020101 then 1 else if [Channel Key] = 2020201 then 2 else if [Channel Key] = 1010101 then 9 else if [Channel Key] = 1010201 then 8 else if [Channel Key] = 2030101 then 6 else if [Channel Key] = 2030201 then 5 else if [Channel Key] = 2040201 then 3 else null),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Conditional Column3", {{"Sort", Int64.Type}, {"Finance Channel (Product Dashboard) Sort", Int64.Type}, {"Channel Key", Int64.Type}, {"Finance Channel", type text}, {"Finance Channel (Product Dashboard)", type text}}),
  #"Marked key columns" = Table.AddKey(#"Changed Type", {"Channel Key"}, false)
in
    #"Marked key columns";
[BindToDefaultDestination = true]
shared #"Channel (DTC Original)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    REPORTING_PROD_WH = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    EDW_V_Schema = REPORTING_PROD_WH{[Name="EDW_V",Kind="Schema"]}[Data],
    D_CHANNEL_View = EDW_V_Schema{[Name="D_CHANNEL",Kind="View"]}[Data],
    #"Remove Underscores" = Table.TransformColumnNames(D_CHANNEL_View,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Filtered Rows" = Table.SelectRows(#"Renamed Columns", each ([Channel Active] <> "No")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows",{"Channel Key", "Channel Name", "Sub Channel Name", "Channel Format", "Channel Geography"}),
    #"Added Conditional Column" = Table.AddColumn(#"Removed Other Columns", "Finance Channel", each if [Channel Key] = 2020101 then "Digital" else if [Channel Key] = 2020201 then "Full Price US Stores" else if [Channel Key] = 2020202 then "Canada" else if [Channel Key] = 2030101 then "Renew Digital" else if [Channel Key] = 2030201 then "Renew Stores" else if [Channel Key] = 2040201 then "Company Stores" else if [Channel Key] = 1010202 then "WHOLESALE CANADA" else if [Channel Key] = 1010203 then "WHOLESALE INTERNATIONAL" else if [Channel Key] = 1010301 then "WHOLESALE US FULL PRICE" else if [Channel Key] = 1010201 then "WHOLESALE US SPECIALTY" else if [Channel Key] = 1010101 then "WHOLESALE 3RD PARTY" else "N/A"),
    #"Added Conditional Column1" = Table.AddColumn(#"Added Conditional Column", "Sort", each if [Channel Key] = 2020101 then 1 else if [Channel Key] = 2020201 then 2 else if [Channel Key] = 2040201 then 3 else if [Channel Key] = 2020202 then 4 else if [Channel Key] = 2030201 then 5 else if [Channel Key] = 2030101 then 6 else if [Channel Key] = 1010301 then 7 else if [Channel Key] = 1010201 then 8 else if [Channel Key] = 1010101 then 9 else if [Channel Key] = 1010202 then 10 else if [Channel Key] = 1010203 then 11 else null),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Conditional Column1", {{"Sort", Int64.Type}, {"Channel Key", Int64.Type}, {"Finance Channel", type text}}),
  #"Marked key columns" = Table.AddKey(#"Changed Type", {"Channel Key"}, false),
  #"ColumnNamePrefix"=Table.TransformColumnNames(#"Marked key columns", each "Original "& _)
in
  ColumnNamePrefix;
[BindToDefaultDestination = true]
shared #"Channel (DTC Allocated)" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    REPORTING_PROD_WH = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    EDW_V_Schema = REPORTING_PROD_WH{[Name="EDW_V",Kind="Schema"]}[Data],
    D_CHANNEL_View = EDW_V_Schema{[Name="D_CHANNEL",Kind="View"]}[Data],
    #"Remove Underscores" = Table.TransformColumnNames(D_CHANNEL_View,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Filtered Rows" = Table.SelectRows(#"Renamed Columns", each ([Channel Active] <> "No")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows",{"Channel Key", "Channel Name", "Sub Channel Name", "Channel Format", "Channel Geography"}),
    #"Added Conditional Column" = Table.AddColumn(#"Removed Other Columns", "Finance Channel", each if [Channel Key] = 2020101 then "Digital" else if [Channel Key] = 2020201 then "Full Price US Stores" else if [Channel Key] = 2020202 then "Canada" else if [Channel Key] = 2030101 then "Renew Digital" else if [Channel Key] = 2030201 then "Renew Stores" else if [Channel Key] = 2040201 then "Company Stores" else if [Channel Key] = 1010202 then "WHOLESALE CANADA" else if [Channel Key] = 1010203 then "WHOLESALE INTERNATIONAL" else if [Channel Key] = 1010301 then "WHOLESALE US FULL PRICE" else if [Channel Key] = 1010201 then "WHOLESALE US SPECIALTY" else if [Channel Key] = 1010101 then "WHOLESALE 3RD PARTY" else "N/A"),
    #"Added Conditional Column1" = Table.AddColumn(#"Added Conditional Column", "Sort", each if [Channel Key] = 2020101 then 1 else if [Channel Key] = 2020201 then 2 else if [Channel Key] = 2040201 then 3 else if [Channel Key] = 2020202 then 4 else if [Channel Key] = 2030201 then 5 else if [Channel Key] = 2030101 then 6 else if [Channel Key] = 1010301 then 7 else if [Channel Key] = 1010201 then 8 else if [Channel Key] = 1010101 then 9 else if [Channel Key] = 1010202 then 10 else if [Channel Key] = 1010203 then 11 else null),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Conditional Column1", {{"Sort", Int64.Type}, {"Channel Key", Int64.Type}, {"Finance Channel", type text}}),
  #"Marked key columns" = Table.AddKey(#"Changed Type", {"Channel Key"}, false),
    #"ColumnNamePrefix"=Table.TransformColumnNames(#"Marked key columns", each "Allocated "& _)
in
  ColumnNamePrefix;
[BindToDefaultDestination = true]
shared Account = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    EDW_V_Schema = EDW_PROD_Database{[Name="EDW_V",Kind="Schema"]}[Data],
    D_WHOLESALE_ACCOUNT_View = EDW_V_Schema{[Name="D_WHOLESALE_ACCOUNT",Kind="View"]}[Data],
    #"Remove Underscores" = Table.TransformColumnNames(D_WHOLESALE_ACCOUNT_View,  each Text.Replace( _, "_", " " ) ),
    #"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns",{"Wholesale Account Key", "Account Name", "Account Type", "Account Code", "Active", "Address Line 1", "Address Line 2", "Address Line 3", "Address Line 4", "City", "State", "Zipcode", "Country", "Allow Back Order", "Always Print", "Auto Create Bulk", "Bill Option", "Bol Load Type", "Call Appointment No Of Days", "Account Tax Exempt Number", "Dba", "Allow Duplicate Sku", "Factor Client Number", "Exclude Freight", "Has Notes", "Insurance", "Process Balance In Invoicing", "Invoicing Cancel Reason", "Invoicing Cancel Type", "Invoice Form", "Invoice Duty", "Location", "Warehouse Key", "Old Account", "Org Code", "Parent", "User Preferred Shipper", "Warn On Zero Price", "Print Invoice", "Resale Number", "Residential", "Upc Required", "Sps Account Number", "Tax Exempt", "Roll Up", "Ar Email Ind", "Use Calculated Freight", "Use Dept Number", "Use Po Number"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Other Columns", {{"Wholesale Account Key", Int64.Type}, {"Call Appointment No Of Days", Int64.Type}, {"Warehouse Key", Int64.Type}}),
  #"Marked key columns" = Table.AddKey(#"Changed column type", {"Wholesale Account Key"}, false)
in
    #"Marked key columns";
