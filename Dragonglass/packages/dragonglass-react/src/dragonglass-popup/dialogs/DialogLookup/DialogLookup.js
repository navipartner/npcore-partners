import React from "react";
import { DialogBase } from "../DialogBase";
import { DialogButtons } from "../DialogButtons";
import {
  localize,
  GlobalCaption,
} from "../../../components/LocalizationManager";
import { LookupBody } from "./LookupBody";

export class DialogLookup extends DialogBase {
  constructor(props) {
    super(props);

    this._dataSource = props.content.source;
    this._configuration = props.content.configuration;
    this._selected = [];

    this.state = {
      data: [],
      hasMore: true,
    };

    this.fetchNextDataBatch();
  }

  async fetchNextDataBatch() {
    const hasMore = await this._dataSource.fetch((data) => {
      if (this.state.data !== data) this.setState({ data });
    });

    if (this.state.hasMore !== hasMore) this.setState({ hasMore });
  }

  componentDidMount() {
    this._mounted = true;
  }

  componentWillUnmount() {
    this._mounted = false;
  }

  accept() {
    this._interface.close(
      typeof this._configuration.return === "function"
        ? this._configuration.return(this._selected)
        : this._selected
    );
  }

  dismiss() {
    this._interface.close(null);
  }

  canAcceptWithEnterKeyPress() {
    return this._confirmOnEnter;
  }

  canDismissByClickingOutside() {
    return false;
  }

  getBody() {
    const { data, hasMore } = this.state;
    return (
      <LookupBody
        configuration={this._configuration}
        data={data}
        hasMore={hasMore}
        updateSelected={(selected) => (this._selected = [...selected])}
        requestMore={() => this.fetchNextDataBatch()}
      />
    );
  }

  getButtons() {
    return (
      <DialogButtons
        buttons={[
          {
            id: "button-dialog-ok",
            caption: localize(GlobalCaption.FromBackEnd.Global_OK),
            click: this.accept.bind(this),
          },
          {
            id: "button-dialog-cancel",
            caption: localize(GlobalCaption.FromBackEnd.Global_Cancel),
            click: this.dismiss.bind(this),
          },
        ]}
      />
    );
  }
}
