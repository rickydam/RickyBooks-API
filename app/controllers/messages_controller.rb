class MessagesController < ApiController
  before_action :require_login
  before_action do
    @conversation = Conversation.find(params[:conversation_id])
  end

  def index
    @messages = @conversation.messages
    render :json => @messages, :include => {:user => {:only => :name}}
  end

  def new
    @message = @conversation.messages.new
  end

  def create
    @message = @conversation.messages.new(message_params)
    if @message.save
      render json: {
          status: 'SUCCESS'
      }, status: :ok
    else
      render json: {
          status: 'ERROR'
      }, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.permit(:body, :user_id, :conversation_id)
  end
end
