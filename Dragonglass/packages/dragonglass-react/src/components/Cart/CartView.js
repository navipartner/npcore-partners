import React, { Component } from "react";
import CartContent from "./CartContent";
import Button from "../Button";
import SimpleBar from "simplebar-react";
import CartBadge from "./CartBadge";
import { Workflow } from "dragonglass-workflows";
import { bindComponentToCartState } from "../../redux/reducers/cartReducer";

class CartView extends Component {
  _expand() {
    this.props.showCart(true);
  }

  _collapse() {
    this.props.showCart(false);
  }

  _callCheckout() {
    Workflow.run(this.props.setup.actions.checkout).then(() =>
      this._collapse()
    );
  }

  render() {
    return (
      <div className="cart-view">
        {this.props.cartVisible ? (
          <>
            {/* Should animate to full screen and show cart content */}
            <div className="cart-view__container cart-view__container--expanded">
              <div className="cart-view__title">
                <span>{this.props.setup.title || "Your cart"}</span>
              </div>
              <div className="cart-view__content">
                <SimpleBar>
                  <CartContent
                    dataSourceName={this.props.dataSourceName}
                    setup={this.props.setup}
                  />
                </SimpleBar>
              </div>
              <div className="cart-view__buttons">
                <Button caption="Close" onClick={() => this._collapse()} />
                <Button
                  caption="Checkout"
                  onClick={() => this._callCheckout()}
                />
              </div>
            </div>
          </>
        ) : (
          <>
            <div
              className="cart-view__container cart-view__container--collapsed"
              onClick={() => this._expand()}
            >
              <div className="cart-view__icon fa fa-shopping-cart">
                <CartBadge dataSourceName={this.props.dataSourceName} />
              </div>
            </div>
          </>
        )}
      </div>
    );
  }
}

export default bindComponentToCartState(CartView);
