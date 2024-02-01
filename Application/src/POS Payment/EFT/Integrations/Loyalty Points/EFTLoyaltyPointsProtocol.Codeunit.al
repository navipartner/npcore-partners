codeunit 6184741 "NPR EFT LoyaltyPointsProtocol"
{
    Access = Internal;

    procedure CreateHwcEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::REFUND:
                PaymentTransaction(EftTransactionRequest, HwcRequest, Workflow);
            EftTransactionRequest."Processing Type"::PAYMENT:
                PaymentTransaction(EftTransactionRequest, HwcRequest, Workflow);

        end;

        HwcRequest.Add('Unattended', EftTransactionRequest."Self Service");

    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        RESERVE_POINTS: Label 'Reserve Points';
    begin
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_MEMBER_LOYALTY);
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('AmountCaption', Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));
        HwcRequest.Add('TypeCaption', RESERVE_POINTS);
    end;

    internal procedure HandleDeviceResponse(EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject; Result: JsonObject)
    var
        JToken: JsonToken;
    begin
        if (Response.Get('ResultCode', JToken)) then
            EftTransactionRequest."Result Code" := JToken.AsValue().AsInteger();

        if (not HandleResponse(EftTransactionRequest)) then begin
            EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));
            EftTransactionRequest."POS Description" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."POS Description"));
            EftTransactionRequest.Successful := false;
            if (not Result.Contains('Message')) then
                Result.Add('Message', EftTransactionRequest."NST Error");
        end;

        EftTransactionRequest.Modify();
        Result.Add('success', EftTransactionRequest.Successful);
    end;

    [TryFunction]
    local procedure HandleResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT,
            EftTransactionRequest."Processing Type"::REFUND:
                PaymentTransactionEnd(EftTransactionRequest);
            else
                Error('%1 not handled.', EftTransactionRequest."Processing Type");
        end;
    end;

    local procedure PaymentTransactionEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PlaceHolder1Lbl: Label '%1 xxxx%2', Locked = true;
        PlaceHolder2Lbl: Label '%1 %2 xxxx%3', Locked = true;
        FailMessage: Label 'Transaction was declined with reason code %1 - %2. ';
    begin
        //  The SOAP action response handler updated the EFT Transaction Request already. 
        if (EFTTransactionRequest.Successful) then begin
            EFTTransactionRequest."POS Description" :=
              CopyStr(
                StrSubstNo(PlaceHolder1Lbl,
                  EFTTransactionRequest."Card Name",
                  CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 2)),
                1, MaxStrLen(EFTTransactionRequest."POS Description"));
        end;

        if (not EFTTransactionRequest.Successful) then begin
            EFTTransactionRequest."POS Description" :=
              CopyStr(
                StrSubstNo(PlaceHolder2Lbl,
                  EFTTransactionRequest."Result Description",
                  EFTTransactionRequest."Card Name",
                  CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 2)),
                1, MaxStrLen(EFTTransactionRequest."POS Description"));

            EFTTransactionRequest."Result Amount" := 0;
            Message(FailMessage, EFTTransactionRequest."Result Code", EFTTransactionRequest."Result Display Text");
        end;

    end;

}