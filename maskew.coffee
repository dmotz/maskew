# Maskew
# Skew the shapes of DOM elements
# Dan Motzenbecker
# http://oxism.com
# 0.1.2
# MIT License


{cos, sin, PI, abs, round} = Math

rad = (deg) -> deg * PI / 180

getMetric = (style, key) -> parseInt style[key], 10

transform = (y, angle) -> "translate3d(0, #{ y }px, 0) rotate3d(0, 0, 1, #{ angle }deg)"

testProp = (prop) ->
  return prop if testEl.style[prop]?
  capProp = prop.charAt(0).toUpperCase() + prop.slice 1
  for prefix in prefixList
    return key if testEl.style[(key = prefix + capProp)]?
  false

hasSupport = true
testEl = document.createElement 'div'
prefixList = ['webkit', 'moz', 'o', 'ms']
css =
  transform:      'transform'
  origin:         'transformOrigin'
  transformStyle: 'transformStyle'

for key, value of css
  css[key] = testProp value
  unless css[key]
    hasSupport = false
    break


class window.Maskew

  constructor: (@_el, @angle, @_options = {}) ->
    return @ unless hasSupport
    return new Maskew @_el, @angle unless @ instanceof Maskew

    @_options.touch       or= false
    @_options.anchor      or= 'top'
    @_options.showElement or= false
    @_options.className   or= 'maskew'

    contents = @_el.cloneNode true
    elStyle  = window.getComputedStyle @_el
    xMetrics = ['width', 'paddingLeft', 'paddingRight', 'borderLeftWidth', 'borderRightWidth']
    yMetrics = ['height', 'paddingTop', 'paddingBottom', 'borderTopWidth', 'borderBottomWidth']
    @_width  = @_height = 0
    @_width  += getMetric elStyle, key for key in xMetrics
    @_height += getMetric elStyle, key for key in yMetrics

    @_outerMask = document.createElement 'div'
    @_outerMask.style.padding  = '0'
    @_outerMask.style.width    = @_width  + 'px'
    @_outerMask.style.height   = @_height + 'px'
    @_outerMask.style.overflow = 'hidden'

    if @_options.showElement
      @_el.style.display = 'block'
      @_outerMask.style.display = @_options.showElement
    else
      @_outerMask.style.display = elStyle.display

    @_innerMask = @_outerMask.cloneNode false
    @_innerMask.style[css.origin] = 'bottom left'

    @_holder = @_outerMask.cloneNode false
    @_holder.style[css.origin] = 'inherit'

    for side in ['Top', 'Right', 'Bottom', 'Left'] then do (key = 'margin' + side) =>
      @_outerMask.style[key] = elStyle[key]

    @_el.style.margin = '0'
    @_el.parentNode.insertBefore @_outerMask, @_el
    @_holder.appendChild @_el
    @_innerMask.appendChild @_holder
    @_outerMask.appendChild @_innerMask
    @_outerMask.className = @_options.className

    @setTouch true if @_options.touch
    @skew @angle


  skew: (angle) =>
    angle  ?= @_dragAngle or 0
    angle   = 0 if angle < 0
    sine    = sin (rads = rad angle)
    cosine  = cos rads
    tlX     = @_height * sine
    tlY     = @_height * cosine
    adj     = @_width - tlX
    adj     = 0 if adj < 0
    hyp     = adj / cosine
    opp     = sine * hyp
    yOffset = round @_height - tlY + opp

    @_outerMask.style.height = round(tlY - opp) + 'px'
    @_innerMask.style.width  = round(hyp) + 'px'
    @_innerMask.style[css.transform] = transform -yOffset, angle
    @_holder.style[css.transform]    = transform 0, -angle

    @_el.style[css.transform] = transform yOffset, 0 if @_options.anchor is 'bottom'
    @


  setTouch: (toggle) ->
    if toggle
      return if @_touchEnabled
      listenFn = 'addEventListener'
      @_outerMask.style.cursor = 'ew-resize'
      @_touchEnabled = true
    else
      return unless @_touchEnabled
      listenFn = 'removeEventListener'
      @_outerMask.style.cursor = 'default'
      @_touchEnabled = false

    eventPairs = [['TouchStart', 'MouseDown'], ['TouchMove', 'MouseMove'],
                  ['TouchEnd', 'MouseUp'], ['TouchLeave', 'MouseOut']]
    for eventPair in eventPairs
      for eString in eventPair then do (fn = '_on' + eventPair[0]) =>
        @_outerMask[listenFn] eString.toLowerCase(), @[fn], false
    @


  destroy: =>
    parent = @_outerMask.parentNode
    parent.insertBefore @_el, @_outerMask
    parent.removeChild @_outerMask
    $.data @_el, 'maskew', null if $
    @[k] = null for k of @
    null


  _onTouchStart: (e) =>
    e.preventDefault()
    @_touchStarted = true
    if e.type is 'mousedown'
      @_x1 = e.pageX
    else if e.type is 'touchstart'
      @_x1 = e.touches[0].pageX

    @_xDelta = 0


  _onTouchMove: (e) =>
    return unless @_touchStarted
    e.preventDefault()
    if e.type is 'mousemove'
      @_xDelta = e.pageX - @_x1
    else if e.type is 'touchmove'
      @_xDelta = e.touches[0].pageX - @_x1

    @_dragAngle = @angle + @_xDelta / abs 3 + @_xDelta / @_width
    @skew()


  _onTouchEnd: =>
    @_touchStarted = false
    @angle = @_dragAngle or @angle


  _onTouchLeave: => @_onTouchEnd()


  @VERSION: '0.1.2'

  @isSupported: hasSupport


if window.jQuery? or window.$?.data?

  $::maskew = (angle, options) ->

    return @ unless hasSupport

    if typeof angle is 'object'
      options = angle
      angle = 0
    else if typeof angle is 'string'

      for el in @
        return @ unless (instance = $.data el, 'maskew')
        return @ unless typeof instance[angle] is 'function'
        instance[angle].call instance, options

      return @

    for el in @
      return instance if (instance = $.data el, 'maskew')
      $.data el, 'maskew', new Maskew el, angle, options

    @

