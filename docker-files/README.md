# AWS Resource Dashboard

This application displays information about your AWS resources, including:
- Running EC2 instances
- Load Balancers
- VPCs
- AMIs

## File Structure

```
docker-files/
├── app.py                # Flask application
├── Dockerfile            # Multi-stage Docker build file
├── docker-compose.yml    # Docker Compose configuration
├── requirements.txt      # Python dependencies
└── templates/
    └── index.html        # HTML template for the dashboard
```

## AWS Credentials

The application requires AWS credentials to access your AWS resources. These are provided as environment variables:

- `AWS_ACCESS_KEY_ID`: Your AWS Access Key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Access Key
- `AWS_REGION`: AWS Region (defaults to us-east-1)


## SSH into the EC2 instance & Clone the repository on the EC2 instance

```bash
ssh -i ~/.ssh/liad_ssh_key ubuntu@
git clone https://github.com/USER/final-test.git
cd final-test
git checkout section3-docker
cd docker-files
```

## Building and Running Locally

1. Build the Docker image (here "aws-dashborad" is the iamge name):
   ```bash
   docker build -t aws-dashboard .
   ```

2. Run the container (insert your access kry and secret key):
   ```bash
   docker run -itd -p 5001:5001 \
     -e AWS_ACCESS_KEY_ID=your_access_key_id \
     -e AWS_SECRET_ACCESS_KEY=your_secret_access_key \
     -e AWS_REGION=us-east-1 \
     aws-dashboard
   ```


## Accessing the Dashboard

when the container is running, access the dashboard at: http://localhost:5001