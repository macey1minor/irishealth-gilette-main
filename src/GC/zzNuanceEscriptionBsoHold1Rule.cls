/// 
Class GC.zzNuanceEscriptionBsoHold1Rule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Archive" disabled="true">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="ReProcess Valid Addendums" disabled="true">
<constraint name="source" value="HL7.S.CrEdocsNuanceOru"></constraint>
<when condition="Exists(&quot;T_eDOCS_ClinicalDocs&quot;,Document.{ORCgrp(1).OBR:4(1).1})&amp;&amp;(Document.{ORCgrp(1).OBXgrp(2).OBX:5(1).3}=&quot;RTF&quot;)">
<send transform="GC.eDOCS.TildeReplace3,GC.Nuance2eDOCSTagRevBFix" target="zzFile.O.eDOCSNuance"></send>
<return></return>
</when>
</rule>
<rule name="ReProcess type 62 reports" disabled="false">
<constraint name="source" value="HL7.S.CrEdocsNuanceOru"></constraint>
<when condition="Exists(&quot;T_eDOCS_ClinicalDocs&quot;,Document.{ORCgrp(1).OBR:4(1).1})&amp;&amp;(Document.{ORCgrp(1).OBXgrp(1).OBX:5(1).3}=&quot;RTF&quot;)">
<send transform="GC.eDOCS.TildeReplace3,GC.Nuance2eDOCSTagRevBFix" target="zzFile.O.eDOCSNuance"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
