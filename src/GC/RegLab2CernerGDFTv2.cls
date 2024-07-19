Class GC.RegLab2CernerGDFTv2 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='22.RegLab:GLT_DFT' targetDocType='231.Cerner:DFT_P03' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// Last Updated: 01/30/2019 Al Johnson
	// Last Updated in Prod:  03/12/2019
	// Created in Cert 01/30/2019 copied from GC.RegLab2CernerGDFTv1 - Al Johnson
	// Changes based on Beaker charges intermixed with Sunquest charges
	//
	// Use Z segment to transfer data in HL7 file instead of flat file
	// Remove leading zero in account numbers if sent
	// Remove leading M or E in Physician code if sent
	// Use GC.RegionsCharges.CernerGetPatientInfo to get MRN off Cerner tables
	//  Beaker now will send MRN.  If not sent read tables
	// 
	// Use GCH.Regions.DFT.VisitTBL Table data to assign MRN and verify Account number
	//    First Using Account get MRN
	//    If Account not found 
	//       use Patient Last & First Name, if unique, to get MRN
	//    If MRN found use to get valid Account number by DOS if IP account exists use else look for valid OP
	//    If none found just send account as sent by Regions
	// Do Not Send CPT code.  Cerner will build in tables based on CDM.
	// --  original dev / prod code - Check for CPT code range >= 80000 and <=89999 add modifier 90 01/26/2016 ALJ
	// Format unique value in FT1-2 TransactionId hl7 max 12 - take MSH:MessageControlID first 8 and last 4 characters
	// 01-11-2017 if cdm is misc CDM00011403 - include cpt and modifier
	// 01-17-2017   cpt - 25.1, 25.3 needs to be CPT  modifier/s - 26.1, 26.3 needs to be CPTMOD
	//
	// 01-30-2019 Beaker charges now include MRN
	// 01-30-2019 Beaker Regions charge code now 11 characters 3 digit revenue code, 5 char cpt/hcpcs, 3 digit counter
	// 01-30-2019 30084999001 is the new code for misc test - old was 00011403

]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"GCH"' property='target.{MSH:ReceivingFacility}' action='set' />
<assign value='"RegLab2CernerGDFTv2"' property='target.{MSH:Security}' action='set' />
<assign value='"DFT^P03"' property='target.{MSH:MessageType}' action='set' />
<assign value='"2.3"' property='target.{MSH:VersionID}' action='set' />
<assign value='"P03"' property='target.{EVN:EventTypeCode}' action='set' />
<assign value='"RGCHG"' property='target.{FT1grp(1).FT1:DepartmentCode}' action='set' />
<assign value='"CHG"' property='target.{FT1grp(1).FT1:TransactionCode.nameofcodingsystem}' action='set' />
<code>
<![CDATA[ 
	// Configure Credits
	//  Remove '-' negative sign if received on credit
]]></code>
<if condition='source.{ZDF:ZDF7ChargeCreditCode} = "CR"' >
<true>
<assign value='$Translate(source.{ZDF:ZDF10Quanity},"-","")' property='source.{ZDF:ZDF10Quanity}' action='set' />
<assign value='$Translate(source.{ZDF:ZDF11ExtAmount},"-","")' property='source.{ZDF:ZDF11ExtAmount}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
    // set FT1-1 setid
    // set FT1-2 transaction id must be unique - take 1st 8 and last 4 from msh message control id
	// set FT1-5 transaction posting date for Cerner
]]></code>
<assign value='"1"' property='target.{FT1grp(1).FT1:SetIDFT1}' action='set' />
<assign value='source.{MSH:MessageControlID}' property='tempid1' action='set' />
<assign value='$EXTRACT(tempid1,1,8)' property='tempid1a' action='set' />
<assign value='$EXTRACT(tempid1,*-3,*)' property='tempid1b' action='set' />
<assign value='tempid1a_tempid1b' property='target.{FT1grp(1).FT1:TransactionID}' action='set' />
<assign value='source.{ZDF:ZDF6DOS}' property='target.{FT1grp(1).FT1:TransactionDate}' action='set' />
<assign value='source.{ZDF:ZDF6DOS}' property='target.{FT1grp(1).FT1:TransactionPostingDate}' action='set' />
<assign value='source.{ZDF:ZDF7ChargeCreditCode}' property='target.{FT1grp(1).FT1:TransactionType}' action='set' />

