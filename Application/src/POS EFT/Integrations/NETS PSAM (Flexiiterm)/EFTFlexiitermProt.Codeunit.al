codeunit 6184516 "NPR EFT Flexiiterm Prot."
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var

    procedure SendRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD,
          EFTTransactionRequest."Processing Type"::PAYMENT,
          EFTTransactionRequest."Processing Type"::REFUND:
                PaymentTransaction(EFTTransactionRequest);
        end;
    end;

    local procedure PaymentTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        State: DotNet NPRNetState6;
        GatewayRequest: DotNet NPRNetPaymentGatewayProcessRequest0;
        EFTFlexiitermIntegration: Codeunit "NPR EFT Flexiiterm Integ.";
        EFTSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error('Critical error');
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");

        State := State.State();
        State.RequestEntryNo := EFTTransactionRequest."Entry No.";
        State.RegisterContactlessEnabled := true;
        State.Amount := EFTTransactionRequest."Amount Input";
        State.ConfirmCardBeforePayment := true;
        State.RegisterNo := EFTTransactionRequest."Register No.";
        State.ReceiptNo := EFTTransactionRequest."Sales Ticket No.";
        State.VerificationMethod := EFTFlexiitermIntegration.GetCVM(EFTSetup);
        State.TransactionType := EFTFlexiitermIntegration.GetTransactionType(EFTSetup);
        State.IsBarcode := false;
        State.CardSwipeActivatesTerminal := true;
        State.Cashback := EFTTransactionRequest."Cashback Amount";
        GatewayRequest := GatewayRequest.PaymentGatewayProcessRequest();
        GatewayRequest.Path := EFTFlexiitermIntegration.GetFolderPath(EFTSetup);
        GatewayRequest.State := State;

        POSFrontEnd.InvokeDevice(GatewayRequest, 'Flexiiterm_EftTrx', 'EftTrx');
    end;

    #region Protocol Events

    local procedure CloseForm(Data: Text)
    var
        State: DotNet NPRNetState6;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFlexiitermIntegration: Codeunit "NPR EFT Flexiiterm Integ.";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        NewCardNumber: Text;
    begin

        State := State.Deserialize(Data);

        EFTTransactionRequest.Get(State.RequestEntryNo);
        NewCardNumber := CreditCardHelper.CutCardPan(State.CardPan);

        if (NewCardNumber <> '') and (EFTTransactionRequest."Card Number" <> NewCardNumber) then begin //Card was switched around during transaction
            EFTTransactionRequest."Card Number" := NewCardNumber;

            SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
            if CreditCardHelper.FindPaymentType(EFTTransactionRequest."Card Number", POSPaymentMethod, SalePOS."Location Code") then begin
                EFTTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
                EFTTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EFTTransactionRequest."Card Name"));
            end;
        end;

        EFTTransactionRequest."Amount Output" := State.CapturedAmount;
        EFTTransactionRequest."Result Amount" := State.CapturedAmount;
        EFTTransactionRequest."POS Description" := EFTFlexiitermIntegration.GetPOSDescription(EFTTransactionRequest);
        EFTTransactionRequest.Modify();

        OnAfterProtocolResponse(EFTTransactionRequest);
    end;

    local procedure FindPaymentType(Data: Text; var ReturnData: Text)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        State: DotNet NPRNetState6;
        EFTSetup: Record "NPR EFT Setup";
    begin

        State := State.Deserialize(Data);

        EFTTransactionRequest.Get(State.RequestEntryNo);
        POSUnit.Get(EFTTransactionRequest."Register No.");

        State.CardPan := CreditCardHelper.CutCardPan(State.CardPan);

        SalePOS.Get(State.RegisterNo, State.ReceiptNo);

        if (CreditCardHelper.FindPaymentType(State.CardPan, POSPaymentMethod, SalePOS."Location Code")) then begin
            State.SalesAmountInclVat := EFTTransactionRequest."Amount Input";
            State.PaymentNo := POSPaymentMethod.Code;

            State.MatchSalesAmount := POSPaymentMethod."Match Sales Amount";

            EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");
            EFTTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
            EFTTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EFTTransactionRequest."Card Name"));

            EFTTransactionRequest.Modify();
        end;

        ReturnData := State.Serialize();
    end;

    local procedure GetGiftVoucherBalance(GiftVoucherNo: Text; var ReturnData: Text)
    begin
        ReturnData := SerializeJson(0);
    end;

    local procedure CheckTransactionFromCheckResult(Data: Text; var ReturnData: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Result: Boolean;
        State: DotNet NPRNetState6;
    begin

        State := State.Deserialize(Data);

        Result := EFTTransactionRequest.Get(State.RequestEntryNo);
        if Result then
            Result := EFTTransactionRequest."Receipt 1".HasValue;
        ReturnData := State.Serialize(Result);
    end;

    local procedure ModifyTransactionFromCheckResult(Data: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        State: DotNet NPRNetState6;
    begin

        State := State.Deserialize(Data);
        EFTTransactionRequest.Get(State.RequestEntryNo);

        EFTTransactionRequest."Result Code" := 3;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."Result Display Text" := 'Approved';
        EFTTransactionRequest."Card Number" := CreditCardHelper.CutCardPan(State.CardPan);
        EFTTransactionRequest."Transaction Date" := Today();
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Modify();
    end;

    local procedure RejectTransactionIfFound(Data: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        State: DotNet NPRNetState6;
    begin

        State := State.Deserialize(Data);
        EFTTransactionRequest.Get(State.RequestEntryNo);

        EFTTransactionRequest."Result Code" := 1;
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."Result Display Text" := 'Declined';
        EFTTransactionRequest."Card Number" := CreditCardHelper.CutCardPan(State.CardPan);
        EFTTransactionRequest."Transaction Date" := Today();
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Modify();
    end;

    local procedure HandleReceipt(Data: Text)
    var
        Lines: DotNet NPRNetArray;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        OStream: OutStream;
        ReceiptLine: Text;
        CreditCardTransaction: Record "NPR EFT Receipt";
        EntryNo: Integer;
        ReceiptNo: Integer;
        State: DotNet NPRNetState6;
    begin

        State := State.Deserialize(Data);
        EFTTransactionRequest.Get(State.RequestEntryNo);
        EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);

        Lines := State.ReceiptData;
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

        foreach ReceiptLine in Lines do begin
            OStream.Write(ReceiptLine);

            CreditCardTransaction."Entry No." := EntryNo;
            CreditCardTransaction.Text := ReceiptLine;
            CreditCardTransaction.Insert();
            EntryNo += 1;
        end;

        EFTTransactionRequest.Modify();
        Commit(); //Prevent receipt data rollback in case of print error below - printing immediately inside the EFT transaction is unfortunately necessary since signature approval transactions depend on it.

        CreditCardTransaction.Reset();
        CreditCardTransaction.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        CreditCardTransaction.SetRange("Receipt No.", ReceiptNo);
        CreditCardTransaction.PrintTerminalReceipt();
    end;

    local procedure SerializeJson("Object": Variant): Text
    var
        JsonConvert: DotNet NPRNetJsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', false, false)]
    local procedure OnDeviceEvent(ActionName: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
    begin

        if (ActionName <> 'Flexiiterm_EftTrx') then
            exit;

        Handled := true;

        case EventName of
            'CloseForm':
                CloseForm(Data);
            'FindPaymentType':
                FindPaymentType(Data, ReturnData);
            'InsertSaleLineFee':
                ; //Delete when event is completely gone from stargate assembly.
            'CheckTransactionFromCheckResult':
                CheckTransactionFromCheckResult(Data, ReturnData);
            'ModifyTransactionFromCheckResult':
                ModifyTransactionFromCheckResult(Data);
            'RejectTransactionIfFound':
                RejectTransactionIfFound(Data);
            'ReadReceipt':
                HandleReceipt(Data);
            'PrintReceipts':
                ; //Delete when event is completely gone from stargate assembly.
            'NumPad':
                ; //Delete when event is completely gone from stargate assembly.
                  //-NPR5.54 [387965]
            'GetGiftVoucherBalance':
                GetGiftVoucherBalance(Data, ReturnData);
            else
                Error('Unhandled event sent from PaymentGateway %1', EventName);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
    end;

    #endregion
}

