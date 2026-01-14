class TagsController < ApplicationController
  before_action :find_project
  before_action :authorize
  before_action :find_key, only: [:index, :create, :update, :destroy]
  before_action :find_tag, only: [:update, :destroy]

  def index
    @tags = @key.tags
  end

  def create
    @tag = @key.tags.build
    @tag.safe_attributes = tag_params
    if @tag.save
      redirect_to project_key_tags_path(@project, @key), notice: 'Tag was successfully created.'
    else
      render :index
    end
  end

  def update
    @tag.safe_attributes = tag_params
    if @tag.save
      redirect_to project_key_tags_path(@project, @key), notice: 'Tag was successfully updated.'
    else
      render :index
    end
  end

  def destroy
    @tag.destroy
    redirect_to project_key_tags_path(@project, @key), notice: 'Tag was successfully deleted.'
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def find_key
    @key = @project.keys.find(params[:key_id])
  end

  def find_tag
    @tag = @key.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end
