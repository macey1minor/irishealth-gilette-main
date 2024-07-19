Class BCBSSC.HL7.Service.HL7S3Inbound Extends EnsLib.HL7.Service.Standard [ ClassType = "", ProcedureBlock ]
{

Parameter ADAPTER = "EnsLib.CloudStorage.InboundAdapter";

/// ConfigID of the operation or process to which response (e.g. ACK) messages should be forwarded.
Property AckTargetConfigNames As %String;

Property LogHandler As Ens.DataType.ConfigName;

Parameter SETTINGS = "AckTargetConfigNames::selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},Framing,OverrideSegmentTerminator:xFormApp,NoBatchReply:xFormApp,LogHandler:xFormApp";

/* (override default value for Setting inherited from base class) */
/// Control of ACK handling; options:
/// - Never : Do not send back any ACK
/// - Immediate : Send back (commit) ACK reply message immediately upon receipt of the inbound message
/// - Application : If message passes validation, wait for ACK from target config item and forward it back when it arrives
/// - MSH-determined : Send back ACK reply messages as requested in the MSH header of the incoming message
Property AckMode As %String(DISPLAYLIST = ",Never,Immediate,Application,MSH-determined", VALUELIST = ",Never,Immed,App,Msh") [ InitialExpression = "Never", Required ];

/// End-Segment marker character(s)
Property SegTerminator As %String [ InitialExpression = {$C(13)} ];

/// Comma separated list of control characters to use for the segment terminators
/// instead of the default standard Carriage Return (Ascii 13 character).<br>
/// Can be Decimal or Hex if have preceding 'x'<br>
/// For example 10 or x0A to specify the use of the Line Feed character as the segment terminator.<br>
/// Enter a ? (question mark) for the service to examine each inbound stream to try to indentify
Property OverrideSegmentTerminator As %String;

Parameter ReadTimeout = 1;

Method OnInit() As %Status
{
	Set tSC=##super()  Quit:$$$ISERR(tSC) tSC
	Set (..%Parser.StartTimeout,..%Parser.ReadTimeout)=..#ReadTimeout
	If $$$XOR(""=..AckTargetConfigNames,"Never"=..AckMode) {
		If ""=..AckTargetConfigNames { $$$LOGWARNING("No ACK Target Config Name configured for AckMode '"_..AckMode_"'") }
		Else { $$$LOGWARNING("ACK Target ConfigName(s) '"_..AckTargetConfigNames_"' configured for AckMode '"_..AckMode_"'") }
	}

	If (..OverrideSegmentTerminator'="")&&(..OverrideSegmentTerminator'="?") {
		#dim tOverrideSegmentTerminator = ..AsciiOrHexAsChars(..OverrideSegmentTerminator)
		If tOverrideSegmentTerminator '= "" {
			Set ..SegTerminator = tOverrideSegmentTerminator
		}
	}
	If (..Adapter.BucketName["/") {
		Do ..parseS3BucketFileSpec(..Adapter.BucketName)
	} Else {
		Set logText = "xFormApp: Based on initial BucketName leaving BucketName at "_..Adapter.BucketName
		$$$LOGINFO(logText)
		Do ##class(%SYS.System).WriteToConsoleLog(logText,1,0)
	}
	Quit $$$OK
}

/// We parse the starting Adapter BucketName setting and modify<br>
/// BucketName can be of the form s3://bucketname/prefix1/prefixn/namewith?or*or. <br>
Method parseS3BucketFileSpec(pS3BucketFileSpec)
{
	#; use a class method  - aids testing
	Do ..ParseS3BucketFileSpecAPI(pS3BucketFileSpec,.tParsed)
	If $Get(tParsed("BucketName"))'=""  {
		Set ..Adapter.BucketName = $Get(tParsed("BucketName"))
		Set ..Adapter.BlobNamePrefix = $Get(tParsed("BlobNamePrefix"))
		Set ..Adapter.BlobNamePattern = $Get(tParsed("BlobNamePattern"))

		Set logText = "xFormApp: Based on initial BucketName resetting BucketName to: "_..Adapter.BucketName
		$$$LOGINFO(logText)
		Do ##class(%SYS.System).WriteToConsoleLog(logText,1,0)

		If ..Adapter.BlobNamePrefix'="" {
			Set logText = "xFormApp: Based on initial BucketName setting BlobNamePrefix to: "_..Adapter.BlobNamePrefix
		} Else {
			Set logText = "xFormApp: Based on initial BucketName leaving BlobNamePrefix empty"
		}
		$$$LOGINFO(logText)
		Do ##class(%SYS.System).WriteToConsoleLog(logText,1,0)

		If ..Adapter.BlobNamePattern'="" {
			Set logText = "xFormApp: Based on initial BucketName setting BlobNamePattern to: "_..Adapter.BlobNamePattern
		} Else {
			Set logText = "xFormApp: Based on initial BucketName leaving BlobNamePattern empty"
		}
		$$$LOGINFO(logText)
		Do ##class(%SYS.System).WriteToConsoleLog(logText,1,0)
	}
	Quit
}

