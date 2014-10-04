class TasksController < ApplicationController

  def update
    @task = Task.find(params[:id])
    @task.update_attributes!(task_params)
    render json: {status: :ok}
  end

  private

  def task_params
    params.require(:task).permit(:enabled)
  end

end
