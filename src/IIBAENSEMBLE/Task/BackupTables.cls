/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Task.BackupTables Extends %SYS.Task.Definition
{

Parameter TaskName = "BackupTables";

Method OnTask() As %Status
{
	Set rset = ##class(%ResultSet).%New()
	do rset.Prepare("Select LeftID1 as SchemaName, LeftID2 as TableName, LeftID3 as FileName, RightID as ColumnNames from IIBAENSEMBLE.LookupTable where LookupID = 'TableBackupList'")
	do rset.Execute()
	
	While rset.Next() {
		kill pParms
	
		set pParms("FileName") = rset.Data("FileName")
		set pParms("Columns") = $LFS(rset.Data("ColumnNames"))
		set pParms("SchemaName") = rset.Data("SchemaName")
		set pParms("TableName") = rset.Data("TableName")
	
		do ..TableExport(.pParms)
	
	}	
	Quit $$$OK
}

/// This Method utilizes the %SQL.Export.Mgr class to export tables to text files.<p>
/// Several of the available parameters are hard coded such as: Delimiter, StringQuote, Date, Time.<p>
/// 4 Parameters are required to successfully use this method.  The parameters are passed to this method as one array with 4 elements.<p>
/// <ul>
/// <li><b>SchemaName</b> - example: set pParms("SchemaName") = "IIBAENSEMBLE" </li>
/// <li><b>Table</b> - example: set pParms("TableName") = "LookupTable" </li>
/// <li><b>FileName</b> - example: set pParms("FileName") = "E:\RestoreData\LookupTableBackup.txt" </li>
/// <li><b>Columns</b> - example: set pParms("Columns") = $LFS("LeftID1^S,LeftID2^S,LeftID3^S,LookupID^S,RightID^S") <br>
/// Columns is a list delimited by commas.  Each list item has two parts delimited by ^.  Part 1 is column name. Part 2 is data type. The data types are:
/// <ul>
/// <li>"D" for %Library.Date </li>
/// <li>"T" for %Library.Time </li>
/// <li>"N" for %Library.Integer, %Library.Boolean, %Library.Float, %Library.Numeric, %Library.SmallInt, %Library.TinyInt, %Library.Currency </li>
/// <li>"S" for %Library.String and all others </li>
/// </ul></li></ul>
/// Example of calling this method with pParms array: do ##class(IIBAENSEMBLE.Utilities).TableExport(.pParms)
Method TableExport(ByRef pParms As %String)
{
		if ($G(pParms("SchemaName"))="") ||
		($G(pParms("TableName"))="") ||
		($G(pParms("FileName"))="") ||
		($G(pParms("Columns"))="") { Quit }
	
	
	set pParms("Delimiter") = 0
	set pParms("StringQuote") = "double"
	set pParms("DateFormat") = 1
	set pParms("TimeFormat") = 1
	set pParms("NoCheck") = 0
	set pParms("HasHeaders") = 1
 	set pParms("TotalColumns") = $LL(pParms("Columns"))
 	
 	Set SchemaName = pParms("SchemaName"), TableName = pParms("TableName")
	
	Do {
	    set mgr = ##class(%SQL.Export.Mgr).%New()
	    Set mobj = ##class(%SQL.Manager.API).%New()
	    Set ok = mobj.CheckIdentifier(.SchemaName)
	    Set ok = mobj.CheckIdentifier(.TableName)
	    Set classname = mobj.FindClassName(SchemaName_"."_TableName)
	    Set mgr.FileName = pParms("FileName")
	    Set mgr.TableName = SchemaName_"."_TableName
	    Set mgr.ClassName = classname
	    Set mgr.Delimiter = $c(9)
	    Set delim = pParms("StringQuote")
	    Set mgr.StringQuote = $s(delim="":"",delim="double":"""",1:"'")
	 	Set mgr.DateFormat = pParms("DateFormat")
	 	Set mgr.TimeFormat = pParms("TimeFormat")
	 	Set mgr.NoCheck = pParms("NoCheck")
	  	Set mgr.HasHeaders = pParms("HasHeaders")
		For i = 1:1:pParms("TotalColumns") {
			Set coldata = $li(pParms("Columns"),i)
			Set colname = $p(coldata,"^",1)
			Set datatype = $p(coldata,"^",2)
 			Set ok = mobj.CheckIdentifier(.colname)
		 	Do mgr.ColumnNames.Insert(colname)
		 	Do mgr.ColumnTypes.Insert(datatype)
		}
 
	 	Set rows = 1000
	 	Set done = 0
	 	Set total = 0
	 	Set totalbytes = 0
	 	Set totalinserted = 0
	 	Set numerr = 0
	 	Set size = 0
	 	Set header = ""
			Set result = mgr.GenerateExportRoutine()
		 	if result '= 1 {
			 	Set tmsg = "Error generating export routine: "_result
			 	do ##class(Ens.Util.Log).LogError("IIBAENSEMBLE.Utilities", "TableExport", tmsg)
			 	Quit
		 	}
			do mgr.OpenExport()
			Set sta = mgr.GetExportSize(.size)
			if size = 0 {
				do ##class(Ens.Util.Log).LogWarning("IIBAENSEMBLE.Utilities", "TableExport", "Table: "_TableName_" - No data to export")
			} else {
				while done = 0 {
					do mgr.ExportRows(.rows,.done)
					Set total = total + rows
				}
				do ##class(Ens.Util.Log).LogInfo("IIBAENSEMBLE.Utilities", "TableExport", "Table: "_TableName_" / Exported: "_total_" rows")
			}
			do mgr.CloseExport()
			do mgr.DeleteExportRoutine()
 
		Set mobj = ""
	} While(0)
}

}
