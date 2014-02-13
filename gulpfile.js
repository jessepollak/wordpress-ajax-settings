var gulp = require('gulp'),
    gutil = require('gulp-util'),
    sass = require('gulp-sass'),
    autoprefixer = require('gulp-autoprefixer'),
    minifycss = require('gulp-minify-css'),
    uglify = require('gulp-uglify'),
    rename = require('gulp-rename'),
    clean = require('gulp-clean'),
    concat = require('gulp-concat'),
    notify = require('gulp-notify'),
    cache = require('gulp-cache'),
    livereload = require('gulp-livereload'),
    coffee = require('gulp-coffee'),
    coffeelint = require('gulp-coffeelint'),
    imagemin = require('gulp-imagemin'),
    lr = require('tiny-lr'),
    filter = require('gulp-filter'),
    server = lr();

gulp.task('default', function() {
    gulp.start('sass', 'coffee', 'php', 'images');
});

gulp.task('coffee', function() {
    return gulp.src('src/coffee/**/*.coffee')
        .pipe(coffeelint({ 
            "indentation": {
                "name": "indentation",
                "value": 4,
                "level": "error"
            }
        }))
        .pipe(coffeelint.reporter())
        .pipe(coffee({bare: true})).on('error', gutil.log)
        .pipe(rename({suffix: '.min'}))
        .pipe(uglify({ sourceMap: true }))
        .pipe(concat("ajax-settings.min.js"))
        .pipe(gulp.dest('dist/js/'))
        .pipe(livereload(server))
        .pipe(notify({ message: "Coffeescript compiled." }));
});

gulp.task('sass', function() {
    return gulp.src('src/sass/**/*.scss')
        .pipe(sass({ style: 'expanded' }))
        .pipe(autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4'))
        .pipe(minifycss())
        .pipe(rename({suffix: '.min'}))
        .pipe(gulp.dest('dist/css/'))
        .pipe(livereload(server))
        .pipe(notify({ message: "Styles compiled."} ));
});

gulp.task('images', function() {
    return gulp.src('src/img/**/*')
        .pipe(imagemin({ optimizationLevel: 3, progressive: true, interlaced: true}))
        .pipe(gulp.dest('dist/img/'))
        .pipe(livereload(server))
        .pipe(notify({message: "Images minified."}));
});

gulp.task('php', function() {
    return gulp.src('ajax-settings.php')
        .pipe(gulp.dest('dist/'));
});

gulp.task('development', function() {
    if (process.env.AJAX_SETTINGS_COPY_DIR) {
        return gulp.src('dist/**/*')
            .pipe(gulp.dest(process.env.AJAX_SETTINGS_COPY_DIR));
    }
});

gulp.task('watch', function() {
    server.listen(35729, function(err) {
        if (err) {
            return gutil.log(err);
        }
    });
    
    gulp.watch('src/img/*', ['images'])
    gulp.watch('src/**/*.coffee', ['coffee']);
    gulp.watch('src/**/*.scss', ['sass']);
    gulp.watch('**/*.php', ['php']);
    gulp.watch('dist/**/*', ['development']);
});