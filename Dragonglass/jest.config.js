const base = require("./jest.config.base.js");

module.exports = {
    ...base,
    projects:
        [
            "<rootDir>/packages/dragonglass-core",
            "<rootDir>/packages/dragonglass-nav",
            "<rootDir>/packages/dragonglass-transcendence",
            "<rootDir>/packages/dragonglass-redux",
            "<rootDir>/packages/dragonglass-front-end-async",
            "<rootDir>/packages/dragonglass-workflows",
        ],
    coverageReporters: ["lcov", "cobertura"]
};
