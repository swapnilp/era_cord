class ChaptersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource param_method: :my_sanitizer
  before_action :check_role, only: [:index, :new, :create, :edit, :show, :update]


  def get_points
    chapter = Chapter.where(id: params[:id]).first
    if chapter
      points = chapter.chapters_points
      render json: {success: true, points: points}
    else
      render json: {success: false}
    end
  end

  def index
    @subjects = Subject.all
    @chapters = Chapter.all.order("id desc").page(params[:page])
  end
  
  def new
    @chapter = Chapter.new({subject_id: params[:subject_id]})
  end

  def create
    params.permit!
    chapter = Chapter.new(params[:chapter])
    chapter.save
    redirect_to subject_path(chapter.subject)
  end
  
  def edit
    @chapter = Chapter.where(id: params[:id]).first
  end
  
  def show
    @chapter = Chapter.where(id: params[:id]).first
  end

  def update
    params.permit!
    chapter = Chapter.where(id: params[:id]).first
    chapter.update_attributes(params[:chapter])
    redirect_to subject_path(chapter.subject)
  end
  
  def filter_chapters
    
  end

  private
  
  def my_sanitizer
    #params.permit!
    params.require(:chapter).permit!
  end

  def check_role
    raise ActionController::RoutingError.new('Not Found') unless (current_user.has_role?(:admin_clark) ||  current_user.has_role?(:super_admin))
  end
  
end
