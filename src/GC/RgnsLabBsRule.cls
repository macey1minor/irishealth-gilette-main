/// 
Class GC.RgnsLabBsRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.HL7.MsgRouter.RoutingEngine" production="PROD.PROD">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="RemoveTestPatients" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="(Substring(HL7.{PID:PatientIdentifierList(1).ID},2,7) In &quot;507424,515173,600000,600001,613174&quot;)">
<return></return>
</when>
</rule>
<rule name="stop adt to sunquest" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A01,ADT_A02,ADT_A03,ADT_A04,ADT_A05,ADT_A06,ADT_A07,ADT_A08,ADT_A09,ADT_A10,ADT_A11,ADT_A12,ADT_A13,ADT_A14,ADT_A15,ADT_A16,ADT_A17,ADT_A21,ADT_A22,ADT_A23,ADT_A24,ADT_A25,ADT_A26,ADT_A28,ADT_A29,ADT_A31,ADT_A34,ADT_A35,ADT_A38,ADT_A44"></constraint>
<when condition="1">
<return></return>
</when>
</rule>
<rule name="stop beaker orders" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ORM_O01"></constraint>
<when condition="(HL7.{ORCgrp(1).OBRgrp.OBR:20}=&quot;&quot;)||(HL7.{ORCgrp(1).OBRgrp.OBR:20}!=&quot;&quot;)&amp;&amp;(Substring(HL7.{ORCgrp(1).OBRgrp.OBR:20},1,1) NotIn &quot;A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z&quot;)">
<return></return>
</when>
</rule>
<rule name="A34,35,44 Missing MRG Segment" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<constraint name="docName" value="ADT_A34,ADT_A35,ADT_A44"></constraint>
<when condition="DoesNotContain(HL7.{MRG})">
<return></return>
</when>
</rule>
<rule name="Archive">
<when condition="1">
<send transform="" target="File.O.ArchiveInbound"></send>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="231.Cerner"></constraint>
<when condition="1">
<send transform="" target="RgnsLab.P.bo"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="false">
<constraint name="docCategory" value="22.RegLab"></constraint>
<when condition="1">
<send transform="" target="RgnsLab.P.bo"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
