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

# Welcome to your new notebook
# Type here in the cell editor to add code!
spark.sql("OPTIMIZE Sandbox_Lakehouse.dbo.`Transactions _Financial_`")



# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
