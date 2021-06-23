import React, { useState } from "react";
import "./styles/index.scss";
import { DragonglassPage } from "./dragonglass-ui/controls/DragonglassPage";
import { DragonglassManager } from "./DragonglassManager";
import { Transcendence } from "./components/renderers/classic/Transcendence";

window.focus();

export default ({ uiSwitcher }) => {
  const [ui, update] = useState("transcendence");
  uiSwitcher.switchUi = () => update("dragonglass"); // TODO: this is just temporary, while developing with Dragonglass mock

  return (
    <div className={`body ${ui}`}>
      <DragonglassManager />
      {{
        transcendence: () => <Transcendence />,
        dragonglass: () => <DragonglassPage />,
      }[ui]()}
    </div>
  );
};
