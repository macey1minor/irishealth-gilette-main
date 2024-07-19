Class IIBAENSEMBLE.Monitor.DBusage Extends (%Persistent, %XML.Adaptor) [ Inheritance = right ]
{

Property Namespace As %String;

Property GlobalName As %String;

Property LogDate As %TimeStamp;

Property DBsize As %Integer;

ClassMethod ProcessIntegrityLog(LogFilename As %String) As %Status
{
	
	if '##class(%File).Exists(LogFilename) w "Cannot opne file '"_LogFilename_"'.",! Q
	
	s file=##class(%File).%New(LogFilename)
	s tSC=file.Open("R")
	
	if 'tSC w "Error: ",tSC Q
	
	//w "The file is open...",!
	
	
	while 'file.AtEnd {
		s line=file.ReadLine()
		//w line,!
		
		if ($E(line,1,30)="Cache Database Integrity Check" ) {
			S LogDate=$REPLACE($LTS($LIST($LFS(line," "),6,8)," ")," at","")
			s LogDate=$ZDT($ZDTH(LogDate),3)
			
			
			
		} else {
			if $G(LogDate)="" w "Could not determine the log date !!" Q
			
			if ($E(line,1,13)="---Directory " ) {
				s namespace=$LIST($LFS(line,"\"),$LL($LFS(line,"\"))-1)
				
				
				
			} elseif ($E($ZSTRIP(line,"<W"),1,6)="Total:") {
				s size=$TR($LIST($LFS($ZSTRIP(line,"=W")," "),6),",")
				
				s len=$L(size)
				s unit=$E(size,len-1,len)
				
				if (unit="kb") {
					s size=$E(size,1,len-2)_"000"
				} elseif (unit="MB") {
					s size=$E(size,1,len-2)_"000000"
				}
				
				
				s tSC=..AddUpdateRow(namespace,global,LogDate,size)
				Q:'tSC
				
				s global="",size=""
				
			
			} elseif ($E(line,1,7)="Global:") {
				s global=$LIST($LFS(line," "),2)
				
				
			} elseif ($F(line,"Total blocks")>0) {
				
				s global="_"_namespace_"_TotalSize"
				s size=$TR($LIST($LFS($ZSTRIP($ZSTRIP(line,"<W"),"=W")," "),4),",")
				
				s len=$L(size)
				s unit=$E(size,len-1,len)
				
				if (unit="kb") {
					s size=$E(size,1,len-2)_"000"
				} elseif (unit="MB") {
					s size=$E(size,1,len-2)_"000000"
				}
				
				s tSC=..AddUpdateRow(namespace,global,LogDate,size)
				Q:'tSC
				
			} elseif ($F(line,"Free blocks")>0) {
				
				s global="_"_namespace_"_FreeSize"
				s size=$TR($LIST($LFS($ZSTRIP(line,"=W")," "),5),",")
				
				s len=$L(size)
				s unit=$E(size,len-1,len)
				
				if (unit="kb") {
					s size=$E(size,1,len-2)_"000"
				} elseif (unit="MB") {
					s size=$E(size,1,len-2)_"000000"
				}
				
				s tSC=..AddUpdateRow(namespace,global,LogDate,size)
				Q:'tSC
				
			}
		}
		
	}
	
	d file.Close()
	
	Q $$$OK
}

ClassMethod AddUpdateRow(rNamespace As %String, rGlobalName As %String, rLogDate As %String, rDBsize As %String) As %Status
{
	s len=$L(rDBsize)
	s unit=$E(rDBsize,len-1,len)
				
	if (unit="kb") {
		s rDBsize=$E(rDBsize,1,len-2)_"000"
	} elseif (unit="MB") {
		s rDBsize=$E(rDBsize,1,len-2)_"000000"
	}
				
	
				
	s rs=##class(%ResultSet).%New()
	s qry="Select DBsize from IIBAENSEMBLE_Monitor.DBusage where Namespace='"_rNamespace_"' and GlobalName='"_rGlobalName_"' and LogDate='"_rLogDate_"'"
	d rs.Prepare(qry)
	s tSC=rs.Execute()
				
	Q:'tSC
				
	if (rs.Next() ) {
	
		d rs.Close()
		s rs=##class(%ResultSet).%New()
		d rs.Prepare("Update IIBAENSEMBLE_Monitor.DBusage set DBsize='"_rDBsize_"' where Namespace='"_rNamespace_"' and GlobalName='"_rGlobalName_"' and LogDate='"_rLogDate_"'")
		s tSC=rs.Execute()
					
		Q:'tSC
				
	} else {
		//W "New row.. will add to the table",!
		
		d rs.Close()
		s rs=##class(%ResultSet).%New()
		s qry="Insert into IIBAENSEMBLE_Monitor.DBusage (Namespace, GlobalName, LogDate, DBsize) values ('"_rNamespace_"', '"_rGlobalName_"', '"_rLogDate_"', '"_rDBsize_"')"
		d rs.Prepare(qry)
		s tSC=rs.Execute()
					
		Q:'tSC
					
		s global="",size=""
		
	} 
	
	Q $$$OK
}

ClassMethod ShowStats(Threshold As %String = 1000000, Dates As %String)
{
	w "Threshold: ",Threshold,!
	k logDates
	s rs=##class(%ResultSet).%New()
	d rs.Prepare("select distinct LogDate from IIBAENSEMBLE_Monitor.DBusage ")
	s tSC=rs.Execute()
	
	while (rs.Next()) {
		s logDates(rs.Get("LogDate"))=1
		w rs.Get("LogDate"),","
		
	}
	w !
	d rs.Close()
	
	k globalStats
	k globallist
	k namespacelist
	s current=$O(logDates(""))
	
	while(current'="") {
		w !,"collection data for: ",current
		
		s rs=##class(%ResultSet).%New()
		w "Sql: ","select Namespace, GlobalName, DBsize from IIBAENSEMBLE_Monitor.DBusage where LogDate='"_current_"' and CONVERT(Decimal(18,0),DBsize)>"_Threshold,!
		d rs.Prepare("select Namespace, GlobalName, DBsize from IIBAENSEMBLE_Monitor.DBusage where LogDate='"_current_"' and CONVERT(Decimal(18,0),DBsize) > "_Threshold)
		s tSC=rs.Execute()
	
	
		while (rs.Next()) {
			s globalStats(rs.Get("Namespace"),rs.Get("GlobalName"),current)=rs.Get("DBsize")
			s globallist(rs.Get("GlobalName"))=1
			s namespacelist(rs.Get("Namespace"))=1
		
		}
		
		s current=$O(logDates(current))
	}
	
	w !!,"Namespace,Global,"
	s current=""
	for {
		s current=$O(logDates(current)) q:current=""
		w current,","
	}
	w !
	s namespace=""
	For {
		s namespace=$O(globalStats(namespace)) q:namespace=""
		
		s global=""
		For {
			s global=$O(globalStats(namespace,global)) q:global=""
			 w namespace,",",global,","
			s current=""
			For {
				s current=$O(logDates(current)) q:'current
				w $G(globalStats(namespace,global,current))/1000000000,","
			}
			w !
		}
	}
}

ClassMethod UsageSummary() As %Status
{
	k logDates
	s rs=##class(%ResultSet).%New()
	d rs.Prepare("select distinct LogDate from IIBAENSEMBLE_Monitor.DBusage ")
	s tSC=rs.Execute()
	
	while (rs.Next()) {
		s logDates(rs.Get("LogDate"))=1
		w rs.Get("LogDate"),","
		
	}
	w !
	d rs.Close()
	
	k globalStats
	k globallist
	k namespacelist
	s current=$O(logDates(""))
	
	while(current'="") {
		w !,"collection data for: ",current
		
		s rs=##class(%ResultSet).%New()
		d rs.Prepare("select Namespace, GlobalName, DBsize from IIBAENSEMBLE_Monitor.DBusage where LogDate='"_current_"' and CONVERT(Decimal(18,0),DBsize)>1000000000")
		s tSC=rs.Execute()
	
	
		while (rs.Next()) {
			s globalStats(rs.Get("Namespace"),rs.Get("GlobalName"),current)=rs.Get("DBsize")
			s globallist(rs.Get("GlobalName"))=1
			s namespacelist(rs.Get("Namespace"))=1
		
		}
		
		s current=$O(logDates(current))
	}
	
	w !!,"Namespace,Global,"
	s current=""
	for {
		s current=$O(logDates(current)) q:current=""
		w current,","
	}
	w !
	s namespace=""
	For {
		s namespace=$O(globalStats(namespace)) q:namespace=""
		
		s global=""
		For {
			s global=$O(globalStats(namespace,global)) q:global=""
			 w namespace,",",global,","
			s current=""
			For {
				s current=$O(logDates(current)) q:'current
				w $G(globalStats(namespace,global,current))/1000000000,","
			}
			w !
		}
	}
}

Storage Default
{
<Data name="DBusageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Namespace</Value>
</Value>
<Value name="3">
<Value>GlobalName</Value>
</Value>
<Value name="4">
<Value>Date</Value>
</Value>
<Value name="5">
<Value>Size</Value>
</Value>
<Value name="6">
<Value>LogDate</Value>
</Value>
<Value name="7">
<Value>DBsize</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.Monitor.DBusageD</DataLocation>
<DefaultData>DBusageDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.Monitor.DBusageD</IdLocation>
<IndexLocation>^IIBAENSEMBLE.Monitor.DBusageI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.Monitor.DBusageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
