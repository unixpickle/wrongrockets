{EventEmitter} = require 'events'

class Watcher extends EventEmitter
  constructor: (@twit, @user) ->
    @stream = null
  
  start: ->
    @stream = @twit.stream 'statuses/filter', track: [@user]
    @stream.on 'error', (err) =>
      @stream = null
      @emit 'error', err
    @stream.on 'tweet', (tweet) =>
      @handleTweet tweet
  
  stop: ->
    @stream.stop()
    @stream = null
  
  handleTweet: (tweet) ->
    # the tweet must include @user and must not *start* with it
    return if tweet.text.toLowerCase().indexOf('@' + @user.toLowerCase()) < 1
    
    # mentions the user, now post a reply
    statuses = [
      "You know, the @rockets you just tweeted at isn't affiliated with the sports team.",
      "Just so you know, that @rockets dude is probably not who you think it is.",
      "FYI, bro, @rockets is a cool guy, but he's no sports team.",
      "Just in case you didn't know, @rockets ain't no sports team.",
      "Hey there brosepher, the Rockets are great, but @rockets doesn't want to hear it."
    ]
    randomStatus = statuses[Math.floor Math.random() * statuses.length]
    args =
      status: "@#{tweet.user.screen_name} #{randomStatus}"
      in_reply_to_status_id: tweet.id_str
    console.log args
    @twit.post 'statuses/update', args, (err) ->
      console.log err if err?

module.exports = Watcher
