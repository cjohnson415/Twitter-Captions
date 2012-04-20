require 'rubygems'
require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

__END__
@@ layout
%html
  %head
    %title Network Tools
  %body
    #header
      %h1 Network Tools
    #content
      =yield

@@ index
%p
  Welcome to Network Tools. Below is a list
  of the tools available.
