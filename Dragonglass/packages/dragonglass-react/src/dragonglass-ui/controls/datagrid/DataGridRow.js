import React, { Component } from "react";
import { CurrentFormat } from "../../../components/FormatManager";

const format = number =>
    CurrentFormat.formatDecimal(number);

const Pending = () =>
    <div>Some running animation to indicate that the row is pending</div>;

export class DataGridRow extends Component {
    constructor(props) {
        super(props);

        this.state = {
            active: false
        }
    }

    _setActive(active) {
        this.setState({active: active});
    }

    render() {
        const { row, template } = this.props;
        const { active } = this.state;

        return (
            <div className = { active ? "c-grid__row c-grid__row--data-item l-vertical is-active" : "c-grid__row c-grid__row--data-item l-vertical" } onClick={() => (this.props.parent._setActive(this), this._setActive(true))}>
                <div className="c-grid__cell c-grid__cell--data-item-name">                    
                    <div className="c-grid__caption c-grid__caption--name">
                        <span>{row.fields[template.caption]}</span>
                        <div className="icon fa fa-cog"></div>
                    </div>                    
                </div>
                {
                    row.pending
                        ? <Pending />
                        : <>
                            <div className="c-grid__cell c-grid__cell--data-item-info" ref={active ? ref => { $(ref).css( 'margin-top', -$( ref ).height())} : ref => { $(ref).css( 'margin-top', 0 )}}>
                                <div className="c-grid__content">
                                    <div className="c-grid__caption">Quantity</div>
                                    <div className="c-grid__value">{format(row.fields[template.quantity])}</div>
                                </div>
                                <div className="c-grid__content">
                                    <div className="c-grid__caption">Unit price</div>
                                    <div className="c-grid__value">{format(row.fields[template.unitPrice])}</div>
                                </div>
                                <div className="c-grid__content">
                                    <div className="c-grid__caption">Discount %</div>
                                    <div className="c-grid__value">{format(row.fields[template.discountPercent])}</div>
                                </div>
                                <div className="c-grid__content">
                                    <div className="c-grid__caption">Discount amount</div>
                                    <div className="c-grid__value">{format(row.fields[template.discountAmount])}</div>
                                </div>
                                <div className="c-grid__content">
                                    <div className="c-grid__caption">Line amount</div>
                                    <div className="c-grid__value">{format(row.fields[template.lineAmount])}</div>
                                </div>
                            </div>

                            <div className="c-grid__cell c-grid__cell--data-item-info c-grid__cell--edit">
                                <div className="c-grid__content c-grid__content--edit">
                                    <div className="c-grid__caption c-grid__caption--edit">Set Quantity</div>
                                    <div className="c-grid__value c-grid__value--edit">{format(row.fields[template.quantity])}</div>
                                </div>
                                <div className="c-grid__content c-grid__content--edit">
                                    <div className="c-grid__caption c-grid__caption--edit">Set Unit Price</div>
                                    <div className="c-grid__value c-grid__value--edit">{format(row.fields[template.unitPrice])}</div>
                                </div>
                                <div className="c-grid__content c-grid__content--edit">
                                    <div className="c-grid__caption c-grid__caption--edit">Set Discount %</div>
                                    <div className="c-grid__value c-grid__value--edit">{format(row.fields[template.discountPercent])}</div>
                                </div>
                                <div className="c-grid__content c-grid__content--edit">
                                    <div className="c-grid__caption c-grid__caption--edit">Set Discount Amount</div>
                                    <div className="c-grid__value c-grid__value--edit">{format(row.fields[template.discountAmount])}</div>
                                </div>
                                <div className="c-grid__content c-grid__content--edit">
                                    <div className="c-grid__caption c-grid__caption--edit">Set Line Amount</div>
                                    <div className="c-grid__value c-grid__value--edit">{format(row.fields[template.lineAmount])}</div>
                                </div>
                            </div>
                        </>
                }
            </div>
        )
    }
}
