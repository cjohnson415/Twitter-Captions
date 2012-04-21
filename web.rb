require 'rubygems'
require 'sinatra'
require 'haml'
require 'twitter'
require 'googleajax'
require 'json'

enable :sessions
GoogleAjax.referrer = "localhost:5000"

get '/' do
	session["twitHandle"] ||= nil
  	haml :ask
end

post '/handleReceived' do
	@tHandle = params["twitterHandle"]
	@userTweets = Twitter.user_timeline(@tHandle)
	haml :displayTweets
end

post '/imagefun' do
	@imageHash = Hash.new
	@userTweets.each do |tweet|
		firstResult = GoogleAjax::Search.images("Hello World")[:results][0]
		url = firstResult[:url]
		@imageHash[tweet] = url
	end
	@caption = @userTweets[0].text
	@image = @imageHash[tweet]
	haml :displayImage
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
%p== So, your twitter handle is really #{@tHandle}? 
%p== Well here are your most recent tweets: 
%table 
  - @userTweets.each do |tweet|
    %tr
      %td=tweet.text 
%form{:action => "imagefun", :method => "post"}
  %p
    %input{:type => "submit", :value => "Have some fun!"}

@@displayImage
%p== Here's the tweet #{@caption}.
%img{:src => @image, :alt => "Smiley face"} 
