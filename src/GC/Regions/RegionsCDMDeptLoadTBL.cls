Class GC.Regions.RegionsCDMDeptLoadTBL Extends Ens.DataTransformDTL [ ClassType = "", DependsOn = EnsLib.HL7.Message, ProcedureBlock ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='22.RegLab:GLT_CDM' targetDocType='22.RegLab:GLT_CDM' create='copy' language='objectscript' >
<code>
<![CDATA[ 	

	//  Last Updated 03/20/2017 by Al Johnson
	//  Last Updated in PROD  - 04/05/2017
	//  Create By: Al Johnson 03/20/2017
	//  Cerner does not accept Regions CDM records
	//   Table the CDM department fields to add to charge report for Charge Services
	//   Key is CDM code, string data seperated by hyphens
	//   Add if new else update format of data field is ZCD-7 dept (-) zcd-9 ub82code (-) zcd-10 status
	]]></code>
<assign value='source.{ZCD:2}' property='wTableKey' action='set' />
<assign value='source.{ZCD:7}' property='wTableValue1' action='set' />
<assign value='source.{ZCD:9}' property='wTableValue2' action='set' />
<assign value='source.{ZCD:10}' property='wTableValue3' action='set' />
<assign value='wTableValue1_"-"_wTableValue2_"-"_wTableValue3' property='wTableData' action='set' />
<code>
<![CDATA[ 
        set wTableName="T_RegionsCDMDept"
        do ##class(Ens.Util.LookupTable).%UpdateValue(wTableName,wTableKey,wTableData)
			
	]]></code>
</transform>
}

}
