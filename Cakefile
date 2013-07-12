{exec, spawn} = require 'child_process'

output = (data) -> console.log data.toString()

print  = (fn) ->
  (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr
    fn?()


task 'build', 'compile and minify library, build tests, build demo assets', ->
  exec 'coffee -mc maskew.coffee', print ->
    exec 'uglifyjs -o maskew.min.js maskew.js', print()
  exec 'coffee -mc test/main.coffee', print()
  exec 'stylus -u nib demo/demo.styl', print()


task 'watch', 'compile continuously', ->
  coffee = spawn 'coffee', '-mwc maskew.coffee'.split ' '
  tests  = spawn 'coffee', '-mwc test/main.coffee'.split ' '
  stylus = spawn 'stylus', '-u nib -w demo/demo.styl'.split ' '

  for proc in [coffee, tests, stylus]
    proc.stdout.on 'data', output
    proc.stderr.on 'data', output

