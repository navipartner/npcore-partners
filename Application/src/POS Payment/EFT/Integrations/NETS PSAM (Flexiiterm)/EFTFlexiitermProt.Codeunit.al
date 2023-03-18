codeunit 6184516 "NPR EFT Flexiiterm Prot."
{
#pragma warning disable AA0139
    Access = Internal;

    procedure ConstructTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject)
    var
        EFTSetup: Record "NPR EFT Setup";
        FlexiitermIntegration: Codeunit "NPR EFT Flexiiterm Integ.";
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        Request.Add('EntryNo', EftTransactionRequest."Entry No.");
        Request.Add('Type', 'StartTransaction');
        Request.Add('Amount', Round(EftTransactionRequest."Amount Input", 0.01));
        Request.Add('FormattedAmount', Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));
        Request.Add('RegisterNo', EftTransactionRequest."Register No.");
        Request.Add('ReceiptNo', EftTransactionRequest."Sales Ticket No.");
        Request.Add('Cashback', EftTransactionRequest."Cashback Amount");
        Request.Add('Path', FlexiitermIntegration.GetFolderPath(EFTSetup));
        Request.Add('VAT', 0); //legacy: unsupported
        Request.Add('Tips', 0); //legacy: unsupported
        Request.Add('Surcharge', 0); //legacy: unsupported        
        case FlexiitermIntegration.GetTransactionType(EFTSetup) of
            0:
                Request.Add('TransactionType', 'NotForced');
            1:
                Request.Add('TransactionType', 'ForcedOnline');
            2:
                Request.Add('TransactionType', 'ForcedOffline');
        end;

        case FlexiitermIntegration.GetCVM(EFTSetup) of
            0:
                Request.Add('VerificationMethod', 'NotForced');
            1:
                Request.Add('VerificationMethod', 'ForcedSignature');
            2:
                Request.Add('VerificationMethod', 'ForcedPin');
        end;
    end;

    procedure HandleCardDataResponse(Response: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") NewRequest: JsonObject
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSUnit: Record "NPR POS Unit";
        POSSaleRecord: Record "NPR POS Sale";
        CardPan: Text;
    begin
        EFTTransactionRequest.Get(Response.GetInteger('EntryNo'));
        CardPan := CreditCardHelper.CutCardPan(Response.GetString('CardPan'));
        POSUnit.Get(EFTTransactionRequest."Register No.");
        POSSale.GetCurrentSale(POSSaleRecord);

        if (CreditCardHelper.FindPaymentType(CardPan, POSPaymentMethod, POSSaleRecord."Location Code")) then begin
            EFTTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
            EFTTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EFTTransactionRequest."Card Name"));
            EFTTransactionRequest.Modify();
        end;

        NewRequest.Add('Type', 'CardDataResult');
    end;

    procedure HandleReceiptCheckResponse(Response: Codeunit "NPR POS JSON Helper") NewRequest: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Result: Boolean;
    begin
        Result := EFTTransactionRequest.Get(Response.GetInteger('EntryNo'));
        if Result then
            Result := EFTTransactionRequest."Receipt 1".HasValue;

        NewRequest.Add('Type', 'ReceiptCheckResult');
        NewRequest.Add('ReceiptFoundInDatabase', Result);
    end;

    procedure HandleReceiptDataResponse(Response: Codeunit "NPR POS JSON Helper") NewRequest: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        OStream: OutStream;
        ReceiptLineToken: JsonToken;
        ReceiptLine: Text;
        CreditCardTransaction: Record "NPR EFT Receipt";
        EntryNo: Integer;
        ReceiptNo: Integer;
        Lines: JsonArray;
    begin
        EFTTransactionRequest.Get(Response.GetInteger('EntryNo'));
        EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);

        Lines := Response.GetJToken('ReceiptData').AsArray();
        EntryNo := 1;

        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");

        if (CreditCardTransaction.FindLast()) then begin
            EntryNo := CreditCardTransaction."Entry No." + 1;
            ReceiptNo := CreditCardTransaction."Receipt No." + 1
        end;

        CreditCardTransaction.Init();
        CreditCardTransaction.Date := Today();
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction.Type := 0;
        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;

        foreach ReceiptLineToken in Lines do begin
            ReceiptLine := ReceiptLineToken.AsValue().AsText();
            OStream.Write(ReceiptLine);

            CreditCardTransaction."Entry No." := EntryNo;
            CreditCardTransaction.Text := ReceiptLine;
            CreditCardTransaction.Insert();
            EntryNo += 1;
        end;

        EFTTransactionRequest.Modify();
        Commit(); //Prevent receipt data rollback in case of print error below - printing immediately inside the EFT transaction is unfortunately necessary since signature approval transactions depend on it.

        CreditCardTransaction.Reset();
        CreditCardTransaction.SetCurrentKey("EFT Trans. Request Entry No.", "Receipt No.");
        CreditCardTransaction.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        CreditCardTransaction.SetRange("Receipt No.", ReceiptNo);
        CreditCardTransaction.PrintTerminalReceipt();

        NewRequest.Add('Type', 'ReceiptDataCommitted');
    end;

    procedure HandleTransactionResultResponse(Response: Codeunit "NPR POS JSON Helper") NewRequest: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        CardPan: Text;
        TrxSuccess: Boolean;
    begin
        if Response.GetString('CardPan', CardPan) then;
        TrxSuccess := Response.GetBoolean('TrxSuccess');

        EFTTransactionRequest.Get(Response.GetInteger('EntryNo'));
        EFTTransactionRequest."Card Number" := CreditCardHelper.CutCardPan(CardPan);
        EFTTransactionRequest."Transaction Date" := Today();
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest."External Result Known" := true;
        if (TrxSuccess) then begin
            EFTTransactionRequest."Result Code" := 3;
            EFTTransactionRequest.Successful := true;
            EFTTransactionRequest."Result Display Text" := 'Approved';
        end else begin
            EFTTransactionRequest."Result Code" := 1;
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."Result Display Text" := 'Declined';
        end;
        EFTTransactionRequest.Modify();
        Commit();

        NewRequest.Add('Type', 'TransactionResultCommitted');
    end;

    procedure HandleTransactionCompletedResponse(Response: Codeunit "NPR POS JSON Helper") NewRequest: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFlexiitermIntegration: Codeunit "NPR EFT Flexiiterm Integ.";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        NewCardNumber: Text;
        EftInterface: Codeunit "NPR EFT Interface";
        BCSuccess: Boolean;
        CardPan: Text;
    begin
        EFTTransactionRequest.Get(Response.GetInteger('EntryNo'));
        if Response.GetString('CardPan', CardPan) then;
        NewCardNumber := CreditCardHelper.CutCardPan(CardPan);

        if (NewCardNumber <> '') and (EFTTransactionRequest."Card Number" <> NewCardNumber) then begin //Card was switched around during transaction
            EFTTransactionRequest."Card Number" := NewCardNumber;

            SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
            if CreditCardHelper.FindPaymentType(EFTTransactionRequest."Card Number", POSPaymentMethod, SalePOS."Location Code") then begin
                EFTTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
                EFTTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EFTTransactionRequest."Card Name"));
            end;
        end;

        EFTTransactionRequest."Amount Output" := Response.GetDecimal('CapturedAmount');
        EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Output";
        EFTTransactionRequest."POS Description" := EFTFlexiitermIntegration.GetPOSDescription(EFTTransactionRequest);
        EFTTransactionRequest.Modify();
        BCSuccess := EFTTransactionRequest.Successful;

        EftInterface.EftIntegrationResponse(EftTransactionRequest); //commits

        NewRequest.Add('BCSuccess', BCSuccess);
    end;
#pragma warning restore AA0139
}
