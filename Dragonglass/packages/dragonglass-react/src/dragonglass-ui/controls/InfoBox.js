import React, { Component } from "react";

export class InfoBox extends Component {
  constructor(props) {
    super(props);
    this.state = {
      active: false,
    };
    this._refs = {};
  }
  render() {
    const { active } = this.state;
    return (
      <div className="c-infobox">
        <div className="c-infobox__customer-total l-horizontal">
          <div className="c-infobox__customer">
            <div className="c-textbox c-textbox--customer-lookup">
              <div
                className={
                  active ? "c-textbox__content is-active" : "c-textbox__content"
                }
              >
                <label className="c-textbox__label">Enter customer name</label>
                <input
                  className="c-textbox__input"
                  ref={(input) => (this._refs.input = input)}
                  type="text"
                  onFocus={() => this.setState({ active: true })}
                  onBlur={() =>
                    this._refs.input.value || this.setState({ active: false })
                  }
                  autoComplete="off"
                />
                <div className="c-button c-button--reset c-button--textbox">
                  <div
                    className="c-button__content c-button__content--textbox c-button__content--reset"
                    onClick={() => {
                      this._refs.input.value = "";
                      this._refs.input.focus();
                    }}
                  >
                    <span className="c-button__icon c-button__icon--reset fa fa-times"></span>
                  </div>
                </div>
                <div className="c-button c-button--search c-button--textbox">
                  <div className="c-button__content c-button__content--textbox c-button__content--search">
                    <span className="c-button__icon c-button__icon--search fa fa-search"></span>
                  </div>
                </div>
              </div>
            </div>
            <div className="c-infobox__customer__details">
              Customer Name A/S
              <br />
              Titangade 12
              <br />
              2200 København N
            </div>
          </div>
          <div className="c-grid c-grid--infobox">
            <div className="c-grid__row c-grid__row--infobox l-vertical">
              <div className="c-grid__cell c-grid__cell--infobox">
                <div className="c-grid__caption c-grid__caption--infobox">
                  Subtotal
                </div>
                <div className="c-grid__value c-grid__value--infobox">
                  6.913,00 DKK
                </div>
              </div>

              <div className="c-grid__cell c-grid__cell--infobox">
                <div className="c-grid__caption c-grid__caption--infobox">
                  Discounts
                </div>
                <div className="c-grid__value c-grid__value--infobox">
                  108,00 DKK
                </div>
              </div>

              <div className="c-grid__cell c-grid__cell--infobox">
                <div className="c-grid__caption c-grid__caption--infobox">
                  VAT
                </div>
                <div className="c-grid__value c-grid__value--infobox">
                  1.382,60 DKK
                </div>
              </div>

              <div className="c-grid__cell c-grid__cell--infobox">
                <div className="c-grid__caption c-grid__caption--infobox">
                  Whatever other info
                </div>
                <div className="c-grid__value c-grid__value--infobox">
                  0,00 DKK
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="c-button-menu c-button-menu--infobox">
          <div className="c-grid c-grid--button-menu">
            <div className="c-grid__row c-grid__row--button-menu">
              <div className="c-button c-button--icon c-button--text">
                <div className="c-button__content">
                  <span className="c-button__icon fa fa-cog"></span>
                  <div className="c-button__caption">
                    <span>
                      Very long Lorem ipsum dolor sit amet, consectetur
                      adipiscing elit. Integer non aliquet urna. Aliquam
                      venenatis, ipsum ut aliquet ullamcorper, sem dui posuere
                      libero, ut condimentum lectus elit in metus. Sed ut
                      vestibulum tortor. Praesent luctus nibh in placerat
                      laoreet. Proin feugiat justo ac rhoncus imperdiet.
                    </span>
                  </div>
                </div>
              </div>
              <div className="c-button c-button--icon c-button--text grey">
                <div className="c-button__content">
                  <span className="c-button__icon fa fa-cog"></span>
                  <div className="c-button__caption">
                    <span>
                      Very long Lorem ipsum dolor sit amet, consectetur
                      adipiscing elit. Integer non aliquet urna. Aliquam
                      venenatis, ipsum ut aliquet ullamcorper, sem dui posuere
                      libero, ut condimentum lectus elit in metus. Sed ut
                      vestibulum tortor. Praesent luctus nibh in placerat
                      laoreet. Proin feugiat justo ac rhoncus imperdiet.
                    </span>
                  </div>
                </div>
              </div>
              <div className="c-button c-button--icon c-button--text purple">
                <div className="c-button__content">
                  <span className="c-button__icon fa fa-cog"></span>
                  <div className="c-button__caption">
                    <span>
                      Very long Lorem ipsum dolor sit amet, consectetur
                      adipiscing elit. Integer non aliquet urna. Aliquam
                      venenatis, ipsum ut aliquet ullamcorper, sem dui posuere
                      libero, ut condimentum lectus elit in metus. Sed ut
                      vestibulum tortor. Praesent luctus nibh in placerat
                      laoreet. Proin feugiat justo ac rhoncus imperdiet.
                    </span>
                  </div>
                </div>
              </div>
              <div className="c-button c-button--icon c-button--text red">
                <div className="c-button__content">
                  <span className="c-button__icon fa fa-cog"></span>
                  <div className="c-button__caption">
                    <span>
                      Very long Lorem ipsum dolor sit amet, consectetur
                      adipiscing elit. Integer non aliquet urna. Aliquam
                      venenatis, ipsum ut aliquet ullamcorper, sem dui posuere
                      libero, ut condimentum lectus elit in metus. Sed ut
                      vestibulum tortor. Praesent luctus nibh in placerat
                      laoreet. Proin feugiat justo ac rhoncus imperdiet.
                    </span>
                  </div>
                </div>
              </div>
              <div className="c-button c-button--icon c-button--text green">
                <div className="c-button__content">
                  <span className="c-button__icon fa fa-shopping-cart"></span>
                  <div className="c-button__caption">
                    <span>
                      Very long Lorem ipsum dolor sit amet, consectetur
                      adipiscing elit. Integer non aliquet urna. Aliquam
                      venenatis, ipsum ut aliquet ullamcorper, sem dui posuere
                      libero, ut condimentum lectus elit in metus. Sed ut
                      vestibulum tortor. Praesent luctus nibh in placerat
                      laoreet. Proin feugiat justo ac rhoncus imperdiet.
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
