Class GC.Cerner2RegLabORMProcRMTST Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ORM_O01' targetDocType='22.RegLab:ORM_O01' create='new' language='objectscript' >
<subtransform class='GC.Cerner2RegLabORMsub' targetObj='target' sourceObj='source' />
<code>
<![CDATA[ 
	//  Last Updated 02/22/2017
	//  Last Updated in Prod: 02/22/2017 Al Johnson
	//  Create: 02/22/2017  Al Johnson 
	//  Description:  
	//	Uses subtransform CernerRegLabORMSub  for Regions Locations
	//  Version of Lab Orders for Microbiology - original source GCH.QCPR2RegLabORM
	//   Cerner gen lab tested without dtl, so only call subtransform
	// ***************************** START ORDER LOGIC ********************************

]]></code>
<assign value='"Cerner2RegLabORM"' property='target.{MSH:8}' action='set' />

<foreach property='target.{OBX()}' key='k1' >
<if condition='target.{OBX(k1):3.1}="TLPHN"' >
<true>
<assign value='""' property='target.{OBX(k1)}' action='remove' />
</true>
</if>
</foreach>

</transform>
}

}
