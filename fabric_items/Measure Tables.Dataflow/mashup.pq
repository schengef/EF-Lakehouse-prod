[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "8a36f33d-a1a9-4e11-afd1-e24a3f8deb56"]}[Data]{[lakehouseId = "eadbf17e-7da4-4599-aa97-04b03a262c1c"]}[Data];
[BindToDefaultDestination = true]
shared #"Budget and Forecast Measures" = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMlSKjQUA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [DELETE = _t]),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"DELETE", Int32.Type}})
in
  #"Changed column type";
[BindToDefaultDestination = true]
shared #"DTC Measures" = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WUlCKjQUA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Column1 = _t]),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"Column1", type text}})
in
  #"Changed column type";
[BindToDefaultDestination = true]
shared #"Inventory Measures" = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WUlCKjQUA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Column1 = _t]),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"Column1", type text}})
in
  #"Changed column type";
[BindToDefaultDestination = true]
shared #"Total Company Measures" = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WUlCKjQUA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Column1 = _t]),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"Column1", type text}})
in
  #"Changed column type";
[BindToDefaultDestination = true]
shared #"Wholesale Measures" = let
  Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WUlCKjQUA", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Column1 = _t]),
  #"Changed column type" = Table.TransformColumnTypes(Source, {{"Column1", type text}})
in
  #"Changed column type";
