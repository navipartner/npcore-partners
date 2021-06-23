import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { defineFontAction } from "../../redux/actions/fontActions";

const deprecated = {
  codes: ["FA", "FA509", "FAB509", "FAS509"],
  prefixes: ["fa-"],
  names: [/^\s*(font)\s+(awesome)/i],
};

const isDeprecated = (font) => {
  if (deprecated.codes.includes(font.Code)) {
    return true;
  }

  if (deprecated.prefixes.includes(font.Prefix)) {
    return true;
  }

  for (let regex of deprecated.names) {
    if (regex.test(font.Name)) {
      return true;
    }
  }

  return false;
};

export class ConfigureFont extends FrontEndAsyncRequestHandler {
  handle(request) {
    if (isDeprecated(request.Font)) {
      console.warn(
        `[ConfigureFont] Ignoring deprecated font "${request.Font.Name}. You should delete this font from POS Web Fonts."`
      );
      return;
    }

    StateStore.dispatch(
      defineFontAction({
        name: request.Font.Name,
        family: request.Font.FontFace,
        url: request.Font.Woff,
        prefix: request.Font.Prefix,
        style: request.Font.Css,
      })
    );
  }
}
