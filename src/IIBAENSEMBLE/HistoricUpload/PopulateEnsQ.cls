Class IIBAENSEMBLE.HistoricUpload.PopulateEnsQ Extends Ens.BusinessProcessBPL [ ClassType = persistent, ProcedureBlock ]
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' response='Ens.Response' height='2000' width='2000' >
<context>
<property name='HL7message' type='EnsLib.HL7.Message' >
</property>
</context>
<sequence xend='550' yend='600' >
<trace name='Start' value='"Start"' xpos='550' ypos='200' />
<transform name='Transform to HL7' class='ICOrderResult.Transforms.RisReportsToCMA' source='request' target='context.HL7message' xpos='550' ypos='300' />
<code name='Save HL7 Message' xpos='550' ypos='400' >
<![CDATA[	// Save the new message to the DB
	$$$TRACE("HL7 message: "_context.HL7message.RawContent)
	d context.HL7message.%Save()]]>
</code>
<code name='Populate queue' xpos='550' ypos='500' >
<![CDATA[	//Add new entry into the queue
	
	s QueueEntry=##class(IIBAENSEMBLE.HistoricUpload.Queue).%New()
	s QueueEntry.SourceIdentifier="CMA"
	s QueueEntry.MessageId=context.HL7message.%Id()
	s QueueEntry.Processed=0
	d QueueEntry.%Save()
	
	
]]>
</code>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
