# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# from https://www.w3schools.com/bootstrap4/bootstrap_forms_custom.asp
# $(".custom-file-input").on("change", function() {
#   var fileName = $(this).val().split("\\").pop();
#   $(this).siblings(".custom-file-label").addClass("selected").html(fileName);
# });


## Below code not working
# $(".custom-file-input").on("change", ()->
#   fileName = $(this).val().split("\\").pop();
#   $(this).siblings(".custom-file-label").addClass("selected").html(fileName);
# )

App.cable.subscriptions.create { channel: "ImportChannel"},
  connected: -> 
    console.log("connected")
    
  recieved: (data)->
    console.log(data)
    # Updating progress bar here. 
}