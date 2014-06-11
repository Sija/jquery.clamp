define ['jquery', 'clamp'], ($, clamp) ->

  $.fn.clamp = (lineClamp) ->
    @each ->
      $(this).data 'original-text', $(this).text()
      clamp this, lineClamp or $(this).data('clamp')
    return this

  $.fn.unclamp = ->
    @each ->
      $(this).text $(this).data('original-text')
    return this
