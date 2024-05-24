enum 6014662 "NPR Adyen Rec. Trans. Type"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; " ")
    {
        Caption = ' ';
    }
    value(10; Settled)
    {
        Caption = 'Settled';
    }
    value(20; Fee)
    {
        Caption = 'Fee';
    }
    value(30; MiscCosts)
    {
        Caption = 'MiscCosts';
    }
    value(40; MerchantPayout)
    {
        Caption = 'MerchantPayout';
    }
    value(50; Refunded)
    {
        Caption = 'Refunded';
    }
    value(60; Chargeback)
    {
        Caption = 'Chargeback';
    }
    value(70; SecondChargeback)
    {
        Caption = 'SecondChargeback';
    }
    value(80; ChargebackReversed)
    {
        Caption = 'ChargebackReversed';
    }
    value(90; RefundedReversed)
    {
        Caption = 'RefundedReversed';
    }
    value(100; DepositCorrection)
    {
        Caption = 'DepositCorrection';
    }
    value(110; InvoiceDeduction)
    {
        Caption = 'InvoiceDeduction';
    }
    value(120; MatchedStatement)
    {
        Caption = 'MatchedStatement';
    }
    value(130; ManualCorrected)
    {
        Caption = 'ManualCorrected';
    }
    value(140; BankInstructionReturned)
    {
        Caption = 'BankInstructionReturned';
    }
    value(150; EpaPaid)
    {
        Caption = 'EpaPaid';
    }
    value(160; Balancetransfer)
    {
        Caption = 'Balancetransfer';
    }
    value(170; PaymentCost)
    {
        Caption = 'PaymentCost';
    }
    value(180; PaidOut)
    {
        Caption = 'PaidOut';
    }
    value(190; PaidOutReversed)
    {
        Caption = 'PaidOutReversed';
    }
    value(200; RefundedInstallment)
    {
        Caption = 'RefundedInstallment';
    }
    value(210; SettledInstallment)
    {
        Caption = 'SettledInstallment';
    }
    value(220; SuspendInstallment)
    {
        Caption = 'SuspendInstallment';
    }
    value(230; "CaptureFailed (Sales Day payout)")
    {
        Caption = 'CaptureFailed (Sales Day payout)';
    }
    value(240; "RefundFailed (Sales Day payout)")
    {
        Caption = 'RefundFailed (Sales Day payout)';
    }
    value(250; "RefundNotCleared (Sales Day payout)")
    {
        Caption = 'RefundNotCleared (Sales Day payout)';
    }
    value(260; "SettledReversed (Sales Day payout)")
    {
        Caption = 'SettledReversed (Sales Day payout)';
    }
    value(270; MerchantPayin)
    {
        Caption = 'MerchantPayin';
    }
    value(280; ReserveAdjustment)
    {
        Caption = 'ReserveAdjustment';
    }
    value(290; MerchantPayinReversed)
    {
        Caption = 'MerchantPayinReversed';
    }
    value(300; XASTransfer)
    {
        Caption = 'XASTransfer';
    }
    value(310; AcquirerPayout)
    {
        Caption = 'AcquirerPayout';
    }
    value(320; AdjustmentExternallyWithInfo)
    {
        Caption = 'AdjustmentExternallyWithInfo';
    }
    value(330; AdvancementCommissionExternallyWithInfo)
    {
        Caption = 'AdvancementCommissionExternallyWithInfo';
    }
    value(340; ChargebackExternallyWithInfo)
    {
        Caption = 'ChargebackExternallyWithInfo';
    }
    value(350; ChargebackReversedExternallyWithInfo)
    {
        Caption = 'ChargebackReversedExternallyWithInfo';
    }
    value(360; RefundedExternallyWithInfo)
    {
        Caption = 'RefundedExternallyWithInfo';
    }
    value(370; RefundedInstallmentExternallyWithInfo)
    {
        Caption = 'RefundedInstallmentExternallyWithInfo';
    }
    value(380; SentForRefund)
    {
        Caption = 'SentForRefund';
    }
    value(390; SentForSettle)
    {
        Caption = 'SentForSettle';
    }
    value(400; SettledExternallyWithInfo)
    {
        Caption = 'SettledExternallyWithInfo';
    }
    value(410; SettledInstallmentExternallyWithInfo)
    {
        Caption = 'SettledInstallmentExternallyWithInfo';
    }
    value(420; UnmatchedBatchExternallyWithInfo)
    {
        Caption = 'UnmatchedBatchExternallyWithInfo';
    }
    value(430; UnmatchedChargebackExternallyWithInfo)
    {
        Caption = 'UnmatchedChargebackExternallyWithInfo';
    }
    value(440; UnmatchedChargebackReversedExternallyWithInfo)
    {
        Caption = 'UnmatchedChargebackReversedExternallyWithInfo';
    }
    value(450; UnmatchedRefundedExternallyWithInfo)
    {
        Caption = 'UnmatchedRefundedExternallyWithInfo';
    }
    value(460; UnmatchedSettledExternallyWithInfo)
    {
        Caption = 'UnmatchedSettledExternallyWithInfo';
    }
}
