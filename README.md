# Terraform Examples

These are the missing Terraform Windows examples. 
Other Terraform examples can be found here: https://github.com/hashicorp/terraform/blob/master/examples.

## AWS Windows

### aws-winrm-instance

Shows how to use `user_data` to configure WinRM, open firewall, and set the Administrator 
password for AWS Window 2012R2 Base image.

### aws-ebs-mount		
 		
Shows how to use `user_data` to bring a persistent ebs volume (as D: drive) online.

### aws-asg-provision

Shows how to use `user_data` to provision an ASG server instance with Chef. 
 
The user_data script does the following:
- downloads and install chef-client
- downloads s3://mybucket/chef-validator.pem and s3://mybucket/encrypted_data_bag_secret
- applies provisioning tag to instance
- runs chef-client with provided runlist and environment && if successful will apply tags 
  (Note that Name tag and Chef node/client names will be name appended with the instance id e.g. example-i-a1b2c3d4)
- removes provisioning tag
  
Note that IAM must be setup to allow access to Chef server and s3.  This example also expects Chef's chef-validator and 
encrypted_data_bag_secret to be downloadable from an S3 bucket.  Be sure to change s3 paths accordingly. 
