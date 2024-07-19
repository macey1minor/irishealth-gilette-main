Include %sySystem

Class GC.Shared.FileOutboundAdapter Extends (Ens.OutboundAdapter, Ens.Util.File) [ ClassType = "", Inheritance = right, ProcedureBlock, System = 3 ]
{

Property FilePath As %String(MAXLEN = 1000);

/// Overwrite file if it exists, instead of appending
Property Overwrite As %Boolean [ InitialExpression = 0 ];

/// Use this Character Set to translate output to the file. For binary output, use 'Binary'.
Property Charset As %String [ InitialExpression = "Default" ];

/// Number of seconds to wait on each attempt to open the output file.
Property OpenTimeout As %Numeric(MINVAL = 0) [ InitialExpression = 5 ];

Parameter SETTINGS = "FilePath,Overwrite,Charset,OpenTimeout";

Property OldIO As %String(MAXLEN = 1000);

Property Device As %String(MAXLEN = 1000);

Property LineTerminator As %String(MAXLEN = 10) [ InitialExpression = {$C(10)} ];

Property Filename As %String;

Method OnInit() As %Status
{
	Set ..OldIO = $IO  Do ##class(Ens.Util.Trace).SetTraceDevice(..OldIO)
	Quit $$$OK
}

Method open(pFilename As %String) As %Status
{
	Set $ZT="Trap",tSC=$$$OK
	Do {
		$$$ASSERT(""=..Device)
		If ""=..FilePath Set tSC=$$$ERROR($$$EnsErrGeneral,"No file path specified; can't access file")  Quit

		Set ..Device = ..fixPath(..FilePath)_pFilename
		If ""'=..Charset&&("default"'=$ZCVT(..Charset,"L")) {
			Set tTable = ##class(%IO.I.TranslationDevice).GetCharEncodingTable(..Charset)
			Set tMode = $S(..Overwrite:"NWUK\",1:"AWUK\")_tTable_"\"
		} Else {
			Set tMode = $S(..Overwrite:"NWU",1:"AWU")
		}
		$$$catTRACE("file","Trying to open for "_$S(..Overwrite:"(over)write",1:"append")_" '"_..Device_"' with timeout="_..OpenTimeout)
		Open ..Device:(tMode):..OpenTimeout  Set:'$Test tSC=$$$ERROR($$$FileCanNotOpen,..Device)

		If $$$ISERR(tSC) Set ..Device = ""
		Else  $$$catTRACE("file","Opened for "_$S(..Overwrite:"(over)write",1:"append")_" '"_..Device_"'")

	} While 0
	If $$$ISERR(tSC) If $$$StatusEquals(tSC,$$$FileCanNotOpen) { Set ..BusinessHost.Retry = 1 } else { $$$LOGSTATUS(tSC) }
Exit
	Quit tSC
Trap
 	Set $ZT=""
 	If $ZE["<NOTOPEN>" { Set tSC=$$$ERROR($$$EnsErrGeneral,"Failed to open for "_$S(..Overwrite:"(over)write",1:"append")_" '"_..Device_" : "_$ZE) }
 	Else {
	 	Set tSC=$$$SystemError
	 	Close:..Device'="" ..Device
 	}
 	Set ..Device = ""
	Goto Exit
}

Method openRead(pFilename As %String) As %Status
{
	Set $ZT="Trap",tSC=$$$OK
	Do {
		$$$ASSERT(""=..Device)

		Set ..Device = ..fixPath(..FilePath)_pFilename
		If ""'=..Charset&&("default"'=$ZCVT(..Charset,"L")) {
			Set tTable = ##class(%IO.I.TranslationDevice).GetCharEncodingTable(..Charset)
			Set tMode = "RUK\"_tTable_"\"
		} Else {
			Set tMode ="RU"
		}
		$$$catTRACE("file","Trying to open for read '"_..Device_"' with timeout="_..OpenTimeout)
		Open ..Device:(tMode):..OpenTimeout  Set:'$Test tSC=$$$ERROR($$$FileCanNotOpen,..Device)

		If $$$ISERR(tSC) Set ..Device = ""
		Else  $$$catTRACE("file","Opened for read '"_..Device_"'")

	} While 0
	If $$$ISERR(tSC) If $$$StatusEquals(tSC,$$$FileCanNotOpen) { Set ..BusinessHost.Retry = 1 } else { $$$LOGSTATUS(tSC) }
Exit
	Quit tSC
Trap
 	Set $ZT="",tSC=$$$SystemError
 	Close:..Device'="" ..Device
 	Set ..Device = ""
	Goto Exit
}

Method close() As %Status
{
	if ""'=..Device {
		if $IO=..Device Use ..OldIO
		Close ..Device
		Set ..Device = ""
	}
	Quit $$$OK
}

