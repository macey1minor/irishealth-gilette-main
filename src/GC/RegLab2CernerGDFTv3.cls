Class GC.RegLab2CernerGDFTv3 Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='22.RegLab:GLT_DFT' targetDocType='231.Cerner:DFT_P03' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// Last Updated: 06/10/2019 Al Johnson
	// Last Updated in Prod:  03/12/2019
	// Created in Cert 06/10/2019 copied from GC.RegLab2CernerGDFTv2 - Al Johnson
	// Changes based on Beaker charges intermixed with Sunquest charges
	// Regions now sending MRN - changes to search for fin and insurance
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
	//
	// 06-10-2019 add search of fin by mrn and dos
	//            CernerGetFinByMrnDos
	//            lgc.sp_HL7_Get_FIN_By_MRN_DOS
	//            Parameter 1: MRN  Parameter 2: DOS
	// 06-10-2019 search for insurance using fin
	//            CernerGetFinInsurance
	//            lgc.sp_HL7_Get_Insurance_By_FIN_And_Rank
	//            Parameter 1: FIN  Parameter 2: Rank
	// 06-10-2019 SQLDBDEV16\DEV16 and SQLDBTEST16\DBTEST16 database EDW_IS both contain Prod data - current to previous day
	// 06-21-2019 if multiple fins returned, blank out on pid-18
	// 06-24-2019 fin returned needs to start with 7 (prod) 2=cert, 9=mock

]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='"GCH"' property='target.{MSH:ReceivingFacility}' action='set' />
<assign value='"RegLab2CernerGDFTv3"' property='target.{MSH:Security}' action='set' />
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
<assign value='source.{ZDF:ZDF6DOS}' property='tZDF6DOS' action='set' />
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
<assign value='""' property='inZDF16Mrn' action='set' />
<assign value='source.{ZDF:ZDF16MRN}' property='tempmrn' action='set' />
<assign value='$ZSTRIP(tempmrn,"&lt;","G")' property='tempmrn1' action='set' />
<assign value='$ZSTRIP(tempmrn1,"&lt;","0")' property='inZDF16Mrn' action='set' />

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
	//  MRN
	// 1.  Use MRN if sent by Regions  (inZDF16Mrn)
	// 2.  Search for MRN using Account sent by Regions (inZDF1Account)
	//                                                  (inZDF1Accounta - leading zeros removed)
	// 3.  Search for MRN using Patient Name
	//
	//  Account
	// 1.  Use Account sent by Regions
	// 2.  Search for Account using MRN and DOS (inZDF1Dos)
	//          implies you have the MRN from above either 1 or 3 (but not 2)
	//
	//  MSH Values 
	//   MSH:21 where MRN came from
	//           NOMRN, MRNbyNAME, MRNbyFIN,  MRNSent
	//   MSH:22 where Account came from
	//           NOFIN, FINbyMRN, FINSent
	//   MSH:23  Number of Fins
	//   MSH:24  Name of Primary Insurance
	//   MSH:25  Primary Insurance Type - MNMedicaid or OtherIns
	//
	//
]]></code>

<code>
<![CDATA[ 
	// strip leading zero on account numbers and set variable.
	// 6/24/2019 Fin in Prod eight digits starting with 7. 2=cert, 9=mock		
]]></code>

<if condition='..StartsWith(source.{ZDF:ZDF1AccountNumber},"7")' >
<true>
<assign value='source.{ZDF:ZDF1AccountNumber}' property='inZDF1Account' action='set' />
<assign value='$ZSTRIP(inZDF1Account,"&lt;","0")' property='inZDF1Accounta' action='set' />
</true>
<false>
<assign value='""' property='inZDF1Accounta' action='set' />
</false>
</if>

<code>
<![CDATA[
    // ***************************
	// search for mrn if not sent
	// ***************************
]]></code>

<assign value='""' property='tableMRNbyFin' action='set' />
<assign value='""' property='tableMRNbyName' action='set' />

<if condition='inZDF16Mrn = ""' >
<true>
<if condition='inZDF1Accounta = ""' >
<false>
<code>
<![CDATA[ 
    // find mrn by fin
       set tableMRNbyFin=##class(GC.CernerGetData2019).CernerGetPatientInfoByFin(inZDF1Accounta)
    // $$$TRACE("tableMRNbyFin= "_tableMRNbyFin)    
    ]]></code>
</false>
</if>
</true>
</if>

<if condition='(inZDF16Mrn="")&amp;(tableMRNbyFin = "")' >
<true>
<code>
<![CDATA[ 
	// Using Patient Last,First Name and Middle Name to get MRN from PatientData table if unique
    //  $$$TRACE("tableMRNbyNameB4="_tableMRNbyName)
    set tableMRNbyName=##class(GC.CernerGetData2019).CernerGetPatientInfoByName(tpatientlastnm,tpatientfirstnm,tpatientmiddlenm)
    // $$$TRACE("tableMRNbyName="_tableMRNbyName)
	]]></code>
</true>
</if>

<code>
<![CDATA[
    // ****************************************************
	// set PID-3 based on MRN sent or by MRN search result
	// ****************************************************
]]></code>	

