/// 
Class GC.OberdBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Check AIP docs and set MSH-11" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="SIU_S12,SIU_S13,SIU_S14,SIU_S15,SIU_S17,SIU_S26"></constraint>
<when condition="1">
<send transform="GC.Cerner2OberdSIUcheckAIP" target="Oberd.P.boSiu"></send>
<return></return>
</when>
</rule>
<rule name="person merge" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34"></constraint>
<when condition="1">
<send transform="GC.Cerner2OberdMRG" target="HL7.O.OberdAdtSiu"></send>
<return></return>
</when>
</rule>
<rule name="ADT from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A31,ADT_A28,ADT_A01,ADT_A04,ADT_A05,ADT_A08"></constraint>
<when condition="1">
<send transform="GC.Cerner2OberdADT" target="HL7.O.OberdAdtSiu"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
