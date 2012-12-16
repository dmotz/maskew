#![Maskew](http://dmotz.github.com/maskew/demo/logo.png)
#[Maskew](http://dmotz.github.com/maskew)
#### Skew the shapes of elements without distorting their contents

[Dan Motzenbecker](http://oxism.com), MIT License

[@dcmotz](http://twitter.com/dcmotz)

### Features
+  < 5k
+  mobile friendly
+  no dependencies
+  optional jQuery support

###[Demos](http://dmotz.github.com/maskew)

### Usage

Use it:
```javascript
var maskew = new Maskew(document.getElementById('skew-me'), angle);
```

With jQuery:
```javascript
var $maskew = $('#skew-me').maskew(angle);
```

Add some touch:
```javascript
// from the start:

var touchMe = new Maskew(document.getElementById('skew-me'), angle, { touch: true });

// or:

maskew.setTouch(true);

// disable touch:

maskew.setTouch(false);
```

