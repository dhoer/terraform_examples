<script>
::
::  This script does the following:
::    - downloads and install chef-client
::    - downloads s3://mybucket/chef-validator.pem and s3://mybucket/encrypted_data_bag_secret
::    - applies provisioning tag to instance
::    - runs chef-client with provided runlist and environment && if successful, applies remaining tags
::      Note that Chef node/client name will be "${name}-instance_id"
::    - removes provisioning tag
::

echo Download and install chef-client >> C:/chef_bootstrap.log
set REMOTE_SOURCE_MSI_URL=https://www.opscode.com/chef/install.msi >> C:/chef_bootstrap.log 2>&1
set LOCAL_DESTINATION_MSI_PATH=%TEMP%\chef-client-latest.msi >> C:/chef_bootstrap.log 2>&1
powershell.exe $webClient = new-object System.Net.WebClient; $webClient.DownloadFile('%REMOTE_SOURCE_MSI_URL%', '%LOCAL_DESTINATION_MSI_PATH%'); >> C:/chef_bootstrap.log 2>&1
msiexec /qn /i "%LOCAL_DESTINATION_MSI_PATH%" >> C:/chef_bootstrap.log 2>&1
echo( >> C:/chef_bootstrap.log

echo Add the embedded ruby installed by Chef to the Path >> C:/chef_bootstrap.log
SET PATH=C:\opscode\chef\embedded\bin;%PATH% >> C:/chef_bootstrap.log 2>&1
echo( >> C:/chef_bootstrap.log

echo Change to chef directory created by install >> C:/chef_bootstrap.log
cd c:\chef >> C:/chef_bootstrap.log 2>&1
echo( >> C:/chef_bootstrap.log

echo Build and set NODE_NAME environment variable >> C:/chef_bootstrap.log
ruby -e 'require "open-uri"; id = open("http://169.254.169.254/latest/meta-data/instance-id").read; puts "${name}-#{id}"' > C:/chef/node_name.txt
set /p NODE_NAME= < C:/chef/node_name.txt >> C:/chef_bootstrap.log 2>&1
echo:%NODE_NAME% >> C:/chef_bootstrap.log
echo( >> C:/chef_bootstrap.log

echo Install aws-sdk gem >> C:/chef_bootstrap.log
call gem install aws-sdk -v "~> 1.61" --no-ri --no-rdoc >> C:/chef_bootstrap.log 2>&1
echo( >> C:/chef_bootstrap.log

echo Download the encrypted_data_bag_secret and chef-validator.pem using the Ruby aws-sdk, keys aren't needed as long as the machine has the IAM role 'chef-provisioning-role' >> C:/chef_bootstrap.log
ruby -e "require 'aws-sdk'; bucket = AWS.s3.buckets['mybucket']; pem = bucket.objects['chef-validator.pem']; secret = bucket.objects['encrypted_data_bag_secret']; IO.write('validation.pem', pem.read); IO.write('encrypted_data_bag_secret', secret.read)" >> C:/chef_bootstrap.log 2>&1
echo( >> C:/chef_bootstrap.log

echo Apply the 'provisioning' tag (lookup the region and instance ID using the meta-data endpoints) >> C:/chef_bootstrap.log
ruby -e "require 'aws-sdk'; require 'open-uri'; region = open('http://169.254.169.254/latest/meta-data/placement/availability-zone').read.chop; id = open('http://169.254.169.254/latest/meta-data/instance-id').read; instance = AWS.regions[region].ec2.instances[id]; instance.add_tag 'provisioning'" >> C:/chef_bootstrap.log 2>&1
echo( >> C:/chef_bootstrap.log

echo Run chef-client, add remaining tags if successful >> C:/chef_bootstrap.log
call chef-client --node-name %NODE_NAME% --environment ${environment} --server https://merle.pearsondev.com --runlist ${run_list} >> C:/chef_bootstrap.log 2>&1 && ruby -e 'require "aws-sdk"; require "open-uri"; region = open("http://169.254.169.254/latest/meta-data/placement/availability-zone").read.chop; id = open("http://169.254.169.254/latest/meta-data/instance-id").read; instance = AWS.regions[region].ec2.instances[id]; instance.tags.set({${tags}, Name:"#{ENV["NODE_NAME"]}"})' >> C:/chef_bootstrap.log 2>&1
echo( >> C:/chef_bootstrap.log

echo Remove provisioning tag >> C:/chef_bootstrap.log
ruby -e "require 'aws-sdk'; require 'open-uri'; region = open('http://169.254.169.254/latest/meta-data/placement/availability-zone').read.chop; id = open('http://169.254.169.254/latest/meta-data/instance-id').read; instance = AWS.regions[region].ec2.instances[id]; instance.tags.delete 'provisioning'" >> C:/chef_bootstrap.log 2>&1
</script>
