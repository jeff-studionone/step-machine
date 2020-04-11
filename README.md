# Deploying a step machine service with terraform

This is a very basic tutorial on how to trigger your **step machine (SFN)** when you upload a file into your **S3 bucket (S3)**. When I started this tutorial I thought that it would be very easy because you can send events form your bucket to your `SQS` or your `Lambda Function` when you put and object into the bucket. However, when I started doing the job I found that we need to use `CloudTrail` to handle the bucket events and `CloudWatch` to trigger you `Step Machine`. So many steps for a simple object. 

The good news in this tutorial is that we are going to use **Terraform** and this tool will help us a lot with AWS. I hate so much to use the AWS console because I need to create everything very manually and debugging it can be more difficult, but when you run Terraform it gives you details and information on what is going to deploy or what is happening.  

Now, let's stop talking so much and lets put hands on this tutorial, but first, let us try to define a proper Terraform module that we can re-use later on in different tutorials or personal projects. 

## File Structure
```buildoutcfg
terraform
├── dev
│   └── main.tf
└── terraform-module
    ├── cloudTrail.tf
    ├── cloudWatch.tf
    ├── iam.tf
    ├── jsonFiles
    │   └── sfnDefinition.json
    ├── stepMachine.tf
    ├── storege.tf
    └── variables.tf 
```

## Process

This file structure will help you to deal with different deployments without need to change your files. The `jsonFiles` contains the definition of your SNF, but in this tutorial we are going to be working with the traditional *Hello World*. 
Now I will start with the S3 and nothing different as the usual documentation from [Terraform](https://www.terraform.io), but there is something to keep in mind and it is that we need to define the policy for this bucket. 

```hcl-terraform 
resource "aws_s3_bucket" "events_storage" {
  bucket        = "${var.project_slug}-${var.env}-events-storage"
  tags          = local.common_tags
  acl           = "private"
  force_destroy = true
  policy        = data.aws_iam_policy_document.s3_events_storage_permission_policy.json
```

This policy will permit the `CloudTrail` to receive the events form this bucket. If you want to see in detail the policy please go to the file `terraform-module/ima.tf` and search for the policy name `s3_events_storage_permission_policy`.

Now, that we have the bucket we need to create the Cloud Trail service. The most important part of this service is the bucket that you are going to receive the objects and the bucket where you are going to store the logs of `CloudTrail`. For more options or information about this service check the terraform [doc](https://www.terraform.io/docs/providers/aws/r/cloudtrail.html).

```hcl-terraform
resource "aws_cloudtrail" "s3_read_images_event" {
  name                          = "${var.project_slug}-${var.env}-s3-read-images-event"
  s3_bucket_name                = aws_s3_bucket.events_storage.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  tags                          = local.common_tags

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.read_images.arn}/"]
    }
  }
} 
```

NowNow, we need to continue with Cloud Watch creating a rule and a target. I don't want to add all the code here in the readme but check the following file with the code `terraform-module/cloundWatch.tf`, there you will find the `event_rule` with the `event_patter`. There is something to highlight here, and it is that if your event_patter does not match with the event from the bucket it will not trigger you `SFN`. Furthermore, this service needs an assumed role and do not forget to allow execution. The following statement is necessary to trigger the `SFN`. What we are doing here is allowing the cloud watch to start the execution in our step machine.   

```hcl-terraform
  statement {
    sid    = "allowRuleTargetStartSFN"
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.sfn_step_machine.id
    ]
  } 
```

Finally, is time to build the step machine but this service is pretty simple. However, you need to learn how to build the structure of this service that is in a JSON file check the file `terraform-module/jsonFiles/sfnDefinition.json`. Now you can build your services, once this process finishes you will be able to see your services up and running in your account of AWS. 

## Building module

```hcl-terraform
cd terraform/dev
terraform init
terraform apply 
```