Method Exists(pFilename As %String) As %Boolean
{
	$$$ASSERT(""=..Device)
	Set tFullname =..fixPath(..FilePath)_pFilename
	Quit ##class(%File).Exists(tFullname)
}

Method Delete(pFilename As %String) As %Status
{
	$$$ASSERT(""=..Device)
	Set tFullname =..fixPath(..FilePath)_pFilename
	Set tOK = ##class(%File).Delete(tFullname)
	if 'tOK Quit $$$EnsError($$$FileCanNotDelete,tFullname)
	Quit $$$OK
}

Method Rename(pFilename As %String, pNewFilename As %String, pNewPath As %String = "") As %Status
{
	$$$ASSERT(""=..Device)
	Set tFullname =..fixPath(..FilePath)_pFilename
	Set tNewFullname =$S(""=pNewPath:..fixPath(..FilePath)_pNewFilename,1:..fixPath(pNewPath)_pNewFilename)
	Set tOK = ##class(%File).Rename(tFullname, tNewFullname)
	if 'tOK Quit $$$EnsError($$$FileCanNotRename,tFullname_" -> "_tNewFullname)
	Quit $$$OK
}

Method PutLine(pFilename As %String, pLine As %String) As %Status [ CodeMode = expression ]
{
..PutString(pFilename, $g(pLine)_..LineTerminator)
}

// added by Ellen 11/04/2009

// this method expect the complete path and file name in the pFilename property

