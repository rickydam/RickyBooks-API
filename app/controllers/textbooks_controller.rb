class TextbooksController < ApiController
  before_action :require_login
  skip_before_action :require_login, only: [:index, :show, :search]

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
      textbooks = user.textbooks.order('created_at DESC')
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

  def search
    if params[:category].present? && params[:input].present?
      textbooks = nil
      case params[:category]
      when 'Title'
        textbooks = Textbook.where('textbook_title ILIKE ?', "%#{params[:input]}%")
      when 'Author'
        textbooks = Textbook.where('textbook_author ILIKE ?', "%#{params[:input]}%")
      when 'Edition'
        textbooks = Textbook.where('textbook_edition ILIKE ?', "%#{params[:input]}%")
      when 'Condition'
        textbooks = Textbook.where('textbook_condition ILIKE ?', "%#{params[:input]}%")
      when 'Type'
        textbooks = Textbook.where('textbook_type ILIKE ?', "%#{params[:input]}%")
      when 'Course'
        textbooks = Textbook.where('textbook_coursecode ILIKE ?', "%#{params[:input]}")
      else
        # No action required
      end
      render :json => textbooks.order('created_at DESC'),
             :include => {
                 :user => {:only => :name},
                 :images => {:only => :url}
             }
    end
  end

  def aws
    if params[:id].present? && params[:ext].present?
      file_name = 'TextbookImage' + params[:id] + '.' + params[:ext]

      textbook = Textbook.find(params[:id])
      textbook.images.create(:url => generate_get_url(file_name),
                             :file_extension => params[:ext],
                             :url_created_at => Time.now,
                             :file_name => file_name)

      s3 = Aws::S3::Resource.new(region: 'ca-central-1')
      obj = s3.bucket('rickybooks').object(file_name)
      put_url = URI.parse(obj.presigned_url(:put))
      render :json => put_url
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
      textbook_title = params[:textbook_title]
      textbook_author = params[:textbook_author]
      textbook_coursecode = params[:textbook_coursecode]

      notify_items = NotifyItem.all
      notify_items.each do |item|
        if item.category == 'Title'
          if textbook_title.include? item.input
            fcm = FCM.new(ENV['FIREBASE_SERVER_KEY'])
            token = [item.user.firebase_token]
            data = {
                data: {
                    title: 'Someone posted a textbook you want!',
                    body: 'Textbook: ' + item.category + ', matching keyword: ' + item.input,
                    action: 'NotifyFragment'
                }
            }
            fcm.send(token, data)
          end
        end
        if item.category == 'Author'
          if textbook_author.include? item.input
            fcm = FCM.new(ENV['FIREBASE_SERVER_KEY'])
            token = [item.user.firebase_token]
            data = {
                data: {
                    title: 'Someone posted a textbook you want!',
                    body: 'Textbook: ' + item.category + ', matching keyword: ' + item.input,
                    action: 'NotifyFragment'
                }
            }
            fcm.send(token, data)
          end
        end
        if item.category == 'Coursecode'
          if textbook_coursecode.include? item.input
            fcm = FCM.new(ENV['FIREBASE_SERVER_KEY'])
            token = [item.user.firebase_token]
            data = {
                data: {
                    title: 'Someone posted a textbook you want!',
                    body: 'Textbook: ' + item.category + ', matching keyword: ' + item.input,
                    action: 'NotifyFragment'
                }
            }
            fcm.send(token, data)
          end
        end
      end

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

  def get_delete_url
    if params[:id].present?
      textbook = Textbook.find(params[:id])
      image = textbook.images.first
      file_extension = image.file_extension
      s3 = Aws::S3::Resource.new(region: 'ca-central-1')
      filename = 'TextbookImage' + params[:id] + '.' + file_extension
      obj = s3.bucket('rickybooks').object(filename)
      delete_url = URI.parse(obj.presigned_url(:delete))
      render :json => delete_url
    end
  end

  def delete_image
    textbook = Textbook.find(params[:id])
    image = textbook.images.first
    image.destroy
  end

  def update
    textbook = Textbook.find(params[:id])
    textbook.update_attributes(textbook_params)
  end

  private

  def textbook_params
    params.permit(
      :id,
      :user_id,
      :textbook_title,
      :textbook_author,
      :textbook_edition,
      :textbook_condition,
      :textbook_type,
      :textbook_coursecode,
      :textbook_price,
      :category,
      :input
    )
  end
end
