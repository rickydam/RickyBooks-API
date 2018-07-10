class TextbooksController < ApiController
  before_action :require_login
  skip_before_action :require_login, only: [:index, :show]

  def index
    # Set the wanted time interval passed before generating a new signed get url
    wanted_interval = 6.days.to_i

    # Get the date and time of expiration
    expiration_date_time = Time.at(Time.now.to_time - wanted_interval)

    # Get all the image signed get urls that were generated before the wanted interval
    images = Image.all
    expired_images = images.where("url_created_at < ?", expiration_date_time)

    # The url is expiring in less than a day, so generate a new signed get url
    expired_images.each do |image|
      image.update_columns(url: generate_get_url(image.file_name),
                           url_created_at: Time.now)
    end

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
      file_name = 'TextbookImage' + params[:id] + '.' + params[:ext]

      textbook = Textbook.find(params[:id])
      textbook.images.create(:url => generate_get_url(file_name),
                             :file_extension => params[:ext],
                             :url_created_at => Time.now,
                             :file_name => file_name)

      post_url = URI.parse(obj.presigned_url(:put))
      render :json => post_url
    end
  end

  def generate_get_url(file_name)
    creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    client = Aws::S3::Client.new(region: ENV['S3_REGION'], credentials: creds)
    signer = Aws::S3::Presigner.new(client: client)
    signer.presigned_url(:get_object, bucket: ENV['S3_BUCKET'], key: file_name, expires_in: 7.days.to_i).to_s
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
