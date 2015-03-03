class TermsController < ApplicationController

  skip_before_action :ensure_current_user

  def index
  end
end
