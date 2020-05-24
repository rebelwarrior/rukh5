// app/javascript/channels/progress_bar_channel.coffee
// App.progress_bar = App.cable.subscriptions.create "ProgressBarChannel",
//   connected: ->
//     # Called when the subscription is ready for use on the server
//
//   disconnected: ->
//     # Called when the subscription has been terminated by the server
//
//   received: (data) ->
//     # Called when there's incoming data on the websocket for this channel


// app/javascript/channels/progress_bar_channel.js
import consumer from "./consumer"
import CableReady from 'cable_ready'

consumer.subscriptions.create("ProgressBarChannel", {
  received: data => {
    if (data.cableReady) CableReady.perform(data.operations)
  }
})