# maskew
# Skew the shapes of DOM elements
# Dan Motzenbecker
# http://oxism.com
# 0.1.0
# MIT License


{cos, sin, PI, abs, round} = Math

rad = (deg) -> deg * PI / 180

getMetric = (style, key) -> parseInt style[key], 10

transform = (y, angle) -> "translate3d(0, #{ y }px, 0) rotate3d(0, 0, 1, #{ angle }deg)"

testProp = (prop) ->
  return prop if testEl.style[prop]?

  capProp = prop.charAt(0).toUpperCase() + prop.slice 1
  for prefix in prefixList
    if testEl.style[prefix + capProp]?
      return prefix + capProp
  false

hasSupport = true
testEl = document.createElement 'div'
prefixList = ['Webkit', 'Moz', 'O', 'ms', 'Khtml']
css =
  transform: 'transform'
  origin: 'transformOrigin'
  transformStyle: 'transformStyle'

for key, value of css
  css[key] = testProp value
  unless css[key]
    hasSupport = false
    break


class window.Maskew

  constructor: (@el, @angle, @options = {}) ->
    return @el unless hasSupport
    return new Maskew @el, @angle unless @ instanceof Maskew

    @options.interactive or= false
    @options.anchor or= 'top'
    @options.showElement or= false

    contents = @el.cloneNode true
    elStyle = window.getComputedStyle @el
    xMetrics = ['width', 'paddingLeft', 'paddingRight', 'borderLeftWidth', 'borderRightWidth']
    yMetrics = ['height', 'paddingTop', 'paddingBottom', 'borderTopWidth', 'borderBottomWidth']
    @width = 0
    @width += getMetric elStyle, key for key in xMetrics
    @height = 0
    @height += getMetric elStyle, key for key in yMetrics

    @outerMask = document.createElement 'div'
    @outerMask.style.padding = '0'
    @outerMask.style.width = @width + 'px'
    @outerMask.style.height = @height + 'px'
    @outerMask.style.overflow = 'hidden'

    if @options.showElement
      @el.style.display = 'block'
      @outerMask.style.display = @options.showElement
    else
      @outerMask.style.display = elStyle.display

    @innerMask = @outerMask.cloneNode false
    @innerMask.style[css.origin] = 'bottom left'

    @holder = @outerMask.cloneNode false
    @holder.style[css.origin] = 'inherit'

    for side in ['Top', 'Right', 'Bottom', 'Left'] then do (key = 'margin' + side) =>
      @outerMask.style[key] = elStyle[key]

    @el.style.margin = '0'

    @el.parentNode.insertBefore @outerMask, @el
    @holder.appendChild @el
    @innerMask.appendChild @holder
    @outerMask.appendChild @innerMask

    if @options.interactive
      @outerMask.style.cursor = 'ew-resize'
      eventPairs = [['TouchStart', 'MouseDown'], ['TouchMove', 'MouseMove'], ['TouchEnd', 'MouseUp']]
      for eventPair in eventPairs
        for eString in eventPair then do (fn = '_on' + eventPair[0]) =>
          @outerMask.addEventListener eString.toLowerCase(), @[fn], false

    @skew @angle


  skew: (angle) =>
    angle ?= @_dragAngle or 0
    angle = 0 if angle < 0
    sine = sin rad angle
    cosine = cos rad angle
    tlX = @height * sine
    tlY = @height * cosine
    adj = @width - tlX
    hyp = adj / cosine
    opp = sine * hyp
    yOffset = round @height - tlY + opp

    @outerMask.style.height = round(tlY - opp) + 'px'
    @innerMask.style.width = round(hyp) + 'px'
    @innerMask.style[css.transform] = transform -yOffset, angle
    @holder.style[css.transform] = transform 0, -angle

    @el.style[css.transform] = transform yOffset, 0 if @options.anchor is 'bottom'


  _onTouchStart: (e) =>
    e.preventDefault()
    if e.type is 'mousedown'
      @_x1 = e.pageX
    else if e.type is 'touchstart'
      @_x1 = e.touches[0].pageX

    @_xDelta = 0


  _onTouchMove: (e) =>
    e.preventDefault()
    if e.type is 'mousemove'
      return if e.which isnt 1
      @_xDelta = e.pageX - @_x1
    else if e.type is 'touchmove'
      @_xDelta = e.touches[0].pageX - @_x1

    @_dragAngle = @angle + @_xDelta / abs 3 + @_xDelta / @width
    @skew()


  _onTouchEnd: (e) =>
    @angle = @_dragAngle or @angle


  @VERSION: '0.1.0'


if window.jQuery? or window.$?.data?

  $::maskew = (angle, options) ->

    return @ unless hasSupport

    if typeof angle is 'object'
      options = angle
      angle = 0
    else if angle is 'skew' and typeof options is 'number'

      for el in @
        instance = $.data el, 'maskew'
        instance.skew.call instance, options

      return @

    for el in @
      return instance if (instance = $.data el, 'maskew')
      $.data el, 'maskew', new Maskew el, angle, options

    @

