(() => {
    const getImageResource = Microsoft.Dynamics.NAV.GetImageResource;

    const pathToThisFile = "/Scripts";
    const thisFileName = "GetImageResource.js";

    function convertToRegExp(input) {
        return input.replace("/", "\\/").replace(".", "\\.");
    }

    function getThisScriptUrl() {
        const regex = new RegExp(`Resources\\/ExtractedResources\\/[0-9A-Fa-f]+\\/(.*)${convertToRegExp(`${pathToThisFile}\\/${thisFileName}`)}\?`);
        const scripts = document.getElementsByTagName("script");
        for (let script of scripts) {
            let match = script.src.match(regex);
            if (match && match.length === 2) {
                return match[1];
            }
        }
    }

    const relativePath = getThisScriptUrl();
    Microsoft.Dynamics.NAV.GetImageResource = path => getImageResource(`${relativePath}/${path}`);
})();
