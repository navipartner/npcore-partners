let main = async ({workflow,captions,parameters,context}) => {
    debugger;

    let CouponTypeCode;

    if (!parameters.CouponTypeCode){
        CouponTypeCode = await workflow.respond("coupon_type_input")
    }
    else
    {
        context.CouponTypeCode = parameters.CouponTypeCode;
    }

    if (parameters.Quantity <= 0)
    {
        context.Qty_input = await popup.numpad({ title: captions.IssueCouponTitle ,caption: captions.Quantity, value: 1 })
    }
    else
    {
        context.Qty_input = parameters.Quantity;
    }

    await workflow.respond("issue_coupon", CouponTypeCode);
};
  