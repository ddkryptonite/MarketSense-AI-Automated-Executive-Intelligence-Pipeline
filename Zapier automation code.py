import requests
import json

# 1. Configuration
# Note: Use Zapier "Secrets" for the API Key in production
API_KEY = "#########"
url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
parameters = {'start':'1', 'limit':'20', 'convert':'USD'} 
headers = {
    'X-CMC_PRO_API_KEY': API_KEY,
    'Accepts': 'application/json'
}

# 2. Fetch Data
response = requests.get(url, headers=headers)
response.raise_for_status()
raw_data = response.json()['data']

# 3. Format for Zapier Google Sheets Step
# We create a flat list that Zapier's Google Sheets action can read.
output_list = []
for coin in raw_data:
    row = {
        "name": coin['name'],
        "symbol": coin['symbol'],
        "price_usd": coin['quote']['USD']['price'],
        "market_cap": coin['quote']['USD']['market_cap'],
        "change_24h": coin['quote']['USD']['percent_change_24h'],
        "change_1h": coin['quote']['USD']['percent_change_1h'],
        "change_7d": coin['quote']['USD']['percent_change_7d'],
        "change_30d": coin['quote']['USD']['percent_change_30d'],
        "change_60d": coin['quote']['USD']['percent_change_60d'],
        "change_90d": coin['quote']['USD']['percent_change_90d'],
        "volume_24h": coin['quote']['USD']['volume_24h'],
        "last_updated": coin['quote']['USD']['last_updated'],
       
    }
    output_list.append(row)

# Wrap in line_items so Zapier can process multiple rows at once
return {"line_items": output_list}