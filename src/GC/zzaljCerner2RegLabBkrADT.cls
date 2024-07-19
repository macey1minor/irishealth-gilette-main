Class GC.zzaljCerner2RegLabBkrADT Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='231.Cerner:ADT_A01' targetDocType='231.Cerner:ADT_A01' create='copy' language='objectscript' >
<code>
<![CDATA[ 
  //    Last Updated 03/27/2019 Al Johnson
  //    Moved to Prod 03/27/2019 Al Johnson
  // Create: 03/27/2019 Al Johnson
  // Description:
  //   Convert to A01 for conversion
]]></code>


<if condition='(source.{EVN:EventTypeCode}="A08")' >
<true>
<assign value='"A01"' property='target.{MSH:9.2}' action='set' />
<assign value='"A01"' property='target.{EVN:EventTypeCode}' action='set' />
</true>
</if>

</transform>
}

}
