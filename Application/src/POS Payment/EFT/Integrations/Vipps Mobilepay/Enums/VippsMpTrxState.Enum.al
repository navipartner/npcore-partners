enum 6014636 "NPR Vipps Mp Trx State"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; WAITING_CUSTOMER) { Caption = 'Waiting Customer', Comment = 'Waiting for customer info.'; }
    value(1; CREATING_TRX) { Caption = 'Initializing Payment', Comment = 'Creating Payment'; }
    value(2; WAITING_AUTHORIZED) { Caption = 'Authorized', Comment = 'The user has accepted the payment.'; }
    value(3; AUTHORIZED) { Caption = 'Authorized', Comment = 'The user has accepted the payment.'; }
    value(4; WAITING_CAPTURE) { Caption = 'Authorized', Comment = 'The user has accepted the payment.'; }
    value(5; COMPLETED) { Caption = 'Completed', Comment = 'The payment has completed'; }
    value(6; ERROR) { Caption = 'Error', Comment = 'An error happened.'; }
    value(7; ABORT_REQUESTED) { Caption = 'Abort Requested', Comment = 'Requested and abort of the Transaction.'; }
    value(8; ABORTED) { Caption = 'Aborted', Comment = 'The payment has been actively stopped by the user.'; }


}