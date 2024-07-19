/// 
Class GC.EdwCernerAdtVisitAL1BsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A08"></constraint>
<when condition="(HL7.{MSH:ContinuationPointer}&gt;0)&amp;&amp; ((HL7.{MSH:19} Contains &quot;ResFiling for: Allergy Assessment&quot;) || 1 )">
<send transform="EDW.dtl.Cerner2EdwADTVisitAL1Loop" target="Bso.P.EdwCernerAdtVisitAL1"></send>
<send transform="EDW.dtl.Cerner2EdwADTVisitAL1" target="SQL.O.EdwVisitAL1"></send>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
