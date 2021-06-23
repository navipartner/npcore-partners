import React from "react";
import { PopupHost } from "./dragonglass-popup/PopupHost";
import FormatManager from "./components/FormatManager";
import LocalizationManager from "./components/LocalizationManager";
import ThemeStylesheetHost from "./dragonglass-themes/ThemeStylesheetHost";
import { StealUsernamePassword } from "./components/ChromeStealUsernamePassword";
import { WebFontManager } from "./components/WebFontManager";
import { Watermark } from "./components/Watermark";
import { NotificationsPanel } from "./dragonglass-notifications/NotificationsPanel";
import { NotificationsHost } from "./dragonglass-notifications/NotificationsHost";

// TODO: those here that return null and only serve to maintain some global internal redux substate should be taken out and should use StateStore.subscribeSelector
export const DragonglassManager = () =>
    <>
        <StealUsernamePassword />
        <PopupHost />
        <FormatManager />
        <LocalizationManager />
        <ThemeStylesheetHost />
        <Watermark />
        <WebFontManager />
        <NotificationsHost />
        <NotificationsPanel />
    </>;
