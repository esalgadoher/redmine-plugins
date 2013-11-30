class ProjectEmailController < ApplicationController
  menu_item :settings
  before_filter :find_project
  def show
    @email = Project.find(params[:id])
  end
  
  def edit
     @project.attributes = params[:project]
     @project.safe_attributes = params[:project]
    @project.save if request.post?
  end
end
