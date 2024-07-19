/// 
Class GC.EdwCernerAdtVisitBsoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="CERT.CERT">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="">
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A03,ADT_A04,ADT_A05,ADT_A08,ADT_A13,ADT_A28,ADT_A31"></constraint>
<when condition="1">
<send transform="EDW.dtl.Cerner2EdwADTVisit" target="SQL.O.EdwADTVisit"></send>
<send transform="EDW.dtl.Cerner2EdwADTVisitLoopSet" target="Bso.P.EdwCernerAdtVisitAL1,Bso.P.EdwCernerAdtVisitObx"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
