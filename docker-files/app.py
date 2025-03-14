import os
import boto3
from flask import Flask, render_template
from botocore.exceptions import ClientError

app = Flask(__name__)

@app.route('/')
def index():
    # Initialize AWS connection
    try:
        # Get AWS credentials from environment variables
        aws_access_key = os.environ.get('AWS_ACCESS_KEY_ID')
        aws_secret_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
        aws_region = os.environ.get('AWS_REGION', 'us-east-1')
        
        if not aws_access_key or not aws_secret_key:
            return "AWS credentials not found in environment variables", 500
        
        # Initialize EC2 client
        ec2 = boto3.client(
            'ec2',
            region_name=aws_region,
            aws_access_key_id=aws_access_key,
            aws_secret_access_key=aws_secret_key
        )
        
        # Get running instances
        instances = ec2.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']}]
        )
        
        # Count running instances
        running_count = 0
        instance_details = []
        
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                running_count += 1
                
                # Get instance name from tags
                instance_name = "Unnamed"
                if 'Tags' in instance:
                    for tag in instance['Tags']:
                        if tag['Key'] == 'Name':
                            instance_name = tag['Value']
                
                # Get instance details
                instance_details.append({
                    'id': instance['InstanceId'],
                    'type': instance['InstanceType'],
                    'state': instance['State']['Name'],
                    'name': instance_name,
                    'az': instance['Placement']['AvailabilityZone']
                })
        
        # Try to get additional AWS resources 
        try:
            # Get list of load balancers
            elb = boto3.client(
                'elbv2',
                region_name=aws_region,
                aws_access_key_id=aws_access_key,
                aws_secret_access_key=aws_secret_key
            )
            load_balancers = elb.describe_load_balancers()
            lb_count = len(load_balancers['LoadBalancers'])
        except Exception as e:
            lb_count = f"Error: {str(e)}"
            
        try:
            # Get list of VPCs
            vpcs = ec2.describe_vpcs()
            vpc_count = len(vpcs['Vpcs'])
        except Exception as e:
            vpc_count = f"Error: {str(e)}"
            
        try:
            # Get list of AMIs owned by the user
            amis = ec2.describe_images(Owners=['self'])
            ami_count = len(amis['Images'])
        except Exception as e:
            ami_count = f"Error: {str(e)}"
            
        return render_template(
            'index.html', 
            running_count=running_count,
            instance_details=instance_details,
            lb_count=lb_count,
            vpc_count=vpc_count,
            ami_count=ami_count,
            region=aws_region
        )
    
    except ClientError as e:
        return f"AWS API Error: {str(e)}", 500
    except Exception as e:
        return f"Error: {str(e)}", 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)