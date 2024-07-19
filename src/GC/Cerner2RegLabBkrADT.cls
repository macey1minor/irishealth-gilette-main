Class GC.Cerner2RegLabBkrADT Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='copy' language='objectscript' >
<subtransform class='GC.Cerner2RegLabBkrSub' targetObj='target' sourceObj='source' />
<code>
<![CDATA[ 
  //    Last Updated 08/17/2021 Al Johnson
  //    Moved to Prod 08/17/2021 Al Johnson
  // Create: 07/16/2018 Al Johnson
  // Description:
  //   Copied from GC.Cerner2RegionsADT
  //   (orignal - ) logic either Cerner alias or Cerner modobject
  //  changed from new to copy - include guarantor, insurance
  //  remove z segments
  //
  //    10/28/16 Eliminate repetitions of EVN-5 name field
  //  original dtl below
  // if A03 PV1:3 is blank; 
  // if A08 is for inpatient account send as A28
  // chg A06 into A01 and A07 into A04
  // chg A22 and A21 into A02 and use location GILD^GILD^99
  // Update Attending & Admitting to prefix E if starts with non-alpha; blank out admitting
  //
  //  Do not change to A28 for Epic Beaker - 8/8/2018
  //  Do not change A06/A07 for Epic Beaker - 8/28/2018
  //  Cerner modobject is changing the MSH but leaving the EVN
  //
  //  Remove A21, A22 send in Cerner Modobject - remove code here - 11/28/2018
  //  Do Not Remove PV1-3 on discharge - 08/17/2021  CNR-22075 RFC SD-94409
]]></code>

<code>
<![CDATA[ 
   // <assign value='' property='target.{EVN}' action='remove' />
   // <assign value='source.{EVN:1}' property='target.{EVN:1}' action='set' />
   // <assign value='source.{EVN:2}' property='target.{EVN:2}' action='set' />
   // <assign value='source.{EVN:3}' property='target.{EVN:3}' action='set' />
   // <assign value='source.{EVN:4}' property='target.{EVN:4}' action='set' />
   // <assign value='source.{EVN:5(1).1}' property='target.{EVN:5(1).1}' action='set' />
   // <assign value='source.{EVN:5(1).2}' property='target.{EVN:5(1).2}' action='set' />
   // <assign value='source.{EVN:5(1).3}' property='target.{EVN:5(1).3}' action='set' />
   // <assign value='source.{EVN:6}' property='target.{EVN:6}' action='set' />
   //
   // <assign value='""' property='target.{PV1:AssignedPatientLocation}' action='remove' />
]]></code>

<if condition='..Contains(source.{MSH:9.2},"A03")' >
<true>
<assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
</true>
</if>
<code>
<![CDATA[ 
	// Do not change to A28 for Epic Beaker - 8/8/2018
    // <if condition='source.{MSH:9.2} = "A08" &amp;  ..Contains(source.{PV1:2},"I")' >
    // <true>
    // <assign value='""' property='target.{PV1:AssignedPatientLocation}' action='remove' />
    // <assign value='"A28"' property='target.{EVN:EventTypeCode}' action='set' />
    // <assign value='"A28"' property='target.{MSH:9.2}' action='set' />
    // </true>
    // </if>
    //
    //  <if condition='..Contains(source.{MSH:9.2},"A06")' >
    //  <true>
    //  <assign value='source.{EVN}' property='target.{EVN}' action='set' />
    //  <assign value='"A01"' property='target.{EVN:EventTypeCode}' action='set' />
    //  <assign value='"A01"' property='target.{MSH:9.2}' action='set' />
    //  </true>
    //  </if>
    //  <if condition='..Contains(source.{MSH:9.2},"A07")' >
    //  <true>
    //  <assign value='source.{EVN}' property='target.{EVN}' action='set' />
    //  <assign value='"A04"' property='target.{EVN:EventTypeCode}' action='set' />
    //  <assign value='"A04"' property='target.{MSH:9.2}' action='set' />
    //  </true>
    //  </if>

    // <if condition='..Contains(source.{MSH:9.2},"A22")' >
    // <true>
    // <assign value='"A02"' property='target.{MSH:9.2}' action='set' />
    // <assign value='source.{EVN}' property='target.{EVN}' action='set' />
    // <assign value='"A02"' property='target.{EVN:1}' action='set' />
    // <assign value='""' property='target.{PV1:PriorPatientLocation}' action='set' />
    // <assign value='"GILD^GILD^99"' property='target.{PV1:PriorPatientLocation.pointofcare}' action='set' />
    // </true>
    // </if>
    // <if condition='..Contains(source.{MSH:9.2},"A21")' >
    // <true>
    // <assign value='"A02"' property='target.{MSH:9.2}' action='set' />
    // <assign value='source.{EVN}' property='target.{EVN}' action='set' />
    // <assign value='"A02"' property='target.{EVN:1}' action='set' />
    // <assign value='""' property='target.{PV1:3}' action='set' />
    // <assign value='"GILD^GILD^99"' property='target.{PV1:3}' action='set' />
    // </true>
    // </if>

]]></code>
</transform>
}

}
