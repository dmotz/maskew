{exec, spawn} = require 'child_process'

print = (fn) ->
  (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr
    fn?()


startWatcher = (bin, args) ->
  watcher = spawn bin, args?.split ' '
  watcher.stdout.pipe process.stdout
  watcher.stderr.pipe process.stderr


task 'build', 'compile and minify library, build tests, build demo assets', ->
  exec 'coffee -mc maskew.coffee', print ->
    exec 'uglifyjs -o maskew.min.js maskew.js', print()
  exec 'coffee -mc test/main.coffee', print()
  exec 'stylus -u nib demo/demo.styl', print()


task 'watch', 'compile continuously', ->
  startWatcher.apply @, pair for pair in [
    ['coffee', '-mwc maskew.coffee']
    ['coffee', '-mwc test/main.coffee']
    ['stylus', '-u nib -w demo/demo.styl']
  ]

