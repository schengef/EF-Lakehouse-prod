# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "eadbf17e-7da4-4599-aa97-04b03a262c1c",
# META       "default_lakehouse_name": "Sandbox_Lakehouse",
# META       "default_lakehouse_workspace_id": "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56",
# META       "known_lakehouses": [
# META         {
# META           "id": "eadbf17e-7da4-4599-aa97-04b03a262c1c"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************


from pyspark.sql.functions import lit, current_timestamp, from_utc_timestamp
from pyspark.sql.types import StructType, StructField, StringType, LongType, TimestampType

LOG_TABLE_NAME = "dbo.Table_Run_History" 
current_pipeline_name = "Hourly_Data_Sync" 
TIMEZONE = "America/New_York"

tables = [t for t in spark.catalog.listTables() if t.tableType != 'VIEW']

log_results = []
for t in tables:
    try:
        count = spark.read.table(f"`{t.name}`").count()
        log_results.append((t.name, count))
    except Exception as e:
        print(f"table {t.name}, error: {str(e)}")

schema = StructType([
    StructField("TableName", StringType(), True),
    StructField("RowCount", LongType(), True)
])

df_current_logs = spark.createDataFrame(log_results, schema) \
    .withColumn("LogTimestamp_UTC", current_timestamp()) \
    .withColumn("LogTimestamp_EDT", from_utc_timestamp("LogTimestamp_UTC", TIMEZONE)) \
    .withColumn("PipelineName", lit(current_pipeline_name)) \
    .drop("LogTimestamp_UTC") 

df_current_logs.write.format("delta").mode("append").saveAsTable(LOG_TABLE_NAME)

# display(df_current_logs)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
