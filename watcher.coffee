{EventEmitter} = require 'events'

class Watcher extends EventEmitter
  constructor: (@twit, @user, @ignore) ->
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
  
  isFollowedBy: (screenname, cb) ->
    dict =
      source_screen_name: @user
      target_screen_name: screenname
    @twit.get 'friendships/show', dict, (err, resp) ->
      if resp?.relationship?.target?.following then cb(true)
      else cb(false)
  
  handleTweet: (tweet) ->
    # the tweet must include @user and must not *start* with it
    return if tweet.text.toLowerCase().indexOf('@' + @user.toLowerCase()) < 1
    return if tweet.user.screen_name.toLowerCase() in @ignore
    @isFollowedBy tweet.user.screen_name, (flag) =>
      return if flag # they probably aren't a noob
      statuses = [
        "You know, the @rockets you just tweeted at isn't affiliated with the sports team.",
        "Just so you know, that @rockets dude is probably not who you think it is.",
        "FYI, bro, @rockets is a cool guy, but he's no sports team.",
        "Just in case you didn't know, @rockets ain't no sports team.",
        "Hey there brosepher, the Rockets are great, but @rockets doesn't want to hear it.",
        "Bro, bro, bro, if you like TECHNOLOGY follow @rockets, otherwise back off"
      ]
      randomStatus = statuses[Math.floor Math.random() * statuses.length]
      if Math.floor(Math.random() * 1000) == 666
        # computers have tempers too
        randomStatus = 'HEY FUCKWIT @ROCKETS ISNT AN NBA TEAM'
      args =
        status: "@#{tweet.user.screen_name} #{randomStatus}"
        in_reply_to_status_id: tweet.id_str
      console.log args
      @twit.post 'statuses/update', args, (err) ->
        console.log err if err?

module.exports = Watcher
