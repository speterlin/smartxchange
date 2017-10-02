class MaterialsController < ApplicationController

  before_action :correct_user?

  def create
    @material = Material.new(material_params)
    @material.name = @material.name.downcase
    respond_to do |format|
      @material.save
      format.js
    end
  end

  def destroy
    @material = Material.find(params[:id])
    @material.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def material_params
    params.require(:material).permit(:name, :attachment, :owner_id, :language, :language_level)
  end
end
