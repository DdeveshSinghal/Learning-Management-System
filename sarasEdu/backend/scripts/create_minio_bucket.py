import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parents[1]
load_dotenv(dotenv_path=BASE_DIR / '.env')

import boto3
from botocore.client import Config

endpoint = os.environ.get('MINIO_ENDPOINT', 'minio:9000')
secure = os.environ.get('MINIO_SECURE', '0') == '1'
access_key = os.environ.get('MINIO_ACCESS_KEY', 'minioadmin')
secret_key = os.environ.get('MINIO_SECRET_KEY', 'minioadmin')
bucket = os.environ.get('MINIO_BUCKET', 'sarasedu')

protocol = 'https' if secure else 'http'
endpoint_url = f"{protocol}://{endpoint}"

print(f"Using endpoint: {endpoint_url}, bucket: {bucket}")

s3 = boto3.client('s3',
                  aws_access_key_id=access_key,
                  aws_secret_access_key=secret_key,
                  endpoint_url=endpoint_url,
                  config=Config(signature_version='s3v4'))

try:
    # create bucket (MinIO ignores LocationConstraint)
    s3.create_bucket(Bucket=bucket)
    print(f"Bucket '{bucket}' created or already exists.")
except Exception as e:
    # Many S3 servers will raise if bucket exists; still treat as success
    print("Create bucket error:", e)
    # try to head bucket to confirm existence
    try:
        s3.head_bucket(Bucket=bucket)
        print(f"Bucket '{bucket}' is accessible.")
    except Exception as e2:
        print('Bucket not accessible:', e2)
        raise