<code>
<![CDATA[ 
	// update Regions price by 1.5048 and round
	// for Cerner update unit price with 1.5048 rounded price
]]></code>
<if condition='( +source.{ZDF:ZDF11ExtAmount} &lt;= 0)' >
<true>
<assign value='"0"' property='target.{FT1grp(1).FT1:TransactionAmountExtended}' action='set' />
<assign value='"0"' property='target.{FT1grp(1).FT1:TransactionAmountUnit}' action='set' />
</true>
<false>
<assign value='source.{ZDF:ZDF11ExtAmount}/source.{ZDF:ZDF10Quanity}' property='currPrice' action='set' />
<assign value='currPrice * (1.5048*1000)' property='newPrice' action='set' />
<assign value='$NUMBER(newPrice,0)' property='newPrice' action='set' />
<assign value='((((( newPrice \ 500 ) + 1 ) * 500 ) - newPrice ) # 500)' property='diff' action='set' />
<assign value=' newPrice + diff' property='newPrice' action='set' />
<assign value='newPrice / 1000' property='newPrice' action='set' />
<assign value='newPrice' property='target.{FT1grp(1).FT1:TransactionAmountUnit}' action='set' />
<assign value='newPrice * source.{ZDF:ZDF10Quanity}' property='newPrice' action='set' />
<assign value='newPrice' property='target.{FT1grp(1).FT1:TransactionAmountExtended}' action='set' />
</false>
</if>
<assign value='source.{ZDF:ZDF10Quanity}' property='target.{FT1grp(1).FT1:TransactionQuantity}' action='set' />
<assign value='source.{ZDF:ZDF2LastName}' property='target.{PID:PatientName(1).familylastname}' action='set' />
<assign value='source.{ZDF:ZDF3FirstName}' property='target.{PID:PatientName(1).givenname}' action='set' />
<assign value='source.{ZDF:ZDF4MiddleName}' property='target.{PID:PatientName(1).middleinitialorname}' action='set' />
<assign value='source.{ZDF:ZDF2LastName}' property='tpatientlastnm' action='set' />
<assign value='source.{ZDF:ZDF3FirstName}' property='tpatientfirstnm' action='set' />
<assign value='source.{ZDF:ZDF4MiddleName}' property='tpatientmiddlenm' action='set' />

<code>
<![CDATA[ 
	// Beaker will send MRN remove G prefix and leading zeros from mrn if sent by Regions
]]></code>
<assign value='""' property='tempmrn' action='set' />
<assign value='""' property='tempmrn1' action='set' />
<assign value='""' property='tempmrn2' action='set' />
<assign value='source.{ZDF:ZDF16MRN}' property='tempmrn' action='set' />
<assign value='$ZSTRIP(tempmrn,"&lt;","G")' property='tempmrn1' action='set' />
<assign value='$ZSTRIP(tempmrn1,"&lt;","0")' property='tempmrn2' action='set' />

