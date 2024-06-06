enum 6014686 "NPR Adyen Webhook Event Code"
{
    Extensible = true;
#IF NOT BC17
    Access = Internal;
#ENDIF
    value(0; ADVICE_OF_DEBIT)
    {
        Caption = 'ADVICE_OF_DEBIT';
    }
    value(10; AUTHENTICATION)
    {
        Caption = 'AUTHENTICATION';
    }
    value(20; AUTHORISATION)
    {
        Caption = 'AUTHORISATION';
    }
    value(30; AUTHORISATION_ADJUSTMENT)
    {
        Caption = 'AUTHORISATION_ADJUSTMENT';
    }
    value(40; AUTORESCUE)
    {
        Caption = 'AUTORESCUE';
    }
    value(50; AUTORESCUE_NEXT_ATTEMPT)
    {
        Caption = 'AUTORESCUE_NEXT_ATTEMPT';
    }
    value(60; CANCEL_AUTORESCUE)
    {
        Caption = 'CANCEL_AUTORESCUE';
    }
    value(70; CANCEL_OR_REFUND)
    {
        Caption = 'CANCEL_OR_REFUND';
    }
    value(80; CANCELLATION)
    {
        Caption = 'CANCELLATION';
    }
    value(90; CAPTURE)
    {
        Caption = 'CAPTURE';
    }
    value(100; CAPTURE_FAILED)
    {
        Caption = 'CAPTURE_FAILED';
    }
    value(110; CHARGEBACK)
    {
        Caption = 'CHARGEBACK';
    }
    value(120; CHARGEBACK_REVERSED)
    {
        Caption = 'CHARGEBACK_REVERSED';
    }
    value(130; DISABLE_RECURRING)
    {
        Caption = 'DISABLE_RECURRING';
    }
    value(140; DISPUTE_DEFENSE_PERIOD_ENDED)
    {
        Caption = 'DISPUTE_DEFENSE_PERIOD_ENDED';
    }
    value(150; DISPUTE_OPENED_WITH_CHARGEBACK)
    {
        Caption = 'DISPUTE_OPENED_WITH_CHARGEBACK';
    }
    value(160; DONATION)
    {
        Caption = 'DONATION';
    }
    value(170; EXPIRE)
    {
        Caption = 'EXPIRE';
    }
    value(180; HANDLED_EXTERNALLY)
    {
        Caption = 'HANDLED_EXTERNALLY';
    }
    value(190; INFORMATION_SUPPLIED)
    {
        Caption = 'INFORMATION_SUPPLIED';
    }
    value(200; ISSUER_COMMENTS)
    {
        Caption = 'ISSUER_COMMENTS';
    }
    value(210; ISSUER_RESPONSE_TIMEFRAME_EXPIRED)
    {
        Caption = 'ISSUER_RESPONSE_TIMEFRAME_EXPIRED';
    }
    value(220; MANUAL_REVIEW_ACCEPT)
    {
        Caption = 'MANUAL_REVIEW_ACCEPT';
    }
    value(230; MANUAL_REVIEW_REJECT)
    {
        Caption = 'MANUAL_REVIEW_REJECT';
    }
    value(240; NOTIFICATION_OF_CHARGEBACK)
    {
        Caption = 'NOTIFICATION_OF_CHARGEBACK';
    }
    value(250; NOTIFICATION_OF_FRAUD)
    {
        Caption = 'NOTIFICATION_OF_FRAUD';
    }
    value(260; OFFER_CLOSED)
    {
        Caption = 'OFFER_CLOSED';
    }
    value(270; ORDER_CLOSED)
    {
        Caption = 'ORDER_CLOSED';
    }
    value(280; ORDER_OPENED)
    {
        Caption = 'ORDER_OPENED';
    }
    value(290; PAIDOUT_REVERSED)
    {
        Caption = 'PAIDOUT_REVERSED';
    }
    value(300; PAYOUT_DECLINE)
    {
        Caption = 'PAYOUT_DECLINE';
    }
    value(310; PAYOUT_EXPIRE)
    {
        Caption = 'PAYOUT_EXPIRE';
    }
    value(320; PAYOUT_THIRDPARTY)
    {
        Caption = 'PAYOUT_THIRDPARTY';
    }
    value(330; PENDING)
    {
        Caption = 'PENDING';
    }
    value(340; POSTPONED_REFUND)
    {
        Caption = 'POSTPONED_REFUND';
    }
    value(350; PREARBITRATION_LOST)
    {
        Caption = 'PREARBITRATION_LOST';
    }
    value(360; PREARBITRATION_WON)
    {
        Caption = 'PREARBITRATION_WON';
    }
    value(370; RECURRING_CONTRACT)
    {
        Caption = 'RECURRING_CONTRACT';
    }
    value(380; REFUND)
    {
        Caption = 'REFUND';
    }
    value(390; REFUND_FAILED)
    {
        Caption = 'REFUND_FAILED';
    }
    value(400; REFUND_WITH_DATA)
    {
        Caption = 'REFUND_WITH_DATA';
    }
    value(410; REFUNDED_REVERSED)
    {
        Caption = 'REFUNDED_REVERSED';
    }
    value(420; REPORT_AVAILABLE)
    {
        Caption = 'REPORT_AVAILABLE';
    }
    value(430; REQUEST_FOR_INFORMATION)
    {
        Caption = 'REQUEST_FOR_INFORMATION';
    }
    value(440; SECOND_CHARGEBACK)
    {
        Caption = 'SECOND_CHARGEBACK';
    }
    value(450; TECHNICAL_CANCEL)
    {
        Caption = 'TECHNICAL_CANCEL';
    }
    value(460; VOID_PENDING_REFUND)
    {
        Caption = 'VOID_PENDING_REFUND';
    }
}
