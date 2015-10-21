module.exports = (grunt) ->

    # Project configuration
    grunt.initConfig({

        pkg: grunt.file.readJSON('package.json')

        coffee:
            options:
                join: true

            build:
                files:
                    'src/tmp/html-string.js': [
                        'src/namespace.coffee'
                        'src/strings.coffee'
                        'src/tags.coffee'
                        'src/characters.coffee'
                    ]

            spec:
                files:
                    'spec/spec-helper.js': 'src/spec/spec-helper.coffee'
                    'spec/html-string-spec.js': 'src/spec/html-string-spec.coffee'

        uglify:
            options:
                banner: '/*! <%= pkg.name %> v<%= pkg.version %> by <%= pkg.author.name %> <<%= pkg.author.email %>> (<%= pkg.author.url %>) */\n'
                mangle: false

            build:
                src: 'build/html-string.js'
                dest: 'build/html-string.min.js'

        concat:
            build:
                src: [
                    'external/fsm.js'
                    'src/tmp/html-string.js'
                ]
                dest: 'build/html-string.js'

        clean:
            build: ['src/tmp']

        jasmine:
            fsm:
                src: ['build/html-string.js']
                options:
                    specs: 'spec/html-string-spec.js'
                    helpers: 'spec/spec-helper.js'

        watch:
            build:
                files: ['src/*.coffee']
                tasks: ['build']

            spec:
                files: ['src/spec/*.coffee']
                tasks: ['spec']
    })

    # Plug-ins
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-contrib-jasmine'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    # Tasks
    grunt.registerTask 'build', [
        'coffee:build'
        'concat:build'
        'uglify:build'
        'clean:build'
    ]

    grunt.registerTask 'spec', [
        'coffee:spec'
    ]

    grunt.registerTask 'watch-build', ['watch:build']
    grunt.registerTask 'watch-spec', ['watch:spec']

