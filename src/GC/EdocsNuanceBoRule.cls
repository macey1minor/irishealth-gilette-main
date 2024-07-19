/// 
Class GC.EdocsNuanceBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Block Mass Mailing" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(Document.{ORCgrp(1).OBR:4(1).1}=&quot;21&quot;)&amp;&amp;((Document.{ORCgrp(1).OBR:4(1).5}=&quot;Health Maintenance Reminder&quot;)||(Document.{ORCgrp(1).OBR:4(1).5}=&quot;Provider Letter-Referral Receipt New&quot;)||(Document.{ORCgrp(1).OBR:4(1).5}=&quot;Provider Letter-Referral Appointment Confirmation&quot;)||(Document.{ORCgrp(1).OBR:4(1).5}=&quot;Provider Letter-Unsuccessful Referral&quot;)||(Document.{ORCgrp(1).OBR:4(1).5}=&quot;Provider Letter-Missed Appointment&quot;)||(Document.{ORCgrp(1).OBR:4(1).5}=&quot;Provider Letter-Referral Receipt Establish&quot;))">
<return></return>
</when>
</rule>
<rule name="stopped 5/19/2020 - msgs ok" disabled="true">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_eDOCS_ClinicalDocs&quot;,Document.{ORCgrp(1).OBR:4(1).1})&amp;&amp;(Document.{ORCgrp(1).OBXgrp(1).OBX:5(1).3}=&quot;RTF&quot;)&amp;&amp;(Document.{ORCgrp(1).OBXgrp(2).OBX:1}=&quot;2&quot;)">
<send transform="GC.Nuance2eDOCSemail" target="Email.O.AlertEmaileDocs"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_eDOCS_ClinicalDocs&quot;,Document.{ORCgrp(1).OBR:4(1).1})&amp;&amp;(Document.{ORCgrp(1).OBXgrp(1).OBX:5(1).3}=&quot;RTF&quot;)">
<send transform="GC.Nuance2eDOCSTagRevC" target="File.O.eDOCSNuance"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
