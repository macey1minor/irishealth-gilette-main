Include (XF.Base.Helper, Ensemble)

Class Service.CloudUtils.DynamoDB Extends %RegisteredObject
{

ClassMethod init()
{
    Set tSC = $$$OK

    #; Create RuleProfile table with hashKey of RuleResultID
    Try {
        Do ..createTable("DS_Result", "RuleResultID")
    }
    Catch ex {
        Write tSC=ex.AsStatus(), !
    }

    #; Create RuleProfile table with hashKey of CustomerName and rangeKey of ProfileName
    Try {
        Do ..createTable("DS_RuleProfile", "CustomerName", "ProfileName")
    }
    Catch ex {
        Write tSC=ex.AsStatus(), !
    }

    W !, "INIT COMPLETE"
}

/* ------ UTIL METHODS ------ */
/// Wraps embedded python createTablePy method in order to provide status to upstream operations
ClassMethod createTable(tableName As %String, hashKey As %String, rangeKey As %String = "") As %Status
{
    Set tSC = $$$OK

    Try{
        Do ..createTablePy(tableName, hashKey, rangeKey)
    } Catch ex {
        Set tSC = ex.AsStatus()
    }

    If $$$ISERR(tSC) {
        Do $SYSTEM.Status.DisplayError(tSC)
    }

    Return tSC
}

// Creates a DynamoDB table

// Amazon DynamodbDB documentation for creating a new table using python/boto3 library:

// https://boto3.amazonaws.com/v1/documentation/api/latest/guide/dynamodb.html#:~:text=import%20boto3-,%23%20Get%20the%20service%20resource.%0Adynamodb%20%3D%20boto3.resource(%27dynamodb%27),-%23%20Create%20the%20DynamoDB

ClassMethod createTablePy(tableName, hashKey, rangeKey) As %SYS.Python [ Language = python ]
{
    import boto3
    
    client = boto3.client(
        service_name='dynamodb', 
        region_name="us-east-1", 
        endpoint_url='http://host.docker.internal:4566', 
    )
    if rangeKey == "":
        response = client.create_table(
            AttributeDefinitions=[
                {
                    'AttributeName': hashKey,
                    'AttributeType': 'S'
                }
            ],
            KeySchema=[
                {
                    'AttributeName': hashKey,
                    'KeyType': 'HASH',
                },
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5,
            },
            TableName = tableName,
        )
    else:
        response = client.create_table(
            AttributeDefinitions=[
                {
                    'AttributeName': hashKey,
                    'AttributeType': 'S'
                },
                {
                    'AttributeName': rangeKey,
                    'AttributeType': 'S'
                }
            ],
            KeySchema=[
                {
                    'AttributeName': hashKey,
                    'KeyType': 'HASH',
                },
                {
                    'AttributeName': rangeKey,
                    'KeyType': 'RANGE',
                },
            ],
            ProvisionedThroughput={
                'ReadCapacityUnits': 5,
                'WriteCapacityUnits': 5,
            },
            TableName = tableName,
        )
}

// GET table

ClassMethod getTable(region, tablename) As %SYS.Python [ Language = python ]
{
    import json
    import boto3

    ## 'dynamodb' is a keyword needed by boto3
    dynamo = boto3.resource("dynamodb", region_name=region) 

    return dynamo.Table(tablename)
}

// List all tables

ClassMethod listTables(client) As %SYS.Python [ Language = python ]
{
    import boto3

    client = boto3.client(
        service_name='dynamodb', 
        region_name="us-east-1", 
        endpoint_url='http://host.docker.internal:4566', 
    )

    response = client.list_tables()

    print(response)

    return response
}

/// ObjectScript method that wraps the python method in order to return status to calling entity
ClassMethod writeToDynamoDB(tableName As %String, json As %DynamicObject) As %Status
{
    #dim tSC As %Status = $$$OK

    //this is not being converted to a string. It is being converted to a "module" type
    Set jsonString = json.%ToJSON() 

    Set pyStatus = ..writeToDynamoDBpython(tableName, jsonString)

    If (pyStatus '= "OK") {Set tSC = $$$ERROR($$$GeneralError,"failed to write to DynamoDB")}

    Quit tSC
}

// PUT new item

// AWS documentation for boto3 put_item

// https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/client/put_item.html 

ClassMethod writeToDynamoDBpython(tableName As %String, pjson) [ Language = python ]
{
    import boto3
    import json

    client = boto3.client(
        service_name='dynamodb', 
        region_name='us-east-1', 
        endpoint_url='http://host.docker.internal:4566'
    )
    
    result = "OK"

    data = json.loads(pjson)

    for i in data: #str name of the list e.g "item"
        for dataDict in data[i]: #individual nested objects in dict form
            try:
                response = client.put_item(
                    TableName=tableName,
                    Item={
                        'RuleResultID': {
                            'S': dataDict['RuleResultID']['S']
                        },
                        'MessageID': {
                            'S': dataDict['MessageID']['S']
                        },
                        'RuleName': {
                            'S': dataDict['RuleName']['S'],
                        },
                        'RuleFailureCategory': {
                            'S': dataDict['RuleFailureCategory']['S'],
                        },
                        'Status': {
                            'S': dataDict['Status']['S'],
                        },
                        'SourceProfileName': {
                            'S': dataDict['SourceProfileName']['S'],
                        },
                        'DataType': {
                            'S' : dataDict['DataType']['S'],
                        },
                        'BatchId': {
                            'S': dataDict['BatchId']['S'],
                        },
                        'FieldValue': {
                            'S': dataDict['FieldValue']['S'],
                        },
                        'LocationInOriginal': {
                            'S': dataDict['LocationInOriginal']['S'],
                        },
                        'SuccessTarget': {
                            'S': dataDict['SuccessTarget']['S'],
                        },
                        'FailTarget': {
                            'S': dataDict['FailTarget']['S'],
                        },
                    },
                )
            except:
                result = "BAD"
            
    return result
}

// KEYS are MessageID (String) and RuleName (String)

ClassMethod getItem(tableName As %String, hashKey As %String, rangeKey As %String = "") As %SYS.Python [ Language = python ]
{
    import json
    import boto3

    client = boto3.client(
        service_name='dynamodb', 
        region_name='us-east-1', 
        endpoint_url='http://host.docker.internal:4566', 
    )

    if rangeKey == "":
        response = client.get_item(
            TableName = tableName,
            Key={
                'RuleResultID':  {
                    'S': hashKey,
                },
            },
        )
    else:
        response = client.get_item(
            TableName = tableName,
            Key={
                'MessageID':  {
                    'S': hashKey,
                },
                'RuleName': {
                    'S': rangeKey,
                },
            },
        )

    item = response['Item']
    
    print(item)

    return item
}

/// Deletes a DDB table
ClassMethod deleteTable(tableName) As %Status [ Language = python ]
{
    import json
    import boto3

    client = boto3.client(
        service_name='dynamodb', 
        region_name='us-east-1', 
        endpoint_url='http://host.docker.internal:4566', 
    )

    response = client.delete_table(
        TableName = tableName
    )

    print(tableName, " deleted")
}

/* ************ TEST METHODS ************ */
ClassMethod testWrite() As %Status
{
    set xdataID="DS.DynamoDBUtils||DSJSON"
    set compiledXdata=##class(%Dictionary.CompiledXData).%OpenId(xdataID)
    set tStream=compiledXdata.Data
    If '$IsObject(tStream) Set tSC=%objlasterror Quit
    
    set testJsonXdata = {}.%FromJSON(tStream)
    set tSC = ..writeToDynamoDB("DS_Result",testJsonXdata)

    quit 1
}

XData DSJSON [ MimeType = application/json ]
{
{
	    "Item": [
		    {
                "RuleResultID": {
                "S": "MessageID_RuleName_01"
                },
                "MessageID": {
                "S": "MessageID"
                },
                "RuleName": {
                "S": "RuleName"
                },
                "RuleFailureCategory": {
                "S": "Fail"
                },
                "Status": {
                "S": "Pass"
                },
                "SourceProfileName": {
                "S": "TEST 1"
                },
                "DataType": {
                "S": "CCD"
                },
                "BatchId": {
                "S": "CCD_12345"
                },
                "FieldValue": {
                "S": "field value 1"
                },
                "SuccessTarget": {
                "S": "S3 Success"
                },
                "FailTarget": {
                "S": "S3 Fail"
                }
            },
            {
                "RuleResultID": {
                "S": "MessageID_RuleName_02"
                },
                "MessageID": {
                "S": "MessageID"
                },
                "RuleName": {
                "S": "RuleName"
                },
                "RuleFailureCategory": {
                "S": "Fail"
                },
                "Status": {
                "S": "Pass"
                },
                "SourceProfileName": {
                "S": "TEST 2"
                },
                "DataType": {
                "S": "BCBS"
                },
                "BatchId": {
                "S": "BCBS_67890"
                },
                "FieldValue": {
                "S": "field value 2"
                },
                "SuccessTarget": {
                "S": "S3 Success"
                },
                "FailTarget": {
                "S": "S3 Fail"
                }
            },
            {
                "RuleResultID": {
                "S": "MessageID_RuleName_03"
                },
                "MessageID": {
                "S": "MessageID"
                },
                "RuleName": {
                "S": "RuleName"
                },
                "RuleFailureCategory": {
                "S": "Fail"
                },
                "Status": {
                "S": "Pass"
                },
                "SourceProfileName": {
                "S": "TEST 3"
                },
                "DataType": {
                "S": "BCBS"
                },
                "BatchId": {
                "S": "BCBS_67890"
                },
                "FieldValue": {
                "S": "field value 3"
                },
                "SuccessTarget": {
                "S": "S3 Success"
                },
                "FailTarget": {
                "S": "S3 Fail"
                }
            }
        ]
    }
}

}
