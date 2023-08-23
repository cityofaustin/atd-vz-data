#!/usr/bin/env python

import json
import os
import requests
import time

from dotenv import load_dotenv

# Load the .env file
load_dotenv("env")

from queries import crash_listing_query, locations_listing_query, fatalities_listing_query

GRAPHQL_ENDPOINT_URL = os.getenv('GRAPHQL_ENDPOINT_URL')
GRAPHQL_ENDPOINT_KEY = os.getenv('GRAPHQL_ENDPOINT_KEY')

print("GRAPHQL_ENDPOINT_URL: ", GRAPHQL_ENDPOINT_URL)



def execute_query(query_template, start_date, end_date, order_by="desc", offset=0, limit=500):
    crash_date = f'_gte: "{start_date}", _lte: "{end_date}"'
    order_by_str = "atd_fatality_count: " + order_by
    
    #print("crash_date: ", crash_date)
    #print("offset: ", offset, " limit: ", limit)
    
    query = query_template.replace("{{ crash_date }}", crash_date)
    query = query.replace("{{ order_by }}", order_by_str)
    query = query.replace("{{ offset }}", str(offset))
    query = query.replace("{{ limit }}", str(limit))

    headers = {
        "content-type": "application/json",
        "x-hasura-admin-secret": GRAPHQL_ENDPOINT_KEY,
    }

    #print(query)

    response = requests.post(
        GRAPHQL_ENDPOINT_URL,
        json={"query": query},
        headers=headers
    )

    return response.json()

def execute_query_timed(query_template, start_date, end_date, order_by="desc", offset=0, limit=500):
    start_time = time.time()  # Start the timer

    crash_date = f'_gte: "{start_date}", _lte: "{end_date}"'
    order_by_str = "atd_fatality_count: " + order_by
    
    #print("crash_date: ", crash_date)
    #print("offset: ", offset, " limit: ", limit)
    
    query = query_template.replace("{{ crash_date }}", crash_date)
    query = query.replace("{{ order_by }}", order_by_str)
    query = query.replace("{{ offset }}", str(offset))
    query = query.replace("{{ limit }}", str(limit))

    headers = {
        "content-type": "application/json",
        "x-hasura-admin-secret": GRAPHQL_ENDPOINT_KEY,
    }

    #print("query: ", query)

    response = requests.post(
        GRAPHQL_ENDPOINT_URL,
        json={"query": query},
        headers=headers
    )

    execution_time = time.time() - start_time  # Calculate the elapsed time

    print(f"Query execution time: {execution_time} seconds")  # Print the execution time

    return response.json(), execution_time

def average(numbers):
    return sum(numbers) / len(numbers) if numbers else 0

def fetch_paginated_results(query, start_date, end_date, order_by="desc", window_size=500):
    offset = 0
    has_more_data = True

    durations = []

    iterations = 0
    while has_more_data and iterations < 10:
        results, duration = execute_query_timed(query, start_date, end_date, order_by, offset, window_size)
        durations.append(duration)
        
        #print("results: ", results)
        
        #data_chunk = results['data']['atd_txdot_crashes']
        #data_chunk = results['data']['locations_with_crash_injury_counts']
        #data_chunk = results['data']['view_fatalities']
        data_chunk = results['data']['records']
        
        # Process the data_chunk here (e.g., print, store, etc.)
        #print(data_chunk)

        # Check if there are more results to fetch
        has_more_data = len(data_chunk) == window_size

        #print(len(data_chunk), " records fetched")

        # Update the offset for the next iteration
        offset += window_size
        iterations = iterations + 1

    print("Average duration: ", average(durations))

#print("Crash listing query")
#fetch_paginated_results(crash_listing_query, "2015-08-22", "2023-08-22", order_by="desc", window_size=500)
#print("Locations listing query")
#fetch_paginated_results(locations_listing_query, "2015-08-22", "2023-08-22", order_by="desc", window_size=500)
print("Fatalities listing query")
fetch_paginated_results(fatalities_listing_query, "2015-08-22", "2023-08-22", order_by="desc", window_size=500)
