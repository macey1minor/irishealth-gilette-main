Class GC.Regions2CernerCredit Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, GC.Regions.DFT.CreditDFT) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='GC.Regions.DFT.CreditDFT' sourceDocType='231.Cerner:DFT_P03' create='new' language='objectscript' >
<code>
<![CDATA[ 
	// Last Moved to Prod - 09/23/2016 
	// Last Updated 09/16/2016
	// Created: 09/16/2016  Al Johnson  
	// Desc: Format Credits for email
]]></code>
<assign value='source.{MSH:DateTimeOfMessage}' property='target.HL7MessageDate' action='set' />
<assign value='source.{PID:PatientName(1).familylastname}_", "_source.{PID:PatientName(1).givenname}' property='target.Name' action='set' />
<assign value='source.{FT1grp(1).FT1:TransactionCode.identifier}' property='target.CDM' action='set' />
<assign value='source.{PID:PatientIdentifierList(1).ID}' property='target.MRN' action='set' />
<assign value='source.{PID:PatientAccountNumber.ID}' property='target.Account' action='set' />
<assign value='source.{FT1grp(1).FT1:TransactionQuantity}' property='target.Quantity' action='set' />
<assign value='source.{FT1grp(1).FT1:TransactionAmountExtended}' property='target.Amount' action='set' />
<assign value='source.{FT1grp(1).FT1:TransactionDate}' property='target.DateOfService' action='set' />
<assign value='source.{FT1grp(1).FT1:ProcedureCode}' property='target.CPT' action='set' />
<assign value='""' property='tmpmodifier' action='set' />
<foreach property='source.{FT1grp(1).FT1:ProcedureCodeModifier()}' key='k1' >
<if condition='k1=1' >
<true>
<assign value='source.{FT1grp(1).FT1:ProcedureCodeModifier(k1).identifier}' property='tmpmodifier' action='set' />
</true>
<false>
<assign value='tmpmodifier_"~"_source.{FT1grp(1).FT1:ProcedureCodeModifier(k1).identifier}' property='tmpmodifier' action='set' />
</false>
</if>
</foreach>
<assign value='tmpmodifier' property='target.CPTModifiers' action='set' />
</transform>
}

}
