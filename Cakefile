{exec, spawn} = require 'child_process'

output = (data) ->
  console.log data.toString()


task 'build', 'Build and minify Maskew from coffee source', ->
  exec 'coffee -c maskew.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr

    exec 'uglifyjs -o maskew.min.js maskew.js', (err, stdout, stderr) ->
      throw err if err
      console.log stdout, stderr

  exec 'coffee -c test/main.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr


task 'watch', 'Build Maskew continuously', ->
  coffee = spawn 'coffee', ['-wc', 'maskew.coffee']
  tests = spawn 'coffee', ['-wc', 'test/main.coffee']
  coffee.stdout.on 'data', output
  coffee.stderr.on 'data', output
  tests.stdout.on 'data', output
  tests.stderr.on 'data', output