Method openCustom(pFilename As %String) As %Status
{
	Set $ZT="Trap",tSC=$$$OK
	Do {
		$$$ASSERT(""=..Device)
		If ""=..FilePath Set tSC=$$$ERROR($$$EnsErrGeneral,"No file path specified; can't access file")  Quit

		//Set ..Device = ..fixPath(..FilePath)_pFilename
		Set ..Device = pFilename
		If ""'=..Charset&&("default"'=$ZCVT(..Charset,"L")) {
			Set tTable = ##class(%IO.I.TranslationDevice).GetCharEncodingTable(..Charset)
			Set tMode = $S(..Overwrite:"NWUK\",1:"AWUK\")_tTable_"\"
		} Else {
			Set tMode = $S(..Overwrite:"NWU",1:"AWU")
		}
		$$$catTRACE("file","Trying to open for "_$S(..Overwrite:"(over)write",1:"append")_" '"_..Device_"' with timeout="_..OpenTimeout)
		Open ..Device:(tMode):..OpenTimeout  Set:'$Test tSC=$$$ERROR($$$FileCanNotOpen,..Device)

		If $$$ISERR(tSC) Set ..Device = ""
		Else  $$$catTRACE("file","Opened for "_$S(..Overwrite:"(over)write",1:"append")_" '"_..Device_"'")

	} While 0
	If $$$ISERR(tSC) If $$$StatusEquals(tSC,$$$FileCanNotOpen) { Set ..BusinessHost.Retry = 1 } else { $$$LOGSTATUS(tSC) }
Exit
	Quit tSC
Trap
 	Set $ZT=""
 	If $ZE["<NOTOPEN>" { Set tSC=$$$ERROR($$$EnsErrGeneral,"Failed to open for "_$S(..Overwrite:"(over)write",1:"append")_" '"_..Device_" : "_$ZE) }
 	Else {
	 	Set tSC=$$$SystemError
	 	Close:..Device'="" ..Device
 	}
 	Set ..Device = ""
	Goto Exit
}

// added by Ellen 11/04/2009

// added existscustom Al 04/04/2017

// this method expect the complete path and file name in the pFilename property

Method ExistsCustom(pFilename As %String) As %Boolean
{
	// returns 0 if file does not exist, returns 1 if file exists
	$$$ASSERT(""=..Device)
	Set tFullname = pFilename
	Quit ##class(%File).Exists(tFullname)
}

Method PutLineCustom(pFilename As %String, pLine As %String) As %Status [ CodeMode = expression ]
{
..PutStringCustom(pFilename, $g(pLine)_..LineTerminator)
}

// added by Ellen 11/04/2009

// this method expect the complete path and file name in the pFilename property

Method PutStringCustom(pFilename As %String, pData As %String) As %Status
{
	Set tSC = ..openCustom(pFilename) Quit:$$$ISERR(tSC) tSC
	Set $ZT="Trap",tSC=$$$OK
	Use ..Device write pData Use ..OldIO
	Set $ZT=""
Exit
	Quit ..close()
	Quit tSC
Trap
	Set $ZT="",tSC=$$$SystemError
	Goto Exit
}

Method PutString(pFilename As %String, pData As %String) As %Status
{
	Set tSC = ..open(pFilename) Quit:$$$ISERR(tSC) tSC
	Set $ZT="Trap",tSC=$$$OK
	Use ..Device write pData Use ..OldIO
	Set $ZT=""
Exit
	Quit ..close()
	Quit tSC
Trap
	Set $ZT="",tSC=$$$SystemError
	Goto Exit
}

Method PutStream(pFilename As %String, pStream As %Stream, ByRef pLen As %Integer = -1) As %Status
{
	#; If a raw temp stream, just rename rather than copying.
	If pStream.%Extends("%Library.FileStreamAdaptor")&&..Overwrite&&..isTemp(pStream) {
		Set tTable = ##class(%IO.I.TranslationDevice).GetCharEncodingTable(..Charset)
		If $S(pStream.%IsA("%Library.FileCharacterStream")&&(0'=pStream.TranslateTable):(tTable=pStream.TranslateTable), 1:("RAW"=tTable)) {
			Set tFilename=pStream.Filename
			Set tSC=pStream.SaveStream()  Quit:$$$ISERR(tSC) tSC
			Set pStream.Filename=..fixPath(..FilePath)_pFilename
			$$$catTRACE("adapter","Optimization: Renaming file stream from '"_tFilename_"' to '"_pStream.Filename_"'")
			Set tOK=##class(%File).Rename(tFilename,..fixPath(..FilePath)_pFilename)
			Set:tOK<0 tSC=$$$ERROR($$$EnsErrGeneral,"PutStream() Rename failed with code "_tOK)
			Quit tSC
		}
	}
	Set tSC = ..open(pFilename) Quit:$$$ISERR(tSC) tSC
	Set $ZT="Trap",tSC=$$$OK
	Use ..Device Set tSC=pStream.OutputToDevice(.pLen) Use ..OldIO
	Set $ZT=""
Exit
	Quit ..close()
Trap
	Set $ZT="",tSC=$$$SystemError
	Goto Exit
}

ClassMethod isTemp(pStream) [ CodeMode = expression ]
{
($$$SYSTempDir=$E(pStream.Filename,1,$L($$$SYSTempDir)))
}

Method GetStream(pFilename As %String, ByRef pStream As %Stream.Object = {$$$NULLOREF}) As %Status
{
	If '$IsObject(pStream) {
		If "binary"'=$ZCVT(..Charset,"L") { Set pStream=##class(%GlobalCharacterStream).%New() } Else { Set Stream=##class(%GlobalBinaryStream).%New() }
	}
	Set tSC = ..openRead(pFilename) Quit:$$$ISERR(tSC) tSC
	Set $ZT="Trap",tSC=$$$OK
	Use ..Device Set pLen=##class(%File).GetFileSize(..fixPath(..FilePath)_pFilename), tSC=pStream.InputFromDevice(.pLen) Use ..OldIO
	$$$catTRACE("file","Read "_pStream.Size_" characters from '"_..fixPath(..FilePath)_pFilename_"'")
	Set $ZT=""
Exit
	Quit ..close()
Trap
	Set $ZT="",tSC=$$$SystemError
	Goto Exit
}

/// Get a list of files in the directory configured by FilePath.
/// The filenames are returned in a %ListOfDataTypes object. Each entry in the list is
/// a semicolon-separated string containing: Filename;Type;Size;DateCreated;DateModified;FullPathName
Method NameList(Output pFileList As %ListOfDataTypes, pWildcards As %String = "*", pIncludeDirs As %Boolean = 0) As %Status
{
	#; ={$Select($$$isVMS:"*.*",1:"*")}
	Set $ZT="Trap",tSC=$$$OK
	do {
		Kill pFileList Set pFileList=##class(%ListOfDataTypes).%New()
		$$$catTRACE("file","Getting list of filenames for "_..fixPath(..FilePath))
		Set tResultSet=##class(%ResultSet).%New("%File:FileSet")
		Set tSC=tResultSet.Execute(..FilePath,pWildcards,"Type",pIncludeDirs)  Quit:$$$ISERR(tSC)
		While 0'=tResultSet.Next() {
			#; PathName;Type;Size;DateCreated;DateModified;Name
			Set tSC = pFileList.Insert(tResultSet.GetData(6)_";="_tResultSet.GetData(2)_";"_tResultSet.GetData(3)_";created="_tResultSet.GetData(4)_";modified="_tResultSet.GetData(5)_";"_tResultSet.GetData(1))  Quit:$$$ISERR(tSC)
		}
	} while (0)
	If $$$ISERR(tSC) $$$LOGSTATUS(tSC)
Exit
	Quit tSC
Trap
	Set $ZT="",tSC=$$$SystemError
	Goto Exit
}

}
