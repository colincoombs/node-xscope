module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffeelint:
      all:
        ['src/*.coffee']
        
    coffee:
      all:
        files: [
          expand: true
          flatten: true
          src: ['src/*.coffee']
          dest: 'lib/'
          ext: '.js'
        ]
        options:
          join: false
          sourceMap: true
 
    simplemocha:
      all:
        options:
          interface: 'bdd'
          reporter: 'spec'
        src:
          'test/*.coffee'
      cov:
        options:
          interface: 'bdd'
          reporter: 'html-cov'
        src:
          'test/*.coffee'

    coffeecov:
      cov:
        src: 'src'
        dest: 'src-cov'
        
    exec:
      doc:
        command: 'codo'
      plantuml:
        command: 'plantuml -tpng doc/plantuml -o ../codo/extra/plantuml'
  
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-coffeecov'
  
  grunt.registerTask 'prepublish', [
    'test'
    'exec:plantuml'
    'exec:doc'
  ]
  
  grunt.registerTask 'coverage', [
    'coffeecov'
    'simplemocha:cov'
  ]

  grunt.registerTask 'test', [
    'coffeelint:all'
    'coffee:all'
    'simplemocha:all'
  ]
