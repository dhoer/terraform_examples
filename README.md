# Terraform Examples

The missing Terraform examples.  Feel free create an issue or pull request if want to add an example or have a 
better or more secure way to accomplish something. The more feedback, the better for me and everyone else. ;-)

## AWS Windows

### aws-winrm-instance

Shows how to use `user_data` to configure WinRM, open firewall, and set the Administrator 
password for AWS Window 2012R2 Base image.

### aws-asg-provision

Shows how to use `user_data` to provision an ASG server instance with Chef. 
 
The user_data script does the following:
- downloads and install chef-client
- downloads s3://mybucket/chef-validator.pem and s3://mybucket/encrypted_data_bag_secret
- applies provisioning tag to instance
- runs chef-client with provided runlist and environment && if successful will apply tags 
  (Note that Name tag and Chef node/client names will be name appended with the instance id e.g. example-i-a1b2c3d4)
- removes provisioning tag
  
Note that IAM must be setup to allow access to Chef server.  This example also expects Chef's chef-validator and 
encrypted_data_bag_secret to be downloadable from an S3 bucket.  Be sure to change s3 paths accordingly. 
