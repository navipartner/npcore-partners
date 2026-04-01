codeunit 6248222 "NPR External POS Sale Pub"
{
    Access = Public;

    var
        ExternalPOSSale: Record "NPR External POS Sale";

    procedure GetBySystemId(SystemId: Guid; var ExternalPOSSaleBuf: Record "NPR External POS Sale Buf") Found: Boolean
    begin
        ExternalPOSSaleBuf.Reset();
        ExternalPOSSaleBuf.DeleteAll();

        if not ExternalPOSSale.GetBySystemId(SystemId) then
            exit;

        PopulateBufferFromRec(ExternalPOSSaleBuf, ExternalPOSSale);
        Found := true;
    end;

    procedure GetByPOSEntrySystemId(POSEntrySystemId: Guid; var ExternalPOSSaleBuf: Record "NPR External POS Sale Buf") Found: Boolean
    begin
        ExternalPOSSaleBuf.Reset();
        ExternalPOSSaleBuf.DeleteAll();

        ExternalPOSSale.SetRange("POS Entry System Id", POSEntrySystemId);
        if not ExternalPOSSale.FindFirst() then
            exit;

        PopulateBufferFromRec(ExternalPOSSaleBuf, ExternalPOSSale);
        Found := true;
    end;

    procedure FindSetByRegisterNo(var ExternalPOSSaleBuf: Record "NPR External POS Sale Buf"; RegisterNo: Code[10]) Found: Boolean
    begin
        ExternalPOSSaleBuf.Reset();
        ExternalPOSSaleBuf.DeleteAll();

        if RegisterNo = '' then
            exit;

        ExternalPOSSale.Setrange("Register No.", RegisterNo);
        if not ExternalPOSSale.FindSet() then
            exit;

        repeat
            PopulateBufferFromRec(ExternalPOSSaleBuf, ExternalPOSSale);
        until ExternalPOSSale.Next() = 0;
        ExternalPOSSaleBuf.FindFirst();
        Found := true;
    end;

    procedure FindSetByConvertedToPOSEntry(var ExternalPOSSaleBuf: Record "NPR External POS Sale Buf"; ConvertedToPOSEntry: Boolean) Found: Boolean
    begin
        ExternalPOSSaleBuf.Reset();
        ExternalPOSSaleBuf.DeleteAll();

        ExternalPOSSale.Setrange("Converted To POS Entry", ConvertedToPOSEntry);
        if not ExternalPOSSale.FindSet() then
            exit;

        repeat
            PopulateBufferFromRec(ExternalPOSSaleBuf, ExternalPOSSale);
        until ExternalPOSSale.Next() = 0;
        ExternalPOSSaleBuf.FindFirst();
        Found := true;
    end;

    procedure FindSetByEmailReceiptSent(var ExternalPOSSaleBuf: Record "NPR External POS Sale Buf"; ConvertedToPOSEntry: Boolean) Found: Boolean
    begin
        ExternalPOSSaleBuf.Reset();
        ExternalPOSSaleBuf.DeleteAll();

        ExternalPOSSale.Reset();
        ExternalPOSSale.SetCurrentKey("Converted To POS Entry", "Send Receipt: Email", "Email Receipt Sent");
        ExternalPOSSale.Setrange("Converted To POS Entry", ConvertedToPOSEntry);
        ExternalPOSSale.SetRange("Send Receipt: Email", true);
        ExternalPOSSale.SetRange("Email Receipt Sent", false);
        if not ExternalPOSSale.FindSet() then
            exit;

        repeat
            PopulateBufferFromRec(ExternalPOSSaleBuf, ExternalPOSSale);
        until ExternalPOSSale.Next() = 0;
        ExternalPOSSaleBuf.FindFirst();
        Found := true;
    end;

    procedure ModifyEmailReceiptSent(ExternalPOSSaleBuf: Record "NPR External POS Sale Buf"; EmailReceiptSent: Boolean)
    begin
        if ExternalPOSSale.Get(ExternalPOSSaleBuf."Entry No.") then
            if ExternalPOSSale."Email Receipt Sent" <> EmailReceiptSent then begin
                ExternalPOSSale."Email Receipt Sent" := EmailReceiptSent;
                ExternalPOSSale.Modify();
            end;
    end;

    local procedure PopulateBufferFromRec(var ExternalPOSSaleBuf: Record "NPR External POS Sale Buf"; ExternalPOSSaleRec: Record "NPR External POS Sale")
    begin
        ExternalPOSSaleBuf.Init();
        ExternalPOSSaleBuf.TransferFields(ExternalPOSSaleRec);
        ExternalPOSSaleBuf.SystemId := ExternalPOSSaleRec.SystemId;
        ExternalPOSSaleBuf.Insert(false, false);
    end;

    [IntegrationEvent(false, false)]
    procedure OnExternalPOSSaleCustomerLookupByPhoneNo(phoneNo: Text[50]; var CustomerNo: Code[20]; var Handled: Boolean)
    begin
    end;
}