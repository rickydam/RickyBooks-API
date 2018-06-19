class TextbooksController < ApiController
  before_action :require_login
  skip_before_action :require_login, only: [:index, :show]

  def index
    if params[:user_id].present?
      user = User.find(params[:user_id])
      textbooks = user.textbooks
    else
      textbooks = Textbook.order('created_at DESC')
    end
    render :json => textbooks, :include => {:user => {:only => :name}}
  end

  def show
    textbook = Textbook.find(params:[:id])
    render json: {
      status: 'SUCCESS',
      message: 'Loaded textbook listing',
      data: textbook
    }, status: :ok
  end

  def create
    textbook = Textbook.new(textbook_params)
    if textbook.save
      render json: {
        status: 'SUCCESS',
        message: 'Added textbook listing',
        data: textbook
      }, status: :ok
    else
      render json: {
        status: 'ERROR',
        message: 'Textbook listing not added',
        data: textbook.errors
      }, status: :unprocessable_entity
    end
  end

  def destroy
    textbook = Textbook.find(params[:id])
    textbook.destroy
    render json: {
      status: 'SUCCESS',
      message: 'Deleted textbook listing',
      data: textbook
    }, status: :ok
  end

  def update
    textbook = Textbook.find(params[:id])
    if textbook.update_attributes(textbook_params)
      render json: {
        status: 'SUCCESS',
        message: 'Updated textbook listing',
        data: textbook
      }, status: :ok
    else
      render json: {
        status: 'ERROR',
        message: 'Textbook listing not updated',
        data: textbook
      }, status: :unprocessable_entity
    end
  end

  private

  def textbook_params
    params.permit(
      :user_id,
      :textbook_title,
      :textbook_author,
      :textbook_edition,
      :textbook_condition,
      :textbook_type,
      :textbook_coursecode,
      :textbook_price
    )
  end
end
