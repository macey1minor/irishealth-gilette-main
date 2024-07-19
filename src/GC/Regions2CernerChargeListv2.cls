Class GC.Regions2CernerChargeListv2 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, GC.Regions.DFT.ChargeDFT) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='GC.Regions.DFT.ChargeDFT' sourceDocType='22.RegLab:GLT_DFT' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// Last Moved to Prod - 03/12/2019 
	// Last Updated 01/30/2019
	// Created: 04/04/2017  Al Johnson  
	// Desc: Report Daily Regions Charges To Cerner
	//  Beaker now sending MRN 01/30/2019 Al Johnson
	]]></code>

<assign value='source.{MSH:DateTimeofMessage}' property='target.HL7MessageDate' action='set' />
<assign value='source.{ZDF:ZDF6DOS}' property='target.TransactionDate' action='set' />
<assign value='source.{ZDF:ZDF6DOS}' property='target.PostingDate' action='set' />
<assign value='"RGCHG"' property='target.DeptCode' action='set' />
<code>
<![CDATA[ 
    // set FT1-1 setid
    // set FT1-2 transaction id must be unique - take 1st 8 and last 4 from msh message control id
	// set FT1-5 transaction posting date for Cerner
]]></code>
<assign value='source.{MSH:MessageControlID}' property='tempid1' action='set' />
<assign value='$EXTRACT(tempid1,1,8)' property='tempid1a' action='set' />
<assign value='$EXTRACT(tempid1,*-3,*)' property='tempid1b' action='set' />
<assign value='tempid1a_tempid1b' property='target.TransactionID' action='set' />

<assign value='source.{ZDF:ZDF7ChargeCreditCode}' property='target.TransactionType' action='set' />
<assign value='""' property='tempCDMtable' action='set' />
<assign value='""' property='tempCDMtableDept' action='set' />
<assign value='""' property='tempCDMtableRevCode' action='set' />
<assign value='""' property='tempCDMtableStatus' action='set' />
<assign value='..Lookup("T_RegionsCDMDept",source.{ZDF:ZDF8ChargeCode})' property='tempCDMtable' action='set' />

<assign value='$PIECE(tempCDMtable,"-",1)' property='tempCDMtableDept' action='set' />
<assign value='$PIECE(tempCDMtable,"-",2)' property='tempCDMtableRevCode' action='set' />
<assign value='$PIECE(tempCDMtable,"-",3)' property='tempCDMtableStatus' action='set' />

<assign value='tempCDMtableDept' property='target.RegionsCDMDept' action='set' />
<assign value='tempCDMtableRevCode' property='target.RegionsCDMRevCode' action='set' />
<assign value='tempCDMtableStatus' property='target.RegionsCDMStatus' action='set' />

<assign value='source.{ZDF:ZDF9ChargeDesc}' property='target.RegionsCDMDesc' action='set' />
<assign value='source.{ZDF:ZDF14CPTCode}' property='target.RegionsSentCPT' action='set' />
<assign value='source.{ZDF:ZDF15Modifier}' property='target.RegionsSentCPTMod' action='set' />

<code>
<![CDATA[ 
	// update Regions price by 1.5048 and round
	// for Cerner update unit price with 1.5048 rounded price
]]></code>
<if condition='( +source.{ZDF:ZDF11ExtAmount} &lt;= 0)' >
<true>
<assign value='"0"' property='target.AmountExtended' action='set' />
<assign value='"0"' property='target.AmountUnit' action='set' />
</true>
<false>
<assign value='source.{ZDF:ZDF11ExtAmount}/source.{ZDF:ZDF10Quanity}' property='currPrice' action='set' />
<assign value='currPrice * (1.5048*1000)' property='newPrice' action='set' />
<assign value='$NUMBER(newPrice,0)' property='newPrice' action='set' />
<assign value='((((( newPrice \ 500 ) + 1 ) * 500 ) - newPrice ) # 500)' property='diff' action='set' />
<assign value=' newPrice + diff' property='newPrice' action='set' />
<assign value='newPrice / 1000' property='newPrice' action='set' />
<assign value='newPrice' property='target.AmountUnit' action='set' />
<assign value='newPrice * source.{ZDF:ZDF10Quanity}' property='newPrice' action='set' />
<assign value='newPrice' property='target.AmountExtended' action='set' />
</false>
</if>

<assign value='source.{ZDF:ZDF10Quanity}' property='target.Quantity' action='set' />

