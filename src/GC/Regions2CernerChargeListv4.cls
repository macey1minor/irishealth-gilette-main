Class GC.Regions2CernerChargeListv4 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, GC.Regions.DFT.ChargeDFTv3) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='GC.Regions.DFT.ChargeDFTv3' sourceDocType='22.RegLab:GLT_DFT' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// Last Moved to Prod - 03/12/2019 
	// Last Updated 06/14/2019
	// Created: 04/04/2017  Al Johnson  
	// Desc: Report Daily Regions Charges To Cerner
	// GC.Regions2CernerChargesListv3 new version from v2
	//  Beaker now sending MRN 01/30/2019 Al Johnson
	//
	// 06-14-2019 add search of fin by mrn and dos
	//            CernerGetFinByMrnDos
	//            lgc.sp_HL7_Get_FIN_By_MRN_DOS
	//            Parameter 1: MRN  Parameter 2: DOS
	// 06-14-2019 search for insurance using fin
	//            CernerGetFinInsurance
	//            lgc.sp_HL7_Get_Insurance_By_FIN_And_Rank
	//            Parameter 1: FIN  Parameter 2: Rank
	// 06-14-2019 SQLDBDEV16\DEV16 and SQLDBTEST16\DBTEST16 database EDW_IS both contain Prod data - current to previous day
	// 06-24-2019 fin returned needs to start with 7 (prod) 2=cert, 9=mock
	// 06-25-2019 Check fin sent against mrn/dos routine
	]]></code>
<assign value='source.{MSH:DateTimeofMessage}' property='target.HL7MessageDate' action='set' />
<assign value='source.{ZDF:ZDF6DOS}' property='target.TransactionDate' action='set' />
<assign value='source.{ZDF:ZDF6DOS}' property='target.PostingDate' action='set' />
<assign value='source.{ZDF:ZDF6DOS}' property='tZDF6DOS' action='set' />
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
	//   MSH:21 / tFinalMRNfromWhere where MRN came from
	//                               NOMRN, MRNbyNAME, MRNbyFIN,  MRNSent
	//   MSH:22 / tFinalFINfromWhere where Account came from
	//                               NOFIN, FINbyMRN, FINSent
	//   MSH:23 / tFinalFINcount   Number of Fins
	//   MSH:24 / tPrimaryInsName  Name of Primary Insurance
	//   MSH:25 / tPrimaryInsType  Primary Insurance - MNMedicaid or OtherIns
	//
	//   target.MSHMRNFind          MRNnotFnd, MRNsent, MRNbyName, MRNbyAcct
	//   target.MRN
	//   target.Fin                "noacct"
	//
]]></code>
<code>
<![CDATA[ 
	// strip leading zero on account numbers and set variable.
	// hold fin sent for later comparison against mrn/dos search		
]]></code>
<assign value='source.{ZDF:ZDF1AccountNumber}' property='inZDF1AccountSent' action='set' />
<assign value='$ZSTRIP(inZDF1AccountSent,"&lt;","0")' property='inZDF1AccountSenta' action='set' />

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
       set tableMRNbyFin=##class(GC.CernerGetData2022).CernerGetPatientInfoByFin(inZDF1Accounta)
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
    set tableMRNbyName=##class(GC.CernerGetData2022).CernerGetPatientInfoByName(tpatientlastnm,tpatientfirstnm,tpatientmiddlenm)
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
<assign value='""' property='target.MRN' action='set' />
<assign value='"NOMRN"' property='tFinalMRNfromWhere' action='set' />
</true>
<false>
<assign value='tableMRNbyName' property='target.MRN' action='set' />
<assign value='tableMRNbyName' property='tFinalMRN' action='set' />
<assign value='"MRNbyNAME"' property='tFinalMRNfromWhere' action='set' />
</false>
</if>
</true>
<false>
<assign value='tableMRNbyFin' property='target.MRN' action='set' />
<assign value='tableMRNbyFin' property='tFinalMRN' action='set' />
<assign value='"MRNbyFIN"' property='tFinalMRNfromWhere' action='set' />
</false>
</if>
</true>
<false>
<assign value='inZDF16Mrn' property='target.MRN' action='set' />
<assign value='inZDF16Mrn' property='tFinalMRN' action='set' />
<assign value='"MRNSent"' property='tFinalMRNfromWhere' action='set' />
</false>
</if>
<code>
<![CDATA[ 
    // ***************************
	// search for fin if not sent
	// search if sent - verify match on fins
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
    set tableFINbyMRNDos=##class(GC.CernerGetData2022).CernerGetFinByMRNDos(tFinalMRN,tZDF6DOS)
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
<assign value='""' property='tFinalFINcount' action='set' />
<if condition='inZDF1Accounta = ""' >
<true>
<if condition='tableFINbyMRNDosFin = ""' >
<true>
<assign value='""' property='target.Fin' action='set' />
<assign value='"NOFIN"' property='tFinalFINfromWhere' action='set' />
<assign value='"0"' property='tFinalFINcount' action='set' />
</true>
<false>
<assign value='tableFINbyMRNDosFin' property='target.Fin' action='set' />
<assign value='tableFINbyMRNDosFin' property='tFinalFIN' action='set' />
<assign value='"FINbyMRN"' property='tFinalFINfromWhere' action='set' />
<assign value='tableFINbyMRNDosCount' property='tFinalFINcount' action='set' />
</false>
</if>
</true>
<false>
<assign value='inZDF1Accounta' property='target.Fin' action='set' />
<assign value='inZDF1Accounta' property='tFinalFIN' action='set' />
<assign value='"FINSent"' property='tFinalFINfromWhere' action='set' />
<assign value='"1"' property='tFinalFINcount' action='set' />
</false>
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
     set tableInsName=##class(GC.CernerGetData2022).CernerGetFinInsurance(tFinalFIN,"1")
    // $$$TRACE("tableInsName after= "_tableInsName)
	]]></code>