<code>
<![CDATA[ 
	// remove CDM prefix and leading zeros from Regions cdm
	// set cpt field and modifier to null
]]></code>
<assign value='source.{ZDF:ZDF8ChargeCode}' property='tempcdm' action='set' />
<assign value='$ZSTRIP(tempcdm,"&lt;","CDM")' property='tempcdm1' action='set' />
<assign value='$ZSTRIP(tempcdm1,"&lt;","0")' property='tempcdm2' action='set' />
<assign value='tempcdm2' property='target.{FT1grp(1).FT1:TransactionCode.identifier}' action='set' />
<code>
<![CDATA[ 
	// keep cpt and modifier on misc cdm 11403 and new code 30084999001
]]></code>
<if condition='(tempcdm2="11403")||(tempcdm2="30084999001")' >
<true>
<assign value='source.{ZDF:ZDF14CPTCode}' property='target.{FT1grp(1).FT1:ProcedureCode.identifier}' action='set' />
<assign value='"CPT"' property='target.{FT1grp(1).FT1:ProcedureCode.nameofcodingsystem}' action='set' />
<assign value='source.{ZDF:ZDF15Modifier}' property='target.{FT1grp(1).FT1:ProcedureCodeModifier(1).identifier}' action='set' />
<if condition='source.{ZDF:ZDF15Modifier}=""' >
<false>
<assign value='"CPTMOD"' property='target.{FT1grp(1).FT1:ProcedureCodeModifier(1).nameofcodingsystem}' action='set' />
</false>
</if>
</true>
<false>
<assign value='""' property='target.{FT1grp(1).FT1:ProcedureCode}' action='set' />
<assign value='""' property='target.{FT1grp(1).FT1:ProcedureCodeModifier(1)}' action='set' />
</false>
</if>
<code>
<![CDATA[ 
    // write !,("tempcdm="_tempcdm_" tempcdm1="_tempcdm1)
    // $$$TRACE("tempcdm="_tempcdm_" tempcdm1="_tempcdm1)
    // $$$TRACE("tMRN="_tMRN)    
	]]></code>
<code>
<![CDATA[ 
	// remove M prefix if one exists
]]></code>
<if condition='..StartsWith(source.{ZDF:ZDF13ServicePhyCode},"M")|| ..StartsWith(source.{ZDF:ZDF12OrderingPhyCode},"E") ' >
<true>
<assign value='..SubString(source.{ZDF:ZDF13ServicePhyCode},2,8)' property='target.{FT1grp(1).FT1:PerformedByCode}' action='set' />
</true>
<false>
<assign value='source.{ZDF:ZDF13ServicePhyCode}' property='target.{FT1grp(1).FT1:PerformedByCode}' action='set' />
</false>
</if>
<if condition='..StartsWith(source.{ZDF:ZDF12OrderingPhyCode},"M") || ..StartsWith(source.{ZDF:ZDF12OrderingPhyCode},"E") ' >
<true>
<assign value='..SubString(source.{ZDF:ZDF12OrderingPhyCode},2,8)' property='target.{FT1grp(1).FT1:OrderedByCode}' action='set' />
</true>
<false>
<assign value='source.{ZDF:ZDF12OrderingPhyCode}' property='target.{FT1grp(1).FT1:OrderedByCode}' action='set' />
</false>
</if>
<code>
<![CDATA[ 
	// ***************** Coding for Account and MRN ************************
	// Use GCH.Regions.DFT.VisitTBL Table data to assign MRN and verify Account number
	// First Using Account get MRN
	// If Account not found 
		// use Patient Last & First Name, if unique, to get MRN
		// with MRN get valid Account by DOS if IP account exists else look for valid OP
			// If none found just send account as sent by Regions
]]></code>
<assign value='source.{ZDF:ZDF2LastName}' property='pPatientNameLast' action='set' />
<assign value='source.{ZDF:ZDF3FirstName}' property='pPatientNameFirst' action='set' />
<assign value='""' property='pMRN' action='set' />
<code>
<![CDATA[ 
	// strip leading zero on account numbers and set variable.		
]]></code>
<assign value='"0NopAcct"' property='pPatientAccount' action='set' />
<assign value='"NotAcct"' property='tPatientAccount' action='set' />
<assign value='"NoOldAcct"' property='OldAccount' action='set' />
<assign value='"NoOutAcct"' property='tAccountOut' action='set' />
<assign value='"NoInAcct"' property='tAccountIn' action='set' />
<assign value='"notMRN"' property='tMRN' action='set' />
<assign value='"Noname"' property='tMRNname' action='set' />
<assign value='""' property='pDOS' action='set' />
<assign value='source.{ZDF:ZDF6DOS}' property='pDOS' action='set' />
<assign value='source.{ZDF:ZDF1AccountNumber}' property='OldAccount' action='set' />
<assign value='$ZSTRIP(OldAccount,"&lt;","0")' property='pPatientAccount' action='set' />
<assign value='pPatientAccount' property='target.{MSH:25}' action='set' />
<assign value='pPatientAccount' property='target.{PID:18}' action='set' />
<assign value='"MRNnotFnd"' property='target.{MSH:16}' action='set' />
<assign value='"NoMRN "' property='target.{MSH:22}' action='set' />
<assign value='""' property='tMRN' action='set' />

