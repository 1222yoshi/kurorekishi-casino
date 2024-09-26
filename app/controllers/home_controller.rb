class HomeController < ApplicationController
  skip_before_action :require_login

  def share
    app_url = "https://kuro-casino-f76882fd1dd7.herokuapp.com?status=vip"
    x_url = "https://x.com/intent/tweet?url=#{CGI.escape(app_url)}"
    redirect_to x_url, allow_other_host: true
  end
end
