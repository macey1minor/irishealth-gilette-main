/// 
Class GC.AviziaBoRuleMock Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="ADT to not send to Avizia" disabled="false">
<constraint name="docCategory" value="231.Cernerbase"></constraint>
<constraint name="docName" value="ADT_A31"></constraint>
<when condition="1">
<return></return>
</when>
</rule>
<rule name="SIU " disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="SIU_S12,SIU_S13,SIU_S14,SIU_S15,SIU_S17,SIU_S26"></constraint>
<when condition="1">
<send transform="GC.AviziaSiu" target="HL7.O.AviziaAdtSiu"></send>
<return></return>
</when>
</rule>
<rule name="">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="HL7.O.AviziaAdtSiu"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
