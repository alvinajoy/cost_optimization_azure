import logging
import azure.functions as func
import os
import json
import requests

COSMOS_ENDPOINT = os.environ['COSMOS_DB_ENDPOINT']
COSMOS_KEY = os.environ['COSMOS_DB_KEY']
DATABASE_NAME = "BillingDB"
CONTAINER_NAME = "Billing"

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Read function triggered.")

    record_id = req.params.get('id')
    partition_key = req.params.get('partitionKey')

    if not record_id or not partition_key:
        return func.HttpResponse("Missing id or partitionKey", status_code=400)

    uri = f"{COSMOS_ENDPOINT}/dbs/{DATABASE_NAME}/colls/{CONTAINER_NAME}/docs/{record_id}"
    headers = {
        'Authorization': COSMOS_KEY,
        'x-ms-version': '2018-12-31',
        'x-ms-documentdb-partitionkey': json.dumps([partition_key])
    }

    try:
        response = requests.get(uri, headers=headers)
        if response.status_code == 200:
            return func.HttpResponse(response.text, mimetype="application/json", status_code=200)
        else:
            return func.HttpResponse("Document not found", status_code=404)
    except Exception as e:
        logging.error(f"Error reading document: {str(e)}")
        return func.HttpResponse("Internal server error", status_code=500)
