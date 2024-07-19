Class GC.Cerner2NowPowADT Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<code>
<![CDATA[ 
	//  Last Updated: 10/22/2019 Al Johnson
	//  Last Updated in Prod: 12/04/2019 Al Johnson
	//  Create: 10/22/2019  Al Johnson
	//
	//  Description:  New Interface - ADT to NowPow
	//
	//  Remove Z segments
	//  Remove NK1 segments - until Gillette fixes / cleans up
	//  Remove multiple doctors in PD1-4, send npi
	//  Remove ssn if in record
	//  Copy Fin into PV1-19
	//
	//  Send Primary Language in PID-15
	//
]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{MSH:3.1}' property='target.{MSH:3.2}' action='set' />
<assign value='source.{MSH:4.1}' property='target.{MSH:4.2}' action='set' />
<assign value='source.{MSH:5.1}' property='target.{MSH:5.2}' action='set' />
<assign value='source.{MSH:6.1}' property='target.{MSH:6.2}' action='set' />
<assign value='source.{EVN}' property='target.{EVN}' action='set' />
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{MSH:4.1}' property='target.{PID:3.4.2}' action='set' />
<assign value='"MR"' property='target.{PID:3.5}' action='set' />
<assign value='source.{NTE()}' property='target.{NTE()}' action='set' />
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
<assign value='source.{PID:18}' property='target.{PV1:19}' action='set' />
<assign value='""' property='target.{PID:19}' action='set' />
<assign value='source.{MSH:4.1}' property='target.{PV1:19.4.2}' action='set' />
<assign value='source.{PV2}' property='target.{PV2}' action='set' />
<assign value='source.{AL1grp()}' property='target.{AL1grp()}' action='set' />
<foreach property='target.{AL1grp()}' key='k2' >
<assign value='""' property='target.{AL1grp(k2).ZAL}' action='remove' />
</foreach>
<assign value='source.{DG1()}' property='target.{DG1()}' action='set' />
<assign value='source.{PR1grp()}' property='target.{PR1grp()}' action='set' />
<assign value='source.{IN1grp()}' property='target.{IN1grp()}' action='set' />
<foreach property='target.{IN1grp()}' key='k1' >
<assign value='""' property='target.{IN1grp(k1).ZNI}' action='remove' />
<foreach property='target.{IN1grp(k1).IN3grp()}' key='k3' >
<assign value='""' property='target.{IN1grp(k1).IN3grp(k3).ZN3}' action='remove' />
</foreach>
</foreach>
<assign value='""' property='tmplang' action='set' />
<foreach property='source.{OBX()}' key='k4' >
<if condition='source.{OBX(k4):3}="PREFERRED_LA"' >
<true>
<assign value='source.{OBX(k4):5(1)}' property='tmplang' action='set' />
</true>
</if>
</foreach>
<if condition='tmplang=""' >
<false>
<assign value='tmplang' property='target.{PID:15}' action='set' />
</false>
</if>

</transform>
}

}
