codeunit 6184516 "NPR EFT Flexiiterm Prot."
{
    // NPR5.51/MMV /20190626 CASE 359385 Removed gift card balance handling (Is now only supported via explicit action).
    //                                   Added gift card load support.
    // NPR5.51/MMV /20190718 CASE 331463 Match card prefix again after result if it switched during trx. (This final match is too late for any surcharge).
    // NPR5.53/MMV /20191219 CASE 383259 Corrections to #331463
    // NPR5.53/MMV /20200113 CASE 385078 Send cashback value to flexiiterm
    // NPR5.54/MMV /20200131 CASE 387965 Reintroduced gift card balance check integration.
    // NPR5.54/MMV /20200225 CASE 364340 Discontinued support for surcharge.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Err001: Label 'Terminal amount is 0';
        AuxNotSupported: Label 'Aux functions are not supported for this credit card solution.';
        GlobalGiftCardCustomerID: Text;

    procedure SendRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        case EFTTransactionRequest."Processing Type" of
            //-NPR5.51 [359385]
            EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD,
          //+NPR5.51 [359385]
          EFTTransactionRequest."Processing Type"::PAYMENT,
          EFTTransactionRequest."Processing Type"::REFUND:
                PaymentTransaction(EFTTransactionRequest);
        end;
    end;

    local procedure PaymentTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        State: DotNet NPRNetState6;
        GatewayRequest: DotNet NPRNetPaymentGatewayProcessRequest0;
        EFTTypePaymentGenParam: Record "NPR EFT Type Pay. Gen. Param.";
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
        //-NPR5.54 [364340]
        //State.UseFee := EFTFlexiitermIntegration.GetSurchargeStatus(EFTSetup);
        //+NPR5.54 [364340]
        State.IsBarcode := false;
        State.CardSwipeActivatesTerminal := true;
        //-NPR5.53 [385078]
        State.Cashback := EFTTransactionRequest."Cashback Amount";
        //+NPR5.53 [385078]

        GatewayRequest := GatewayRequest.PaymentGatewayProcessRequest();
        GatewayRequest.Path := EFTFlexiitermIntegration.GetFolderPath(EFTSetup);
        GatewayRequest.State := State;

        POSFrontEnd.InvokeDevice(GatewayRequest, 'Flexiiterm_EftTrx', 'EftTrx');
    end;

    local procedure "--- Protocol Events"()
    begin
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet NPRNetState6;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFlexiitermIntegration: Codeunit "NPR EFT Flexiiterm Integ.";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        PaymentTypePOS: Record "NPR Payment Type POS";
        SalePOS: Record "NPR Sale POS";
        NewCardNumber: Text;
    begin

        State := State.Deserialize(Data);

        EFTTransactionRequest.Get(State.RequestEntryNo);
        //-NPR5.51 [331463]
        //-NPR5.53 [383259]
        // IF EFTTransactionRequest."Card Number" <> State.CardPan THEN BEGIN //Card was switched around during transaction
        NewCardNumber := CreditCardHelper.CutCardPan(State.CardPan);

        if (NewCardNumber <> '') and (EFTTransactionRequest."Card Number" <> NewCardNumber) then begin //Card was switched around during transaction
            EFTTransactionRequest."Card Number" := NewCardNumber;
            //+NPR5.53 [383259]

            SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
            if CreditCardHelper.FindPaymentType(EFTTransactionRequest."Card Number", PaymentTypePOS, SalePOS."Location Code") then begin
                EFTTransactionRequest."POS Payment Type Code" := PaymentTypePOS."No.";
                EFTTransactionRequest."Card Name" := CopyStr(PaymentTypePOS.Description, 1, MaxStrLen(EFTTransactionRequest."Card Name"));
            end;
            //-NPR5.53 [383259]
            //  EFTTransactionRequest."Card Number" := State.CardPan;
            //+NPR5.53 [383259]
        end;
        //+NPR5.51 [331463]

        EFTTransactionRequest."Amount Output" := State.CapturedAmount;
        EFTTransactionRequest."Result Amount" := State.CapturedAmount;
        EFTTransactionRequest."POS Description" := EFTFlexiitermIntegration.GetPOSDescription(EFTTransactionRequest);
        EFTTransactionRequest.Modify();

        OnAfterProtocolResponse(EFTTransactionRequest);
    end;

    local procedure FindPaymentType(Data: Text; var ReturnData: Text)
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        PaymentNo: Code[10];
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Register: Record "NPR Register";
        SalePOS: Record "NPR Sale POS";
        State: DotNet NPRNetState6;
        ConfirmFee: Boolean;
        EFTFlexiitermIntegration: Codeunit "NPR EFT Flexiiterm Integ.";
        EFTSetup: Record "NPR EFT Setup";
    begin

        State := State.Deserialize(Data);

        EFTTransactionRequest.Get(State.RequestEntryNo);
        Register.Get(EFTTransactionRequest."Register No.");

        State.CardPan := CreditCardHelper.CutCardPan(State.CardPan);

        SalePOS.Get(State.RegisterNo, State.ReceiptNo);

        if (CreditCardHelper.FindPaymentType(State.CardPan, PaymentTypePOS, SalePOS."Location Code")) then begin
            State.SalesAmountInclVat := EFTTransactionRequest."Amount Input";
            State.PaymentNo := PaymentTypePOS."No.";

            State.MatchSalesAmount := PaymentTypePOS."Match Sales Amount";

            EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");
            EFTTransactionRequest."POS Payment Type Code" := PaymentTypePOS."No.";
            EFTTransactionRequest."Card Name" := CopyStr(PaymentTypePOS.Description, 1, MaxStrLen(EFTTransactionRequest."Card Name"));

            EFTTransactionRequest.Modify();
        end;

        ReturnData := State.Serialize();
    end;

    local procedure GetGiftVoucherBalance(GiftVoucherNo: Text; var ReturnData: Text)
    var
        GiftVoucherBalance: Decimal;
        ExpiryDate: Text;
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
        CreditCardTransaction: Record "NPR EFT Receipt";
        State: DotNet NPRNetState6;
    begin

        State := State.Deserialize(Data);
        EFTTransactionRequest.Get(State.RequestEntryNo);

        EFTTransactionRequest."Result Code" := 3;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."Result Display Text" := 'Approved';
        EFTTransactionRequest."Card Number" := CreditCardHelper.CutCardPan(State.CardPan);
        EFTTransactionRequest."Transaction Date" := Today;
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Modify();
    end;

    local procedure RejectTransactionIfFound(Data: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        CreditCardTransaction: Record "NPR EFT Receipt";
        CreditCardHelper: Codeunit "NPR Credit Card Prot. Helper";
        State: DotNet NPRNetState6;
    begin

        State := State.Deserialize(Data);
        EFTTransactionRequest.Get(State.RequestEntryNo);

        EFTTransactionRequest."Result Code" := 1;
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."Result Display Text" := 'Declined';
        EFTTransactionRequest."Card Number" := CreditCardHelper.CutCardPan(State.CardPan);
        EFTTransactionRequest."Transaction Date" := Today;
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Modify();
    end;

    local procedure HandleReceipt(Data: Text)
    var
        Lines: DotNet NPRNetArray;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        OStream: OutStream;
        Util: Codeunit "NPR Receipt Footer Mgt.";
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

        CreditCardTransaction.Init;
        CreditCardTransaction.Date := Today;
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
            CreditCardTransaction.Insert;
            EntryNo += 1;
        end;

        EFTTransactionRequest.Modify();
        Commit; //Prevent receipt data rollback in case of print error below - printing immediately inside the EFT transaction is unfortunately necessary since signature approval transactions depend on it.

        CreditCardTransaction.Reset;
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
    var
        PaymentRequest: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if (ActionName <> 'Flexiiterm_EftTrx') then
            exit;

        Handled := true;

        case EventName of
            'CloseForm':
                CloseForm(Data);
            'FindPaymentType':
                FindPaymentType(Data, ReturnData);
            //-NPR5.54 [364340]
            'InsertSaleLineFee':
                ; //Delete when event is completely gone from stargate assembly.
                  //+NPR5.54 [364340]
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
            //+NPR5.54 [387965]
            else
                Error('Unhandled event sent from PaymentGateway %1', EventName);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
    end;
}

