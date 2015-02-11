desc 'Run JS tests'
task js: [:jslint, 'jasmine:ci']
