import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { defineThemeAction } from "../../redux/actions/themeActions";
import { ThemeType } from "../../dragonglass-themes/ThemeType";
import { ThemeTargetType, themeTargetTypesNav, themeTargetTypeTags } from "../../dragonglass-themes/ThemeTargetType";
import { viewTypeToTagMap } from "../../dragonglass-themes/ViewType";

const makeSureThemeTargetTypeMatches = (theme, expectedTargetType, dependencyType) => {
    if (theme.themeTargetType !== expectedTargetType)
        return true;
    console.warn(`[FrontEndAsync.ConfigureTheme] Dependency type ${dependencyType} can only be applied to target type ${themeTargetTypesNav[theme.themeTargetType]}.`);
    return false;
};

const addPayloadArrayPropertyFromTheme = (payload, prop, theme) => {
    payload[prop] = payload[prop] || [];
    payload[prop].push(theme.content);
}

export class ConfigureTheme extends FrontEndAsyncRequestHandler {
    handle(request) {
        if (!request.Content || !request.Content.theme || !request.Content.theme.length)
            return;

        const { theme } = request.Content;
        const payload = {};
        theme.forEach(t => {
            switch (t.type) {
                case ThemeType.LOGO:
                    payload.logo = t.content;
                    return;
                case ThemeType.BACKGROUND:
                    payload.background = payload.background || {};
                    payload.background[themeTargetTypeTags[t.targetType]] = payload.background[themeTargetTypeTags[t.targetType]] || {};
                    switch (t.targetType) {
                        case ThemeTargetType.CLIENT:
                            payload.background[themeTargetTypeTags[t.targetType]] = t.content;
                            return;
                        case ThemeTargetType.VIEW:
                            payload.background[themeTargetTypeTags[t.targetType]][t.view] = t.content;
                            return;
                        case ThemeTargetType.VIEWTYPE:
                            payload.background[themeTargetTypeTags[t.targetType]][viewTypeToTagMap[t.viewType]] = t.content;
                            return;
                    }

                    return;
                case ThemeType.STYLESHEET:
                    if (!makeSureThemeTargetTypeMatches(t, ThemeTargetType.CLIENT, "Stylesheet"))
                        return;
                    addPayloadArrayPropertyFromTheme(payload, "styles", t);
                    return;
                case ThemeType.JAVASCRIPT:
                    if (!makeSureThemeTargetTypeMatches(t, ThemeTargetType.CLIENT, "JavaScript"))
                        return;
                    addPayloadArrayPropertyFromTheme(payload, "scripts", t);
                    return;
            }
        });
        StateStore.dispatch(defineThemeAction(payload));
    }
}