<assign value='source.{ZDF:ZDF2LastName}' property='tpatientlastnm' action='set' />
<assign value='source.{ZDF:ZDF3FirstName}' property='tpatientfirstnm' action='set' />
<assign value='source.{ZDF:ZDF4MiddleName}' property='tpatientmiddlenm' action='set' />
<assign value='(tpatientlastnm_", "_tpatientfirstnm_" "_tpatientmiddlenm)' property='target.Name' action='set' />

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
<assign value='tempcdm2' property='target.CDM' action='set' />
<code>
<![CDATA[ 
	// keep cpt and modifier on misc cdm 11403 and new code 30084999001
]]></code>

<if condition='(tempcdm2="11403")||(tempcdm2="30084999001") ' >
<true>
<assign value='source.{ZDF:ZDF14CPTCode}' property='tmpcpt' action='set' />
<assign value='tmpcpt_"^CPT"' property='target.CPT' action='set' />
<assign value='source.{ZDF:ZDF15Modifier}' property='tmpCPTMod' action='set' />
<if condition='source.{ZDF:ZDF15Modifier}=""' >
<false>
<assign value='tmpCPTMod_"^CPTMOD"' property='target.CPTModifiers' action='set' />
</false>
</if>
</true>
<false>
<assign value='""' property='target.CPT' action='set' />
<assign value='""' property='target.CPTModifiers' action='set' />
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
<if condition='..StartsWith(source.{ZDF:ZDF13ServicePhyCode},"M")|| ..StartsWith(source.{ZDF:ZDF13ServicePhyCode},"E") ' >
<true>
<assign value='..SubString(source.{ZDF:ZDF13ServicePhyCode},2,8)' property='target.PerformingDoc' action='set' />
</true>
<false>
<assign value='source.{ZDF:ZDF13ServicePhyCode}' property='target.PerformingDoc' action='set' />
</false>
</if>
<if condition='..StartsWith(source.{ZDF:ZDF12OrderingPhyCode},"M") || ..StartsWith(source.{ZDF:ZDF12OrderingPhyCode},"E") ' >
<true>
<assign value='..SubString(source.{ZDF:ZDF12OrderingPhyCode},2,8)' property='target.OrderedByDoc' action='set' />
</true>
<false>
<assign value='source.{ZDF:ZDF12OrderingPhyCode}' property='target.OrderedByDoc' action='set' />
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
	// 	<assign value='pPatientAccount' property='target.{MSH:25}' action='set' />
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

<assign value='"MRNnotFnd"' property='target.MSHMRNFind' action='set' />
<assign value='""' property='tMRN' action='set' />

<if condition='tempmrn2 = ""'>
<false>
<assign value='tempmrn2' property='tMRN' action='set'/>
<assign value='"MRNsent"' property='target.MSHMRNFind' action='set' />
<assign value='tempmrn2' property='target.MRN' action='set' />
<assign value='pPatientAccount' property='target.Fin' action='set' />
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
<if condition='tMRN=""' >
<false>
<assign value='pPatientAccount' property='tAccountIn' action='set' />
<assign value='pPatientAccount' property='target.Fin' action='set' />
</false>
</if>
</true>
</if>

<if condition='tMRN = ""' >
<true>
<code>
<![CDATA[ 
	// Using Patient Last,First Name and Middle Name to get MRN from PatientData table if unique
    set tMRN=##class(GC.CernerGetData).CernerGetPatientInfoByName(tpatientlastnm,tpatientfirstnm,tpatientmiddlenm)
	]]></code>
<if condition='tMRN = ""' >
<true>
<assign value='""' property='target.MRN' action='set' />
<assign value='"MRNnotFnd"' property='target.MSHMRNFind' action='set' />
</true>
<false>
<assign value='"MRNbyName"' property='target.MSHMRNFind' action='set' />
<assign value='tMRN' property='target.MRN' action='set' />
</false>
</if>
</true>
<false>
<assign value='"MRNbyAcct"' property='target.MSHMRNFind' action='set' />
<assign value='tMRN' property='target.MRN' action='set' />
</false>
</if>
<if condition='target.Fin = "noacct"' >
<true>
<code>
<![CDATA[ 
	//  If no valid account found account as sent from Regions
]]></code>
<assign value='pPatientAccount' property='target.Fin' action='set' />
</true>
</if>

</transform>
}

}
