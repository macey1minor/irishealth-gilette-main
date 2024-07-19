/// Use orm to get patient informaton for Xltek sleep study. Format as XML
Class GC.XltekBsRule Extends Ens.Rule.Definition [ ProcedureBlock ]
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssistCompatible";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Stop Interface 5-7-20" disabled="false">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<return></return>
</when>
</rule>
<rule name="Stop &amp; Archive Orders w/CM or XO" disabled="true">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(HL7.{ORCgrp(1).ORC:OrderControl}=&quot;CM&quot;)||(HL7.{ORCgrp(1).ORC:OrderControl}=&quot;XO&quot;)">
<send transform="" target="File.O.ArchiveStopped"></send>
<return></return>
</when>
</rule>
<rule name="Block Test Patients - ORM" disabled="true">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="Archive" disabled="true">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="Send to BO" disabled="true">
<constraint name="msgClass" value="EnsLib.HL7.Message"></constraint>
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="Xltek.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
