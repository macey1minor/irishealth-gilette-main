/// 
Class GC.NuancePDSBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="process docs PRA with DocID and NPI" disabled="false">
<constraint name="docCategory" value="231.Cernerbase"></constraint>
<constraint name="docName" value="MFN_M02"></constraint>
<when condition="(Document.{MFI:1.1} = (&quot;PRA&quot;))&amp;&amp;(Document.{MFEgrp(1).STF:1.1} != (&quot;&quot;))&amp;&amp;(Document.{MFEgrp(1).STF:2.1} != (&quot;&quot;))">
<send transform="" target="NuancePDS.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