<if condition='tempmrn2 = ""'>
<false>
<assign value='tempmrn2' property='tMRN' action='set'/>
<assign value='"MRNsent"' property='target.{MSH:16}' action='set' />
<assign value='tempmrn2' property='target.{PID:3}' action='set' />
<assign value='tempmrn2' property='target.{MSH:22}' action='set' />
</false>
</if>

<if condition='tempmrn2 = ""' >
<true>
<if condition='pPatientAccount = ""' >
<false>
<code>
<![CDATA[ 
	// Using Account and get MRN 
    // alj 	set tMRN = ##class(GCH.Regions.DFT.VisitTBL).AccountGetMRN(pPatientAccount)
    // $$$TRACE("pPatientAccount="_pPatientAccount)
    set tMRN=""
    set tMRN=##class(GC.CernerGetData).CernerGetPatientInfoByFin(pPatientAccount)
    // $$$TRACE("tMRN="_tMRN)    
    ]]></code>
</false>
</if>
</true>
</if>

<if condition='tMRN=""' >
<false>
<assign value='pPatientAccount' property='tAccountIn' action='set' />
</false>
</if>

<if condition='tMRN = ""' >
<true>
<assign value='"AcctNoFnd"' property='target.{MSH:21}' action='set' />
<code>
<![CDATA[ 
	// Using Patient Last,First Name and Middle Name to get MRN from PatientData table if unique
    //  $$$TRACE("tMRNpatnmB4="_tMRN)
    set tMRN=##class(GC.CernerGetData).CernerGetPatientInfoByName(tpatientlastnm,tpatientfirstnm,tpatientmiddlenm)
    // $$$TRACE("tMRN="_tMRN)
	]]></code>
<if condition='tMRN = ""' >
<true>
<assign value='""' property='target.{PID:3}' action='set' />
</true>
<false>
<assign value='"MRNbyName"' property='target.{MSH:16}' action='set' />
<assign value='tMRN' property='target.{PID:3}' action='set' />
<assign value='tMRN' property='target.{MSH:22}' action='set' />
</false>
</if>
</true>
<false>
<assign value='"MRNbyAcct"' property='target.{MSH:16}' action='set' />
<assign value='tMRN' property='target.{PID:3}' action='set' />
<assign value='tMRN' property='target.{MSH:22}' action='set' />
<assign value='"AcctFound"' property='target.{MSH:21}' action='set' />
</false>
</if>

<if condition='target.{PID:18} = "noacct"' >
<true>
<code>
<![CDATA[ 
	//  If no valid account found account as sent from Regions
]]></code>
<assign value='pPatientAccount' property='target.{PID:18}' action='set' />
</true>
</if>

<code>
<![CDATA[ 
	// MSH Value Depending on Account Number Changed
]]></code>
<if condition='target.{PID:18} = source.{ZDF:ZDF1AccountNumber}' >
<true>
<assign value='"AcctSame"' property='target.{MSH:23}' action='set' />
<assign value='source.{ZDF:ZDF1AccountNumber}' property='target.{MSH:24}' action='set' />
<assign value='target.{PID:18}' property='target.{MSH:25}' action='set' />
<assign value='""' property='target.{MSH:26}' action='set' />
</true>
<false>
<if condition='target.{PID:18} = target.{MSH:25}' >
<true>
<assign value='"AcctChg"' property='target.{MSH:23}' action='set' />
<assign value='source.{ZDF:ZDF1AccountNumber}' property='target.{MSH:24}' action='set' />
<assign value='""' property='target.{MSH:26}' action='set' />
</true>
<false>
<assign value='"NewAccount"' property='target.{MSH:23}' action='set' />
<assign value='source.{ZDF:ZDF1AccountNumber}' property='target.{MSH:24}' action='set' />
<assign value='target.{PID:18}' property='target.{MSH:26}' action='set' />
<assign value='""' property='target.{MSH:27}' action='set' />
</false>
</if>
</false>
</if>
</transform>
}

}
