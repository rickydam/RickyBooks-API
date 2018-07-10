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
    render :json => textbooks,
           :include => {
               :user => {:only => :name},
               :images => {:only => :url}
           }
  end

  def show
    textbook = Textbook.find(params:[:id])
    render json: {
      status: 'SUCCESS',
      message: 'Loaded textbook listing',
      data: textbook
    }, status: :ok
  end

  def aws
    if params[:id].present? && params[:ext].present?
      s3 = Aws::S3::Resource.new(region: 'ca-central-1')
      obj = s3.bucket('rickybooks').object('TextbookImage' + params[:id] + '.' + params[:ext])

      get_url = URI.parse(obj.presigned_url(:get))
      textbook = Textbook.find(params[:id])
      textbook.images.create(:url => get_url, :file_extension => params[:ext])

      post_url = URI.parse(obj.presigned_url(:put))
      render :json => post_url
    end
  end

  def create
    textbook = Textbook.new(textbook_params)
    if textbook.save
      render :json => textbook.id
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
    if textbook.images.size > 0
      s3 = Aws::S3::Resource.new(region: 'ca-central-1')
      image = textbook.images.first
      obj = s3.bucket('rickybooks').object('TextbookImage' + params[:id] + '.' + image.file_extension)
      delete_url = URI.parse(obj.presigned_url(:delete))
      render :json => delete_url
    else
      render :json => nil
    end
    textbook.destroy
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
