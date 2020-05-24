# class ProgressBarChannel < ApplicationCable::Channel
#   def subscribed
#     # stream_from "some_channel"
#   end
#
#   def unsubscribed
#     # Any cleanup needed when channel is unsubscribed
#   end
# end

# app/channels/progress_bar_channel.rb
class ProgressBarChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ProgressBarChannel"
  end
end