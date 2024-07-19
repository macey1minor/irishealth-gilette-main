/// 
Class GC.SprBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="Result To Cerner Invalid Radiologist" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(HL7.{MSH:MessageControlID} DoesNotStartWith &quot;Q&quot;)&amp;&amp;(Length(HL7.{ORCgrp(1).OBR:32.1.1})!=3)">
<send transform="" target="Email.O.AlertEmailSprORU"></send>
<return></return>
</when>
</rule>
<rule name="FROM Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(HL7.{MSH:MessageControlID} StartsWith &quot;Q&quot;)">
<send transform="" target="HL7.O.SprOrmOru"></send>
<return></return>
</when>
</rule>
<rule name="TO Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(HL7.{MSH:MessageControlID} DoesNotStartWith &quot;Q&quot;)">
<send transform="" target="HL7.O.CrSprOru"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
