/// Copyright 2007 by Inland Imaging Business Associates
Class IIBAENSEMBLE.Functions Extends Ens.Rule.FunctionSet
{

ClassMethod xRef(sPTName As %String, sRTSystem As %String, refValue As %String, returnDefault As %Boolean = 1, ByRef RVId As %Integer = 0) As %String [ CodeMode = expression, Final ]
{
..xRefFunct(..StringReplace(.sPTName,"'","''"), ..StringReplace(.sRTSystem,"'","''") , ..StringReplace(.refValue,"'","''"), returnDefault, .RVId)
}

ClassMethod xRefFunct(sPTName As %String, sRTSystem As %String, refValue As %String, returnDefault As %Boolean, ByRef RVId As %Integer) As %String [ Final ]
{
	set sPTID="", sPTPrincipalRole="", sReturnValue=""
	
	&sql(SELECT ID, PrincipalRole INTO :sPTID, :sPTPrincipalRole FROM IIBAENSEMBLE_Reference.PrincipalType WHERE Name = :sPTName)
	if SQLCODE '= 0 Quit sReturnValue
	
	if sPTPrincipalRole = "source" {
		&sql(SELECT ID, RValue INTO :RVId, :sReturnValue FROM IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->PrincipalType = :sPTID AND RelatedType->System = :sRTSystem AND PrincipalValue->PValue = :refValue)
		if SQLCODE '= 0 set sReturnValue = "", RVId = 0
	}
	
	if sPTPrincipalRole = "target" {
		&sql(SELECT ID, PrincipalValue->PValue INTO :RVId, :sReturnValue FROM IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->PrincipalType = :sPTID AND RelatedType->System = :sRTSystem AND RValue = :refValue)
		if SQLCODE '= 0 set sReturnValue = "", RVId = 0
	}
	
	if (sReturnValue="")&&(returnDefault) { 
		&sql(SELECT DefaultValue INTO :sReturnValue FROM IIBAENSEMBLE_Reference.RelatedType WHERE PrincipalType = :sPTID AND System = :sRTSystem)
		if SQLCODE '= 0 set sReturnValue = ""
	}
	
	Quit sReturnValue
}

ClassMethod xRefR(sPTName As %String, sRTSystem As %String, refValue As %String) As %String [ CodeMode = expression, Final ]
{
..xRefFunctR(..StringReplace(.sPTName,"'","''"), ..StringReplace(.sRTSystem,"'","''") , ..StringReplace(.refValue,"'","''"))
}

ClassMethod xRefFunctR(sPTName As %String, sRTSystem As %String, refValue As %String) As %String [ Final ]
{
	set sPTID="", sPTPrincipalRole="", sReturnValue=""
	
	&sql(SELECT ID, PrincipalRole INTO :sPTID, :sPTPrincipalRole FROM IIBAENSEMBLE_Reference.PrincipalType WHERE Name = :sPTName)
	if SQLCODE '= 0 Quit sReturnValue
	
	if sPTPrincipalRole = "source" {
		&sql(SELECT ID, PrincipalValue->PValue INTO :RVId, :sReturnValue FROM IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->PrincipalType = :sPTID AND RelatedType->System = :sRTSystem AND RValue = :refValue)
		if SQLCODE '= 0 set sReturnValue = "", RVId = 0
	}
	
	if sPTPrincipalRole = "target" {
		&sql(SELECT TOP 1 ID, RValue INTO :RVId, :sReturnValue FROM IIBAENSEMBLE_Reference.RelatedValue WHERE PrincipalValue->PrincipalType = :sPTID AND RelatedType->System = :sRTSystem AND PrincipalValue->PValue = :refValue)
		if SQLCODE '= 0 set sReturnValue = "", RVId = 0
	}
	
	Quit sReturnValue
}

ClassMethod xRefRAttr(sPTName As %String, sRTSystem As %String, refValue As %String, attrName As %String) As %String [ CodeMode = expression, Final ]
{
..xRefRAttrFunct(..StringReplace(.sPTName,"'","''"), ..StringReplace(.sRTSystem,"'","''") , ..StringReplace(.refValue,"'","''"), ..StringReplace(.attrName,"'","''"))
}

ClassMethod xRefRAttrFunct(sPTName As %String, sRTSystem As %String, refValue As %String, attrName As %String) As %String [ Final ]
{
	set RVId = 0, sReturnValue = ""
	set tSC = ..xRef(sPTName,sRTSystem,refValue,,.RVId)	
	
	set oRV = ##class(IIBAENSEMBLE.Reference.RelatedValue).%OpenId(RVId)
	
	if $ISOBJECT(oRV) {
		if $ISOBJECT(oRV.attr()) set sReturnValue = $ZOBJPROPERTY(oRV.attr(),attrName)
	}
	
	Quit sReturnValue
}

ClassMethod xRefUpSert(sPTName As %String, sRTSystem As %String, sPV As %String, sRV As %String) As %String [ CodeMode = expression, Final ]
{
..xRefUpSertFunct(..StringReplace(.sPTName,"'","''"), ..StringReplace(.sRTSystem,"'","''"), ..StringReplace(.sPV,"'","''"), ..StringReplace(.sRV,"'","''"))
}

ClassMethod xRefUpSertFunct(sPTName As %String, sRTSystem As %String, sPV As %String, sRV As %String) As %String [ Final ]
{
	set tSC = 1
	
	set oPT = ##class(IIBAENSEMBLE.csp.Reference).getPTobj(sPTName)
	set sPTID=oPT.%Id()
	
	set oPV = ##class(IIBAENSEMBLE.csp.Reference).getPVobj(sPV, sPTID)
	set sPVID=oPV.%Id()	
	
	set oRT = ##class(IIBAENSEMBLE.csp.Reference).getRTobj(sRTSystem, sPTID)
	set sRTID=oRT.%Id()
	
	set sRVID=##class(IIBAENSEMBLE.csp.Reference).getRVID(sRV, sPVID, sRTID)
	
	if sRVID="" {
		set tSC = ##class(IIBAENSEMBLE.csp.Reference).doRVUpSert(oPT, oRT, oPV, sRV)
	}
	
	Quit tSC
}

ClassMethod TableUpdateOrInsertExpr(value1 As %String = "", value2 As %String = "", value3 As %String = "", targetvalue As %String, translationID As %String) As %String [ CodeMode = expression, Final ]
{
..TableUpdateOrInsertFunct(..StringReplace(.value1,"'","''"),..StringReplace(.value2,"'","''"),..StringReplace(.value3,"'","''"),..StringReplace(.targetvalue,"'","''"),.translationID)
}

ClassMethod TableUpdateOrInsertFunct(value1 As %String = "", value2 As %String = "", value3 As %String = "", targetvalue As %String, translationID As %String) As %String [ Final ]
{
	set exists = ..TableLookup(value1,value2,value3,translationID,0)
	
	//set ^CacheTempMattsTrace3(1) = exists
	//set ^CacheTempMattsTrace3(2) = value1_value2_value3_translationID
	
	If exists '= "" {
		Set rset = ##class(%ResultSet).%New()
	
		If (value2 '= "") & (value3 '= "") {
			Do rset.Prepare("UPDATE IIBAENSEMBLE.LookupTable SET RightID= '"_targetvalue_"' WHERE LeftID1 = '"_value1_"' AND LeftID2 = '"_value2_"' AND LeftID3 = '"_value3_"' AND LookupID = '"_translationID_"'")
		} ElseIf value2 '= "" {
			Do rset.Prepare("UPDATE IIBAENSEMBLE.LookupTable SET RightID= '"_targetvalue_"' WHERE LeftID1 = '"_value1_"' AND LeftID2 = '"_value2_"' AND LeftID3 IS NULL AND LookupID = '"_translationID_"'")
		} Else {
			Do rset.Prepare("UPDATE IIBAENSEMBLE.LookupTable SET RightID= '"_targetvalue_"' WHERE LeftID1 = '"_value1_"' AND LeftID2 IS NULL AND LeftID3 IS NULL AND LookupID = '"_translationID_"'")
		}
	
		Set tSC = rset.Execute()

	} Else {
	
		Set rset = ##class(%ResultSet).%New()
			
		If (value2 '= "") & (value3 '= "") {
			Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTable (LeftID1, LeftID2, LeftID3, RightID, LookupID) VALUES ('"_value1_"', '"_value2_"', '"_value3_"', '"_targetvalue_"', '"_translationID_"')")
		} ElseIf value2 '= "" {
			Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTable (LeftID1, LeftID2, RightID, LookupID) VALUES ('"_value1_"', '"_value2_"', '"_targetvalue_"', '"_translationID_"')")
		} Else {
			Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTable (LeftID1, RightID, LookupID) VALUES ('"_value1_"', '"_targetvalue_"', '"_translationID_"')")
		}
		
		set tSC = rset.Execute()
	
	}
			
	Quit tSC
}

