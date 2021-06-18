module.exports = {
    transform: {
        "^.+\\.ts$": "ts-jest"
    },
    testRegex: "(/test/.*.(test|spec)).(jsx?|tsx?)$",
    moduleFileExtensions: [
        "ts",
        "tsx",
        "js",
        "jsx",
        "json"
    ],
    collectCoverage: true,
    coveragePathIgnorePatterns: [
        "(test/.*.mock).(jsx?|tsx?)$",
        "(test/mock/.*).(jsx?|tsx?)$",
    ],
    coverageDirectory: "<rootDir>/coverage/",
    verbose: true
};
