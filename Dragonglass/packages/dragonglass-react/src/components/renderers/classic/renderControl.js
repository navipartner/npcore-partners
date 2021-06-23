import React from "react";
import Panel from "../../Panel";
import Caption from "../../Caption";
import Image from "../../Image";
import InfoBox from "../../InfoBox";
import LoginPad from "../../LoginPad";
import ButtonGrid from "../../ButtonGrid";
import Button from "../../Button";
import Grid from "../../Grid/Grid";
import Input from "../../Input";
import Layout from "../../Layout";
import CartView from "../../Cart/CartView";
import { MenuButtonGridClickHandler } from "../../../dragonglass-click-handlers/grid/MenuButtonGridClickHandler";
import textEnter from "../../../dragonglass-textenter/textEnter";
import TimeoutHandler from "../../TimeoutHandler";
import RestaurantView from "../../Restaurant/RestaurantView";
import StateBoundPanel from "../../StateBoundPanel";
import RestaurantLocationSelection from "../../Restaurant/RestaurantLocationSelection";
import WaiterPadsList from "../../Restaurant/WaiterPadsList";
import ActiveTableWaiterPads from "../../Restaurant/ui/ActiveTableWaiterPads";
import WaiterPadStatusList from "../../Restaurant/ui/statuses/WaiterPadStatusList";
import TableStatusList from "../../Restaurant/ui/statuses/TableStatusList";
import TableInfo from "../../Restaurant/ui/TableInfo";
import NumberOfGuests from "../../Restaurant/ui/NumberOfGuests";
import { BalanceView } from "../../Balance/BalanceView";

const typeMap = {
  container: "panel",
};

const haveChildren = {
  panel: true,
};

const keys = {};

const wrapInLayout = (key, control, layout) => (
  <Layout key={key} layout={layout} style={layout.style}>
    {control}
  </Layout>
);

const renderers = {
  button: (control, key, defaultLayoutOptions) => (
    <Button
      defaultLayoutOptions={defaultLayoutOptions}
      key={key}
      id={key}
      additionalClassNames={control.additionalClassNames}
      caption={control.caption}
      icon={control.icon}
      onClick={control.onClick}
      layout={control}
      action={control.action}
    />
  ),
  panel: (control, key, defaultLayoutOptions, children) =>
    control.bindToState ? (
      <StateBoundPanel
        defaultLayoutOptions={defaultLayoutOptions}
        key={key}
        id={key}
        layout={control}
        bindToState={control.bindToState}
      >
        {children}
      </StateBoundPanel>
    ) : (
      <Panel defaultLayoutOptions={defaultLayoutOptions} key={key} id={key} layout={control}>
        {children}
      </Panel>
    ),
  logo: (control, key, defaultLayoutOptions) =>
    wrapInLayout(
      key,
      <Image defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} imageId="logo" />,
      control
    ),
  image: (control, key, defaultLayoutOptions) =>
    wrapInLayout(
      key,
      <Image defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} src={control.src} />,
      control
    ),
  label: (control, key, defaultLayoutOptions) =>
    wrapInLayout(
      key,
      <Caption
        defaultLayoutOptions={defaultLayoutOptions}
        key={key}
        id={key}
        caption={control.caption}
        layout={control}
      />,
      control
    ),
  captionbox: (control, key, defaultLayoutOptions) =>
    wrapInLayout(
      key,
      <InfoBox defaultLayoutOptions={defaultLayoutOptions} id={key} binding={control.binding} />,
      control
    ),
  loginpad: (control, key, defaultLayoutOptions) =>
    wrapInLayout(key, <LoginPad defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />, control),
  menu: (control, key, defaultLayoutOptions) =>
    wrapInLayout(
      key,
      <ButtonGrid
        clickHandler={new MenuButtonGridClickHandler()}
        defaultLayoutOptions={defaultLayoutOptions}
        id={key}
        layout={control}
      />,
      control
    ),
  grid: (control, key, defaultLayoutOptions) =>
    wrapInLayout(key, <Grid defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />, control),
  text: (control, key, defaultLayoutOptions) =>
    wrapInLayout(
      key,
      <Input
        textEnter={textEnter}
        defaultLayoutOptions={defaultLayoutOptions}
        id={key}
        layout={control}
        simple={true}
      />,
      control
    ),
  mobilecore: (control, key, defaultLayoutOptions) => (
    <MobileCore key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  "npre-restaurant-view": (control, key, defaultLayoutOptions) => (
    <RestaurantView key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  "npre-locations": (control, key, defaultLayoutOptions) => (
    <RestaurantLocationSelection key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  "npre-waiterpads": (control, key, defaultLayoutOptions) => (
    <WaiterPadsList key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  "npre-table-waiterpads": (control, key, defaultLayoutOptions) => (
    <ActiveTableWaiterPads key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  "npre-statuses-waiterpad": (control, key, defaultLayoutOptions) => (
    <WaiterPadStatusList key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  "npre-statuses-table": (control, key, defaultLayoutOptions) => (
    <TableStatusList key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  "npre-table-info": (control, key, defaultLayoutOptions) => (
    <TableInfo key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  "npre-number-of-guests": (control, key, defaultLayoutOptions) => (
    <NumberOfGuests key={key} defaultLayoutOptions={defaultLayoutOptions} id={key} layout={control} />
  ),
  balance: (control, key, defaultLayoutOptions) => (
    <BalanceView defaultLayoutOptions={defaultLayoutOptions} key={key} id={key} layout={control} />
  ),
};

const render = (control, key, defaults, setKey) => {
  let type = (control.type || "panel").toString().toLowerCase();
  if (typeMap.hasOwnProperty(type)) type = typeMap[type];
  const renderer = renderers.hasOwnProperty(type) ? renderers[type] : renderers.panel;

  let typeKey = control._key;
  if (setKey && !typeKey) {
    keys[key] = keys[key] || {};
    keys[key][type] = keys[key][type] || 0;
    keys[key][type]++;
    typeKey = `${key}-${type}${keys[key][type]}`;
    control._key = typeKey;
  }

  return renderer(
    control,
    typeKey,
    defaults,
    control.content && haveChildren[type] === true && getContent(control.content, typeKey, defaults)
  );
};

const getContent = (content, key, defaults) => {
  const result = [];
  if (!content || typeof content !== "object") return result;

  if (!Array.isArray(content)) content = [content];

  for (let child of content) {
    result.push(render(child, key, defaults, true));
  }

  switch (result.length) {
    case 0:
      return [];
    case 1:
      return Array.isArray(result[0]) ? result[0] : [result[0]];
    default:
      return result;
  }
};

const renderControl = (layout, defaultOptions = {}) => {
  if (!layout || typeof layout !== "object") return;

  const defaults = {
    ...defaultOptions,
    ...(typeof layout.default === "object" ? layout.default : null),
  };

  const content = [...(Array.isArray(layout.content) ? layout.content : [layout.content])];
  const result = [...getContent(content, layout.tag, defaults)];

  if (layout.cart) {
    const { cart } = layout;
    result.push(<CartView key="key_cart_view" dataSourceName={cart.dataSource} setup={cart.setup} />);
  }

  if (layout.timeout) {
    const { timeout } = layout;
    result.push(<TimeoutHandler key="key_timeout_handler" timeout={timeout} tag={layout.tag} />);
  }

  switch (result.length) {
    case 0:
      return;
    case 1:
      return result[0];
    default:
      return result;
  }
};

export default renderControl;
