class RelationshipsController < ApplicationController
  before_action :signed_in_staff

  def edit
    @relationship = Relationship.find(params[:id])
    respond_to :js
  end

  def update
    @relationship = Relationship.find(params[:id])
    if params[:delete]
      @relationship.update(note: nil)
      @relationship.save
      redirect_to :back
    else
      if @relationship.update_attributes(relationship_params)
        redirect_to :back
      end
    end
  end

  private
  def relationship_params
    params.require(:relationship).permit(:note)
  end

end
