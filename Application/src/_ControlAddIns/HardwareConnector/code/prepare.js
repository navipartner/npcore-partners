import * as fs from "fs";

if (!['dev', 'prod'].includes(process.argv[2])) {
  console.log('invalid input');
  process.exit(0);
}

const production = (process.argv[2] === 'prod')

if (production) {
  fs.copyFile("./dist/assets/bundle.js", "../bundle.js", (error) => { if (error) throw error });
  fs.copyFile("./dist/assets/bundle.css", "../bundle.css", (error) => { if (error) throw error });
  console.log("Copied bundle.js and bundle.css from /dist/ to AL controladdin folder");
}