ClassMethod TableInsert(value1 As %String = "", value2 As %String = "", value3 As %String = "", targetvalue As %String, translationID As %String) As %String [ CodeMode = expression, Final ]
{
..TableInsertAction(..StringReplace(.value1,"'","''"),..StringReplace(.value2,"'","''"),..StringReplace(.value3,"'","''"),..StringReplace(.targetvalue,"'","''"),.translationID)
}

ClassMethod TableInsertAction(value1 As %String = "", value2 As %String = "", value3 As %String = "", targetvalue As %String, translationID As %String) As %String [ Final ]
{
	set exists = ..TableLookup(value1,value2,value3,translationID,0)
	
	If exists '= "" {
		set tSC = "AlreadyExists"
	} Else {
	
		Set rset = ##class(%ResultSet).%New()
			
		If (value2 '= "") & (value3 '= "") {
			Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTable (LeftID1, LeftID2, LeftID3, RightID, LookupID) VALUES ('"_value1_"', '"_value2_"', '"_value3_"', '"_targetvalue_"', '"_translationID_"')")
		} ElseIf value2 '= "" {
			Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTable (LeftID1, LeftID2, RightID, LookupID) VALUES ('"_value1_"', '"_value2_"', '"_targetvalue_"', '"_translationID_"')")
		} Else {
			Do rset.Prepare("INSERT INTO IIBAENSEMBLE.LookupTable (LeftID1, RightID, LookupID) VALUES ('"_value1_"', '"_targetvalue_"', '"_translationID_"')")
		}
		
		set tSC = rset.Execute()
	
	}
			
	Quit tSC
}

