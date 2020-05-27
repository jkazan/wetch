import requests
import json
import shutil
from pathlib import Path


url = "https://opendata-download-radar.smhi.se/api/version/latest/area/sweden/product/comp"
headers = {"Content-Type": "application/json"}
response = requests.get(url, headers=headers)
print(response.status_code)
data = response.json()
img_url = data["lastFiles"][0]["formats"][0]["link"].replace('"', "")

response = requests.get(img_url, stream = True)
print(response.status_code)

if response.status_code == 200:
    response.raw.decode_content = True
    home = Path.home()
    with open(home/".cache/wetch/radar.png", 'wb') as f:
        shutil.copyfileobj(response.raw, f)
        