</false>
</if>


<code>
<![CDATA[ 
    // ***************************
	// search for fin by mrn/dos when fin sent
	// compare result for difference
	// ***************************
]]></code>
<assign value='""' property='tableFINSentSearchbyMRNDos' action='set' />
<assign value='""' property='tableFINSentSearchbyMRNDosCount' action='set' />
<if condition='inZDF1AccountSenta = ""' >
<false>
<if condition='tFinalMRN = ""' >
<false>
<code>
<![CDATA[ 
    //  routine adds a comma between fin followed by a count of fins seperated by verbiage Count=
    //   i.e. 70037267,70116182,70204540,70214105,70332251Count=5
    set tableFINSentSearchbyMRNDos=##class(GC.CernerGetData2022).CernerGetFinByMRNDos(tFinalMRN,tZDF6DOS)
    // $$$TRACE("tableFINbyMRNDos after= "_tableFINbyMRNDos)
	]]></code>
</false>
</if>
</false>
</if>
<assign value='""' property='tableFINSentSearchbyMRNDosCount' action='set' />
<assign value='""' property='tableFINSentSearchbyMRNDosFin' action='set' />
<assign value='$PIECE(tableFINSentSearchbyMRNDos,"Count=",1)' property='tableFINSentSearchbyMRNDosFin' action='set' />
<assign value='$PIECE(tableFINSentSearchbyMRNDos,"Count=",2)' property='tableFINSentSearchbyMRNDosCount' action='set' />

<assign value='""' property='tfinmatchdiff' action='set' />

<if condition='inZDF1AccountSenta = ""' >
<true>
<assign value='""' property='tfinmatchdiff' action='set' />
</true>
<false>
<if condition='inZDF1AccountSenta = tableFINSentSearchbyMRNDosFin' >
<true>
<assign value='"No"' property='tfinmatchdiff' action='set' />
</true>
<false>
<if condition='(tableFINSentSearchbyMRNDosCount)&gt;"1"' >
<true>
<if condition='..In(inZDF1AccountSenta,tableFINSentSearchbyMRNDosFin)' >
<true>
<assign value='"No"' property='tfinmatchdiff' action='set' />
</true>
<false>
<assign value='"Yes"' property='tfinmatchdiff' action='set' />
</false>
</if>
</true>
<false>
<if condition='tableFINSentSearchbyMRNDosFin=inZDF1AccountSenta' >
<true>
<assign value='"No"' property='tfinmatchdiff' action='set' />
</true>
<false>
<assign value='"Yes"' property='tfinmatchdiff' action='set' />
</false>
</if>
</false>
</if>
</false>
</if>
</false>
</if>


<code>
<![CDATA[ 
	// ***************** Set MSH Values ************************
	//
	//  MSH Values 
	//   MSH:21 / tFinalMRNfromWhere where MRN came from
	//                               NOMRN, MRNbyNAME, MRNbyFIN,  MRNSent
	//   MSH:22 / tFinalFINfromWhere where Account came from
	//                               NOFIN, FINbyMRN, FINSent
	//   MSH:23 / tFinalFINcount   Number of Fins
	//   MSH:24 / tPrimaryInsName  Name of Primary Insurance
	//   MSH:25 / tPrimaryInsType  Primary Insurance - MNMedicaid or OtherIns
	//
	//   tableFINSentSearchbyMRNDosFin   table lookup when fin sent by regions
	//   inZDF1AccountSenta         orig / actual fin sent - change if not 7xxxxxxx
	//   tfinmatchdiff                 yes or no - lookup and value sent match
	//                              or included if multiple fins returned
	//
]]></code>
<assign value='""' property='tPrimaryInsType' action='set' />
<assign value='tableInsName' property='tPrimaryInsName' action='set' />
<if condition='tableInsName="MN MED ASSISTANCE"' >
<true>
<assign value='"MNMedicaid"' property='tPrimaryInsType' action='set' />
</true>
<false>
<assign value='"OtherIns"' property='tPrimaryInsType' action='set' />
</false>
</if>
<assign value='tFinalMRNfromWhere' property='target.MSHMRNFind' action='set' />
<assign value='tFinalFINfromWhere' property='target.MSHFINFind' action='set' />
<assign value='tFinalFINcount' property='target.FINFindCount' action='set' />
<assign value='tPrimaryInsName' property='target.PrimInsName' action='set' />
<assign value='tPrimaryInsType' property='target.PrimInsType' action='set' />
<assign value='tfinmatchdiff' property='target.FinDifference' action='set' />
<assign value='inZDF1AccountSenta' property='target.OriginalFinSent' action='set' />
<assign value='tableFINSentSearchbyMRNDosFin' property='target.FinDiffLookup' action='set' />
</transform>
}

}
