require 'rubygems'
require 'sinatra'
require 'haml'
require 'twitter'
require 'googleajax'
require 'json'

DEFAULT_URL = "http://dessertdarling.com/wp-content/uploads/2012/02/sadface3.jpg"

enable :sessions
GoogleAjax.referrer = "localhost:5000"

get '/' do
	session['twitHandle'] ||= nil
	haml :ask
end

#Stores the twitter handle as a session variable, and displays the ten most recent tweets
post '/handleReceived' do
	tHandle = params["twitterHandle"]
	session['twitHandle'] = tHandle
	@tweets = Twitter.user_timeline(tHandle)
	haml :displayTweets
end

#Searches and displays images with tweets as captions
post '/imagefun' do
	TweetImage = Struct.new(:tweet, :imageUrl)
	@images = Array.new
	tweets = Twitter.user_timeline(session['twitHandle'])
	tweets.each do |tweet|
		firstResult = GoogleAjax::Search.images(tweet.searchText)[:results][0]
		if (firstResult == nil)
			pair = TweetImage.new(tweet.text + "\n No pictures found for this tweet!", DEFAULT_URL ) 
		else
			pair = TweetImage.new(tweet.text, firstResult[:unescaped_url]) 
		end
		@images << pair
	end
	haml :tweetImages
end

#return a string suitable for a search (currently just removes @'s followed by characters)
class Twitter::Status
	def searchText
		return self.text.gsub(/@\w*\s?/, '')
	end
end

__END__
@@ layout
%html
  %head
    %title Twitter Fun
  %body
    %h1 Twitter Captions!
    = yield

@@ask
%form{:action => "/handleReceived", :method => "post"}
  %p
    %label{:for => ""} Please enter your twitter handle:
    %input{:type => "textbox", :name => "twitterHandle", :id => "twitterHandle"}
  %p
    %input{:type => "submit", :value => "Submit!"}

@@displayTweets
%p== So, your twitter handle is really #{session['twitHandle']}? 
%p== Well here are your most recent tweets: 
%table 
  - @tweets.each do |tweet|
    %tr
      %td=tweet.text 
%form{:action => "imagefun", :method => "post"}
  %p
    %input{:type => "submit", :value => "Have some fun!"}

@@tweetImages
%p They say you can know a person by their tweets...
%p
%table{:class => "image"}
	- @images.each do |image|
		%tr
			%td
				%img{:src => image.imageUrl, :height => 200}
		%tr
			%td=image.tweet 
		%tr
			%td
				%br
