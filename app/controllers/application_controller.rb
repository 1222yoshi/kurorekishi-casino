class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :require_login
  before_action :set_vip, if: -> { params[:status].present? }

  add_flash_types :success, :danger

  private

  def not_authenticated
    redirect_to login_path
    flash[:danger] = '当カジノは会員制でございます。'
  end

  def set_vip
    @vip = params[:status]
  end
end
