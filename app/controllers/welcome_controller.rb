class WelcomeController < ApplicationController

  skip_before_action :ensure_current_user

  def index
    @quotes = {
      "Cayla Hayes" => "\"gCamp has changed my life! It's the best tool I've ever used.\"",
      "Leta Jaskolski" => "\"Before gCamp I was a disorderly slob. Now I'm more organized than I've ever been\"",
      "Lavern Upton" => "\"Don't hesitate - sign up right now! You'll never be the same.\""
    }
  end
end
