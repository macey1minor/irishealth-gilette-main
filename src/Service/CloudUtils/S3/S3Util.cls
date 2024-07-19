Class Service.CloudUtils.S3.S3Util Extends %RegisteredObject
{
    ClassMethod CreateBucket(inboundfromiris As %String) As %Status 
    {
        Set tSC = $$$OK
        Try {
            Set tSC = ..MakeBucket(inboundfromiris)
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        If $$$ISERR(tSC) {
            Do $SYSTEM.Status.DisplayError(tSC)
        }
        Return tSC
    }

    ClassMethod PutObject(inboundfromiris As %String, objectKey As %String) As %Status [ Language = python ]
    {
        import boto3

        try:
            content = "Hello, World!".encode('utf-8')

            s3 = boto3.client(
                service_name='s3',
                region_name="us-east-1",
                endpoint_url='http://host.docker.internal:4566'
            )

            s3.put_object(Bucket=inboundfromiris, Key=objectKey, Body=content)
            print("Object uploaded successfully!")
            return 1
        except Exception as e:
            print("Error:", e)
            return 0
    }


    ClassMethod GetBucket(inboundfromiris As %String) As %Status 
    {
        Set tSC = $$$OK
        Try {
            Set tSC = ..FetchBucket(inboundfromiris)
        } Catch ex {
            Set tSC = ex.AsStatus()
        }
        If $$$ISERR(tSC) {
            Do $SYSTEM.Status.DisplayError(tSC)
        }
        Return tSC
    }

    ClassMethod MakeBucket(inboundfromiris As %String) As %Status [ Language = python ]
    {
        import boto3

        s3 = boto3.client(
            service_name='s3', 
            region_name="us-east-1", 
            endpoint_url='http://host.docker.internal:4566', 
        )

        try:
            s3.create_bucket(Bucket=inboundfromiris)
            print("Bucket created successfully")
            return 1
        except Exception as e:
            print("Error:", e)
            return 0
    }

    ClassMethod FetchBucket(inboundfromiris As %String) As %Status [ Language = python ]
    {
        import boto3

        s3 = boto3.client(
            service_name='s3', 
            region_name="us-east-1", 
            endpoint_url='http://host.docker.internal:4566', 
        )

        try:
            response = s3.list_objects(Bucket=inboundfromiris)
            if 'Contents' in response:
                print("Objects in bucket", inboundfromiris)
                for obj in response['Contents']:
                    print(obj['Key'])
                return 1
            else:
                print("Error: Bucket is empty or does not exist")
                return 0
        except Exception as e:
            print("Error:", e)
            return 0
    }

ClassMethod PullObjectFromBucket(inboundfromiris As %String, objectKey As %String) As %Status [ Language = python ]
    {
        import boto3

        def pull_object_from_bucket(bucket_name, object_key):
            try:
                s3 = boto3.client(
                    service_name='s3', 
                    region_name="us-east-1", 
                    endpoint_url='http://host.docker.internal:4566', 
                )

                obj_response = s3.get_object(Bucket=bucket_name, Key=object_key)
                content = obj_response['Body'].read().decode('utf-8')
                print("Content of object with key '", object_key, "':", content)
                return True
            except Exception as e:
                print("Error:", e)
                return False

        pull_object_from_bucket(inboundfromiris, objectKey)
    }

}