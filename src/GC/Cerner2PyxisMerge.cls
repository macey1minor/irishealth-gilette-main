Class GC.Cerner2PyxisMerge Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A35' targetDocType='231.Cerner:ADT_A35' create='new' language='objectscript' >
<annotation>Cerner A35 to Pyxis A42</annotation>
<code>
<![CDATA[ // Adding Merge msg to ADT feed. A35 to A42_9.25.17 mmw
  ]]></code>
<code>
<![CDATA[ //Move mrg.3.1 to mrg.5.1_9.25.17 mmw
  ]]></code>
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<if condition='source.{MSH:MessageType.triggerevent}="A35"' >
<true>
<assign value='"A42"' property='target.{MSH:MessageType.triggerevent}' action='set' />
</true>
</if>
<assign value='source.{PID}' property='target.{PID}' action='set' />
<assign value='source.{PD1}' property='target.{PD1}' action='set' />
<assign value='source.{MRG}' property='target.{MRG}' action='set' />
<if condition='source.{MSH:MessageType.triggerevent}="A35"' >
<true>
<assign value='source.{MRG:PriorPatientAccountNumber}' property='target.{MRG:PriorVisitNumber}' action='set' />
<assign value='' property='target.{MRG:PriorPatientAccountNumber}' action='clear' />
</true>
</if>
<assign value='source.{PV1}' property='target.{PV1}' action='set' />
</transform>
}

}
