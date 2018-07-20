class ConversationsController < ApiController
  before_action :require_login

  def index
    @conversations = Conversation.all
  end

  def show
    conversations = Conversation.where(:sender_id => params[:id]) + Conversation.where(:recipient_id => params[:id])
    render :json => conversations,
           :include => {
               :recipient => {
                   :only => :name
               },
               :sender => {
                   :only => :name
               }
           }
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

  private

  def conversation_params
    params.permit(:sender_id, :recipient_id, :textbook_id)
  end
end