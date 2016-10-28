# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO: investigate if delegation, installing the click handlers
# on higher elements outside the rewritten scope, might be a
# better solution
attachButtonPaneClickHandlers = ->
  console.log("attaching")
  $('.pass-button').click (evt) ->
    console.log("!!!!")
    evt.stopPropagation()
    return true # keep the direct behavior

  # TODO: include a change handler which sets the
  # play/expanded icon appropriately when Bootstrap
  # alters its collapsed class, rather than this
  # 'synced' on-click toggle

  # the play button changes regardless whether the
  # button itself or the panel behind it was clicked
  $('.panel-heading').click (evt) ->
    button = $(this).find('.play-button')
    # console.log(button.val())

    # TODO: this is lazy, instead detect and
    # change appropriate with the actual
    # initial presence of collapsed on $(this).

    # ▼ is &#9660; and ► is &#9658;
    if button.val() == '►'
     button.val('▼')
    else
      button.val('►')

    return true # keep the direct behavior

  return

# TODO: find how Rails does its namespacing and perhaps use that
window.QuestionsJS = {};
window.QuestionsJS.attachButtonPaneClickHandlers = attachButtonPaneClickHandlers
$(document).ready(attachButtonPaneClickHandlers);
# this is also called in views/voices/create.js.erb