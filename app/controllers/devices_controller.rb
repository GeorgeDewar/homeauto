class DevicesController < ApplicationController

  def update
    @device = Device.find(params[:id])
    @device.update_attributes!(device_params)
    render json: {status: :ok}
  end

  private

  def device_params
    params.require(:device).permit(:name)
  end

end
