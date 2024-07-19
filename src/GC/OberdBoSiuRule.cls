/// 
Class GC.OberdBoSiuRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="valid doc and appt type" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="SIU_S12,SIU_S13,SIU_S14,SIU_S15,SIU_S17,SIU_S26"></constraint>
<when condition="(Document.{MSH:14}=&quot;YES&quot;)">
<send transform="GC.Cerner2OberdSIU" target="HL7.O.OberdAdtSiu"></send>
<return></return>
</when>
</rule>
<rule name="S13 - not valid doc- send cancel" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="SIU_S13"></constraint>
<when condition="1">
<send transform="GC.Cerner2OberdSIUResched" target="HL7.O.OberdAdtSiu"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
