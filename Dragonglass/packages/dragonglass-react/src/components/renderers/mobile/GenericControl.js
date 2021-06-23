import React from "react";
import { InvalidControl } from "../../InvalidControl";
import LoginPad from "./login/LoginPad";
import { Menu } from "./menu/Menu";
import { Layout } from "./Layout";
import { DataGrid } from "./datagrid/DataGrid";
import { InfoBox } from "./infobox/InfoBox";
import { MenuButtonGridClickHandler } from "../../../dragonglass-click-handlers/grid/MenuButtonGridClickHandler";

const renderers = {
  loginpad: (layout) => <LoginPad layout={layout} />,
  menu: (layout) => (
    <Menu layout={layout} clickHandler={new MenuButtonGridClickHandler()} />
  ),
  datagrid: (layout) => (
    <DataGrid layout={layout} clickHandler={new MenuButtonGridClickHandler()} />
  ),
  infobox: (layout) => <InfoBox layout={layout} />,
};

export const GenericControl = ({ control }) => {
  const { type, ...layout } = control;

  const renderer = renderers[type];
  if (typeof renderer !== "function") {
    return <InvalidControl control={control} />;
  }

  return <Layout layout={layout}>{renderers[type](layout)}</Layout>;
};
