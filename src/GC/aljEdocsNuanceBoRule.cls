/// 
Class GC.aljEdocsNuanceBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Block Test Patients - ORU" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="Block Mass Mailing" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(Document.{ORCgrp(1).OBR:4(1).1}=&quot;21&quot;)&amp;&amp;(Document.{ORCgrp(1).OBR:4(1).5}=&quot;Health Maintenance Reminder&quot;)">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_eDOCS_ClinicalDocs&quot;,Document.{ORCgrp(1).OBR:4(1).1})&amp;&amp;(Document.{ORCgrp(1).OBXgrp(1).OBX:5(1).3}=&quot;RTF&quot;)">
<send transform="GC.Nuance2eDOCSTagRevCalj" target="zALJ.O.eDOCShl7"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
