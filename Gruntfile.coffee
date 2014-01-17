module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      all:
        src: ['src/*.coffee']
        dest: 'lib/xscope.js'
        options: 
          join: true
          sourceMap: true
      
    coffeelint:
      all:
        ['src/*.coffee']
        
    exec:
      doc:
        command: 'codo'
      plantuml:
        command: 'plantuml -tpng doc/plantuml -o ../codo/extra/plantuml'
  
    simplemocha:
      all:
        options:
          interface: 'bdd'
          reporter: 'spec'
        src:
          'test/*.coffee'
          
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-simple-mocha'

  grunt.registerTask 'prepublish', [
    'test', 
    'exec:plantuml',
    'exec:doc'
  ]
  
  grunt.registerTask 'test', [
    'coffeelint:all',
    'coffee:all',
    'simplemocha:all'
  ]
