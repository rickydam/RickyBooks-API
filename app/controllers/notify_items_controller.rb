class NotifyItemsController < ApiController
  before_action :require_login

  def index
    notify_items = NotifyItem.all
    render :json => notify_items
  end

  def create
    notify_item = NotifyItem.new(notify_items_params)
    if notify_item.save
    else
      render json: {
          status: 'ERROR',
          data: notify_item.errors
      }, status: :unprocessable_entity
    end
  end

  private

  def notify_items_params
    params.permit(
      :user_id,
      :category,
      :input
    )
  end
end
