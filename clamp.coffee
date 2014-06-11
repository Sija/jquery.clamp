# http://css-tricks.com/line-clampin/

# Clamp.js
# https://github.com/josephschmitt/Clamp.js

###
TextOverflowClamp.js

Updated 2014-06-07 to fix word measurement bug (off by -1).
Updated 2014-05-08 to improve speed and fix some bugs.
Updated 2013-05-09 to remove jQuery dependancy.

But be careful with webfonts!

NEW!
- Support for padding.
- Support for nearby floated elements.
- Support for text-indent.
###

define ->

  # the actual meat is here
  d   = document
  ce  = d.createElement.bind(d)
  ctn = d.createTextNode.bind(d)

  # measurement element is made a child of the clamped element to get it's style
  measure = ce('span')
  ((s) ->
    s.position   = 'absolute' # prevent page reflow
    s.whiteSpace = 'pre'      # cross-browser width results
    s.visibility = 'hidden'   # prevent drawing
    return
  ) measure.style

  # width element calculates the width of each line
  width = ce('span')
  widthChild = ce('span')
  widthChild.style.display  = 'block'
  widthChild.style.overflow = 'hidden'
  widthChild.appendChild ctn("\u2060")

  clamp = (el, lineClamp = 2) ->

    # make sure the element belongs to the document
    return if not el.ownerDocument or not el.ownerDocument is d

    # reset to safe starting values
    lineStart = wordStart = 0
    lineCount = 1
    wasNewLine = no
    # lineWidth = el.clientWidth
    lineWidth = []

    # get all the text, remove any line changes
    text = (el.textContent or el.innerText).replace /\n/g, ' '

    # append space at the end to match all of the words
    text += ' '

    # create a child block element that accounts for floats
    i = 1
    while i < lineClamp
      newWidthChild = widthChild.cloneNode(true)
      width.appendChild newWidthChild
      widthChild.style.textIndent = 0 if i is 1
      i++
    widthChild.style.textIndent = ''

    # remove all content
    el.removeChild el.firstChild while el.firstChild

    # ready for width calculating magic
    el.appendChild width

    # then start calculating widths of each line
    i = 0
    while i < lineClamp - 1
      lineWidth.push width.childNodes[i].clientWidth
      i++

    # we are done, no need for this anymore
    el.removeChild width

    # cleanup the lines
    width.removeChild width.firstChild while width.firstChild

    # add measurement element within so it inherits styles
    el.appendChild measure

    # http://ejohn.org/blog/search-and-dont-replace/
    text.replace RegExp(' ', 'g'), (m, pos) ->

      # ignore any further processing if we have total lines
      return if lineCount is lineClamp

      # create a text node and place it in the measurement element
      measure.appendChild ctn(text.substr(lineStart, pos - lineStart))

      # have we exceeded allowed line width?
      if lineWidth[lineCount - 1] <= measure.clientWidth

        if wasNewLine
          # we have a long word so it gets a line of it's own
          lineText = text.substr(lineStart, pos + 1 - lineStart)

          # next line start position
          lineStart = pos + 1

        else
          # grab the text until this word
          lineText = text.substr(lineStart, wordStart - lineStart)

          # next line start position
          lineStart = wordStart

        # create a line element
        line = ce('span')

        # add text to the line element
        line.appendChild ctn(lineText)

        # add the line element to the container
        el.appendChild line

        # yes, we created a new line
        wasNewLine = yes
        lineCount++

      else
        # did not create a new line
        wasNewLine = no

      # remember last word start position
      wordStart = pos + 1

      # clear measurement element
      measure.removeChild measure.firstChild
      return

    # remove the measurement element from the container
    el.removeChild measure

    # create the last line element
    line = ce('span')

    # see if we need to add styles
    if lineCount is lineClamp

      # give styles required for text-overflow to kick in
      ((s) ->
        s.display       = 'block'
        s.overflow      = 'hidden'
        s.textOverflow  = 'ellipsis'
        s.whiteSpace    = 'nowrap'
        s.textIndent    = 0
        return
      ) line.style

    # add all remaining text to the line element
    line.appendChild ctn(text.substr(lineStart))

    # add the line element to the container
    el.appendChild line
    return

  clamp
