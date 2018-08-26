class NotifyItemsController < ApiController
  before_action :require_login

  def index
    authenticate_with_http_token do |token|
      user = User.find_by_token(token)
      notify_items = user.notify_items
      render :json => notify_items
    end
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

  def notify_results
    user = User.find(params[:user_id])
    notify_items = user.notify_items

    results = []

    notify_items.each do |item|
      category = item.category
      input = item.input

      case category
      when 'Title'
        textbooks = Textbook.where('textbook_title ILIKE ?', "%#{input}%")
        textbooks.each do |textbook|
          results.push(textbook)
        end
      when 'Author'
        textbooks = Textbook.where('textbook_author ILIKE ?', "%#{input}%")
        textbooks.each do |textbook|
          results.push(textbook)
        end
      when 'Coursecode'
        textbooks = Textbook.where('textbook_coursecode ILIKE ?', "%#{input}%")
        textbooks.each do |textbook|
          results.push(textbook)
        end
      else
        # No action required
      end
    end

    render :json => results.uniq,
           :include => {
               :user => {:only => :name},
               :images => {:only => :url}
           }
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
