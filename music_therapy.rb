require "roda"
require 'rspotify'
require 'cgi'

class MusicTherapy < Roda

  plugin :json
  plugin :public
  plugin :render

  HOSTNAME = ENV["RACK_HOST"] ? ENV["RACK_HOST"] : "http://localhost:9292"
  
  CLIENT_ID = ENV["CLIENT_ID"]
  CLIENT_SECRET = ENV["CLIENT_SECRET"]

  RSpotify.authenticate(CLIENT_ID, CLIENT_SECRET)

  route do |r|
    # Allows static files (ie. favicon.ico) to be found in /public
    r.public

    r.is "spotify/auth" do
    
      # Bring user to Spotify login page
      r.redirect (
        "https://accounts.spotify.com/authorize?" +
        "client_id=#{CLIENT_ID}&" +
        "response_type=code&" +
        "state=test_state&" +
        "redirect_uri=" +
        CGI.escape("#{HOSTNAME}/spotify/auth/callback")
      )
    end

    r.is "spotify/auth/callback" do 

      # The authorization was successful
      if r.params["code"]
        auth_string = "<p>The auth code is: #{r.params["code"]}</p>"

        if r.params["state"] 
          auth_string += "<p>The state is: #{r.params["state"]}</p>"
        else
          auth_string += "<p>There was no state parameter</p>"
        end

      # Authorization failed (redirected to callback with error parameter)
      elsif r.params["error"]
        "Authorization failed due to the following error: #{r.params["error"]}"

      # Authorization failed (redirect did not contain code or error)
      else
        "Authorization failed due to an unknwon reason (unknown parameters)"
      
      end
    
    end

    r.on "spotify/api" do

      # /spotify/api/v1
      r.on "v1" do  
        #insert our own API endpoints here
      end

    end

  end
end
