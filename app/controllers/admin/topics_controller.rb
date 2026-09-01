module Admin
  class TopicsController < BaseController
    before_action :set_topic, only: [ :edit, :update, :destroy ]

    def index
      authorize :admin, :index?
      @topics = Topic.for_forum.ordered
    end

    def new
      authorize :admin, :create?
      @topic = Topic.new(position: (Topic.maximum(:position) || 0) + 1)
    end

    def create
      authorize :admin, :create?
      @topic = Topic.new(topic_params)

      if @topic.save
        redirect_to admin_topics_path, notice: "Tópico creado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize :admin, :edit?
    end

    def update
      authorize :admin, :update?

      if @topic.update(topic_params)
        redirect_to admin_topics_path, notice: "Tópico actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize :admin, :destroy?

      if @topic.destroy
        redirect_to admin_topics_path, notice: "Tópico eliminado."
      else
        redirect_to admin_topics_path, alert: @topic.errors.full_messages.to_sentence
      end
    end

    private

    def set_topic
      @topic = Topic.find(params[:id])
    end

    def topic_params
      params.require(:topic).permit(:name, :slug, :description, :position)
    end
  end
end
