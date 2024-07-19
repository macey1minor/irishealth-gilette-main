/// 
Class GC.EdocsNuanceBsoRule Extends Ens.Rule.Definition
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
<rule name="TestPatients" disabled="false">
<constraint name="source" value="HL7.S.CrEdocsNuanceOru"></constraint>
<when condition="(HL7.{PID:PatientIdentifierList(1).ID} In &quot;507424,515173,600000,600001&quot;)">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="HL7.S.CrEdocsNuanceOru"></constraint>
<when condition="Exists(&quot;T_eDOCS_ClinicalDocs&quot;,Document.{ORCgrp(1).OBR:4(1).1})&amp;&amp;(Document.{ORCgrp(1).OBXgrp(1).OBX:5(1).3}=&quot;RTF&quot;)">
<send transform="GC.Nuance2eDOCSTagRevC" target="File.O.eDOCSNuance"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="source" value="zResend.S.AljOrueDOCS"></constraint>
<when condition="Exists(&quot;T_eDOCS_ClinicalDocs&quot;,Document.{ORCgrp(1).OBR:4(1).1})&amp;&amp;(Document.{ORCgrp(1).OBXgrp(1).OBX:5(1).3}=&quot;RTF&quot;)">
<send transform="GC.Nuance2eDOCSTagRevC" target="File.O.eDOCSNuance"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
