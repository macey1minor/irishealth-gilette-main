Class GC.PyxisZPMUnload2Cerner Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='23.Pyxis:ZPM' targetDocType='23.Pyxis:ZPM' create='new' language='objectscript' >
<assign value='source.{MSH}' property='target.{MSH}' action='set' />
<assign value='source.{ZPM}' property='target.{ZPM}' action='set' />
<assign value='"0"' property='target.{ZPM:ZPM16setid}' action='set' />
</transform>
}

}