ClassMethod TableLookup(value1 As %String = "", value2 As %String = "", value3 As %String = "", translationID As %String = "", returnDefault As %Boolean = 1) As %String [ CodeMode = expression, Final ]
{
..TableTranslate(..StringReplace(.value1,"'","''"),..StringReplace(.value2,"'","''"),..StringReplace(.value3,"'","''"),.translationID,.returnDefault)
}

ClassMethod TableLookupApos(value1 As %String = "", value2 As %String = "", value3 As %String = "", translationID As %String = "", returnDefault As %Boolean = 1) As %String [ CodeMode = expression, Final ]
{
..TableTranslate(..StringReplace(.value1,"'","''"),..StringReplace(.value2,"'","''"),..StringReplace(.value3,"'","''"),.translationID,.returnDefault)
}

ClassMethod TableTranslate(value1 As %String = "", value2 As %String = "", value3 As %String = "", translationID As %String = "", returnDefault As %Boolean = 1) As %String [ Final ]
{
	// $$$LOGINFO(value1_" , "_value2_" , "_value3_" , "_translationID)
	Set tgtID = "", srcID1 = value1, srcID2 = value2, srcID3 = value3, count = 0, lookuptable = translationID
	
	//$$$LOGINFO("1:"_value1_"2:"_value2_"3:"_value3_"translationID:"_translationID)
		
	Set rset = ##class(%ResultSet).%New()
	If (srcID2 '= "") & (srcID3 '= "") {
		Do rset.Prepare("SELECT TOP 1 RightID FROM IIBAENSEMBLE.LookupTable WHERE LeftID1 = '"_srcID1_"' AND LeftID2 = '"_srcID2_"' AND LeftID3 = '"_srcID3_"' AND LookupID = '"_lookuptable_"'")
	} ElseIf srcID2 '= "" {
		Do rset.Prepare("SELECT TOP 1 RightID FROM IIBAENSEMBLE.LookupTable WHERE LeftID1 = '"_srcID1_"' AND LeftID2 = '"_srcID2_"' AND LeftID3 is NULL AND LookupID = '"_lookuptable_"'")
	} Else {
		Do rset.Prepare("SELECT TOP 1 RightID FROM IIBAENSEMBLE.LookupTable WHERE LeftID1 = '"_srcID1_"' AND LeftID2 is NULL AND LeftID3 is NULL AND LookupID = '"_lookuptable_"'")
	}
	
	Do rset.Execute()
	While (rset.Next(.sc)) {
		If ($SYSTEM.Status.IsOK(sc)) // check if this succeeded without errors
            {
                set tgtID = rset.Data("RightID")
            }
        Else // if there was an error, break out of the While loop
            {
                Quit
            }		
	}
	
	If $SYSTEM.Status.IsError(sc) // if there was an error, process that
     {
     $$$LOGERROR("Table Lookup Error") // perform error processing
     }
     
    if returnDefault = 1 {
     if tgtID = "" {
		Set rset = ##class(%ResultSet).%New()
	    //Do rset.Prepare("SELECT TOP 1 RightID FROM IIBAENSEMBLE.LookupTable WHERE LeftID1 = 'DefaultValue' AND LeftID2 = 'DefaultValue' AND LeftID3 = 'DefaultValue' AND LookupID = '"_lookuptable_"'")
	 	Do rset.Prepare("SELECT TOP 1 ID,LookupTableName,DefaultValue FROM IIBAENSEMBLE.LookupTableHeader WHERE LookupTableName = '"_lookuptable_"'")
	 	Do rset.Execute()
		While (rset.Next(.sc)) {
			If ($SYSTEM.Status.IsOK(sc)) // check if this succeeded without errors
    	        {
    	            //set tgtID = rset.Data("RightID")
    	            set tgtID = rset.Data("DefaultValue")
    	        }
    	    Else // if there was an error, break out of the While loop
    	        {
    	            Quit
    	        }		
		}
     } 
    }
	
	Quit tgtID
}

ClassMethod TableLookupR(value1 As %String = "", translationID As %String = "", Delimiter As %String = "") As %String [ CodeMode = expression, Final ]
{
..TableTranslateR(.value1,.translationID,.Delimiter)
}

