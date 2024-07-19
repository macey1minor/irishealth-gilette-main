/// 
Class GC.SprBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="Cerner ORM ORU forSPR" effectiveBegin="" effectiveEnd="">
<rule name="Block Test Patients - ORM and ORU)" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="Exists(&quot;T_CernerProd_TestPatients&quot;,HL7.{PID:PatientIdentifierList(1).ID})">
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="Spr.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
