{exec, spawn} = require 'child_process'

output = (data) ->
  console.log data.toString()

print = (fn) ->
  (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr
    fn?()


task 'build', 'compile and minify library and tests', ->
  exec 'coffee -mc maskew.coffee', print ->
    exec 'uglifyjs -o maskew.min.js maskew.js', print()
  exec 'coffee -mc test/main.coffee', print()


task 'watch', 'compile continuously', ->
  coffee = spawn 'coffee', ['-mwc', 'maskew.coffee']
  tests  = spawn 'coffee', ['-mwc', 'test/main.coffee']
  for proc in [coffee, tests]
    proc.stdout.on 'data', output
    proc.stderr.on 'data', output

