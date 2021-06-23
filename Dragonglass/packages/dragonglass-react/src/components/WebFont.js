import React, { Component } from "react";

export class WebFont extends Component {
    render() {
        const { family, prefix, url, style } = this.props;
        return (
            <style>
{`
@font-face {
    font-family: '${family}';
    src: url('${url}') format('woff');
    font-weight: normal;
    font-style: normal;
    font-display: block;
  }
  
  [class^="${prefix}"], [class*=" ${prefix}"] {
    font-family: '${family}' !important;
    speak: none;
    font-style: normal;
    font-weight: normal;
    font-variant: normal;
    text-transform: none;
    line-height: 1;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }

  ${style ? style : ""}
`}
            </style>
        );
    }
}