ClassMethod TableTranslateR(value1 As %String = "", translationID As %String = "", Delimiter As %String = "") As %String [ Final ]
{
	//$$$LOGINFO(value1_" , "_translationID)
	Set tgtID = "", srcID1 = value1, lookuptable = translationID, strDelimiter = Delimiter
	If strDelimiter = "" { set strDelimiter = "^" }
	Set rset = ##class(%ResultSet).%New()
	Do rset.Prepare("SELECT TOP 1 LeftID1, LeftID2, LeftID3 FROM IIBAENSEMBLE.LookupTable WHERE RightID = '"_srcID1_"' AND LookupID = '"_lookuptable_"'")
	Do rset.Execute()
	While (rset.Next(.sc)) {
		If ($SYSTEM.Status.IsOK(sc)) // check if this succeeded without errors
            {
	
				If (rset.Data("LeftID2") '= "") & (rset.Data("LeftID3") '= "") {
					Set tgtID = rset.Data("LeftID1")_strDelimiter_rset.Data("LeftID2")_strDelimiter_rset.Data("LeftID3")
				} ElseIf rset.Data("LeftID2") '= "" {
					Set tgtID = rset.Data("LeftID1")_strDelimiter_rset.Data("LeftID2")
				} Else {
					Set tgtID = rset.Data("LeftID1")
				}
	
			}
        Else // if there was an error, break out of the While loop
            {
                Quit
            }		
	}
	
	If $SYSTEM.Status.IsError(sc) // if there was an error, process that
     {
     $$$LOGERROR("Reverse Table Lookup Error") // perform error processing
     }
	
	
	Quit tgtID
}

// 

// INPUT

//    SourceTimeZoneGMT -  Source Time zone relative to GMT

// 			Default is Pacific Standard Time (-8)

//    SourceDayLightSaveYN - Is daylight saving used at the source time zone Y/N

// 			Default is "Y"

//    TargetTimeZoneGMT - Target Time zone relative to GMT (Pacific standard = -8 )

//    TargetDayLightSaveYN - Is daylight saving used at the target time zone Y/N

/// This function determines the time difference between two time zones, taking
/// into consideration whether or not we are in daylight savings, and whether or 
/// or not daylight savings is used. The assumption is that everyone is in daylight
/// savings at the same time.
ClassMethod TimeZoneDiffExpr(SourceTimeZoneGMT As %Integer = -8, SourceDaylightSaveYN As %String = "Y", TargetTimeZoneGMT As %Integer, TargetDaylightSaveYN As %String, TimeValue As %String = "") As %Integer [ CodeMode = expression, Final ]
{
..TimeZoneDiffFunct(.SourceTimeZoneGMT,.SourceDaylightSaveYN, .TargetTimeZoneGMT,.TargetDaylightSaveYN,.TimeValue)
}

