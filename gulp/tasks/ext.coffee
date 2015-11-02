gulp = require('gulp-help') require 'gulp'
$ = do require 'gulp-load-plugins'
config = require '../config'
paths = require '../paths'
util = require '../util'


gulp.task 'ext', false, ->
  for key of config
    if not config[key].ext
      continue
    gulp.src config[key].ext
    .pipe $.plumber errorHandler: util.onError
    .pipe $.concat key+'_ext.js'
    .pipe do $.uglify
    .pipe $.size {title: 'Minified ext libs'}
    .pipe gulp.dest "#{paths.static.min}/script"


gulp.task 'ext:dev', false, ->
  for key of config
    if not config[key].ext
      continue
    gulp.src config[key].ext
    .pipe $.plumber errorHandler: util.onError
    .pipe do $.sourcemaps.init
    .pipe $.concat key+'_ext.js'
    .pipe do $.sourcemaps.write
    .pipe gulp.dest "#{paths.static.dev}/script"
