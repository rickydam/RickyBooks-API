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
      if params[:user_id] == @conversation.recipient_id.to_s
        @other_user_id = @conversation.sender_id
      else
        @other_user_id = @conversation.recipient_id
      end
      other_user = User.find(@other_user_id)
      other_user_firebase_token = other_user.firebase_token
      fcm = FCM.new(ENV['FIREBASE_SERVER_KEY'])
      token = [other_user_firebase_token]
      data = {
          data: {
              title: 'Message from ' + User.find(params[:user_id]).name,
              body: params[:body],
              conversation_id: params[:conversation_id]
          }
      }
      fcm.send(token, data)
      render status: :ok
    else
      render status: :unprocessable_entity
      if @conversation.messages.count == 0
        @conversation.destroy
      end
    end
  end

  private

  def message_params
    params.permit(:body, :user_id, :conversation_id)
  end
end
