let main = async ({ workflow, context, popup, parameters, captions}) => 
{
    const _cityCardNumber = await popup.input({
        caption: captions.NumberInputPrompt, 
        title: captions.WindowTitle
    });
    if (_cityCardNumber === null) // cancel returns null
        return;

    let _dialogRef = await popup.simplePayment({
        showStatus: true, 
        title: captions.WindowTitle,
        amount: ' '
    });

    let _cityCardRequest = {cityCardNumber: _cityCardNumber, validated: false, redeemed: false, coupon: false};

    try {
        debugger;
        _dialogRef && _dialogRef.updateStatus(captions.ValidatingStatus);
        const docLXValidation = await workflow.respond('Validate', _cityCardRequest); 
        _cityCardRequest.validated = (docLXValidation.state.code === 200);

        if (docLXValidation.state.code === 523) {
            // already redeemed for a single entry location, get the previous coupon we issued and re-attempt to redeem, will fail if the coupon is already used
            _dialogRef && _dialogRef.updateStatus(captions.ApplyingCoupon);
            const docLXCoupon = await workflow.respond('AcquireCoupon', _cityCardRequest);
            _cityCardRequest.coupon = (docLXCoupon.state.code === 200);
            if (!_cityCardRequest.coupon) {
                await popup.message({
                    caption: "<center><font color=red size=72>&#x274C;</font><h3>"+docLXCoupon.state.message+"</h3></center>", 
                    title: captions.WindowTitle});
            }

            debugger;
            if (_cityCardRequest.coupon) {
                await workflow.run('SCAN_COUPON', { parameters: { ReferenceNo: docLXCoupon.coupon.reference_no } });
                const ticketReservation = await workflow.respond('CheckReservation');
                if (ticketReservation.needsSchedule) {
                    const reservationSelected = await popup.entertainment.scheduleSelection({ token: ticketReservation.token });
                    if (!reservationSelected) {
                        await workflow.run('DELETE_POS_LINE', { parameters: { ConfirmDialog: true } })
                    }
                }
            }
            return; // existing coupon was re-used.
        }

        if (!_cityCardRequest.validated) {
            await popup.message({
                caption: "<center><font color=red size=72>&#x274C;</font><h3>"+docLXValidation.state.message+"</h3></center>", 
                title: captions.WindowTitle});
        }
        
        debugger;
        if (_cityCardRequest.validated) {
            _dialogRef && _dialogRef.updateStatus(captions.RedeemingStatus);
            const docLXRedeem = await workflow.respond('Redeem', _cityCardRequest);
            _cityCardRequest.redeemed = (docLXRedeem.state.code === 200);
            if (!_cityCardRequest.redeemed) {
                await popup.message({
                    caption: "<center><font color=red size=72>&#x274C;</font><h3>"+docLXRedeem.state.message+"</h3></center>", 
                    title: captions.WindowTitle});
            }
        }

        debugger;
        if (_cityCardRequest.redeemed) {
            _dialogRef && _dialogRef.updateStatus(captions.ApplyingCoupon);
            const docLXCoupon = await workflow.respond('AcquireCoupon', _cityCardRequest);
            _cityCardRequest.coupon = (docLXCoupon.state.code === 200);
            if (!_cityCardRequest.coupon) {
                await popup.message({
                    caption: "<center><font color=red size=72>&#x274C;</font><h3>"+docLXCoupon.state.message+"</h3></center>", 
                    title: captions.WindowTitle});
            }

            debugger;
            if (_cityCardRequest.coupon) {
                await workflow.run('SCAN_COUPON', { parameters: { ReferenceNo: docLXCoupon.coupon.reference_no } });
                const ticketReservation = await workflow.respond('CheckReservation');
                if (ticketReservation.needsSchedule) {
                    const reservationSelected = await popup.entertainment.scheduleSelection({ token: ticketReservation.token });
                    if (!reservationSelected) {
                        await workflow.run('DELETE_POS_LINE', { parameters: { ConfirmDialog: true } })
                    }
                }
            }
        }

    } catch (error) {
        console.error(error);
    } finally {
        _dialogRef && _dialogRef.close();
    }

}