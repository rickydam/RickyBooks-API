class NotifyItemsController < ApiController
  before_action :require_login

  def index
    notify_items = NotifyItem.all
    render :json => notify_items
  end
