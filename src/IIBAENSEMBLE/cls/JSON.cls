Class IIBAENSEMBLE.cls.JSON Extends %Persistent
{

Property TOKENNONE As %Integer [ InitialExpression = 0 ];

Property TOKENCURLYOPEN As %Integer [ InitialExpression = 1 ];

Property TOKENCURLYCLOSE As %Integer [ InitialExpression = 2 ];

Property TOKENSQUAREDOPEN As %Integer [ InitialExpression = 3 ];

Property TOKENSQUAREDCLOSE As %Integer [ InitialExpression = 4 ];

Property TOKENCOLON As %Integer [ InitialExpression = 5 ];

Property TOKENCOMMA As %Integer [ InitialExpression = 6 ];

Property TOKENSTRING As %Integer [ InitialExpression = 7 ];

Property TOKENNUMBER As %Integer [ InitialExpression = 8 ];

Property TOKENTRUE As %Integer [ InitialExpression = 9 ];

Property TOKENFALSE As %Integer [ InitialExpression = 10 ];

Property TOKENNULL As %Integer [ InitialExpression = 11 ];

Property lastErrorIndex As %Integer [ InitialExpression = -1 ];

Property lastDecode As %String;

ClassMethod JsonDecode(json As %String) As %ArrayOfDataTypes
{
	set JSON = ##class(IIBAENSEMBLE.cls.JSON).%New()
	set JSON.lastDecode = json
	
	if json '= "" {
		set index = 1
		set tSC = 1
		set returnValue = JSON.ParseValue(json, .index, .tSC)
		if tSC {
			Quit returnValue
		} else {
			//handle error
			Quit ""
		}				
	}
}

Method EatWhiteSpace(json As %String, ByRef index As %Integer)
{
	WHILE index < $L(json) {
		if ($A($E(json,index))=9)||($A($E(json,index))=32)||($A($E(json,index))=160)||($A($E(json,index))=13)||($A($E(json,index))=10) {
			set z = $I(index)
		} else {
			Quit
		}
	}
}

Method GetLastIndexOfNumber(json As %String, index As %Integer) As %Integer
{
	set lastIndex = index
	WHILE $I(lastIndex) < $L(json) {
		if '$ISVALIDDOUBLE($E(json,index,lastIndex)) Quit
	}
	set z = $I(lastIndex,-1)
	Quit lastIndex
}

Method LookAhead(json As %String, index As %Integer) As %Integer
{
	set saveIndex = index
	Quit ..NextToken(json, .saveIndex)
}

