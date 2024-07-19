Class IIBAENSEMBLE.FTP.PassthroughOperation Extends Ens.BusinessOperation [ ProcedureBlock, System = 4 ]
{

Parameter ADAPTER = "EnsLib.FTP.OutboundAdapter";

/// Name of file to output the document(s) to. May include timestamp specifiers. The %f specifier if present will be 
/// replaced with the name of the document's original source filename (stripped of characters illegal in filenames).<p>
/// See the method Ens.Util.File.CreateTimestamp() for documentation of timestamping options.
Property Filename As %String(MAXLEN = 1000, MINLEN = 1) [ InitialExpression = "%f_%Q", Required ];

Parameter SETTINGS As %String = "Filename";

// Modified OnMessage to include the path from the stream filename in the filename that is passed to the adapter.

//   This allows for a 'dynamic' path for the file place on the ftp target.

//

Method OnMessage(pRequest As Ens.StreamContainer, Output pResponse As %Persistent) As %Status
{
	set tFullFilename=pRequest.Stream.Attributes("Filename")
	Set tFilename=..Adapter.CreateTimestamp(##class(%File).GetFilename(tFullFilename),..Filename)
	//Quit ..Adapter.PutStream(tFilename, pRequest.Stream)
	//s tDirname=$TR($E(tFullFilename,1,$L(tFullFilename)-$L(##class(%File).GetFilename(tFullFilename))),"\","/")
	s tDirname=..Adapter.fixSvrPath($E(tFullFilename,1,$L(tFullFilename)-$L(##class(%File).GetFilename(tFullFilename))))
	Quit ..Adapter.PutStream(tDirname_tFilename, pRequest.Stream)
}

}
