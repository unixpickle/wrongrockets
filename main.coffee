if process.argv.length isnt 3
  console.log 'Usage: coffee main.coffee <port>'
  process.exit 1

express = require 'express'
fs = require 'fs'
Twit = require 'twit'
{OAuth} = require 'oauth'
Watcher = require './watcher.coffee'

app = express()
watcher = null
consumer = JSON.parse fs.readFileSync 'config.json'
throw 'invalid port number' if isNaN port = parseInt process.argv[2]

oa = new OAuth(
	"https://api.twitter.com/oauth/request_token",
	"https://api.twitter.com/oauth/access_token",
	consumer.key,
	consumer.secret,
	"1.0",
	"http://aqnichol.com:#{port}/auth/twitter/callback",
	"HMAC-SHA1"
)

app.use express.cookieParser()
app.use express.session secret: 'foobar' + Math.random() + new Date()

app.use express.basicAuth 'testUser', 'testPass'

app.get '/auth/twitter', (req, res) ->
  oa.getOAuthRequestToken (error, token, tokenSecret, results) ->
    if error?
      res.send 'there was an error requesting the token'
      console.log error
    else
      req.session.oauth = token: token, tokenSecret: tokenSecret
      base = 'https://twitter.com/oauth/authenticate?oauth_token='
      res.redirect base + token

app.get '/auth/twitter/callback', (req, res) ->
  return res.send 'not authenticated' if not req.session.oauth?
  req.session.oauth.verifier = req.query.oauth_verifier
  oauth = req.session.oauth
  callback = (error, accessToken, accessTokenSecret, results) ->
    return res.send 'something broke: ' + error.toString() if error?
    req.session.oauth.accessToken = accessToken
    req.session.oauth.accessTokenSecret = accessTokenSecret
    res.redirect '/'
  oa.getOAuthAccessToken(oauth.token, oauth.tokenSecret,
                         oauth.verifier, callback)
                         

app.get '/start', (req, res) ->
  return res.send 'already started' if watcher?
  if not req.session.oauth?.accessToken?
    return res.send 'you must be authenticated with Twitter first'
  session = new Twit
    consumer_key: consumer.key
    consumer_secret: consumer.secret
    access_token: req.session.oauth.accessToken
    access_token_secret: req.session.oauth.accessTokenSecret
  watcher = new Watcher session, consumer.watch, consumer.ignore
  watcher.on 'error', (error) ->
    watcher = null
    console.log error
  watcher.start()
  res.redirect '/'

app.get '/stop', (req, res) ->
  watcher?.stop?()
  watcher = null
  res.redirect '/'

app.get '/', (req, res) ->
  if watcher? then startStop = '<a href="/stop">Stop</a>'
  else startStop = '<a href="/start">Start</a>'
  res.send '<html><head>' +
           '<title>Wrong Rockets</title>' +
           '</head><body>' +
           '<a href="/auth/twitter">Authenticate with Twitter</a><br />' +
           startStop +
           '</body></html>'

app.listen port
