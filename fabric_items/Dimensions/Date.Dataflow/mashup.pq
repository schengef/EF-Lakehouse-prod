[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared Date = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
WITH StartDate AS (
    SELECT MAX(WEEK_END_DATE) - 7 AS StartDate
    FROM EDW_V.V_UNIFIED_CALENDAR
)
SELECT 
    T.*,
    CASE 
        WHEN T.WEEK_END_DATE <= M.StartDate THEN 1 
        ELSE 0 
    END AS IS_PRIOR_WEEK_OR_BEFORE
FROM EDW_V.V_UNIFIED_CALENDAR T
CROSS JOIN StartDate M",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),    
#"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
#"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
#"Renamed Columns1" = Table.RenameColumns(#"Renamed Columns",{{"Select A Calendar", "Select a Calendar"}, {"Currweek End Date", "CurrWeek End Date"}, {"Monthname", "MonthName"},{"Date Ly", "Date LY"}, {"Date Lly", "Date LLY"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns1",{"This Year Vs Last Year"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Week", Int64.Type}, {"Year", Int64.Type}, {"Dayofweek", Int64.Type}, {"Dayofmonth", Int64.Type}, {"Dayofyear", Int64.Type}, {"Monthnum", Int64.Type}, {"Datekey", Int64.Type}, {"Sequential Day Number", Int64.Type}, {"Monthsort", Int64.Type}, {"Monthindex", Int64.Type}}),
  #"Added custom" = Table.AddColumn(#"Changed column type", "Select a date", each "Select a date"),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "SundayFlag", each if Date.DayOfWeekName(DateTime.Date(DateTime.FixedLocalNow()))="Sunday" then "1" else "0"),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Added custom 1", {{"Select a date", type text}, {"Is Prior Week Or Before", type text}})
in
    #"Changed column type 1";
[BindToDefaultDestination = true]
shared #"Date EOY" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.*,
from EDW_V.V_UNIFIED_CALENDAR_EOY T",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),    
#"Remove Underscores" = Table.TransformColumnNames(NativeQuery,  each Text.Replace( _, "_", " " ) ),
#"Renamed Columns" = Table.TransformColumnNames( #"Remove Underscores",  each Text.Proper( _ ) ),
#"Renamed Columns1" = Table.RenameColumns(#"Renamed Columns",{{"Select A Calendar", "Select a Calendar"}, {"Currweek End Date", "CurrWeek End Date"}, {"Monthname", "MonthName"},{"Date Ly", "Date LY"}, {"Date Lly", "Date LLY"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns1",{"This Year Vs Last Year"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Removed Columns", {{"Week", Int64.Type}, {"Year", Int64.Type}, {"Dayofweek", Int64.Type}, {"Dayofmonth", Int64.Type}, {"Dayofyear", Int64.Type}, {"Monthnum", Int64.Type}, {"Datekey", Int64.Type}, {"Sequential Day Number", Int64.Type}, {"Monthsort", Int64.Type}, {"Monthindex", Int64.Type}}),
  #"Added custom" = Table.AddColumn(#"Changed column type", "Select a date", each "Select a date"),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Added custom", {{"Select a date", type text}})
in
    #"Changed column type 1";
[BindToDefaultDestination = true]
shared #"Filter Dates" = let
    Source = Snowflake.Databases("eileen.us-east-1.snowflakecomputing.com","REPORTING_PROD_WH"),
    EDW_PROD_Database = Source{[Name="EDW_PROD",Kind="Database"]}[Data],
    SQLStatement = 
    "
select T.DATE, T.DATEKEY
from EDW_V.V_UNIFIED_CALENDAR_EOY T
GROUP BY DATE, DATEKEY",
NativeQuery = Value.NativeQuery(EDW_PROD_Database, SQLStatement, null, [EnableFolding=true]),
#"Renamed Columns" = Table.TransformColumnNames( NativeQuery,  each Text.Proper( _ ) ),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed Columns", {"Datekey", Int64.Type})
in
    #"Changed column type";
