import React from "react";
import Alert from "./Alert/Alert";
import ALERT_MESSAGE_TYPES from "./Alert/AlertMessageTypes";
// import { Background } from "./Background";
import { Body } from "./Body";
import { Drawer } from "./drawer/Drawer";
import { Navigation } from "./navigation/Navigation";
import { Toolbar } from "./toolbar/Toolbar";

export const View = ({ layout }) => {
  if (!layout.navigation || !layout.navigation.length) {
    return (
      <Alert
        messageType={ALERT_MESSAGE_TYPES.DANGER}
        originFile="View.js"
        originProperties={["layout.navigation"]}
      />
    );
  }

  return (
    <div className="mobile-view">
      <Drawer menu={layout.drawer} />
      <Toolbar pages={layout.pages} />
      {/* <Background /> */}
      <Body pages={layout.pages} />
      <Navigation buttons={layout.navigation} />
    </div>
  );
};
