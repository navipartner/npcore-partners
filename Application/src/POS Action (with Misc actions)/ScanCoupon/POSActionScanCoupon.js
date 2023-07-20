let main = async ({parameters, captions, popup, context}) => {
    if (!parameters.ReferenceNo) {
        context.CouponCode = await popup.input ({caption: captions.ScanCouponPrompt, title: captions.CouponTitle});
        if (!context.CouponCode) { return }
    } else {
        context.CouponCode = parameters.ReferenceNo;
    }
    const{RequireSerialNo} = await workflow.respond('ScanCoupon');
    if (RequireSerialNo){
        await workflow.run('ASSIGN_SERIAL_NO', { parameters: { SelectSerialNo: parameters.SelectSerialNo } });
    }
}