gulp = require('gulp')
$ = require('gulp-load-plugins') {}

gulp.task 'default', ['test']

gulp.task 'test', ['lint-json', 'lint-coffee', 'test-mocha']

gulp.task 'lint-json', ->
  gulp.src('package.json')
    .pipe($.jsonlint())

gulp.task 'lint-coffee', ->
  gulp.src(['src/**/*.coffee', 'test/**/*.coffee'])
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter('coffeelint-stylish'))

gulp.task 'test-mocha', ->
  gulp.src(['test/**/*.coffee'])
    .pipe($.mocha())
