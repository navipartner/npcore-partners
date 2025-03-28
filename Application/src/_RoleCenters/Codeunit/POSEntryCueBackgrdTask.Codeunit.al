﻿codeunit 6014697 "NPR POS Entry Cue Backgrd Task"
{
    Access = Internal;
    trigger OnRun()
    begin
        Calculate();
    end;

    local procedure Calculate()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        POSEntryCue: Record "NPR POS Entry Cue.";
        Result: Dictionary of [Text, Text];
        TransationAmountLCY: Decimal;
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
    begin
        if not POSEntryCue.Get() then
            exit;

        POSEntryCue.SetRange("EFT Errors Date Filter", CalcDate('<-30D>', Today()), Today());
        POSEntryCue.CalcFields(
            "Unposted Item Trans.", "Unposted G/L Trans.", "Failed Item Transaction.", "Failed G/L Posting Trans.",
            "EFT Reconciliation Errors", "Unfinished EFT Requests", "EFT Req. with Unknown Result",
            "Campaign Discount List", "Mix Discount List", "Coupon List", "Voucher List");

        Result.Add(Format(POSEntryCue.FieldNo("Unposted Item Trans.")), Format(POSEntryCue."Unposted Item Trans.", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("Unposted G/L Trans.")), Format(POSEntryCue."Unposted G/L Trans.", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("Failed Item Transaction.")), Format(POSEntryCue."Failed Item Transaction.", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("Failed G/L Posting Trans.")), Format(POSEntryCue."Failed G/L Posting Trans.", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("EFT Reconciliation Errors")), Format(POSEntryCue."EFT Reconciliation Errors", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("Unfinished EFT Requests")), Format(POSEntryCue."Unfinished EFT Requests", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("EFT Req. with Unknown Result")), Format(POSEntryCue."EFT Req. with Unknown Result", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("Campaign Discount List")), Format(POSEntryCue."Campaign Discount List", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("Mix Discount List")), Format(POSEntryCue."Mix Discount List", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("Coupon List")), Format(POSEntryCue."Coupon List", 0, 9));
        Result.Add(Format(POSEntryCue.FieldNo("Voucher List")), Format(POSEntryCue."Voucher List", 0, 9));
        TransationAmountLCY := POSStatisticsMgt.CalculateTransactionAmount();
        Result.Add(Format(POSEntryCue.FieldNo("Transaction Amount (LCY)")), Format(TransationAmountLCY, 0, 9));
        if AdyenSetup.Get() and AdyenSetup."Enable Reconcil. Automation" then begin
            POSEntryCue.CalcFields("Reconc. Batches with Errors");
            Result.Add(Format(POSEntryCue.FieldNo("Reconc. Batches with Errors")), Format(POSEntryCue."Reconc. Batches with Errors", 0, 9));
        end;

        Page.SetBackgroundTaskResult(Result);
    end;
}