ClassMethod TimeZoneDiffFunct(SourceTimeZoneGMT As %Integer, SourceDaylightSaveYN As %String, TargetTimeZoneGMT As %Integer, TargetDaylightSaveYN As %String, TimeValue As %String = "") As %Integer [ Final ]
{
	
	If ( TimeValue = "" ) {
		Set TimeValue=$TR($TR($ZDT($H,8,1)," ",""),":","")
	}
	
	Set TimeValue=$E(TimeValue_"000000000000",1,12)
	
	set Diff=0
	
	
	/// Determine if we are in daylight savings
	//	- Calculate the difference between current local time and GMT
	//  - Compare to Timezone difference from GMT
	Set TimeDiff=($P($P($ZTIMESTAMP,",",2),".",1) - $P($HOROLOG,",",2))/3600
	If ( TimeDiff < 0 ) {
		Set TimeDiff=TimeDiff+24
	}
	Set DayLightSavings=($ZTIMEZONE/60)-TimeDiff
	
	//Determine time zone time difference
	Set Diff=TargetTimeZoneGMT-SourceTimeZoneGMT
	
	//Account for instances where day light savings is not used at some places
	if ( ( DayLightSavings=1 ) & ( TargetDaylightSaveYN '= SourceDaylightSaveYN ) ) {
		If ( (SourceDaylightSaveYN="Y") & ( TargetDaylightSaveYN="N") ) {
			
			Set Diff=Diff-1
		} Else {
			Set Diff=Diff+1
		}
	}
	
	Quit Diff
}

//         

//   Converts the timestamp to $H, adds TimeAdjustment, and converts back to HL7 format

/// Adjusts an HL7 timestamp, adding the TimeAdjustment value (in seconds) to the HL7 Time Stamp
ClassMethod HL7TimestampAdjustExpr(Timestamp As %String, TimeAdjustment As %Integer, TimestampLength As %Integer = 14) As %String [ CodeMode = expression, Final ]
{
..HL7TimestampAdjustFunct(.Timestamp,.TimeAdjustment,.TimestampLength)
}

ClassMethod HL7TimestampAdjustFunct(Timestamp As %String, TimeAdjustment As %Integer, TimestampLength As %Integer) As %String [ Final ]
{
	// $$$TRACE("HL7 Timetamp Adjust Inputs: Timestamp:"_Timestamp_", Adjustment:"_TimeAdjustment)
	Set NewTimestamp=""
	
	If (Timestamp '= "" ) {
		//First convert the HL7 Timestamp to $H format
		Set Htimestamp=$ZDTH($E(Timestamp,5,6)_"/"_$E(Timestamp,7,8)_"/"_$E(Timestamp,1,4)_" "_$E(Timestamp,9,10)_":"_$E(Timestamp,11,12)_":"_$E(Timestamp,13,14))
	
		//Now Adjust time stamp 
		Set Hday=$P(Htimestamp,",",1)
		Set Htime=$P(Htimestamp,",",2)
	
		Set NewTime=Htime+TimeAdjustment
		Set NewDay=Hday
		If ( (NewTime > 86399) || (NewTime<0) ) {
			If (NewTime > 86399 ) {
				Set DayCount=NewTime\86400
			} Else {
				Set DayCount=NewTime\86400-1
			}
			Set NewTime=NewTime-(86400*DayCount)
			Set NewDay=NewDay+DayCount
		}
	
	
		Set NewTimestamp=$TRANSLATE($ZDT(NewDay_","_NewTime,8,1),": ")
	}
	Quit $E(NewTimestamp,1,TimestampLength)
}

/// Format the MRN to IDX format, adding the dashes
ClassMethod FormatIDXMrnExpr(MRN As %String = "", MrnLength As %Integer = 8, PrefixChar As %String = "0") As %String [ CodeMode = expression, Final ]
{
..FormatIDXMrnFunct(.MRN,.MrnLength,.PrefixChar)
}

ClassMethod FormatIDXMrnFunct(MRN As %String = "", MrnLength As %Integer = "", PrefixChar As %String = "") As %String [ Final ]
{
	Set IdxMrn=""
	
	If (PrefixChar '= "") {
		Set MRN=$JUSTIFY(MRN,MrnLength)
		Set MRN=$TR(MRN," ",PrefixChar)
	}
	
	Set MrnLen=$Length(MRN)
	For i=0:2:MrnLength-2 {
		If ( i>0 ) {
			Set IdxMrn="-"_IdxMrn
		}
		
		Set IdxMrn=$Extract(MRN,MrnLength-i-1,MrnLength-i)_IdxMrn
	}
	
	
	Quit IdxMrn
}

ClassMethod StringReplace(OriginalString As %String, ReplaceThis As %String, ReplaceWith As %String = "") As %String [ CodeMode = expression, Final ]
{
$ListToString($ListFromString($G(OriginalString),ReplaceThis),ReplaceWith)
}

ClassMethod date2digitexpr(sdate As %String = "") As %String [ CodeMode = expression, Final ]
{
..date2digitfun(.sdate)
}

ClassMethod date2digitfun(sdate As %String = "") As %String [ Final ]
{
	
	set tSC = ""
	
	if sdate?2N1"/"2N1"/"4N {
		set tSC = sdate
	} elseif sdate?2N1"/"2N1"/"2N {
		set tyearnow = $E($ZD($H,3),3,4)
		set tyear = $P(sdate,"/",3)
		if tyear > tyearnow {
			set $P(sdate,"/",3) = "19"_tyear
		} else {
			set $P(sdate,"/",3) = "20"_tyear
		}
		set tSC = sdate
	}
				
	Quit tSC
}

ClassMethod dateODBCexpr(sdate As %String = "") As %String [ CodeMode = expression, Final ]
{
..dateODBCfun(.sdate)
}

ClassMethod dateODBCfun(sdate As %String = "") As %String [ Final ]
{
	
	set tSC = ""
	
	//sdate is expected to be in the format MM/DD/[YY]YY
	if (sdate?2N1"/"2N1"/"4N)||(sdate?2N1"/"2N1"/"2N) {
		
		set tdate = ..date2digitfun(sdate)
		set tSC = $ZD($ZDH(tdate,1),3)
	}
	
	//sdate is expected to be in the format MM/DD/[YY]YY hh:mm AM/PM
	if (sdate?2N1"/"2N1"/"4N1" "2N1":"2N1" "2A)||(sdate?2N1"/"2N1"/"2N1" "2N1":"2N1" "2A) {
		set tdate = ..date2digitfun($P(sdate," ",1))
		set ttime = $P(sdate," ",2)_" "_$P(sdate," ",3)
		set tSC = $ZDT($ZDTH(tdate_" "_ttime,1,4),3,1)
	}
	
	//sdate is HL7 date/time CCYYMMDDHHMMSS (HH, MM, SS opt)
	if ( sdate?8.14N  ) {
		
		// add seconds if not included
		If $LENGTH(sdate)<13 {
			set sdate=$E(sdate_"000000",1,14)
		}
		
		set tdate=$E(sdate,1,4)_"-"_$E(sdate,5,6)_"-"_$E(sdate,7,8)
		set ttime=$E(sdate,9,10)_":"_$E(sdate,11,12)_":"_$E(sdate,13,14)
		set tSC=tdate_" "_ttime
	}
	
	//sdate is expected to be in the format CCYYMMDD HH:MM
	if ( sdate?8N1" "2N1":"2N ) {
		
		set tdate=$E(sdate,1,4)_"-"_$E(sdate,5,6)_"-"_$E(sdate,7,8)
		set ttime=$E(sdate,10,14)_":00"
		set tSC=tdate_" "_ttime
	}
				
	Quit tSC
}

ClassMethod ParseCSV(CSVDataToProcess As %String) As %List
{
	
	//Declaring variables for text delimiter and text qualifyer
    set TextDelimiter="", TextQualifyer=""

	//Declaring the variables used in determining action to be taken
    set ProcessQualifyer="", NewRecordCreate=""

	//Declaring variables dealing with input string
    set CharMaxNumber=0, CharLocation=0, CharCurrentVal="", CharCounter=0, CharStorage=""

	//Declaring variables that handle array duties
    
    set CSVArrayCount=0

    
    
    //----------------------------------
    
    //Setting default values for various variables

   //<- Text delimiter is a comma
    set TextDelimiter = ","

   //<- Chr(34) is the ascii code for "
    set TextQualifyer = $C(34)

   //<- Determining how record should be processed
   set ProcessQualifyer = "False"

   //<- Calculating no. of characters in variable
    set CharMaxNumber = $LENGTH(CSVDataToProcess)

   //<- Determining how to handle record at different
   //   stages of operation
   //   0 = Don//t create new record
   //   1 = Write data to existing record
   //   2 = Close record and open new one
   set NewRecordCreate = 0

   //<- Priming the array counter
   set CSVArrayCount = 0

   //<- Initializing the array
   kill CSVArray
   set CSVArray = ""
   set CSVArray(CSVArrayCount) = ""

   //<- Record character counter
   set CharCounter = 0

   //----------------------------------
   
   //Starting the main loop
   
   For CharLocation=1:1:CharMaxNumber {
	   
	   //Retrieving the next character in sequence from CSVDataToProcess
	   set CharCurrentVal = $E(CSVDataToProcess,CharLocation,CharLocation)
	   
	   //This will figure out if the record uses a text qualifyer or not
	   If (CharCurrentVal = TextQualifyer) && (CharCounter = 0) {
         set ProcessQualifyer = "True"
         set CharCurrentVal = ""
	   }
	   
	   //Advancing the record 'letter count' counter
       set CharCounter = CharCounter + 1

	   //Choosing data extraction method (text qualifyer or no text qualifyer)
       If ProcessQualifyer = "True" {
	              
	       //This section handles records with a text qualifyer and text delimiter
           //It is also handles the special case scenario, where the qualifyer is
           //part of the data.  In the CSV file, a double quote represents a single
           //one  ie.  "" = "
           If $LENGTH(CharStorage) '= 0 {
	           
               If CharCurrentVal = TextDelimiter {
	               set CharStorage = ""
                   set ProcessQualifyer = "False"
                   set NewRecordCreate = 2
               } Else {
                   set CharStorage = ""
                  set NewRecordCreate = 1
               }
           } Else {
	           
	           If CharCurrentVal = TextQualifyer {
		           set CharStorage = CharStorage_CharCurrentVal
                   set NewRecordCreate = 0
	           } Else {
		           set NewRecordCreate = 1
	           }
           }
	       
       } Else {
	       
	       //This section handles a regular CSV record.. without the text qualifyer
	       If CharCurrentVal = TextDelimiter {
		       set NewRecordCreate = 2
	       } Else {
		       set NewRecordCreate = 1
	       }
       }
       
       //Writing the data to the array
       if NewRecordCreate = 1 {
	       //This section just writes the info to the array
           set CSVArray(CSVArrayCount) = CSVArray(CSVArrayCount)_CharCurrentVal
       }
       
       if NewRecordCreate = 2 {
	       //This section closes the current record and creates a new one
	       set CharCounter = 0
	       set CSVArrayCount = CSVArrayCount + 1
	       set CSVArray(CSVArrayCount) = ""
	       
	       
       }
      
       
	   
   }

	
	for i=0:1:CSVArrayCount {
		//w CSVArray(i),!
		set $LIST(lCSV,i+1) = CSVArray(i)
	}
	
	Quit lCSV
}