<assign value='""' property='tFinalMRN' action='set' />
<assign value='""' property='tFinalMRNfromWhere' action='set' />	
<if condition='inZDF16Mrn = ""' >
<true>
<if condition='tableMRNbyFin = ""' >
<true>
<if condition='tableMRNbyName = ""' >
<true>
<assign value='""' property='target.{PID:3}' action='set' />
<assign value='"NOMRN"' property='target.{MSH:21}' action='set' />
</true>
<false>
<assign value='tableMRNbyName' property='target.{PID:3}' action='set' />
<assign value='tableMRNbyName' property='tFinalMRN' action='set' />
<assign value='"3"' property='tFinalMRNfromWhere' action='set' />
<assign value='"MRNbyNAME"' property='target.{MSH:21}' action='set' />
</false>
</if>
</true>
<false>
<assign value='tableMRNbyFin' property='target.{PID:3}' action='set' />
<assign value='tableMRNbyFin' property='tFinalMRN' action='set' />
<assign value='"2"' property='tFinalMRNfromWhere' action='set' />
<assign value='"MRNbyFIN"' property='target.{MSH:21}' action='set' />
</false>
</if>
</true>
<false>
<assign value='inZDF16Mrn' property='target.{PID:3}' action='set' />
<assign value='inZDF16Mrn' property='tFinalMRN' action='set' />
<assign value='"1"' property='tFinalMRNfromWhere' action='set' />
<assign value='"MRNSent"' property='target.{MSH:21}' action='set' />
</false>
</if>

<code>
<![CDATA[
    // ***************************
	// search for fin if not sent
	// ***************************
]]></code>

<assign value='""' property='tableFINbyMRNDos' action='set' />
<assign value='""' property='tableFINbyMRNDosCount' action='set' />
<if condition='inZDF1Accounta = ""' >
<true>
<if condition='tFinalMRN = ""' >
<false>
<code>
<![CDATA[ 
    //  routine adds a comma between fin followed by a count of fins seperated by verbiage Count=
    //   i.e. 70037267,70116182,70204540,70214105,70332251Count=5
    set tableFINbyMRNDos=##class(GC.CernerGetData2019).CernerGetFinByMRNDos(tFinalMRN,tZDF6DOS)
    // $$$TRACE("tableFINbyMRNDos after= "_tableFINbyMRNDos)
	]]></code>
</false>
</if>
</true>
</if>

<assign value='""' property='tableFINbyMRNDosCount' action='set' />
<assign value='""' property='tableFINbyMRNDosFin' action='set' />
<assign value='$PIECE(tableFINbyMRNDos,"Count=",1)' property='tableFINbyMRNDosFin' action='set' />
<assign value='$PIECE(tableFINbyMRNDos,"Count=",2)' property='tableFINbyMRNDosCount' action='set' />

<code>
<![CDATA[
    // *****************************************************
	// set PID-18 based on FIN sent or by MRN search result
	// *****************************************************
]]></code>

<assign value='""' property='tFinalFIN' action='set' />
<assign value='""' property='tFinalFINfromWhere' action='set' />	
<if condition='inZDF1Accounta = ""' >
<true>
<if condition='tableFINbyMRNDosFin = ""' >
<true>
<assign value='""' property='target.{PID:18}' action='set' />
<assign value='"NOFIN"' property='target.{MSH:22}' action='set' />
<assign value='"0"' property='target.{MSH:23}' action='set' />
</true>
<false>
<assign value='tableFINbyMRNDosFin' property='target.{PID:18}' action='set' />
<assign value='tableFINbyMRNDosFin' property='tFinalFIN' action='set' />
<assign value='"2"' property='tFinalFINfromWhere' action='set' />
<assign value='"FINbyMRN"' property='target.{MSH:22}' action='set' />
<assign value='tableFINbyMRNDosCount' property='target.{MSH:23}' action='set' />
</false>
</if>
</true>
<false>
<assign value='inZDF1Accounta' property='target.{PID:18}' action='set' />
<assign value='inZDF1Accounta' property='tFinalFIN' action='set' />
<assign value='"1"' property='tFinalFINfromWhere' action='set' />
<assign value='"FINSent"' property='target.{MSH:22}' action='set' />
<assign value='"1"' property='target.{MSH:23}' action='set' />
</false>
</if>

<if condition='tableFINbyMRNDosCount &gt; "1"' >
<true>
<assign value='""' property='target.{PID:18}' action='set' />
</true>
</if>

<code>
<![CDATA[
    // ********************************************************
	// find insurance based on fin - 1=primary, 2=secodary etc
	// ********************************************************
]]></code>

<assign value='""' property='tableInsName' action='set' />
	
<if condition='tFinalFIN = ""' >
<false>
<code>
<![CDATA[
     // $$$TRACE("b4insnamecall= "_tFinalFIN)
     set tableInsName=##class(GC.CernerGetData2019).CernerGetFinInsurance(tFinalFIN,"1")
    // $$$TRACE("tableInsName after= "_tableInsName)
	]]></code>
</false>
</if>

<code>
<![CDATA[ 
	// ***************** Set MSH Values ************************
	//
	//  MSH Values 
	//   MSH:21 where MRN came from
	//           NOMRN, MRNbyNAME, MRNbyFIN,  MRNSent
	//   MSH:22 where Account came from
	//           NOFIN, FINbyMRN, FINSent
	//   MSH:23  Number of Fins
	//   MSH:24  Name of Primary Insurance
	//   MSH:25  Primary Insurance Type - MNMedicaid or OtherIns
	//
	//   MSH:
	//
]]></code>

<assign value='tableInsName' property='target.{MSH:24}' action='set' />
<if condition='tableInsName="MN MED ASSISTANCE"' >
<true>
<assign value='"MNMedicaid"' property='target.{MSH:25}' action='set' />
</true>
<false>
<assign value='"OtherIns"' property='target.{MSH:25}' action='set' />
</false>
</if>

</transform>
}

}
