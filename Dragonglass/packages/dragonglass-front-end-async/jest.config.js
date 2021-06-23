const package = require("./package.json");
const base = require("../../jest.config.base.js");

module.exports = {
    ...base,

    name: package.name,
    displayName: package.displayName,
};