ClassMethod FormatExamCodeWModifierExpr(ExamCode As %String, Modifier As %String) As %String [ CodeMode = expression, Final ]
{
..FormatExamCodeWModifierFunct(.ExamCode,.Modifier)
}

ClassMethod FormatExamCodeWModifierFunct(ExamCode As %String, Modifier As %String) As %String [ Final ]
{
	Set NewExamCode=ExamCode
	
	If ( (Modifier="RIGHT") || (Modifier="LEFT") || (Modifier="BILAT") ) {
		Set NewExamCode=NewExamCode_"/"_Modifier
	}
	
	Quit NewExamCode
}

ClassMethod TestEmail(ByRef FileName As %String) As %Status
{
	set OldFileName = FileName
	set FileName = FileName_".dat"
	set FileRename = ##class(%File).Rename(OldFileName,FileName)
	Quit $$$OK
}

ClassMethod CheckHL7OBXForString(HL7 As %RegisteredObject, StringValue As %String = "") As %Boolean
{
	Set i=""
	set tSC=""
	Set ReportText = ""
	Set Return = 0
	
	For {
		Set i=HL7.GetNextIndex("OBX()",i,.tSC)  Quit:i=""
		Set ReportText=HL7.GetValueAt("OBX("_i_"):5")
		if $FIND($ZSTRIP(ReportText,"<>W"),$ZSTRIP(StringValue,"<>W")) {
			set Return = 1
			Quit
		}	
	}
	
	
	Quit Return
}

