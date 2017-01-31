<?xml version="1.0" encoding="iso-8859-1"?>
<Package	PackName = "TCK_TransacCompletenessLOCAL"
			Type = "INTERNAL"
 			Version ="1.0.2"
			SupportedServer = "ALL"
			Display="TCK"
			Description="Automated Fonction Points - Transaction Completeness kit"
      DatabaseKind="KB_LOCAL" >
	<Include>
		<PackName>DSSAPP_LOCAL</PackName>
		<Version>8.0.0</Version>
 	</Include>
	<Exclude>
	</Exclude>
	<Install>
	</Install>
	<Update>
	</Update>
	<Refresh>
		<Step Type="PROC" Option="4" File="TCK_TransacCompletenessLocalProcedures.sql" />
	</Refresh>
	<Remove>
			<Step Type="PROC" Option="4" File="TCK_TransacCompletenessCleanLocalProcedures.sql" />
	</Remove>
</Package>