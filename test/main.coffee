# Maskew
# Mocha test suite
# Dan Motzenbecker

styleFetcher = (el) -> do (style = {}) ->
  style[k] = v for k, v of window.getComputedStyle el
  (key) -> style[key]


getRotation = (el) ->
  parseFloat el.style[transformKey].match(/(-?\d+)deg/i)?[0]


getY = (el) ->
  parseFloat el.style[transformKey].match(/translate3d\(\d+px\,\s?(-?\d+)px/i)?[1]


testPresence = (el) ->
  while el = el.parentNode
    return true if el is document
  false


testDiv = document.createElement 'div'
testDiv.className = 'maskew-test'
transformKey = do ->
  return 'transform' if testDiv.style.transform?
  for prefix in ['webkit', 'Moz', 'o', 'ms']
    return key if testDiv.style[(key = prefix + 'Transform')]?

testDiv.style.width           = '200px'
testDiv.style.height          = '200px'
testDiv.style.margin          = '20px'
testDiv.style.padding         = '20px'
testDiv.style.backgroundColor = '#fff'
testDiv2 = testDiv.cloneNode false
testDiv2.className = 'maskew-test2'
document.body.appendChild testDiv
document.body.appendChild testDiv2
originalParent = testDiv.parentNode
cleanStyle     = styleFetcher testDiv

testMaskew = new Maskew testDiv
dirtyStyle = styleFetcher testMaskew._outerMask


describe 'Maskew', ->

  describe '#constructor()', ->

    it 'should return an instance of Maskew', ->
      expect(testMaskew instanceof Maskew).to.equal true

    it 'should insert an element into the document', ->
      expect(testPresence testMaskew._outerMask).to.equal true

    it 'should insert an element in the same place as the target', ->
      expect(testMaskew._outerMask.parentNode).to.equal originalParent

    it 'should create an element of the same dimensions', ->
      expect(dirtyStyle 'width').to.equal  testDiv.clientWidth  + 'px'
      expect(dirtyStyle 'height').to.equal testDiv.clientHeight + 'px'

    it 'should create an element with the same margins and padding', ->
      for side in ['Top', 'Right', 'Bottom', 'Left']
        margin  = 'margin' + side
        padding = 'padding' + side
        expect(dirtyStyle margin).to.equal cleanStyle margin
        expect(testMaskew._el.style[padding]).to.equal cleanStyle padding


  describe '#skew()', ->

    it 'should skew an element to a given angle', ->
      testMaskew.skew 20
      expect(getRotation testMaskew._innerMask).to.equal 20

    it 'should keep inner contents upright', ->
      expect(getRotation testMaskew._holder).to.equal -20

    it 'should shift contents within the view mask based on angle', ->
      expect(getY testMaskew._innerMask).to.equal -72
      testMaskew.skew 10
      expect(getY testMaskew._innerMask).to.equal -39

    it 'should narrow the mask width based on the given angle', ->
      expect(parseInt testMaskew._innerMask.style.width, 10).to.equal 201
      testMaskew.skew 30
      expect(parseInt testMaskew._innerMask.style.width, 10).to.equal 139

    it 'should shorten the mask height based on the given angle', ->
      expect(parseInt testMaskew._outerMask.style.height, 10).to.equal 139
      testMaskew.skew 5
      expect(parseInt testMaskew._outerMask.style.height, 10).to.equal 220

    it 'should revert to 0 degrees when given a negative angle', ->
      testMaskew.skew -20
      expect(getRotation testMaskew._innerMask).to.equal 0


  describe '#destroy()', ->
    el = testMaskew._outerMask

    it 'should remove the Maskew element from the document', ->
      testMaskew.destroy()
      expect(testPresence el).to.equal false

    it 'should set all the object attributes to null', ->
      allNull = do ->
        for k, v of testMaskew
          return false if v isnt null
        true
      expect(allNull).to.equal true


  describe '#$.fn.maskew()', ->
    $testMaskew = $('.maskew-test2').maskew()

    it 'should return a jQuery object', ->
      expect($testMaskew instanceof jQuery).to.equal true

    it 'should stash a reference to the Maskew instance in the data cache', ->
      expect($testMaskew.maskew()).to.equal $testMaskew.maskew()

    it 'should return its Maskew instance by calling it with no arguments', ->
      expect($testMaskew.maskew() instanceof Maskew).to.equal true

    it 'should proxy Maskew methods as string arguments', ->
      $testMaskew.maskew 'skew', 5
      expect(parseInt $testMaskew.maskew()._outerMask.style.height, 10).to.equal 220
      $testMaskew.maskew 'setTouch', true
      expect($testMaskew.maskew()._outerMask.style.cursor).to.equal 'ew-resize'