ClassMethod CheckForBlankOBX(HL7 As %RegisteredObject) As %String
{
	
	Set i=""
	set tSC=""
	Set ReportText = ""
	Set Return = "Blank"
	
	For {
		Set i=HL7.GetNextIndex("OBX()",i,.tSC)  Quit:i=""
		Set ReportText=HL7.GetValueAt("OBX("_i_"):5")
		if (($ZSTRIP(ReportText,"*W")'="")&&($ZSTRIP(ReportText,"*W")'="S:SQ")) {
			set Return = "NotBlank"
			Quit
		}	
	}
	
	
	Quit Return
}

/// Makes the first character of each sentence upper case, changes the remaining characters to lower case
/// and adds a period at the end of the sentence. 
/// An optional parameter is used to define the sentence separator. The defualt is period followed by a space
ClassMethod SentenceCaseHack(origSentence As %String, Separator As %String = ". ") As %String
{
	
	Set SentenceList=$LFS(origSentence,Separator)
	Set newSentence=""
	s ptr=0,sentence="",pos=0
	// Break up the sentence using the provided separator
	while $LISTNEXT(SentenceList,ptr,sentence) {
		s pos=pos+1
		s nw=1
		//Find first none space character in the sentence.
		While ( (nw <= $LENGTH(sentence)) && ($E(sentence,nw) = " ") ) {
			Set nw=nw+1
		}
		
		s $LIST(SentenceList,pos)=$ZCONVERT($E(sentence,1,nw),"U")_$ZCONVERT($E(sentence,nw+1,$LENGTH(sentence)),"L")
	}
	// Put the sentence back together again.
	Set newSentence=$ZSTRIP($LTS(SentenceList,Separator),">W")
	Set:$E(newSentence,$LENGTH(newSentence))'="." newSentence=newSentence_"."
	
	Quit newSentence
}

