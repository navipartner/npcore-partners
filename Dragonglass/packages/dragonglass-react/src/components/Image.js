import React, { PureComponent } from "react";
import { NAV } from "dragonglass-nav";
import { bindComponentToImageSrcState } from "../redux/reducers/imagesReducer";

const DEFAULT_LOGO = "npretaillogo_med.png";

class Image extends PureComponent {
  render() {
    let { id, imageId, src, style, className } = this.props;
    if (imageId === "logo" && !src)
      src = NAV.instance.mapPath(`Images/${DEFAULT_LOGO}`);

    const additional = {};
    if (style) additional.style = style;

    return (
      <div className={`image ${className || ""}`} id={id} {...additional}>
        <img src={src}></img>
      </div>
    );
  }
}

export default bindComponentToImageSrcState(Image);
