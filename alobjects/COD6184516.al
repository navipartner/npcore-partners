codeunit 6184516 "EFT Flexiiterm Protocol"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object


    trigger OnRun()
    begin
    end;

    var
        Err001: Label 'Terminal amount is 0';
        AuxNotSupported: Label 'Aux functions are not supported for this credit card solution.';

    procedure SendRequest(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        RetailFormCode: Codeunit "Retail Form Code";
        KasseNr: Code[20];
    begin
        case EFTTransactionRequest."Processing Type" of
          EFTTransactionRequest."Processing Type"::Payment,
          EFTTransactionRequest."Processing Type"::Refund :
            PaymentTransaction(EFTTransactionRequest);
        end;
    end;

    local procedure PaymentTransaction(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        State: DotNet State6;
        GatewayRequest: DotNet PaymentGatewayProcessRequest0;
        EFTTypePaymentGenParam: Record "EFT Type Payment Gen. Param.";
        EFTFlexiitermIntegration: Codeunit "EFT Flexiiterm Integration";
        EFTSetup: Record "EFT Setup";
        POSSession: Codeunit "POS Session";
        POSFrontEnd: Codeunit "POS Front End Management";
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
        State.UseFee := EFTFlexiitermIntegration.GetSurchargeStatus(EFTSetup);
        State.IsBarcode := false;
        State.CardSwipeActivatesTerminal := true;

        GatewayRequest := GatewayRequest.PaymentGatewayProcessRequest();
        GatewayRequest.Path := EFTFlexiitermIntegration.GetFolderPath(EFTSetup);
        GatewayRequest.State := State;

        POSFrontEnd.InvokeDevice (GatewayRequest, 'Flexiiterm_EftTrx', 'EftTrx');
    end;

    local procedure "--- Protocol Events"()
    begin
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet State6;
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTFlexiitermIntegration: Codeunit "EFT Flexiiterm Integration";
    begin

        State := State.Deserialize(Data);

        EFTTransactionRequest.Get (State.RequestEntryNo);
        EFTTransactionRequest."Card Number" := State.CardPan;
        EFTTransactionRequest."Amount Output" := State.CapturedAmount;
        EFTTransactionRequest."Result Amount" := State.CapturedAmount;
        EFTTransactionRequest."POS Description" := EFTFlexiitermIntegration.GetPOSDescription(EFTTransactionRequest);
        EFTTransactionRequest.Modify ();

        OnAfterProtocolResponse (EFTTransactionRequest);
    end;

    local procedure FindPaymentType(Data: Text;var ReturnData: Text)
    var
        PaymentTypePOS: Record "Payment Type POS";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        CreditCardHelper: Codeunit "Credit Card Protocol Helper";
        PaymentNo: Code[10];
        EFTTransactionRequest: Record "EFT Transaction Request";
        Register: Record Register;
        SalePOS: Record "Sale POS";
        State: DotNet State6;
        ConfirmFee: Boolean;
        EFTFlexiitermIntegration: Codeunit "EFT Flexiiterm Integration";
        EFTSetup: Record "EFT Setup";
    begin

        State := State.Deserialize(Data);

        EFTTransactionRequest.Get (State.RequestEntryNo);
        Register.Get (EFTTransactionRequest."Register No.");

        State.CardPan := CreditCardHelper.CutCardPan (State.CardPan);

        SalePOS.Get(State.RegisterNo, State.ReceiptNo);

        if (CreditCardHelper.FindPaymentType (State.CardPan, PaymentTypePOS, SalePOS."Location Code")) then begin
          State.SalesAmountInclVat := EFTTransactionRequest."Amount Input";
          State.PaymentNo := PaymentTypePOS."No.";

          State.MatchSalesAmount := PaymentTypePOS."Match Sales Amount";
          State.CardPanValidGiftVoucher := ((PaymentTypePOS."PBS Gift Voucher" and (PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::"Gift Voucher")));

          EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."POS Payment Type Code");
          ConfirmFee := EFTFlexiitermIntegration.GetSurchargeDialogStatus(EFTSetup);
          State.NewFee := CreditCardHelper.CalcTransFee (PaymentTypePOS, EFTTransactionRequest."Amount Input", ConfirmFee);
          State.FeeItem := PaymentTypePOS."Fee Item No.";

          EFTTransactionRequest."POS Payment Type Code" := PaymentTypePOS."No.";
          EFTTransactionRequest."Card Name" := CopyStr (PaymentTypePOS.Description, 1, MaxStrLen (EFTTransactionRequest."Card Name"));;

          EFTTransactionRequest.Modify();
        end;

        ReturnData := State.Serialize();
    end;

    local procedure GetGiftVoucherBalance(GiftVoucherNo: Text;var ReturnData: Text)
    var
        GiftVoucherBalance: Decimal;
        ExpiryDate: Text;
        PBSGiftVoucherFunctions: Codeunit "PBS Gift Voucher Functions";
    begin

        GiftVoucherBalance := PBSGiftVoucherFunctions.GetBalance (GiftVoucherNo, ExpiryDate) / 100;
        ReturnData := SerializeJson (GiftVoucherBalance);
    end;

    local procedure InsertSaleLineFee(Data: Text)
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSFee: Record "Sale Line POS";
        EFTTransactionRequest: Record "EFT Transaction Request";
        State: DotNet State6;
    begin

        State := State.Deserialize(Data);

        EFTTransactionRequest.Get (State.RequestEntryNo);
        EFTTransactionRequest."Fee Amount" := State.NewFee;
        EFTTransactionRequest.Modify;

        SaleLinePOS.Reset;
        Clear (SaleLinePOS);
        SaleLinePOS.SetFilter ("Register No.", '=%1', EFTTransactionRequest."Register No.");
        SaleLinePOS.SetFilter ("Sales Ticket No.", '=%1', EFTTransactionRequest."Sales Ticket No.");
        if (SaleLinePOS.FindLast ()) then ;

        SaleLinePOSFee.Init();
        SaleLinePOSFee."Register No." := SaleLinePOS."Register No.";
        SaleLinePOSFee."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        SaleLinePOSFee."Location Code" := SaleLinePOS."Location Code";
        SaleLinePOSFee.Date := SaleLinePOS.Date;
        SaleLinePOSFee."Line No." := SaleLinePOS."Line No." + 10000;
        SaleLinePOSFee."Sale Type" := SaleLinePOS."Sale Type"::Sale;

        SaleLinePOSFee.Validate (Type, SaleLinePOS.Type::Item);
        SaleLinePOSFee.Validate ("No.", State.FeeItem);
        SaleLinePOSFee.Validate (Quantity, 1);
        SaleLinePOSFee.Validate ("Unit Price", State.NewFee);
        SaleLinePOSFee.Insert();
    end;

    local procedure CheckTransactionFromCheckResult(Data: Text;var ReturnData: Text)
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        Result: Boolean;
        State: DotNet State6;
    begin

        State := State.Deserialize (Data);

        Result := EFTTransactionRequest.Get (State.RequestEntryNo);
        if Result then
          Result := EFTTransactionRequest."Receipt 1".HasValue;
        ReturnData := State.Serialize (Result);
    end;

    local procedure ModifyTransactionFromCheckResult(Data: Text)
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        CreditCardHelper: Codeunit "Credit Card Protocol Helper";
        CreditCardTransaction: Record "Credit Card Transaction";
        State: DotNet State6;
    begin

        State := State.Deserialize (Data);
        EFTTransactionRequest.Get (State.RequestEntryNo);

        EFTTransactionRequest."Result Code" := 3;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."Result Display Text" := 'Approved';
        EFTTransactionRequest."Card Number" := CreditCardHelper.CutCardPan (State.CardPan);
        EFTTransactionRequest."Transaction Date" := Today;
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest."External Result Received" := true;
        EFTTransactionRequest.Modify();
    end;

    local procedure RejectTransactionIfFound(Data: Text)
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        CreditCardTransaction: Record "Credit Card Transaction";
        CreditCardHelper: Codeunit "Credit Card Protocol Helper";
        State: DotNet State6;
    begin

        State := State.Deserialize (Data);
        EFTTransactionRequest.Get (State.RequestEntryNo);

        EFTTransactionRequest."Result Code" := 1;
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."Result Display Text" := 'Declined';
        EFTTransactionRequest."Card Number" := CreditCardHelper.CutCardPan(State.CardPan);
        EFTTransactionRequest."Transaction Date" := Today;
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest."External Result Received" := true;
        EFTTransactionRequest.Modify();
    end;

    local procedure HandleReceipt(Data: Text)
    var
        Lines: DotNet Array;
        EFTTransactionRequest: Record "EFT Transaction Request";
        OStream: OutStream;
        Util: Codeunit Utility;
        ReceiptLine: Text;
        CreditCardTransaction: Record "Credit Card Transaction";
        EntryNo: Integer;
        ReceiptNo: Integer;
        State: DotNet State6;
    begin

        State := State.Deserialize(Data);
        EFTTransactionRequest.Get (State.RequestEntryNo);
        EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);

        Lines := State.ReceiptData;
        EntryNo := 1;

        CreditCardTransaction.SetRange ("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange ("Sales Ticket No.",EFTTransactionRequest."Sales Ticket No.");

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
          Util.Ansi2Ascii(ReceiptLine);
          ReceiptLine := StrSubstNo ('%1',ConvertStr(ReceiptLine,'���������','�����ԙ��'));
          OStream.Write (ReceiptLine);

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
        JsonConvert: DotNet JsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', false, false)]
    local procedure OnDeviceEvent(ActionName: Text;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text;var Handled: Boolean)
    var
        PaymentRequest: Integer;
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin

        if (ActionName <> 'Flexiiterm_EftTrx') then
          exit;

        Handled := true;

        case EventName of
          'CloseForm':                         CloseForm(Data);
          'FindPaymentType':                   FindPaymentType(Data,ReturnData);
          'GetGiftVoucherBalance':             GetGiftVoucherBalance(Data,ReturnData);
          'InsertSaleLineFee':                 InsertSaleLineFee(Data);
          'CheckTransactionFromCheckResult':   CheckTransactionFromCheckResult(Data,ReturnData);
          'ModifyTransactionFromCheckResult':  ModifyTransactionFromCheckResult(Data);
          'RejectTransactionIfFound':          RejectTransactionIfFound(Data);
          'ReadReceipt':                       HandleReceipt(Data);
          'PrintReceipts' : ; //Delete when event is completely gone from stargate assembly.
          'NumPad' : ; //Delete when event is completely gone from stargate assembly.
          else
            Error ('Unhandled event sent from PaymentGateway %1', EventName);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EFTTransactionRequest: Record "EFT Transaction Request")
    begin
    end;
}

