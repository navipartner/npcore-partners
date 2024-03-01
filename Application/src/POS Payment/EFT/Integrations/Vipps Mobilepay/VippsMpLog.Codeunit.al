codeunit 6184756 "NPR Vipps Mp Log"
{
    Access = Internal;

    internal procedure Log(Lvl: Enum "NPR Vipps Mp Log Lvl"; EFTTransactionRequest: Record "NPR EFT Transaction Request"; Description: Text; LogContent: JsonObject)
    begin
        Log(Lvl, EFTTransactionRequest."Entry No.", EFTTransactionRequest."Original POS Payment Type Code", Description, LogContent);
    end;

    internal procedure Log(Lvl: Enum "NPR Vipps Mp Log Lvl"; EFTEntryNo: Integer; VippsPaymentSetupCode: Text; Description: Text; LogContent: JsonObject)
    var
        EFTTrxLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        VippsMpPaymentSetup: Record "NPR Vipps Mp Payment Setup";
        LogContentTxt: Text;
    begin
        VippsMpPaymentSetup.Get(VippsPaymentSetupCode);
        if (Lvl.AsInteger() <= VippsMpPaymentSetup."Log Level".AsInteger()) then begin
            LogContent.WriteTo(LogContentTxt);
            EFTTrxLoggingMgt.WriteLogEntry(EFTEntryNo, Description, LogContentTxt);
        end;
    end;

    internal procedure Log(Lvl: Enum "NPR Vipps Mp Log Lvl"; EFTTransactionRequest: Record "NPR EFT Transaction Request"; Description: Text; LogContent: Text)
    begin
        Log(Lvl, EFTTransactionRequest."Entry No.", EFTTransactionRequest."Original POS Payment Type Code", Description, LogContent);
    end;

    internal procedure Log(Lvl: Enum "NPR Vipps Mp Log Lvl"; EFTEntryNo: Integer; VippsPaymentSetupCode: Text; Description: Text; LogContent: Text)
    var
        EFTTrxLoggingMgt: Codeunit "NPR EFT Trx Logging Mgt.";
        VippsMpPaymentSetup: Record "NPR Vipps Mp Payment Setup";
    begin
        VippsMpPaymentSetup.Get(VippsPaymentSetupCode);
        if (Lvl.AsInteger() <= VippsMpPaymentSetup."Log Level".AsInteger()) then
            EFTTrxLoggingMgt.WriteLogEntry(EFTEntryNo, Description, LogContent);
    end;


}