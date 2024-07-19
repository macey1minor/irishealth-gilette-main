# gilette sample
A sample implementation


## Usage
Once Docker starts without issue, then reach the Management Portal with this address: 

User: _system Pass: SYS

[Management Portal](http://localhost:45461/csp/sys/UtilHome.csp)



## Install
Clone this repository

```bash
git clone git@github.com:LEADNorthLLC/irishealth-gilette.git
```

**Docker**

```bash
docker-compose up --build -d
```

## IRIS Terminal

To find the running container names:
```bash
docker ps
```

Access Terminal by entering the following in Docker terminal or Bash terminal. Iris is automaticallly logged in.
```bash
docker exec -it [Docker Container Name]-[Iris container name] bash
iris terminal IRIS
```


example: 
```bash
docker exec -it iris-aws-localstack-demo-iris-1 bash
iris terminal IRIS
```




A technology example to accompany the following technical article in the InterSystems community.

# InterSystems IRIS® AWS LocalStack Demo
A demo of how to add a LocalStack* instance to a Docker container in order to simulate S3 Buckets and DynamoDB for local testing without AWS. ObjectScript write and read utilities for S3 and DynamoDB were created with embedded Python.

[LocalStack](https://www.localstack.cloud) is an open source is a cloud software development framework and emulator used to develop and test your AWS applications locally. 

## Introduction

Accessing Amazon S3 (Simple Storage Service) buckets programmatically is a common requirement for many applications. However, setting up and managing AWS accounts is daunting and expensive, especially for small-scale projects or local development environments. This repository demonstrates how to overcome this hurdle by using localstack to simulate AWS services locally. We used ObjectScript with embedded Python to communicate with IRIS and AWS simultaneously. Before beginning, ensure you have Python and Docker Desktop installed on your system. 

**Creating an S3 Bucket**

Now that LocalStack is running, let's create an S3 bucket programmatically. We'll use Python and the Boto3 library—a Python SDK for AWS services. Take a look at the MakeBucket method provided in the S3UUtil class. This method utilizes Boto3 to create an S3 bucket:

```
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
```

To create a bucket named "mybucket", you would call this method with the desired bucket name:

```python
status = S3UUtil.MakeBucket("mybucket")
```

## Uploading Objects to the Bucket

Onc\e the bucket is created, you can upload objects to it programmatically. The PutObject method demonstrates how to achieve this:

```python
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
```
## Listing Objects in the Bucket

To list objects in the bucket, you can use the FetchBucket method:

```python
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
```

## Retrieving Objects from the Bucket

Finally, to retrieve objects from the bucket, you can use the PullObjectFromBucket method:

```python
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
```



## Run commands - S3
Run the following commands within the IRIS Terminal to interact with the bucket programmatically

**Create bucket** 
Do ##class(DS.CloudUtils.S3.S3Util).CreateBucket("yourBucket")

**Get bucket** 
Do ##class(DS.CloudUtils.S3.S3Util).GetBucket("yourBucket", "yourObjectKey")

**Put objects in bucket**
Do ##class(DS.CloudUtils.S3.S3Util).PutObject("yourBucket", "yourObjectKey")

**Pull objects from bucket** 
Do ##class(DDS.CloudUtils.S3.S3Util).PullObjectFromBucket("yourBucket", "yourObjectKey")

## Run commands - DynamoDB
Run the following commands within the iris terminal to interact with the DynamoDB instance programmatically

**Create bucket** 
Do ##class(DQS.CloudUtils.S3.S3UUtil).CreateBucket("yourBucket")

**Get bucket** 
Do ##class(S3.S3UUtil).GetBucket("yourBucket", "yourObjectKey")

**Put objects in bucket**
Do ##class(S3.S3UUtil).PutObject("yourBucket", "yourObjectKey")

**Pull objects from bucket** 
Do ##class(DQS.CloudUtils.S3.S3UUtil).PullObjectFromBucket("yourBucket", "yourObjectKey")

## Authors
Macey Minor, Andre Ribera, Nathan Holt [LEADNorth, LLC Innovations](https://github.com/LEADNorthLLC)