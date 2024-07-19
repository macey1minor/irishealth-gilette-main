/// In order to control width, justification, and filler character for a fixed width lines, specify the associated parameters in the property defintion.
/// Example: (JUSTIFIED = "L", FILLER = " ", MAXLEN = 12)
/// The MAXLEN parameter specifies the fixed width of the column
/// JUSTIFIED should be either L or R to specify left or right justified.  The default value is "L".
/// FILLER should be the filler character that is used to fill in columns to the specified fixed width.  The default value is " ".
Class IIBAENSEMBLE.cls.FixedWidth Extends %RegisteredObject
{

ClassMethod FixedWidthLineToMsgObject(pInput As %String, ByRef pOutput As %RegisteredObject) As %Status
{
	#dim tSC As %Status = $$$OK
	#dim sMsgClsName As %String
	#dim sJustified As %String = "L"
	#dim sFiller As %String = " "
	#dim iMaxLen As %Integer = 0
	#dim iCurrentPosition As %Integer = 1
	#dim sCurrentValue As %String
	
	if '$ISOBJECT(pOutput) Quit $$$ERROR($$$GeneralError,"pOutput must be passed in as an instance of an object.")

	s sMsgClsName = $CLASSNAME(pOutput)
	
	Set rs = ##class(%ResultSet).%New()
	s tSC = rs.Prepare("Select Name, InitialExpression, Parameters from %Dictionary.PropertyDefinition where parent = '"_sMsgClsName_"' AND Name <> 'CreatedOn' Order by SequenceNumber")
	if $$$ISERR(tSC) Quit tSC
	d rs.Execute()
	
	While (rs.Next()) {
		//re-initialize the parameters to the default values for each property
		s sJustified = "L"
		s sFiller = " "
		s iMaxLen = 0
	
		s PropertyParams = rs.Data("Parameters")
		for i=1:1:$L(PropertyParams,",") { 
			if $P($P(PropertyParams,",",i),"=",1)="MAXLEN" {
				s iMaxLen = $P($P(PropertyParams,",",i),"=",2)
			}
			if $P($P(PropertyParams,",",i),"=",1)="JUSTIFIED" {
				s sJustified = $P($P(PropertyParams,",",i),"=",2)
			}
			if $P($P(PropertyParams,",",i),"=",1)="FILLER" {
				s sFiller = $P($P(PropertyParams,",",i),"=",2)
			}
		}
		
		s sCurrentValue = $E(pInput,iCurrentPosition,iCurrentPosition+iMaxLen-1)
		if sJustified = "L" {
			s sCurrentValue = $ZSTRIP(sCurrentValue,">",sFiller)
		} ElseIf sJustified = "R" {
			s sCurrentValue = $ZSTRIP(sCurrentValue,"<",sFiller)
		}
		s $PROPERTY(pOutput,rs.Data("Name")) = sCurrentValue
		s iCurrentPosition = iCurrentPosition+iMaxLen
	}
	
	Quit tSC
}

ClassMethod msgObjectToFixedWidthLine(pInput As %RegisteredObject) As %String
{
	#dim sMsgClsName As %String
	#dim sJustified As %String = "L"
	#dim sFiller As %String = " "
	#dim iMaxLen As %Integer = 0
	#dim sFixedWidthLine As %String = ""
	
	s sMsgClsName = $CLASSNAME(pInput)
	
	
	
	
	Set rs = ##class(%ResultSet).%New()
	Do rs.Prepare("Select Name, InitialExpression, Parameters from %Dictionary.PropertyDefinition where parent = '"_sMsgClsName_"' AND Name <> 'CreatedOn' Order by SequenceNumber")
	d rs.Execute()
	
	While (rs.Next()) {
		
		//re-initialize the parameters to the default values for each property
		s sJustified = "L"
		s sFiller = " "
		s iMaxLen = 0
	
		s PropertyParams = rs.Data("Parameters")
		for i=1:1:$L(PropertyParams,",") { 
			if $P($P(PropertyParams,",",i),"=",1)="MAXLEN" {
				s iMaxLen = $P($P(PropertyParams,",",i),"=",2)
			}
			if $P($P(PropertyParams,",",i),"=",1)="JUSTIFIED" {
				s sJustified = $P($P(PropertyParams,",",i),"=",2)
			}
			if $P($P(PropertyParams,",",i),"=",1)="FILLER" {
				s sFiller = $P($P(PropertyParams,",",i),"=",2)
			}
		}
		
		s FillerString = ""
		s FixedWidthValue = ""
		s $P(FillerString,sFiller,iMaxLen+1)=""
		
		if sJustified="L" {
			s FixedWidthValue = $PROPERTY(pInput,rs.Data("Name"))_FillerString
			s FixedWidthValue = $E(FixedWidthValue,1,iMaxLen)
		}
		if sJustified="R" {
			
			s FixedWidthValue = FillerString_$PROPERTY(pInput,rs.Data("Name"))
			s FixedWidthValue = $E(FixedWidthValue,$L(FixedWidthValue)-iMaxLen+1,$L(FixedWidthValue))
		}
		
		s sFixedWidthLine = sFixedWidthLine_FixedWidthValue
		
		
	}
	
	Quit sFixedWidthLine
}

}
