const gulp = require("gulp");
const run = require("gulp-run");
const config = require("./gulpfile.config.json");

const dragonglass = (file) =>
  `${config.pathToDragonglass}/webpack/dist/${file}`;

const build = () =>
  run("npm run build", {
    cwd: config.pathToDragonglass,
  }).exec();

const copyScript = () =>
  gulp
    .src([dragonglass("bundle.js"), dragonglass("bundle.js.map")])
    .pipe(gulp.dest(`${config.pathToControlAddIn}/Scripts`));

const copyStyles = () =>
  gulp
    .src([dragonglass("bundle.css"), dragonglass("themeDefault.css")])
    .pipe(gulp.dest(`${config.pathToControlAddIn}/StyleSheets`));

gulp.task("build", build);
gulp.task("copy", gulp.series(copyScript, copyStyles));
gulp.task("prepare", gulp.series(build, copyScript, copyStyles));
