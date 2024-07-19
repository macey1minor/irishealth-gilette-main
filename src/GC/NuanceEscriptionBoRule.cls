/// 
Class GC.NuanceEscriptionBoRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="MDM from Dictaphone" disabled="false">
<constraint name="docCategory" value="22.Dictaphone"></constraint>
<when condition="1">
<send transform="GC.Nuance2CernerMDM" target="HL7.O.CrNuanceEscriptionMdm"></send>
<return></return>
</when>
</rule>
<rule name="SIU from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="SIU_S12,SIU_S13,SIU_S14,SIU_S15,SIU_S17,SIU_S26"></constraint>
<when condition="1">
<send transform="GC.Cerner2NuanceSiu" target="HL7.O.NuanceEscriptionSIU"></send>
<return></return>
</when>
</rule>
<rule name="ADT from Cerner" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A31,ADT_A28,ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A15,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A24,ADT_A25,ADT_A26,ADT_A44,ADT_A38,ADT_A35,ADT_A34"></constraint>
<when condition="1">
<send transform="" target="HL7.O.NuanceEscriptionADT"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
