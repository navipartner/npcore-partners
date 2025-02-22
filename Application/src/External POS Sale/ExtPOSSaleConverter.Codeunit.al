codeunit 6014637 "NPR Ext. POS Sale Converter"
{
    Access = Internal;
    TableNo = "NPR External POS Sale";
    trigger OnRun()
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSEntry: Record "NPR POS Entry";
        POSSaleCU: Codeunit "NPR POS Sale";
    begin
        Rec.LockTable();
        Rec.Find();
        if (Rec."Converted To POS Entry") then
            exit;
        Rec."Sales Ticket No." := POSSaleCU.GetNextReceiptNo(Rec."Register No.");
        CreateEftData(Rec);
        POSCreateEntry.CreatePOSEntryFromExternalPOSSale(Rec, POSEntry);
        Rec.Modify();
    end;

    local procedure CreateEftData(var ExternalPOSSale: Record "NPR External POS Sale")
    var
        ExternalPOSSaleLine: Record "NPR External POS Sale Line";
        ExternalPOSSaleEftLine: Record "NPR External POS Sale Eft Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Base64Convert: Codeunit "Base64 Convert";
        EftResponseDataBase64: Text;
        EftResponseData: Text;
        StreamData: Text;
        InS: InStream;
        EftPaymenLineNotFoundLbl: Label 'EFT Data not found for payment Line number: %1';
    begin
        ExternalPOSSale.TestField("Sales Ticket No.");
        ExternalPOSSaleLine.SetFilter("External POS Sale Entry No.", '=%1', ExternalPOSSale."Entry No.");
        ExternalPOSSaleLine.SetFilter("Line Type", '=%1', Enum::"NPR POS Sale Line Type"::"POS Payment");
        ExternalPOSSaleLine.SetFilter("Payment Type", '=%1', ExternalPOSSaleLine."Payment Type"::EFT);
        if (not ExternalPOSSaleLine.FindSet()) then
            exit;
        repeat begin
            if (not ExternalPOSSaleEftLine.Get(ExternalPOSSale."Entry No.", ExternalPOSSaleLine."Line No.")) then begin
                Error(EftPaymenLineNotFoundLbl, ExternalPOSSaleLine."Line No.");
            end else begin
                ExternalPOSSaleEftLine.CalcFields(Base64Data);
                ExternalPOSSaleEftLine.Base64Data.CreateInStream(InS);
                while not InS.EOS() do begin
                    if (InS.ReadText(StreamData) > 0) then
                        EftResponseDataBase64 += StreamData;
                end;
                EftResponseData := Base64Convert.FromBase64(EftResponseDataBase64);
                EFTTransactionRequest.Init();
                EFTTransactionRequest.Insert();
                EFTTransactionRequestPrefill(ExternalPOSSale, EFTTransactionRequest, ExternalPOSSaleLine, ExternalPOSSaleEftLine);
                EFTTransactionRequestIntegrationHandle(EFTTransactionRequest, EftResponseData, ExternalPOSSaleEftLine);
                ExternalPOSSaleLine."No." := EFTTransactionRequest."POS Payment Type Code";
                ExternalPOSSaleLine.Modify();
            end;
        end until ExternalPOSSaleLine.Next() <> 1;
    end;

    local procedure EFTTransactionRequestPrefill(
        var ExternalPOSSale: Record "NPR External POS Sale";
        var EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ExternalPOSSaleLine: Record "NPR External POS Sale Line";
        ExternalPOSSaleEftLine: Record "NPR External POS Sale Eft Line")
    begin
        //Should fail on bad info
#pragma warning disable AA0139
        EFTTransactionRequest.Token := CreateGuid();
        EFTTransactionRequest."Integration Type" := 'External POS';
        EFTTransactionRequest."Amount Input" := ExternalPOSSaleLine.Amount;
        EFTTransactionRequest."Result Amount" := ExternalPOSSaleLine.Amount;
        EFTTransactionRequest."User ID" := ExternalPOSSale."User ID";
        EFTTransactionRequest."Sales Ticket No." := ExternalPOSSale."Sales Ticket No.";
        EFTTransactionRequest."Sales ID" := ExternalPOSSale."External Pos Sale Id";
        EFTTransactionRequest."Register No." := ExternalPOSSale."Register No.";
        EFTTransactionRequest."POS Payment Type Code" := ExternalPOSSaleLine."No.";
        EFTTransactionRequest."Original POS Payment Type Code" := ExternalPOSSaleLine."No.";
        EFTTransactionRequest."Processing Type" := ExternalPOSSaleEftLine."Processing Type";
        EFTTransactionRequest."Reference Number Input" := ExternalPOSSaleEftLine."EFT Reference";
        EFTTransactionRequest.Started := CurrentDateTime();
#pragma warning restore AA0139
        EFTTransactionRequest.Modify();
    end;

    local procedure EFTTransactionRequestIntegrationHandle(
        var EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EftResponseData: Text;
        ExternalPOSSaleEftLine: Record "NPR External POS Sale Eft Line")
    begin
        case ExternalPOSSaleEftLine."EFT Type" of
            ExternalPOSSaleEftLine."EFT Type"::"NP Pay":
                begin
                    NpPayEftIntegrationHandler(EFTTransactionRequest, EftResponseData, ExternalPOSSaleEftLine);
                end;
        end;
        EftTransactionRequest."Result Processed" := true;
        EftTransactionRequest.Finished := CurrentDateTime();
        EftTransactionRequest.Modify();
    end;

    local procedure NpPayEftIntegrationHandler(
        var EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EftResponseData: Text;
        ExternalPOSSaleEftLine: Record "NPR External POS Sale Eft Line"
    )
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        EFTAdyenResponseType: Enum "NPR EFT Adyen Response Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        case ExternalPOSSaleEftLine."Processing Type" of
            ExternalPOSSaleEftLine."Processing Type"::PAYMENT,
            ExternalPOSSaleEftLine."Processing Type"::REFUND:
                EFTAdyenResponseType := EFTAdyenResponseType::Payment
        end;
        EFTAdyenResponseParser.SetResponseData(EFTAdyenResponseType, EftResponseData, EFTTransactionRequest."Entry No.");

        EFTAdyenResponseParser.Run();
        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");
        if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
            EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
            EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
        end;

    end;
}
