codeunit 6014530 "Credit Card Protocol C-sharp"
{
    // NPR5.00/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 228807 NP Retail 2016
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.20/TSA/20160223  CASE 235337 Changed signature on the ProtocolEvent to include CodeunitID
    // NPR5.22/VB/20160505 CASE 239274 "Enable Contactless" field from the Register table passed into the protocol.
    // NPR5.23/JDH /20160527 CASE 238798 Removed fee from beeing added to the amount, hence it resulted in adding it twice
    // NPR5.26/JHL/20160822 CASE 249746 Change so that the Credit Card Transaction, do not write cancel on all transaction
    // NPR5.26/JHL/20160901 CASE 249900 Change so that all receipt from the terminal is printed on received. Removed the parameter (Data, Text) in the function PrintReceipts().
    // NPR5.26/JHL/20160902 CASE 249746 Change so the Credit Card Transaction is local and not global.
    //                                  Deleted to none useds global variable (Transaction, record "Credit Card Transaction") and (dkTrans, record "Credit Card Transction")
    // NPR5.26/TSA/20160919 CASE 248043 Breaking Change .NET version from 5.0.398.0 to 5.0.398.1
    //                                  Added a change to intgration protocol, Dankort=> Integration responds on card swipe. Steria=> Integration triggered by sending amount
    // NPR5.26/TSA/20160919 CASE 248043 Unused constant and variable cleanup, checking guidelines,
    // NPR5.27/MMV /20161006 CASE 254376 Print changes.
    // NPR5.27/JHL/20161006 CASE 254661 Cut CardPan to the right length
    // NPR5.28/TSA/20161110 CASE 248043 (Re)Added Support for Steria AUX functions, SetAuxFunction()
    // NPR5.36/MMV /20170908 CASE 283791 Bugfixes & changes from transcendence protocol backported.
    // NPR5.37/MMV /20171024 CASE 293784 Increased paymentgateway assembly version.
    // NPR5.38/MMV /20171215 CASE 299748 Added line no. filter to prevent cross transaction state being hit in certain edge cases.
    //                                   Increment Receipt No. correctly.
    // NPR5.38/MHA /20180105  CASE 301053 Object renmaed from "Credit Card Protocol C#" to "Credit Card Protocol C-sharp"
    // NPR5.38/MMV /20180117 CASE 302551 Don't send final amount before looking up card no. even when not using surcharge.
    // NPR5.38/JDH /20180124 CASE 302394 Removed unused variable on danish, that contained a local character (wasnt used)
    // NPR5.42/MMV /20180507 CASE 306689 Added support for location specific payment type.
    // NPR5.43/MMV /20180620 CASE 317969 Moved constant string in-line instead of ENU caption.
    // NPR5.46/NPKNAV/20181008  CASE 290734-01 Transport NPR5.46 - 8 October 2018

    SingleInstance = true;
    TableNo = TempBlob;

    trigger OnRun()
    begin
        ProcessSignal(Rec);
    end;

    var
        Err001: Label 'Terminal amount is 0';
        POSDeviceProxyManager: Codeunit "POS Device Proxy Manager";
        ExpectedResponseType: DotNet npNetType;
        ExpectedResponseId: Guid;
        ProtocolManagerId: Guid;
        QueuedRequests: DotNet npNetStack;
        QueuedResponseTypes: DotNet npNetStack;
        PBSGiftVoucherFunctions: Codeunit "PBS Gift Voucher Functions";
        Util: Codeunit Utility;
        ConnectionProfileMgt: Codeunit "Connection Profile Management";
        Ekspeditionslinie: Record "Sale Line POS";
        Kasse: Record Register;
        MessageText: Text[250];
        Amount: Decimal;
        Done: Boolean;
        Path: Text[250];
        Started: Boolean;
        Vent: Boolean;
        Afvist: Boolean;
        EventTimer: Integer;
        ForceClose: Boolean;
        Cvm: Integer;
        Onoffline: Integer;
        ClearAllPressed: Integer;
        WaitApplication: Boolean;
        ApplicationsCount: Integer;
        Marshaller: Codeunit "POS Event Marshaller";
        UseFee: Boolean;
        NewFee: Decimal;
        CardSwipeActivatesTerminal: Boolean;
        CapturedAmount: Decimal;
        Gavekortnr: Code[19];
        ExpiryDate: Text[30];
        Barcode: Text[19];
        IsBarcodeTransfer: Boolean;
        InitErrorText: Text;
        AuxFunction: Integer;
        AuxFunctionIsSet: Boolean;
        AuxNotSupported: Label 'Aux functions are not supported for this credit card solution.';

    local procedure "--- Protocol functions"()
    begin
    end;

    procedure InitializeProtocol()
    begin
        ClearAll();
    end;

    local procedure ProcessSignal(var TempBlob: Record TempBlob)
    var
        Signal: DotNet npNetSignal;
        StartSignal: DotNet npNetStartSession;
        QueryCloseSignal: DotNet npNetQueryClosePage;
        Response: DotNet npNetMessageResponse;
    begin
        POSDeviceProxyManager.DeserializeObject(Signal, TempBlob);
        case true of
            Signal.TypeName = Format(GetDotNetType(StartSignal)):
                begin
                    QueuedRequests := QueuedRequests.Stack();
                    QueuedResponseTypes := QueuedResponseTypes.Stack();

                    POSDeviceProxyManager.DeserializeSignal(StartSignal, Signal);
                    Start(StartSignal.ProtocolManagerId);
                end;
            Signal.TypeName = Format(GetDotNetType(Response)):
                begin
                    POSDeviceProxyManager.DeserializeSignal(Response, Signal);
                    MessageResponse(Response.Envelope);
                end;
            Signal.TypeName = Format(GetDotNetType(QueryCloseSignal)):
                if QueryClosePage() then
                    POSDeviceProxyManager.AbortByUserRequest(ProtocolManagerId);
        end;
    end;

    local procedure Start(ProtocolManagerIdIn: Guid)
    var
        State: DotNet npNetState;
        GatewayRequest: DotNet npNetPaymentGatewayProcessRequest;
        VoidResponse: DotNet npNetVoidResponse;
    begin
        ProtocolManagerId := ProtocolManagerIdIn;

        State := State.State();
        State.Amount := Amount;
        State.Barcode := Barcode;
        State.VerificationMethod := Cvm;
        State.TransactionType := Onoffline;
        State.IsBarcode := IsBarcodeTransfer;
        State.UseFee := UseFee;
        State.RegisterNo := Kasse."Register No.";
        State.ReceiptNo := Ekspeditionslinie."Sales Ticket No.";
        State.RegisterContactlessEnabled := Kasse."Enable Contactless";
        State.CardSwipeActivatesTerminal := CardSwipeActivatesTerminal;
        //-NPR5.38 [302551]
        State.ConfirmCardBeforePayment := true;
        //+NPR5.38 [302551]

        State.AdminFunction := 0; // Normal Operation
        if (AuxFunctionIsSet) then begin
            State.PerformAdminFunction := true;
            State.AdminFunction := AuxFunction;
        end;

        GatewayRequest := GatewayRequest.PaymentGatewayProcessRequest();
        GatewayRequest.State := State;
        GatewayRequest.Path := Path;

        AwaitResponse(
          GetDotNetType(VoidResponse),
          POSDeviceProxyManager.SendMessage(
            ProtocolManagerId, GatewayRequest));
    end;

    local procedure MessageResponse(Envelope: DotNet npNetResponseEnvelope)
    begin
        if Envelope.ResponseTypeName <> Format(ExpectedResponseType) then
            Error('Unknown response type: %1 (expected %2)', Envelope.ResponseTypeName, Format(ExpectedResponseType));
    end;

    local procedure QueryClosePage(): Boolean
    begin
        exit(true);
    end;

    local procedure CloseProtocol()
    begin
        POSDeviceProxyManager.ProtocolClose(ProtocolManagerId);
    end;

    local procedure AwaitResponse(Type: DotNet npNetType; Id: Guid)
    begin
        ExpectedResponseType := Type;
        ExpectedResponseId := Id;
    end;

    local procedure "---"()
    begin
    end;

    procedure Init(pAmount: Decimal; var pEkspeditionslinie: Record "Sale Line POS"; pcvm: Integer; pOnOffline: Integer; BarcodeTransfer: Boolean): Boolean
    var
        RetailFormCode: Codeunit "Retail Form Code";
        KasseNr: Code[20];
    begin
        if pAmount = 0 then begin
            InitErrorText := Err001;
            exit(false);
        end;

        Done := false;
        Amount := pAmount;
        MessageText := '';
        Started := false;
        Afvist := false;
        EventTimer := 0;
        ForceClose := false;
        Vent := false;
        Ekspeditionslinie := pEkspeditionslinie;

        Cvm := pcvm;
        Onoffline := pOnOffline;
        ClearAllPressed := 0;
        ApplicationsCount := 0;
        WaitApplication := false;
        IsBarcodeTransfer := BarcodeTransfer;

        Util.MakeVars;

        //-NPR5.38 [302394]
        //NPKOps�t.GET;
        //+NPR5.38 [302394]

        KasseNr := RetailFormCode.FetchRegisterNumber;
        Kasse.Get(KasseNr);
        Path := ConnectionProfileMgt.GetCreditCardExtension;

        UseFee := Kasse."Use Fee" and (Amount > 0);

        CardSwipeActivatesTerminal := true;

        exit(true);
    end;

    procedure InitSteriaSupport()
    begin

        UseFee := false;
        CardSwipeActivatesTerminal := false;
    end;

    procedure GetInitErrorText(): Text
    begin
        exit(InitErrorText);
    end;

    procedure GetFee(): Decimal
    begin
        exit(NewFee);
    end;

    procedure GetCapturedAmount(): Decimal
    begin
        exit(CapturedAmount);
    end;

    procedure SetBarcode(InBarcode: Code[19])
    begin
        Barcode := InBarcode;
        IsBarcodeTransfer := true;
    end;

    procedure SetAuxFunction(CreditCardSolution: Option; AuxFunctionID: Integer; var pEkspeditionslinie: Record "Sale Line POS"): Boolean
    var
        PosSetup: Record Register;
        RetailFormCode: Codeunit "Retail Form Code";
        KasseNr: Code[20];
    begin
        AuxFunction := 0;
        AuxFunctionIsSet := false;

        if (CreditCardSolution <> PosSetup."Credit Card Solution"::Steria) then
            Error(AuxNotSupported);

        AuxFunction := AuxFunctionID;

        Done := false;
        Amount := 0;
        MessageText := '';
        Started := false;
        Afvist := false;
        EventTimer := 0;
        ForceClose := false;
        Vent := false;
        Ekspeditionslinie := pEkspeditionslinie;

        Cvm := 0;
        Onoffline := 0;
        ClearAllPressed := 0;
        ApplicationsCount := 0;
        WaitApplication := false;
        IsBarcodeTransfer := false;
        UseFee := false;

        Util.MakeVars;
        //-NPR5.38 [302394]
        //NPKOps�t.GET;
        //+NPR5.38 [302394]

        KasseNr := RetailFormCode.FetchRegisterNumber;
        Kasse.Get(KasseNr);
        Path := ConnectionProfileMgt.GetCreditCardExtension;
        CardSwipeActivatesTerminal := true;

        AuxFunctionIsSet := (AuxFunction <> 0);
        exit(AuxFunctionIsSet);
    end;

    local procedure "--- Protocol Events"()
    begin
    end;

    local procedure CloseForm(Data: Text)
    var
        State: DotNet npNetState;
    begin
        State := State.Deserialize(Data);

        CapturedAmount := State.CapturedAmount;
        NewFee := State.NewFee;

        CloseProtocol();
    end;

    local procedure FindPaymentType(Data: Text; var ReturnData: Text)
    var
        PaymentTypePOS: Record "Payment Type POS";
        SalePOS: Record "Sale POS";
        RetailSalesLineCode: Codeunit "Retail Sales Line Code";
        CreditCardHelper: Codeunit "Credit Card Protocol Helper";
        State: DotNet npNetState;
        PaymentNo: Code[10];
    begin
        State := State.Deserialize(Data);

        State.CardPan := CreditCardHelper.CutCardPan(State.CardPan);

        //-NPR5.42 [306689]
        // CreditCardHelper.FindPaymentType(State.CardPan,PaymentTypePOS);
        // CreditCardHelper.ResolvePrefix(State.CardPan,PaymentNo);
        // SalePOS.GET(Ekspeditionslinie."Register No.",Ekspeditionslinie."Sales Ticket No.");
        SalePOS.Get(Ekspeditionslinie."Register No.", Ekspeditionslinie."Sales Ticket No.");

        CreditCardHelper.FindPaymentType(State.CardPan, PaymentTypePOS, SalePOS."Location Code");
        //+NPR5.42 [306689]

        State.SalesAmountInclVat := RetailSalesLineCode.GetSalesAmountInclVAT(SalePOS);
        //-NPR5.42 [306689]
        //State.PaymentNo := PaymentNo;
        State.PaymentNo := PaymentTypePOS."No.";
        //+NPR5.42 [306689]
        State.MatchSalesAmount := PaymentTypePOS."Match Sales Amount";
        State.CardPanValidGiftVoucher := PBSGiftVoucherFunctions.IsGiftVoucher(State.CardPan);
        State.NewFee := CreditCardHelper.CalcTransFee(PaymentTypePOS, Amount, Kasse."Confirm Fee");

        State.FeeItem := PaymentTypePOS."Fee Item No.";

        ReturnData := State.Serialize();
    end;

    local procedure GetGiftVoucherBalance(Data: Text; var ReturnData: Text)
    var
        GiftVoucherBalance: Decimal;
    begin
        GiftVoucherBalance := PBSGiftVoucherFunctions.GetBalance(Gavekortnr, ExpiryDate) / 100;
        ReturnData := SerializeJson(GiftVoucherBalance);
    end;

    local procedure InsertSaleLineFee(Data: Text)
    var
        SaleLinePOSFee: Record "Sale Line POS";
        State: DotNet npNetState;
        LastLineNo: Integer;
    begin
        State := State.Deserialize(Data);

        SaleLinePOSFee.SetRange("Register No.", Ekspeditionslinie."Register No.");
        SaleLinePOSFee.SetRange("Sales Ticket No.", Ekspeditionslinie."Sales Ticket No.");
        SaleLinePOSFee.SetRange(Date, Ekspeditionslinie.Date);
        if SaleLinePOSFee.FindLast then;
        LastLineNo := SaleLinePOSFee."Line No." + 15001;
        SaleLinePOSFee.Init();
        SaleLinePOSFee."Register No." := Ekspeditionslinie."Register No.";
        SaleLinePOSFee."Sales Ticket No." := Ekspeditionslinie."Sales Ticket No.";
        SaleLinePOSFee."Location Code" := Ekspeditionslinie."Location Code";
        SaleLinePOSFee.Date := Ekspeditionslinie.Date;
        SaleLinePOSFee."Line No." := LastLineNo;
        SaleLinePOSFee."Sale Type" := SaleLinePOSFee."Sale Type"::Sale;
        SaleLinePOSFee.Validate(Type, SaleLinePOSFee.Type::Item);
        SaleLinePOSFee.Validate("No.", State.FeeItem);
        SaleLinePOSFee.Validate(Quantity, 1);
        SaleLinePOSFee.Validate("Unit Price", State.NewFee);
        SaleLinePOSFee.Insert();
    end;

    local procedure PrintReceipts()
    var
        CreditCardTransaction: Record "Credit Card Transaction";
    begin
        CreditCardTransaction.Reset;
        CreditCardTransaction.FilterGroup := 2;
        CreditCardTransaction.SetCurrentKey("Register No.", "Sales Ticket No.", Type);
        CreditCardTransaction.SetRange("Register No.", Ekspeditionslinie."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", Ekspeditionslinie."Sales Ticket No.");
        CreditCardTransaction.SetRange(Type, 0);
        CreditCardTransaction.SetRange("No. Printed", 0);
        CreditCardTransaction.FilterGroup := 0;

        //-NPR5.46 [290734]
        // IF (NOT Kasse."Terminal Auto Print") AND (NOT CreditCardTransaction.ISEMPTY) THEN
        //  CreditCardTransaction.PrintTerminalReceipt(FALSE);
        if CreditCardTransaction.FindSet then
            CreditCardTransaction.PrintTerminalReceipt();
        //+NPR5.46 [290734]
    end;

    local procedure Numpad(Caption: Text; var Result: Text)
    begin
        Marshaller.NumPadText(Caption, Result, false, false);
    end;

    local procedure CheckTransactionFromCheckResult(Data: Text; var ReturnData: Text)
    var
        State: DotNet npNetState;
        CreditCardTransaction: Record "Credit Card Transaction";
    begin
        with CreditCardTransaction do begin
            SetCurrentKey("Register No.", "Sales Ticket No.", Type);
            SetRange("Register No.", Ekspeditionslinie."Register No.");
            SetRange("Sales Ticket No.", Ekspeditionslinie."Sales Ticket No.");
            //-NPR5.38 [299748]
            SetRange("Line No.", Ekspeditionslinie."Line No.");
            //+NPR5.38 [299748]
            SetRange(Type, 1);
            ReturnData := State.Serialize(FindLast());
        end;
    end;

    local procedure ModifyTransactionFromCheckResult(Data: Text)
    var
        CreditCardHelper: Codeunit "Credit Card Protocol Helper";
        CreditCardTransaction: Record "Credit Card Transaction";
        CreditCardTransaction2: Record "Credit Card Transaction";
    begin
        with CreditCardTransaction do begin
            SetCurrentKey("Register No.", "Sales Ticket No.", Type);
            SetRange("Register No.", Ekspeditionslinie."Register No.");
            SetRange("Sales Ticket No.", Ekspeditionslinie."Sales Ticket No.");
            //-NPR5.38 [299748]
            SetRange("Line No.", Ekspeditionslinie."Line No.");
            //+NPR5.38 [299748]
            SetRange(Type, 1);
            if FindLast() then begin
                Type := 3;
                Text := CreditCardHelper.CutCardPan(SelectStr(1, Data));
                Modify;
                //-NPR5.36 [283791]
            end else begin
                Reset;

                CreditCardTransaction2.SetRange("Register No.", Ekspeditionslinie."Register No.");
                CreditCardTransaction2.SetRange("Sales Ticket No.", Ekspeditionslinie."Sales Ticket No.");
                if CreditCardTransaction2.FindLast then;

                Init;
                "Entry No." := CreditCardTransaction2."Entry No." + 1;
                "Register No." := Ekspeditionslinie."Register No.";
                "Sales Ticket No." := Ekspeditionslinie."Sales Ticket No.";
                "Line No." := Ekspeditionslinie."Line No.";
                Type := 3;
                Text := CreditCardHelper.CutCardPan(SelectStr(1, Data));
                Date := Today;
                "Transaction Time" := Time;
                Insert;
            end;
            //  END ELSE
            //    CreditCardHelper.CreateErrorReceipt(Ekspeditionslinie,Data);
            //+NPR5.36 [283791]
        end;
    end;

    local procedure RejectTransactionIfFound(Data: Text)
    var
        CreditCardTransaction: Record "Credit Card Transaction";
    begin
        with CreditCardTransaction do begin
            SetCurrentKey("Register No.", "Sales Ticket No.", Type);
            SetRange("Register No.", Ekspeditionslinie."Register No.");
            SetRange("Sales Ticket No.", Ekspeditionslinie."Sales Ticket No.");
            //-NPR5.38 [299748]
            SetRange("Line No.", Ekspeditionslinie."Line No.");
            //+NPR5.38 [299748]
            SetRange(Type, 1);
            if FindLast() then begin
                Text := 'Afvist!';
                Modify;
            end;
        end;
    end;

    local procedure ReadReceipt(Data: Text)
    var
        State: DotNet npNetState;
        Lines: DotNet npNetArray;
        Ekspedition: Record "Sale POS";
        RecieptLine: Text[100];
        Register: Record Register;
        RetailFormCode: Codeunit "Retail Form Code";
        KasseNr: Code[20];
        EntryNo: Integer;
        CreditCardTransaction: Record "Credit Card Transaction";
        ReceiptNo: Integer;
    begin
        Lines := Lines.CreateInstance(GetDotNetType(''), 0);
        Lines := State.DeserializeAsType(Data, Lines.GetType());

        Ekspedition.Get(Ekspeditionslinie."Register No.", Ekspeditionslinie."Sales Ticket No.");

        KasseNr := RetailFormCode.FetchRegisterNumber();
        Register.Get(KasseNr);

        EntryNo := 1;

        CreditCardTransaction.SetRange("Register No.", Ekspedition."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", Ekspedition."Sales Ticket No.");
        //-NPR5.38 [299748]
        if CreditCardTransaction.FindLast() then
            EntryNo := CreditCardTransaction."Entry No." + 1;

        ReceiptNo := GetLastReceiptNo() + 1;
        // IF CreditCardTransaction.FINDLAST() THEN BEGIN
        //  EntryNo := CreditCardTransaction."Entry No." + 1;
        //  ReceiptNo := CreditCardTransaction."Receipt No." + 1;
        // END;
        //+NPR5.38 [299748]

        with CreditCardTransaction do begin
            foreach RecieptLine in Lines do begin
                Util.Ansi2Ascii(RecieptLine);
                //-NPR5.43 [317969]
                //RecieptLine := CONVERTSTR(RecieptLine,t001,t002);
                RecieptLine := ConvertStr(RecieptLine, '���������', '�����ԙ��');
                //+NPR5.43 [317969]
                Init;
                "Entry No." := EntryNo;
                Date := Today;
                Type := 0;
                "Transaction Time" := Time;
                Text := RecieptLine;
                "Register No." := Ekspedition."Register No.";
                "Sales Ticket No." := Ekspedition."Sales Ticket No.";
                "Line No." := Ekspeditionslinie."Line No.";
                "Salesperson Code" := Ekspedition."Salesperson Code";
                //-NPR5.36 [283791]
                "Receipt No." := ReceiptNo;
                //+NPR5.36 [283791]
                EntryNo += 1;
                Insert;
            end;

            Init;
            "Entry No." := EntryNo;
            Date := Today;
            Type := 1;
            "Transaction Time" := Time;
            Text := '';
            "Register No." := Ekspedition."Register No.";
            "Sales Ticket No." := Ekspedition."Sales Ticket No.";
            "Line No." := Ekspeditionslinie."Line No.";
            "Salesperson Code" := Ekspedition."Salesperson Code";
            Insert;
        end;

        Commit;
        PrintReceipts();
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure GetLastReceiptNo(): Integer
    var
        CreditCardTransaction: Record "Credit Card Transaction";
    begin
        //-NPR5.38 [299748]
        CreditCardTransaction.SetRange("Register No.", Ekspeditionslinie."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", Ekspeditionslinie."Sales Ticket No.");
        CreditCardTransaction.SetRange(Type, 0);
        if CreditCardTransaction.FindLast() then;
        exit(CreditCardTransaction."Receipt No.");
        //+NPR5.38 [299748]
    end;

    local procedure "--- Protocol Event Handling"()
    begin
    end;

    local procedure SerializeJson("Object": Variant): Text
    var
        JsonConvert: DotNet JsonConvert;
    begin
        exit(JsonConvert.SerializeObject(Object));
    end;

    [EventSubscriber(ObjectType::Page, 6014657, 'ProtocolEvent', '', false, false)]
    local procedure ProtocolEvent(ProtocolCodeunitID: Integer; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text)
    begin
        if (ProtocolCodeunitID <> CODEUNIT::"Credit Card Protocol C-sharp") then
            exit;

        case EventName of
            'CloseForm':
                CloseForm(Data);
            'FindPaymentType':
                FindPaymentType(Data, ReturnData);
            'GetGiftVoucherBalance':
                GetGiftVoucherBalance(Data, ReturnData);
            'InsertSaleLineFee':
                InsertSaleLineFee(Data);
                //-NPR5.36 [283791]
                //  'PrintReceipts':
                //    //-NPR5.26
                //    PrintReceipts();
                //    //PrintReceipts(Data);
                //    //+NPR5.26
                //  'NumPad':
                //    Numpad(Data,ReturnData);
            'PrintReceipts':
                ;
            'NumPad':
                ;
                //+NPR5.36 [283791]
            'CheckTransactionFromCheckResult':
                CheckTransactionFromCheckResult(Data, ReturnData);
            'ModifyTransactionFromCheckResult':
                ModifyTransactionFromCheckResult(Data);
            'RejectTransactionIfFound':
                RejectTransactionIfFound(Data);
            'ReadReceipt':
                ReadReceipt(Data);
        end;
    end;
}

