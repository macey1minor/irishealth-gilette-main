Class GC.Cerner2RegionsLabADT Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='new' language='objectscript' >
<subtransform class='GC.Cerner2RegLabSub' targetObj='target' sourceObj='source' />
<code>
<![CDATA[ 
  //    Last Updated 10/28/2016 Al Johnson
  //    Moved to Prod 10/28/2016 Al Johnson
  // Create: 10/28/2016 Al Johnson
  // Description:
  //    10/28/16 Eliminate repetitions of EVN-5 name field
  //  original dtl below
  // if A03 PV1:3 is blank; 
  // if A08 is for inpatient account send as A28
  // chg A06 into A01 and A07 into A04
  // chg A22 and A21 into A02 and use location GILD^GILD^99
  // Update Attending & Admitting to prefix E if starts with non-alpha; blank out admitting
]]></code>
<assign value='' property='target.{EVN}' action='remove' />
<assign value='source.{EVN:1}' property='target.{EVN:1}' action='set' />
<assign value='source.{EVN:2}' property='target.{EVN:2}' action='set' />
<assign value='source.{EVN:3}' property='target.{EVN:3}' action='set' />
<assign value='source.{EVN:4}' property='target.{EVN:4}' action='set' />
<assign value='source.{EVN:5(1).1}' property='target.{EVN:5(1).1}' action='set' />
<assign value='source.{EVN:5(1).2}' property='target.{EVN:5(1).2}' action='set' />
<assign value='source.{EVN:5(1).3}' property='target.{EVN:5(1).3}' action='set' />
<assign value='source.{EVN:6}' property='target.{EVN:6}' action='set' />

<if condition='..Contains(source.{MSH:9.2},"A03")'>
<true>
<assign property='target.{PV1:AssignedPatientLocation}' value='""' action='remove'/>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
</true>
</if>
<if condition='source.{MSH:9.2} = "A08" &amp;  ..Contains(source.{PV1:2},"I")'>
<true>
<assign property='target.{PV1:AssignedPatientLocation}' value='""' action='remove'/>
<assign property='target.{EVN:EventTypeCode}' value='"A28"' action='set'/>
<assign property='target.{MSH:9.2}' value='"A28"' action='set'/>
</true>
</if>
<if condition='..Contains(source.{MSH:9.2},"A06")'>
<true>
<assign property='target.{EVN}' value='source.{EVN}' action='set'/>
<assign property='target.{EVN:EventTypeCode}' value='"A01"' action='set'/>
<assign property='target.{MSH:9.2}' value='"A01"' action='set'/>
</true>
</if>
<if condition='..Contains(source.{MSH:9.2},"A07")'>
<true>
<assign property='target.{EVN}' value='source.{EVN}' action='set'/>
<assign property='target.{EVN:EventTypeCode}' value='"A04"' action='set'/>
<assign property='target.{MSH:9.2}' value='"A04"' action='set'/>
</true>
</if>
<if condition='..Contains(source.{MSH:9.2},"A22")'>
<true>
<assign property='target.{MSH:9.2}' value='"A02"' action='set'/>
<assign property='target.{EVN}' value='source.{EVN}' action='set'/>
<assign property='target.{EVN:1}' value='"A02"' action='set'/>
<assign property='target.{PV1:PriorPatientLocation}' value='""' action='set'/>
<assign property='target.{PV1:PriorPatientLocation.pointofcare}' value='"GILD^GILD^99"' action='set'/>
</true>
</if>
<if condition='..Contains(source.{MSH:9.2},"A21")'>
<true>
<assign property='target.{MSH:9.2}' value='"A02"' action='set'/>
<assign property='target.{EVN}' value='source.{EVN}' action='set'/>
<assign property='target.{EVN:1}' value='"A02"' action='set'/>
<assign property='target.{PV1:3}' value='""' action='set'/>
<assign property='target.{PV1:3}' value='"GILD^GILD^99"' action='set'/>
</true>
</if>

<code>
<![CDATA[ 
	// *********************** Add Logic For adding Suffix of E on Attending Doctor and clear other doctors ********************************
	//  <assign value='""' property='target.{PV1:9}' action='clear' />
    //  <assign value='"E"_source.{PV1:7.1}' property='target.{PV1:7.1}' action='set' />
    //  <assign value='"E"_source.{PV1:17.1}' property='target.{PV1:17.1}' action='set' />
]]></code>

</transform>
}

}
