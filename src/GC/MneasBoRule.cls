/// 
Class GC.MneasBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Block PreReg" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(Document.{PV1:18} StartsWith &quot;Pre&quot;)||((Document.{PV1:2}=&quot;O&quot;)&amp;&amp;(Document.{PV1:18}!=&quot;Observation&quot;))">
<return></return>
</when>
</rule>
<rule name="NO=does not opt out" disabled="true">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A03,ADT_A04,ADT_A08"></constraint>
<when condition="(Document.{MSH:14}=&quot;NO&quot;)">
<send transform="GC.Cerner2MneasADT" target="HL7.O.MneasAdt"></send>
<return></return>
</when>
</rule>
<rule name="Covid19 - send ALL" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A03,ADT_A04,ADT_A08"></constraint>
<when condition="1">
<send transform="GC.Cerner2MneasADT" target="HL7.O.MneasAdt"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
