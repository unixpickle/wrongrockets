# Setup

    npm install express
    npm install twit
    npm install oauth

# Usage

Create a config.json file:

    {
      "key": "consumer_key",
      "secret": "consumer_secret",
      "watch": "rockets",
      "ignore": ["POSTING_USER_NAME"]
    }

Run:

    coffee main.coffee 1234

Connect:

    http://localhost:1234/