/// Fix sentence capitalization, and replace short keys with full descriptions.
/// Shorkeys are defined in the tranlsation table 'Radflow common shortkeys'.
/// Shortkeys in lookup table must be upper case.
ClassMethod VerbiageCleanupHack(Verbiage As %String, SeparatorList As %String = " ") As %String
{
	
	set SentenceStart=1,newVerbiage="",Separator=$E(SeparatorList)
	set ptr=0
	
	// Assume words are separated by a space
	while ($LISTNEXT($LFS(Verbiage,Separator),ptr,token)) {
	
		if (token'="") {
			
			s ShortkeyReplace=..CheckShortKeys(token,$E(SeparatorList,2,$LENGTH(SeparatorList)))
			
			
			s newToken=ShortkeyReplace
			
			//Capitalize if first word in a sentence
			s:SentenceStart $E(newToken,1)=$ZCONVERT($E(newToken,1),"U")
			
			//Check to see if we are at the end of a sentence
			if ( ($ZCONVERT(token,"U")="DR") || ($ZCONVERT(token,"U")="DR.") ) {
				S newToken="Dr."
				s SentenceStart=1
			} elseif ( $FIND(".!",$E(token,$LENGTH(token))) && (token'?.(1A1".")) ) {
				s SentenceStart=1
			} elseif ( (token'="?") && ($E(token,$LENGTH(token))="?") ) {
				s SentenceStart=1
			} else  {
				s SentenceStart=0
			}
			
			s:newVerbiage'="" newVerbiage=newVerbiage_Separator
			s newVerbiage=newVerbiage_newToken
		}
	}
	
	//Add a period at the end vergiage if it does not end with a punctuation character
	s:'$F(".?;,",$E(newVerbiage,$L(newVerbiage))) newVerbiage=newVerbiage_"."
	
	//Make sure there is a space after every period
	s ptr=0,count=0,tmp=""
	While ($LISTNEXT($LFS(newVerbiage,"."),ptr,token)) {
		s count=count+1
		if ((count>1) && ($E(token)'=" ") && ($LENGTH(token)>1)) {
			s tmp=tmp_". "_$ZCONVERT($E(token),"U")_$E(token,2,$LENGTH(token))
		} else {
			s:tmp'="" tmp=tmp_"."
			s tmp=tmp_token
		}
	}
	
	s newVerbiage=tmp
	
	//Make sure there is a space after every comma
	s ptr=0,count=0,tmp=""
	While ($LISTNEXT($LFS(newVerbiage,","),ptr,token)) {
		s count=count+1
		if ((count>1) && ($E(token)'=" ") && ($LENGTH(token)>1)) {
			s tmp=tmp_", "_token
		} else {
			s:tmp'="" tmp=tmp_","
			s tmp=tmp_token
		}
	}
	
	s newVerbiage=tmp
			
	
	
	Q newVerbiage
}

ClassMethod CheckShortKeys(token As %String, SeparatorList As %String) As %String
{
	
	
	
	//W !,"in CheckShortKeys- token: ",token," SeparatorList: ",SeparatorList,!
	
	Q:token=""
		
	s nToken=""
	
	//Check for Shortkey conversion
	if ( token?.P ) {
		s Shortkey=token
	} elseif (token'?.(1A1".") ) {
		s Shortkey=$ZSTRIP(token,"<>P")
	} else {
		s Shortkey=token
	}
	
	//w "Shortkey: ",Shortkey,!
	
	s Shortkey=$ZCONVERT(Shortkey,"U")
	s ShortkeyReplace=##class(IIBAENSEMBLE.Functions).TableLookup(Shortkey,"","","RADFLOW COMMON ShortkeyS")
	
	//w "ShortkeyReplace ",ShortkeyReplace,!
	
	if (ShortkeyReplace="") {	
		if ( SeparatorList="" ) {
			S nToken=$ZCONVERT(token,"L")
			
		} else {
			s ptr=0,Separator=$E(SeparatorList),count=0
			While ($LISTNEXT($LFS(token,Separator),ptr,sToken)) {
				s tmp="",count=count+1
				s:sToken'="" tmp=..CheckShortKeys(sToken,$E(SeparatorList,2,$LENGTH(SeparatorList)))
				
				s:count>1 nToken=nToken_Separator
				s nToken=nToken_tmp
			}
		}
	} else {
		s nToken=token
		s end=$F($ZCONVERT(token,"U"),Shortkey)
		s $E(nToken,end-$LENGTH(Shortkey),end-1)=ShortkeyReplace
	} 	
	
	//W "In CheckShortKey- nToken: ",nToken,!
	Q nToken
}

ClassMethod DateFilter(tDate As %String) As %String
{
	s rv=""
	s tDate2H=$ZDH(tDate,3)
	s tDateDiff=tDate2H-($H+0)
	if (tDateDiff = 0 ) {
		s rv="=HorologDate"
	} elseif (tDateDiff>0) {
		s rv=">HorologDate"
	} else {
		s rv="<HorologDate"
	}
	
	Q rv
}

ClassMethod WaitSeconds(Seconds As %String = "0") As %String [ CodeMode = expression, Final ]
{
..WaitSecondsFunct(.Seconds)
}

ClassMethod WaitSecondsFunct(Seconds As %String = "0") As %String [ Final ]
{
	hang Seconds
	
	Quit 1
}

ClassMethod longStringToMaxLengthLines(longString As %String, MaxLength As %Integer, ByRef Lines As %List) As %Status
{
	s tSC = 1
	s Lines = ""
	s curLineNum = 0
	s curLine = ""
	s curLineList = ""
	s curPosition = 0
	
	Do {
		s curLineList = $LFS($E(longString,curPosition+1,curPosition+MaxLength)," ")
		if curPosition+MaxLength >= $L(longString) {
			s curLine = $LTS(curLineList," ")
		} else {
			s curLine = $LTS($LI(curLineList,1,$LL(curLineList)-1)," ")
		}
		s $LI(Lines,$INCREMENT(curLineNum)) = curLine
		s curPosition = curPosition + $L(curLine)+1
	} WHILE curPosition < $L(longString)
	
	
	
	Quit tSC
}

ClassMethod timeDiff(T2 As %TimeStamp, T1 As %TimeStamp) As %Integer [ CodeMode = expression, Final ]
{
##class(Ens.DataType.UTC).timeDiff(T2,T1)
}

ClassMethod ObjExists(ClassName As %String, ID As %String) As %Boolean
{

	Quit $ISOBJECT($CLASSMETHOD(ClassName,"%OpenId",ID))
}

}
