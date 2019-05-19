# ReadReceipt

Function:

1. Use baidu aip as the OCR library to read receipt image from a url link
2. Select the food items and suggest the food categories, expiry days

# Development platform
  Python 3.6/ AWS Lambda

# Database system
  MySQL

# Installation 
  1. Download ocrwithremove.zip
  2. Create lambda function on AWS, selecting Python 3.6 as the language
  3. Upload the ocrwithremove.zip file 
  

# Settings
  MySQL setting
  
  rds_host  = ""
  name = ""
  password =
  db_name = ""
  
  Baidu-aip setting 
  create an account from baidu aip (https://cloud.baidu.com/doc/OCR/OCR-Python-SDK.html) 
  APP_ID = ''
  API_KEY = ''
  SECRET_KEY = ''
  client = AipOcr(APP_ID, API_KEY, SECRET_KEY)
