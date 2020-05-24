# app/controllers/progress_bars_controller.rb
class ProgressBarsController < ApplicationController
  def show
    ProgressBarJob.set(wait: 1.second).perform_later
  end
end