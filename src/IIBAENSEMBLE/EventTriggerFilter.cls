///   Provides a filter of HL7 messages based off of the accession and the trigger event, allowing the
/// blocking of transactions when there are multiple messages for the same accession/trigger within a time threshold.
/// 
Class IIBAENSEMBLE.EventTriggerFilter Extends (%Persistent, Ens.Rule.FunctionSet) [ Inheritance = right ]
{

Property OrgAccessionTrigger As %String;

Property CreatedOn As %TimeStamp;

Property ModifiedOn As %TimeStamp;

Index IDIndex On OrgAccessionTrigger [ IdKey, Unique ];

/// Checks to see if this accession and trigger were reported within the time threshold (in minutes)
///   (The default time threshold is 30 minutes)
ClassMethod EventTriggerTimeCheck(Org As %String, Accession As %String, Trigger As %String, TimeThreshold As %String = 30) As %String
{
	S ModifyFlag="Recent"
	
	//$$$TRACE("Calling EventTriggerModifyCheck with: "_Org_"."_Accession_"."_Trigger)
	
	s oref=##class(IIBAENSEMBLE.EventTriggerFilter).%OpenId(Org_"."_Accession_"."_Trigger)
	if $ISOBJECT(oref) {
		
		//w "Modified On: ",oref.ModifiedOn,!
		//W "Now: ",$H,"  ",$ZDT($H,3),!
		//W "Threshold: ",TimeThreshold,!
		
		S TimeDiff=##class(Ens.DataType.UTC).timeDiff($ZDT($H,3),oref.ModifiedOn)
		//w "Time Diff: ",TimeDiff," (",TimeDiff\60,")",!
		If ( (TimeDiff>0) && ((TimeDiff\60)>TimeThreshold) ) {
			S ModifyFlag=TimeDiff
		}
	} else {
		s ModifyFlag="New"
	}
	
	Quit ModifyFlag
}

ClassMethod EventTriggerInsertOrUpdate(Org As %String, Accession As %String, Trigger As %String) As %Status
{
	S oref=##class(IIBAENSEMBLE.EventTriggerFilter).%OpenId(Org_"."_Accession_"."_Trigger)
	if $ISOBJECT(oref) {
		s oref.ModifiedOn=$ZDT($H,3)
		s tSC=oref.%Save()
		
	} else {
		s oref=##class(IIBAENSEMBLE.EventTriggerFilter).%New()
		s oref.OrgAccessionTrigger=Org_"."_Accession_"."_Trigger
		s oref.CreatedOn=$ZDT($H,3)
		s oref.ModifiedOn=$ZDT($H,3)
		s tSC=oref.%Save()
	}
	
	Quit tSC
}

Storage Default
{
<Data name="EventTriggerFilterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CreatedOn</Value>
</Value>
<Value name="3">
<Value>ModifiedOn</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.EventTrigge6718D</DataLocation>
<DefaultData>EventTriggerFilterDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.EventTrigge6718D</IdLocation>
<IndexLocation>^IIBAENSEMBLE.EventTrigge6718I</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.EventTrigge6718S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
