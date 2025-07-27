import logging
import azure.functions as func
import datetime
import os
import json
import requests

COSMOS_ENDPOINT = os.environ['COSMOS_DB_ENDPOINT']
COSMOS_KEY = os.environ['COSMOS_DB_KEY']
DATABASE_NAME = "BillingDB"
CONTAINER_NAME = "Billing"

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Archive function triggered.")

    headers = {
        'Authorization': COSMOS_KEY,
        'Content-Type': 'application/query+json',
        'x-ms-version': '2018-12-31',
        'x-ms-documentdb-isquery': 'true',
    }

    query = {
        'query': "SELECT * FROM c WHERE c.archived != true AND c.timestamp < @cutoff",
        'parameters': [
            {
                'name': '@cutoff',
                'value': (datetime.datetime.utcnow() - datetime.timedelta(days=90)).isoformat()
            }
        ]
    }

    uri = f"{COSMOS_ENDPOINT}/dbs/{DATABASE_NAME}/colls/{CONTAINER_NAME}/docs"
    params = {
        'partitionKey': 'billing'
    }

    try:
        response = requests.post(uri, headers=headers, params=params, data=json.dumps(query))
        docs = response.json().get('Documents', [])
        archived_count = 0

        for doc in docs:
            doc['archived'] = True
            update_uri = f"{COSMOS_ENDPOINT}/dbs/{DATABASE_NAME}/colls/{CONTAINER_NAME}/docs/{doc['id']}"
            update_headers = headers.copy()
            update_headers.update({
                'If-Match': '*',
                'x-ms-documentdb-partitionkey': json.dumps([doc['partitionKey']])
            })
            update_resp = requests.put(update_uri, headers=update_headers, data=json.dumps(doc))
            if update_resp.status_code == 200:
                archived_count += 1

        return func.HttpResponse(f"Archived {archived_count} documents.", status_code=200)

    except Exception as e:
        logging.error(f"Error archiving documents: {str(e)}")
        return func.HttpResponse("Internal server error", status_code=500)