/// tS3BucketFileSpec can be of the form s3://bucketname/prefix1/prefixn/namewith?or*or. <br>
/// s3:// is optional.<br>
/// pParsed("BucketName") is first / delimited string after optional leading 3://
/// /prefix1/prefixn/ is optional and can be one or more prefixes
/// and pParsed("BlobNamePrefix") will be set to this without the leading / or trailing / <br>
/// namewith?or*or. is optional and will be identified as the last / part of the string
/// if the string does not terminate with a / and contains an ? or * or . <br>
/// If /text/ is specified and namewith?or*or. is not specified then we identify text
/// as a prefix. <br>
/// This means we cannot pickup up just one particular filename
/// but it avoids having to terminate just a prefix with a / <br>
/// ..Adapter.BucketName = bucketname<br>
/// ..Adapter.BlobNamePrefix = /prefix1/predixn<br>
/// ..Adapter.BlobNamePattern = namewith?or*or.<br>
ClassMethod ParseS3BucketFileSpecAPI(tS3BucketFileSpec As %String, Output pParsed As %String)
{
	Kill pParsed
	#; leave out s to simplify incase s or S
	If tS3BucketFileSpec["3://" {
		Set tS3BucketFileSpec = $Piece(tS3BucketFileSpec,"3://",2)
	}
	Set pParsed("BucketName") = $Piece(tS3BucketFileSpec,"/")
	If tS3BucketFileSpec["/" {
		Set pParsed("BlobNamePrefix") = $Piece(tS3BucketFileSpec,"/",2,*-1)
		If $Extract(tS3BucketFileSpec,*)'="/" {
			Set lastPiece = $Piece(tS3BucketFileSpec,"/",*)
			If $TR(lastPiece,"*?.","") '= lastPiece {
				Set pParsed("BlobNamePattern") = lastPiece
			} Else {
				If $Get(pParsed("BlobNamePrefix"))="" {
					Set pParsed("BlobNamePrefix") = lastPiece
				} Else {
					Set pParsed("BlobNamePrefix") = pParsed("BlobNamePrefix")_"/"_lastPiece
				}
			}
		}
	}
	Quit
}

