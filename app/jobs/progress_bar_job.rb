# app/jobs/progress_bar_job.rb
class ProgressBarJob < ApplicationJob
  queue_as :default

  def perform(*args)
    status = 0
    while status < 100
      status += 10
      cable_ready["ProgressBarChannel"].set_attribute(
        selector: "#progress-bar>div",
        name: "style",
        value: "width:#{status}%; transition: .5s;"
      )
      cable_ready.broadcast
      sleep 1 # fake some latency
    end
  end
end
