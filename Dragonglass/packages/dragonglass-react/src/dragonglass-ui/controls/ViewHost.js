import React, { Component } from "react";
import { View } from "./View";
import { Panel } from "./Panel";
import { TextBox } from "./TextBox";
import { InfoBox } from "./InfoBox";
import { ButtonMenu } from "./buttonmenu/ButtonMenu";
import DataGrid from "./datagrid/DataGrid";

const template = {
  caption: 10,
  quantity: 12,
  unitPrice: 15,
  discountPercent: 19,
  discountAmount: 20,
  lineAmount: 31,
};

export class ViewHost extends Component {
  render() {
    return (
      <div className="l-views">
        <View>
          <Panel direction="l-vertical">
            <TextBox label="Enter or scan item number" />
            <DataGrid dataSourceName="BUILTIN_SALELINE" template={template} />
            <InfoBox />
          </Panel>
          <Panel>
            <ButtonMenu />
          </Panel>
        </View>
      </div>
    );
  }
}
