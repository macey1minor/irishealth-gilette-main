/// 
Class GC.zzRgnsLabBsoHold1Rule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="QCPR Order Nbrs" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<constraint name="docName" value="ORU_R01,ORM_O01,ORM_O02"></constraint>
<when condition="LENGTH(HL7.{OBR:2.1})=7">
<send transform="" target="zzBso.P.RgnsHold2ORU"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
