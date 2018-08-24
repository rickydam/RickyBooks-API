class ConversationsController < ApiController
  before_action :require_login

  def index
    @conversations = Conversation.all
  end

  def show
    conversations = Conversation.where(:sender_id => params[:id]) + Conversation.where(:recipient_id => params[:id])
    conversations_json = conversations.as_json(
        {
            :include => [
                recipient: {
                    only: [:name]
                },
                sender: {
                    only: [:name]
                }
            ]
        }
    )

    last_messages = []
    conversations.each do |conversation|
      last_message_json = conversation.messages.last.as_json(
          {
              :include => {
                  :user => {
                      :only => :name
                  }
              }
          }
      )
      last_messages.push(last_message_json)
    end

    render :json => {conversations: conversations_json, last_messages: last_messages}
  end

  def create
    if Conversation.between(params[:sender_id], params[:recipient_id]).present?
      @conversation = Conversation.between(params[:sender_id], params[:recipient_id]).first
      render json: {
          conversation_id: @conversation.id
      }
    else
      @conversation = Conversation.create!(conversation_params)
      render json: {
          conversation_id: @conversation.id
      }
    end
  end

  def destroy
    conversation = Conversation.find(params[:id])
    conversation.destroy
  end

  private

  def conversation_params
    params.permit(:sender_id, :recipient_id, :textbook_id)
  end
end