Method NextToken(json As %String, ByRef index As %Integer) As %Integer
{
	do ..EatWhiteSpace(json, .index)
	if index = $L(json) {
		Quit ..TOKENNONE
	}
	set c = $E(json,index)
	set z = $I(index)
	
	if c = "{" {
		Quit ..TOKENCURLYOPEN
	} elseif c = "}" {
		Quit ..TOKENCURLYCLOSE
	} elseif c = "[" {
		Quit ..TOKENSQUAREDOPEN
	} elseif c = "]" {
		Quit ..TOKENSQUAREDCLOSE
	} elseif c = "," {
		Quit ..TOKENCOMMA
	} elseif c = """" {
		Quit ..TOKENSTRING
	} elseif (c = 0)||(c = 1)||(c = 2)||(c = 3)||(c = 4)||(c = 5)||(c = 6)||(c = 7)||(c = 8)||(c = 9)||(c = "-"){
		Quit ..TOKENNUMBER
	} elseif c = ":" {
		Quit ..TOKENCOLON
	}
	
	set z = $I(index,-1)
	
	set remainingLength = $L(json) - index
	
	// false
	if (remainingLength >= 5)&&($E(json,index,index+5) = "false") {
		set z = $I(index,5)
		Quit ..TOKENFALSE
	}
	
	// true
	if (remainingLength >= 4)&&($E(json,index,index+4) = "true") {
		set z = $I(index,4)
		Quit ..TOKENTRUE
	}
	
	// null
	if (remainingLength >= 4)&&($E(json,index,index+4) = "null") {
		set z = $I(index,4)
		Quit ..TOKENFALSE
	}
	
	Quit ..TOKENNONE
}

Method ParseArray(json As %String, ByRef index As %Integer) As %ArrayOfDataTypes
{
	set returnObject = ##class(%ArrayOfDataTypes).%New()
	do ..NextToken(json,.index)
	set arrCounter = -1
	set done = 0
	Do {
		set token = ..LookAhead(json,index)
		if token = ..TOKENNONE {
			set done = 1
			CONTINUE
		} elseif token = ..TOKENCOMMA {
			do ..NextToken(json,.index)
		} elseif token = ..TOKENSQUAREDCLOSE {
			do ..NextToken(json,.index)
			set done = 1
			CONTINUE
		} else {
			set success = 1
			set value = ..ParseValue(json, .index, .success)
			if 'success {
				set done = 1
				CONTINUE
			}
			do returnObject.SetAt(value,$I(arrCounter))
		}
	} WHILE 'done
	
	if returnObject.Count() > 0 {
		Quit returnObject
	} else {
		Quit "" 
	}
}

Method ParseNumber(json As %String, ByRef index As %Integer) As %Double
{
	do ..EatWhiteSpace(json,.index)
	set lastIndex = ..GetLastIndexOfNumber(json,index)
	set returnValue = $E(json,index,lastIndex)
	set index = lastIndex + 1
	Quit returnValue
}

Method ParseObject(json As %String, ByRef index As %Integer) As %ArrayOfDataTypes
{
	set returnObject = ##class(%ArrayOfDataTypes).%New()
	do ..NextToken(json,.index)
	set done = 0
	Do {
		set token = ..LookAhead(json,index)
		if token = ..TOKENNONE {
			set done = 1
			CONTINUE
		} elseif token = ..TOKENCOMMA {
			do ..NextToken(json,.index)
		} elseif token = ..TOKENCURLYCLOSE {
			do ..NextToken(json,.index)
			set done = 1
			CONTINUE
		} else {
			set name = ..ParseString(json, .index)
			if name = "" {
				set done = 1
				CONTINUE
			}
			
			set token = ..LookAhead(json,index)
			if token '= ..TOKENCOLON {
				set done = 1
				CONTINUE 
			} else {
				do ..NextToken(json,.index)
			}
			
			set success = 1
			set value = ..ParseValue(json, .index, .success)
			if 'success {
				set done = 1
				CONTINUE
			}
			
			do returnObject.SetAt(value,name)
			
		}
	} WHILE 'done
	
	if returnObject.Count() > 0 {
		Quit returnObject
	} else {
		Quit "" 
	}
}

Method ParseString(json As %String, ByRef index As %Integer) As %String
{
	set s = ""
	do ..EatWhiteSpace(json,.index)
	
	// first "
	//set c = $E(json,$I(index))
	
	set complete = 0
	Do {
		if index = $L(json) {
			set complete = 1
			set s = ""
			CONTINUE
		}
		set c = $E(json,$I(index))
		if c = """" {
			set complete = 1
			CONTINUE
		} elseif c = "\" {
			if index = $L(json) {
				set complete = 1
				set s = ""
				CONTINUE
			}
			set c = $E(json,$I(index))
			if c = """" {
				set s = s_c
			} elseif c = "\" {
				set s = s_c
			} elseif c = "/" {
				set s = s_c
			} else {
				set s = s_"\"_c
			}
		} else {
			set s = s_c				
		}
		
	} WHILE 'complete
	set z = $I(index)
	Quit s
}

Method ParseValue(json As %String, ByRef index As %Integer, ByRef tSC As %Boolean) As %ArrayOfDataTypes
{
	set token = ..LookAhead(json, index)
	if token = ..TOKENSTRING {
		Quit ..ParseString(json, .index)
	} elseif token = ..TOKENNUMBER {
		Quit ..ParseNumber(json, .index)
	} elseif token = ..TOKENCURLYOPEN {
		Quit ..ParseObject(json, .index)
	} elseif token = ..TOKENSQUAREDOPEN {
		Quit ..ParseArray(json, .index)
	} elseif token = ..TOKENTRUE {
		d ..NextToken(json, .index)
		Quit 1
	} elseif token = ..TOKENFALSE {
		d ..NextToken(json, .index)
		Quit 0
	} elseif token = ..TOKENNULL {
		d ..NextToken(json, .index)
		Quit ""
	} elseif token = ..TOKENNONE {
		set tSC = 0
		Quit ""
	}
}

Storage Default
{
<Data name="JSONDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>TOKENNONE</Value>
</Value>
<Value name="3">
<Value>TOKENCURLYOPEN</Value>
</Value>
<Value name="4">
<Value>TOKENCURLYCLOSE</Value>
</Value>
<Value name="5">
<Value>TOKENSQUAREDOPEN</Value>
</Value>
<Value name="6">
<Value>TOKENSQUAREDCLOSE</Value>
</Value>
<Value name="7">
<Value>TOKENCOLON</Value>
</Value>
<Value name="8">
<Value>TOKENCOMMA</Value>
</Value>
<Value name="9">
<Value>TOKENSTRING</Value>
</Value>
<Value name="10">
<Value>TOKENNUMBER</Value>
</Value>
<Value name="11">
<Value>TOKENTRUE</Value>
</Value>
<Value name="12">
<Value>TOKENFALSE</Value>
</Value>
<Value name="13">
<Value>TOKENNULL</Value>
</Value>
<Value name="14">
<Value>lastErrorIndex</Value>
</Value>
<Value name="15">
<Value>lastDecode</Value>
</Value>
<Value name="16">
<Value>JSON</Value>
</Value>
</Data>
<DataLocation>^IIBAENSEMBLE.cls.JSOND</DataLocation>
<DefaultData>JSONDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^IIBAENSEMBLE.cls.JSOND</IdLocation>
<IndexLocation>^IIBAENSEMBLE.cls.JSONI</IndexLocation>
<StreamLocation>^IIBAENSEMBLE.cls.JSONS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