Method OnProcessInput(pInput As EnsLib.CloudStorage.InboundInput, Output pOutput As %RegisteredObject) As %Status
{
	Set tSC=$$$OK
	$$$sysTRACE("Got Input "_pInput)
	#; Reet session id so we can detect if file had no HL7 data
	Set ..%SessionId=""
	If (..OverrideSegmentTerminator="?") {
		/* Look for segment terminator incase not $c(13)
		 this is done for every batch we get */
		Try {
			Do pInput.Content.Rewind()
			/* Grab enough to cover first segment see if $c(13), $c(10)
			or any combination of those 2 (some of which are unlikely) */
			#dim tLookForTerminatorSample = pInput.Content.Read(1000)
			For tPossibility = $C(13),$C(10) {
				If tLookForTerminatorSample[tPossibility {
					Set ..SegTerminator = tPossibility
					/* This logic assumes actual terminator found and does
					not check if an escaped terminator for text */
					Set tNextChar = $Extract(tLookForTerminatorSample,$find(tLookForTerminatorSample,tPossibility))
					If ($C(13,10)[tNextChar) Set ..SegTerminator=..SegTerminator_tNextChar
					Quit
				}
			}
			Do pInput.Content.Rewind()
		} Catch ex {}
	}
	Set tIOStream=##Class(%IO.MetaCharacterStream).%New(pInput.Content)  Quit:'$IsObject(tIOStream) %objlasterror
	Set tIOStream.Name=pInput.Name
	
	Do ..%Parser.Reset()
	While 'tIOStream.AtEnd { ; Loop over docs in the file
		Set tSC1=..%Parser.ParseFramedIOStream(tIOStream,,1)
		Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
		Quit:$$$StatusEquals(tSC1,$$$EnsErrGeneral) // !!! quit on fatal errors only
	}
	/*	If no session was created then it means there was no HL7 data
		identifiable in the file.
		Note this is different from some non identifiable followed by
		identifiable HL7 data.
	*/
	If (..%SessionId="")&&(..LogHandler'="") Do ..HandleNonHL7FormatFile(pInput)

	Do ..%Parser.Reset() ; release the file
	Quit tSC
}

/// The file did not contain a single HL7 identifiable message
Method HandleNonHL7FormatFile(pInput As EnsLib.CloudStorage.InboundInput)
{
	Try {
		Set tErrorContainer = ##class(XF.Base.Message.ErrorContainer).%New()
		Set tErrorContainer.SourceStream = ##class(%Stream.GlobalBinary).%New()
		Do pInput.Content.Rewind()
		Do tErrorContainer.SourceStream.CopyFrom(pInput.Content)
		Set tErrorContainer.ErrorLog.dateTime = $$$timeUTC
		Set tErrorContainer.ErrorLog.errorType = "Conversion"
		Set tErrorContainer.ErrorLog.errorText = "Source File does not contain identifiable HL7 data"
		Set tErrorContainer.ErrorLog.originalSourceFilename = pInput.Name
		Do ..SendRequestAsync(..LogHandler,tErrorContainer)
	} Catch {}
}

Method SendReply(pReplyDocument As EnsLib.EDI.Document, pOriginalDoc As EnsLib.EDI.Document = {$$$NULLOREF}) As %Status
{
	If ""=..AckTargetConfigNames {
		$$$sysTRACE("ACK "_pReplyDocument_$S($IsObject(pReplyDocument):"/"_pReplyDocument.%Id(),1:"")_" not sent because no ACK Target Config Name is configured")
		Quit $$$OK
	}
	Set pReplyDocument.IsMutable=0
	Set tSC=$$$OK  For iTarget=1:1:$L(..AckTargetConfigNames, ",") { Set tOneTarget=$ZStrip($P(..AckTargetConfigNames,",",iTarget),"<>W")  Continue:""=tOneTarget
		Set tSC1=..SendRequestAsync(tOneTarget,pReplyDocument) Quit:$$$ISERR(tSC)
		Set:$$$ISERR(tSC1) tSC=$$$ADDSC(tSC,tSC1)
	}
	Quit tSC
}

/// Return the segment terminator string that the Parser and the OutputTo...() methods will use.
Method GetSegmentTerminator() As %String
{
	Quit ..SegTerminator
}

ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	Do ##super(.pArray,pItem)
	If pItem.GetModifiedSetting("AckTargetConfigNames",.tValue) {
		For i=1:1:$L(tValue,",") { Set tOne=$ZStrip($P(tValue,",",i),"<>W")  Continue:""=tOne  Set pArray(tOne)="" }
	}
}

/// Revision number of this class
Parameter SrcVer = 3;

}
