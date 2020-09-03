codeunit 6184497 "NPR Pepper Protocol"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.22\BR\20160412  CASE 231481 Support for offline terminal status
    // NPR5.22\BR\20160421  CASE 231481 Support Adding signature
    // NPR5.22\BR\20160422  CASE 231481 Support for installation
    // NPR5.25\BR\20160422  CASE 231481 Bugfix for installation
    // NPR5.25\BR\20160610  CASE 231481 Support for downloading license
    // NPR5.26/BR/20160812  CASE 248685 Added character overflow check on Receipt
    // NPR5.27/BR/20161017  CASE 248228 Allow negative lines
    // NPR5.27/BR/20161025  CASE 255131 Added Function FindTerminalCode
    // NPR5.27/BR/20161025  CASE 256318 Return Negative Amount if negative amount is given
    // NPR5.28/TSA/20161108  CASE 257214 Refactored the creation of credit card transaction lines - missing date / time
    // NPR5.28/TSA/20161111  CASE 257214 Fixed option string in AUXFunction to match that definition in 6184480 (added strmenu as option 0)
    // NPR5.28/BR /20161124  CASE 255137 Check field "Suppress Receipt Print"
    // NPR5.28/BR /20161128  CASE 259563 Added support for "Open Terminal and Retry"
    // NPR5.29/BR /20161221  CASE 261673 Added Nets requirement for signature confirmation
    // NPR5.30/BR /20170116  CASE 263458 Refactored to EFT Transaction requests
    // NPR5.34/BR /20170320  CASE 268697 Added fields Min. Length Authorisation No. and Max. Length Authorisation No.
    // NPR5.34/BR /20170608  CASE 268698 Added support for voiding refunds
    // NPR5.34/BR /20170619  CASE 268702 Print before asking for signature confirmation
    // NPR5.35/BR /20170803  CASE 285804 Added Receipt No. so that a cut can be made between Merchant and Client tickets
    // NPR5.35/BR /20170815  CASE 284379 Added support for Cashback
    // NPR5.36/BHR/20171002  CASE 292254 Correct the DataType of the Transaction amount from integer to decimal
    // NPR5.38/MHA /20180105  CASE 301053 Removed duplicate CASE of "Debit Sale" in CalcCashBackAmount()
    // NPR5.46/MMV /20180924 CASE 290734 Refactored EFT framework


    trigger OnRun()
    begin
        if InstallTerminal('2') then
            Message('Success')
        else
            Message('Failure');
    end;

    var
        Register: Record "NPR Register";
        SaleLinePOS: Record "NPR Sale Line POS";
        RetailSetup: Record "NPR Retail Setup";
        PepperTerminal: Record "NPR Pepper Terminal";
        PepperInstance: Record "NPR Pepper Instance";
        PepperConfiguration: Record "NPR Pepper Config.";
        PepperVersion: Record "NPR Pepper Version";
        GLSetup: Record "General Ledger Setup";
        PepperLibrary: Codeunit "NPR Pepper Library";
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
        RequestedAmount: Decimal;
        Cvm: Integer;
        Onoffline: Integer;
        ApplicationsCount: Integer;
        Err001: Label 'Terminal amount is 0';
        InitErrorText: Text;
        path: Text[250];
        useFee: Boolean;
        Barcode: Text[19];
        IsBarcodeTransfer: Boolean;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTRecoveryTransactionRequest: Record "NPR EFT Transaction Request";
        AuxFunction: Option STRMENU,ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINAQUERY,SHOWCUSTOMMENU;
        PaymentReference: Text;
        Success: Boolean;
        TransactionSelection: Option Payment,Open,Close,EndOfDay,Cancel,Auxiliary;
        CurrencyCode: Code[10];
        ReverseTransactionRequestEntryNo: Integer;
        TextErrorAux: Label 'Auxiliary Terminal Function not supported or failed.';
        AuthorisationNo: Text[12];
        IsNegativeAmount: Boolean;
        TextConfirmSignature: Label 'The customer''s signature is required on the receipt. Please check if the signature is valid. Do you wish to complete the transaction?';
        TextInvalidVoid: Label 'Cannot Void this type of transaction.';
        CashbackAmount: Decimal;

    procedure SendTransaction(): Boolean
    var
        TextSetFixedCurrency: Label 'Transactions can only be refunded/reversed if the field %1 is set to the transactional currency %2 on %3.';
        CreditCardTransaction: Record "NPR EFT Receipt";
        Register: Record "NPR Register";
    begin
        Success := false;
        if PepperTerminal."Open Automatically" then begin
            //-NPR5.22
            //IF (PepperTerminal.Status <> PepperTerminal.Status::Open) AND (TransactionSelection <> TransactionSelection :: Open ) THEN BEGIN
            if ((PepperTerminal.Status <> PepperTerminal.Status::Open) and (PepperTerminal.Status <> PepperTerminal.Status::ActiveOffline)) and
               (TransactionSelection <> TransactionSelection::Open) then begin
                //+NPR5.22
                //-NPR5.25 [231481]
                //IF PepperLibrary.EftOpen(SaleLinePOS."Sales Ticket No.") THEN BEGIN
                if PepperLibrary.EftOpen(SaleLinePOS."Sales Ticket No.", false) then begin
                    //+NPR5.25 [231481]
                    PepperLibrary.GetEFTTransactionRequest(EFTTransactionRequest);
                    WriteRequestReceipts;
                    PepperTerminal.Validate(Status, PepperTerminal.Status::Open);
                    PepperTerminal.Modify(true);
                    Commit;
                    //-NPR5.28 [259563]
                    Clear(PepperLibrary);
                    PepperLibrary.SetPepperConfiguration(PepperTerminal, PepperInstance, PepperConfiguration, PepperVersion);
                    //+NPR5.28 [259563]
                end else
                    exit(false)
            end;
        end;

        Commit;

        with SaleLinePOS do begin
            PaymentReference := "Sales Ticket No.";
            //-NPR5.22
            if PepperTerminal.Status = PepperTerminal.Status::ActiveOffline then
                PaymentReference := AuthorisationNo;
            //-NPR5.22
            case TransactionSelection of
                TransactionSelection::Payment:
                    begin
                        //-NPR5.27 [248228]
                        if RequestedAmount < 0 then begin
                            if PepperTerminal."Fixed Currency Code" <> CurrencyCode then begin
                                Success := false;
                                Message(TextSetFixedCurrency, PepperTerminal.FieldCaption("Fixed Currency Code"), CurrencyCode, PepperTerminal.TableCaption);
                            end else
                                Success := PepperLibrary.EftRefund("Sales Ticket No.", -RequestedAmount, 0, CurrencyCode, PaymentReference);
                        end else
                            //-NPR5.27 [248228]
                            if IsBarcodeTransfer then
                                //-NPR5.35 [284379]
                                //  Success := PepperLibrary.EftPaymentComplete("Sales Ticket No.",RequestedAmount,CurrencyCode,PaymentReference,3,Barcode,'')
                                //ELSE
                                //  Success := PepperLibrary.EftPayment("Sales Ticket No.",RequestedAmount,CurrencyCode,PaymentReference);
                                Success := PepperLibrary.EftPaymentComplete("Sales Ticket No.", RequestedAmount, CashbackAmount, CurrencyCode, PaymentReference, 3, Barcode, '')
                            else
                                Success := PepperLibrary.EftPayment("Sales Ticket No.", RequestedAmount, CashbackAmount, CurrencyCode, PaymentReference);
                        //+NPR5.35 [284379]
                    end;
                TransactionSelection::Cancel:
                    begin
                        Success := PepperLibrary.ReverseTransactionRequest("Sales Ticket No.", ReverseTransactionRequestEntryNo)
                    end;
                TransactionSelection::Open:
                    begin
                        //-NPR5.25 [231481]
                        //Success := PepperLibrary.EftOpen("Sales Ticket No.");
                        Success := PepperLibrary.EftOpen("Sales Ticket No.", false);
                        //+NPR5.25 [231481]
                        if Success then begin
                            //-NPR5.22
                            if (PepperTerminal.Status <> PepperTerminal.Status::ActiveOffline) then begin
                                //+NPR5.22
                                PepperTerminal.Validate(Status, PepperTerminal.Status::Open);
                                PepperTerminal.Modify(true);
                                //-NPR5.22
                            end;
                            //+NPR5.22
                        end;
                    end;
                TransactionSelection::Close:
                    begin
                        Success := PepperLibrary.EftClose("Sales Ticket No.", false);
                        if Success then begin
                            PepperTerminal.Validate(Status, PepperTerminal.Status::Closed);
                            PepperTerminal.Modify(true);
                        end;
                    end;
                TransactionSelection::EndOfDay:
                    begin
                        Success := PepperLibrary.EftClose("Sales Ticket No.", true);
                        if Success then begin
                            PepperTerminal.Validate(Status, PepperTerminal.Status::Closed);
                            PepperTerminal.Modify(true);
                        end;
                    end;
                TransactionSelection::Auxiliary:
                    begin
                        Success := PepperLibrary.EftAuxFunction("Sales Ticket No.", AuxFunction);
                        if not Success then
                            Message(TextErrorAux);
                    end;
            end;
        end;
        Commit;
        PepperLibrary.GetEFTTransactionRequest(EFTTransactionRequest);
        WriteRequestReceipts;
        if PepperLibrary.HasRecovery then begin
            Commit;
            PepperLibrary.GetEFTRecoveryTransactionRequest(EFTRecoveryTransactionRequest);
            WriteRequestReceipts;
        end;
        Commit;
        //-NPR5.29 [261673]
        if (EFTTransactionRequest."Authentication Method" = EFTRecoveryTransactionRequest."Authentication Method"::Signature) and
           (PepperTerminal."Cancel at Wrong Signature") and
           (Success) then begin

            //-NPR5.34 [268702]
            CreditCardTransaction.Reset;
            CreditCardTransaction.SetCurrentKey("Register No.", "Sales Ticket No.", Type);
            CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
            CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
            CreditCardTransaction.SetRange(Type, 0);
            //-NPR5.46 [290734]
            CreditCardTransaction.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
            if CreditCardTransaction.FindSet then
                CreditCardTransaction.PrintTerminalReceipt();
            //  CreditCardTransaction.SETRANGE("No. Printed", 0);
            //  Register.GET(EFTTransactionRequest."Register No.");
            //  IF (NOT Register."Terminal Auto Print") AND (NOT CreditCardTransaction.ISEMPTY) THEN
            //    CreditCardTransaction.PrintTerminalReceipt(FALSE);
            //+NPR5.46 [290734]
            Commit;
            //+NPR5.34 [268702]

            if not Confirm(TextConfirmSignature, true) then begin
                //-NPR5.35 [284379]
                //Init(EFTTransactionRequest."Amount Output", SaleLinePOS,Cvm, Onoffline,IsBarcodeTransfer);
                Init(EFTTransactionRequest."Amount Output", EFTTransactionRequest."Cashback Amount", SaleLinePOS, Cvm, Onoffline, IsBarcodeTransfer);
                //+NPR5.35 [284379]
                Commit;
                SetTransaction(0);
                //-NPR5.34 [268698]
                //Success := PepperLibrary.EftRefund(SaleLinePOS."Sales Ticket No.",RequestedAmount,1,EFTTransactionRequest."Currency Code",EFTTransactionRequest."Reference Number Output");
                Sleep(5000); //wait for terminal to be ready for voiding transaction
                case EFTTransactionRequest."Processing Type" of
                    EFTTransactionRequest."Processing Type"::PAYMENT:
                        Success := PepperLibrary.EftRefund(SaleLinePOS."Sales Ticket No.", RequestedAmount, 1, EFTTransactionRequest."Currency Code", EFTTransactionRequest."Reference Number Output");
                    EFTTransactionRequest."Processing Type"::REFUND:
                        Success := PepperLibrary.EftRefund(SaleLinePOS."Sales Ticket No.", RequestedAmount, 2, EFTTransactionRequest."Currency Code", EFTTransactionRequest."Reference Number Output");
                    else
                        Error(TextInvalidVoid);
                end;
                //+NPR5.34 [268698]
                Clear(PepperLibrary);
                exit(not Success);
            end;
        end;
        //+NPR5.29 [261673]
        //-NPR5.28 [259563]
        Clear(PepperLibrary);
        //+NPR5.28 [259563]
        exit(Success);
    end;

    procedure InitializeProtocol()
    begin
        ClearAll();
    end;

    procedure Init(pAmount: Decimal; pCashbackAmount: Decimal; var pSaleLinePOS: Record "NPR Sale Line POS"; pcvm: Integer; pOnOffline: Integer; BarcodeTransfer: Boolean): Boolean
    var
        RetailFormCode: Codeunit "NPR Retail Form Code";
        RegisterNo: Code[20];
    begin
        RequestedAmount := pAmount;
        //-NPR5.35 [284379]
        CashbackAmount := pCashbackAmount;
        //+NPR5.35 [284379]
        SaleLinePOS := pSaleLinePOS;
        CurrencyCode := pSaleLinePOS."Currency Code";
        if CurrencyCode = '' then begin
            GLSetup.Get;
            CurrencyCode := GLSetup."LCY Code";
        end;

        //-NPR5.27 [NPR5.27]
        IsNegativeAmount := pAmount < 0;
        //+NPR5.27 [NPR5.27]

        //-NPR5.46 [290734]
        // Cvm               := pcvm;
        // Onoffline         := pOnOffline;
        //+NPR5.46 [290734]
        IsBarcodeTransfer := BarcodeTransfer;

        RetailSetup.Get;

        if pSaleLinePOS."Register No." <> '' then
            RegisterNo := pSaleLinePOS."Register No."
        else
            RegisterNo := RetailFormCode.FetchRegisterNumber;
        Register.Get(RegisterNo);

        //-NPR5.46 [290734]
        //useFee := Register."Use Fee" AND (RequestedAmount > 0);
        //+NPR5.46 [290734]

        Clear(PepperLibrary);
        if not FindTerminalSetupFromRegister(pSaleLinePOS."Register No.", PepperTerminal, PepperInstance, PepperConfiguration, PepperVersion) then
            exit(false);
        PepperLibrary.SetPepperConfiguration(PepperTerminal, PepperInstance, PepperConfiguration, PepperVersion);


        exit(true);
    end;

    procedure IsOffline(): Boolean
    begin
        //-NPR5.22
        exit(PepperTerminal.Status = PepperTerminal.Status::ActiveOffline);
        //+NPR5.22
    end;

    procedure AuthNoRequired(): Boolean
    begin
        //-NPR5.22
        exit(PepperConfiguration."Offline mode" = PepperConfiguration."Offline mode"::"Mandatory Authorisation No.");
        //+NPR5.22
    end;

    procedure SetAuthorisationNo(ParAuthorisationNo: Text[12])
    begin
        //-NPR5.22
        AuthorisationNo := ParAuthorisationNo;
        //+NPR5.22
    end;

    procedure SetTerminalOfflineStatus(ParStatus: Option Offline,Online) Success: Boolean
    var
        TextNotOpen: Label 'Status must be Open to set Payment Terminal to Offline.  ';
        TextNotOffline: Label 'Terminal is not set to Offline mode. Please Open the terminal first.';
    begin
        //-NPR5.22
        Success := false;
        case ParStatus of
            ParStatus::Offline:
                begin
                    if (PepperTerminal.Status = PepperTerminal.Status::ActiveOffline) then begin
                        exit(true);
                    end;
                    if (PepperTerminal.Status <> PepperTerminal.Status::Open) then begin
                        Message(TextNotOpen);
                        exit(false)
                    end;
                    PepperTerminal.Validate(Status, PepperTerminal.Status::ActiveOffline);
                    PepperTerminal.Modify(true);
                    Commit;
                end;
            ParStatus::Online:
                begin
                    if (PepperTerminal.Status = PepperTerminal.Status::Open) then begin
                        exit(true);
                    end;
                    if (PepperTerminal.Status <> PepperTerminal.Status::ActiveOffline) then begin
                        Message(TextNotOffline);
                        exit(false);
                    end;
                    PepperTerminal.Validate(Status, PepperTerminal.Status::Open);
                    PepperTerminal.Modify(true);
                    Commit;
                end;
        end;
        exit(true);
        //+NPR5.22
    end;

    procedure SetTransaction(ParTransactionSelection: Option Payment,Open,Close,EndOfDay,Cancel,Auxiliary)
    begin
        TransactionSelection := ParTransactionSelection;
    end;

    procedure SetAuxFunctionNo(ParAuxFunction: Option STRMENU,ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINAQUERY,SHOWCUSTOMMENU)
    begin
        AuxFunction := ParAuxFunction;
    end;

    procedure GetInitErrorText(): Text
    begin
        exit(InitErrorText);
    end;

    procedure GetCapturedAmount(): Decimal
    begin
        if Success then
            //-NPR5.27 [NPR5.27]
            if IsNegativeAmount then
                exit(-EFTTransactionRequest."Amount Output");
        //+NPR5.27 [NPR5.27]
        exit(EFTTransactionRequest."Amount Output");
        exit(0);
    end;

    procedure GetPaymentTypePOS(): Code[10]
    var
        PepperCardType: Record "NPR Pepper Card Type";
    begin
        if EFTTransactionRequest."Card Type" <> '' then
            if PepperCardType.Get(EFTTransactionRequest."Card Type") then
                exit(PepperCardType."Payment Type POS");
        exit('');
    end;

    procedure GetPaymentDescription(DescriptionType: Option Description,Reference): Text
    var
        PepperCardType: Record "NPR Pepper Card Type";
        TextDescription: Label '%1:%2';
        TextUnknown: Label 'Card: %1';
    begin
        case DescriptionType of
            DescriptionType::Description:
                begin
                    if EFTTransactionRequest."Card Name" <> '' then begin
                        if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                            exit(StrSubstNo(TextDescription, CopyStr(EFTTransactionRequest."Card Name", 1, 8), CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
                        else
                            exit(StrSubstNo(EFTTransactionRequest."Card Name"))
                    end else begin
                        if PepperCardType.Get(EFTTransactionRequest."Card Type") then
                            if (PepperCardType.Description <> '') and (StrLen(EFTTransactionRequest."Card Number") > 8) then
                                exit(StrSubstNo(TextDescription, CopyStr(EFTTransactionRequest."Card Name", 1, 8), CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
                            else
                                exit(StrSubstNo(TextUnknown, PepperCardType.Description))
                        else
                            exit(StrSubstNo(TextUnknown, EFTTransactionRequest."Card Number"));
                    end;
                end;
            DescriptionType::Reference:
                begin
                    exit(EFTTransactionRequest."Reference Number Output");
                end;
        end;
    end;

    procedure GetCardNumber(): Text[30]
    begin
        exit(EFTTransactionRequest."Card Number");
    end;

    local procedure GetTerminal(TerminalCode: Code[10])
    begin
        if PepperTerminal.Code <> TerminalCode then
            if not PepperTerminal.Get(TerminalCode) then
                PepperTerminal.Init;
    end;

    procedure GetRetrytransaction(): Boolean
    var
        PepperResultCode: Record "NPR Pepper EFT Result Code";
    begin
        //-NPR5.28 [259563]
        if IsOffline then
            exit(false);
        if not Success then
            if PepperResultCode.Get(EFTTransactionRequest."Integration Type",
                  EFTTransactionRequest."Pepper Transaction Type Code",
                  EFTTransactionRequest."Pepper Trans. Subtype Code",
                  EFTTransactionRequest."Result Code") then
                exit(PepperResultCode."Open Terminal and Retry");
        exit(false);
        //+NPR5.28 [259563]
    end;

    procedure SetTerminalToUnknown()
    begin
        //-NPR5.28 [259563]
        if PepperTerminal.Status <> PepperTerminal.Status::Unknown then begin
            PepperTerminal.Validate(Status, PepperTerminal.Status::Unknown);
            PepperTerminal.Modify;
        end;
        //+NPR5.28 [259563]
    end;

    procedure SetBarcode(InBarcode: Code[19])
    begin
        Barcode := InBarcode;
        IsBarcodeTransfer := true;
    end;

    procedure SetReverseTransactionRequestEntryNo(ParReverseTransactionRequestEntryNo: Integer)
    begin
        ReverseTransactionRequestEntryNo := ParReverseTransactionRequestEntryNo;
    end;

    local procedure WriteRequestReceipts()
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        RetailComment: Record "NPR Retail Comment";
        Utility: Codeunit "NPR Utility";
        EntryNo: Integer;
        ReceiptLineText: Text;
        StreamIn: InStream;
        Encoding: TextEncoding;
        I: Integer;
        TextDot: Label '______________________________';
        TextSig: Label 'Customer Signature';
        PepperTransactionType: Record "NPR Pepper EFT Trx Type";
    begin
        with CreditCardTransaction do begin
            Reset;
            SetRange("Register No.", SaleLinePOS."Register No.");
            SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
            if FindLast then
                EntryNo := "Entry No."
            else
                EntryNo := 0;
            //-NPR5.28 [255137]
            if PepperTransactionType.Get(EFTTransactionRequest."Pepper Transaction Type Code") then
                if PepperTransactionType."Suppress Receipt Print" then
                    exit;
            //+NPR5.28 [255137]

            //-NPR5.28 [257214]
            EFTTransactionRequest.CalcFields("Receipt 1", "Receipt 2");
            if (EFTTransactionRequest."Receipt 1".HasValue) then begin
                EFTTransactionRequest."Receipt 1".CreateInStream(StreamIn);
                MakeReceipt(StreamIn, EntryNo, 0);
            end;

            if (EFTTransactionRequest."Receipt 2".HasValue) then begin
                EFTTransactionRequest."Receipt 2".CreateInStream(StreamIn);
                MakeReceipt(StreamIn, EntryNo, 1);
            end;

        end;
        //  INIT;
        //  ReceiptLineText := '';
        //  EFTTransactionRequest.CALCFIELDS("Receipt 1","Receipt 2");
        //  IF EFTTransactionRequest."Receipt 1".HASVALUE OR EFTTransactionRequest."Receipt 2".HASVALUE THEN BEGIN
        //    IF EFTTransactionRequest."Receipt 1".HASVALUE THEN BEGIN
        //      EFTTransactionRequest."Receipt 1".CREATEINSTREAM(StreamIn);
        //      IF PepperConfiguration."Header and Footer Handling" = PepperConfiguration."Header and Footer Handling" ::"Add Headers and Footers at Printing" THEN BEGIN
        //        Utility.getTicketText(RetailComment,Register);
        //        IF RetailComment.FINDSET THEN REPEAT
        //          EntryNo := EntryNo + 1;
        //          InitCreditCardTransaction (CreditCardTransaction, SaleLinePOS, EntryNo);
        //          VALIDATE("Register No.",SaleLinePOS."Register No.");
        //          VALIDATE("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        //          VALIDATE("Line No.",SaleLinePOS."Line No.");
        //          VALIDATE("Entry No.",EntryNo);
        //          VALIDATE(Type,0);
        //          //-NPR5.26 [248685]
        //          //VALIDATE(Text,RetailComment.Comment);
        //          VALIDATE(Text,COPYSTR(RetailComment.Comment,1,MAXSTRLEN(Text)));
        //          //+NPR5.26 [248685]
        //          INSERT(TRUE);
        //        UNTIL RetailComment.NEXT = 0;
        //      END;
        //      WHILE NOT StreamIn.EOS DO BEGIN
        //        StreamIn.READTEXT(ReceiptLineText);
        //        EntryNo := EntryNo + 1;
        //        VALIDATE("Register No.",SaleLinePOS."Register No.");
        //        VALIDATE("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        //        VALIDATE("Line No.",SaleLinePOS."Line No.");
        //        VALIDATE("Entry No.",EntryNo);
        //        VALIDATE(Type,0);
        //        //-NPR5.26 [248685]
        //        //VALIDATE(Text,ReceiptLineText);
        //        VALIDATE(Text,COPYSTR(ReceiptLineText,1,MAXSTRLEN(Text)));
        //        //+NPR5.26 [248685]
        //        INSERT(TRUE);
        //      END;
        //    END;
        //    CLEAR(StreamIn);
        //    ReceiptLineText := '';
        //    IF EFTTransactionRequest."Receipt 2".HASVALUE THEN BEGIN
        //      EFTTransactionRequest."Receipt 2".CREATEINSTREAM(StreamIn);
        //      IF PepperConfiguration."Header and Footer Handling" = PepperConfiguration."Header and Footer Handling" ::"Add Headers and Footers at Printing" THEN BEGIN
        //        Utility.getTicketText(RetailComment,Register);
        //        IF RetailComment.FINDSET THEN REPEAT
        //          EntryNo := EntryNo + 1;
        //          VALIDATE("Register No.",SaleLinePOS."Register No.");
        //          VALIDATE("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        //          VALIDATE("Line No.",SaleLinePOS."Line No.");
        //          VALIDATE("Entry No.",EntryNo);
        //          VALIDATE(Type,0);
        //          //-NPR5.26 [248685]
        //          //VALIDATE(Text,RetailComment.Comment);
        //          VALIDATE(Text,COPYSTR(RetailComment.Comment,1,MAXSTRLEN(Text)));
        //          //+NPR5.26 [248685]
        //          INSERT(TRUE);
        //        UNTIL RetailComment.NEXT = 0;
        //      END;
        //      REPEAT
        //        StreamIn.READTEXT(ReceiptLineText);
        //        EntryNo := EntryNo + 1;
        //        VALIDATE("Register No.",SaleLinePOS."Register No.");
        //        VALIDATE("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        //        VALIDATE("Line No.",SaleLinePOS."Line No.");
        //        VALIDATE("Entry No.",EntryNo);
        //        VALIDATE(Type,0);
        //        //-NPR5.26 [248685]
        //        //VALIDATE(Text,ReceiptLineText);
        //        VALIDATE(Text,COPYSTR(ReceiptLineText,1,MAXSTRLEN(Text)));
        //        //+NPR5.26 [248685]
        //        INSERT(TRUE);
        //      UNTIL StreamIn.EOS;
        //      //-NPR5.22
        //      IF EFTTransactionRequest."Receipt Signature" = EFTTransactionRequest."Receipt Signature"::"Sign Receipt" THEN BEGIN
        //        GetTerminal(EFTTransactionRequest."Terminal Code");
        //        IF PepperTerminal."Add Customer Signature Space" THEN BEGIN
        //          FOR I := 1 TO 4 DO BEGIN
        //            EntryNo := EntryNo + 1;
        //            WriteRequestLine(CreditCardTransaction,EntryNo,'');
        //          END;
        //          EntryNo := EntryNo + 1;
        //          WriteRequestLine(CreditCardTransaction,EntryNo,TextDot);
        //          EntryNo := EntryNo + 1;
        //          WriteRequestLine(CreditCardTransaction,EntryNo,TextSig);
        //          FOR I := 1 TO 2 DO BEGIN
        //            EntryNo := EntryNo + 1;
        //            WriteRequestLine(CreditCardTransaction,EntryNo,'');
        //          END;
        //        END;
        //      END;
        //      ///+NPR5.22
        //
        //    END;
        //  END;
        // END;

        //+257214 [257214]
    end;

    local procedure MakeReceipt(var StreamIn: InStream; var EntryNo: Integer; ReceiptType: Option CUSTOMER,MERCHANT)
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        RetailComment: Record "NPR Retail Comment";
        Utility: Codeunit "NPR Utility";
        ReceiptLineText: Text;
        Encoding: TextEncoding;
        I: Integer;
        TextDot: Label '______________________________';
        TextSig: Label 'Customer Signature';
    begin
        //-NPR5.28 [257214]
        if PepperConfiguration."Header and Footer Handling" = PepperConfiguration."Header and Footer Handling"::"Add Headers and Footers at Printing" then begin
            Utility.GetTicketText(RetailComment, Register);
            if RetailComment.FindSet then
                repeat
                    EntryNo := EntryNo + 1;
                    //-NPR5.35 [285804]
                    //WriteRequestLine(CreditCardTransaction,EntryNo, COPYSTR(RetailComment.Comment,1,MAXSTRLEN(CreditCardTransaction.Text)));
                    WriteRequestLine(CreditCardTransaction, EntryNo, ReceiptType, CopyStr(RetailComment.Comment, 1, MaxStrLen(CreditCardTransaction.Text)));
                //+NPR5.35 [285804]
                until RetailComment.Next = 0;
        end;

        repeat
            StreamIn.ReadText(ReceiptLineText);
            EntryNo := EntryNo + 1;
            //-NPR5.35 [285804]
            //WriteRequestLine(CreditCardTransaction,EntryNo, COPYSTR(ReceiptLineText,1,MAXSTRLEN(CreditCardTransaction.Text)));
            WriteRequestLine(CreditCardTransaction, EntryNo, ReceiptType, CopyStr(ReceiptLineText, 1, MaxStrLen(CreditCardTransaction.Text)));
        //+NPR5.35 [285804]
        until StreamIn.EOS;

        if (ReceiptType = ReceiptType::MERCHANT) then begin
            if EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature then begin
                GetTerminal(EFTTransactionRequest."Pepper Terminal Code");
                if PepperTerminal."Add Customer Signature Space" then begin
                    //-NPR5.35 [285804]
                    // FOR I := 1 TO 4 DO BEGIN
                    //  EntryNo := EntryNo + 1;
                    //  WriteRequestLine(CreditCardTransaction,EntryNo,'');
                    // END;
                    // EntryNo := EntryNo + 1;
                    // WriteRequestLine(CreditCardTransaction,EntryNo,TextDot);
                    // EntryNo := EntryNo + 1;
                    // WriteRequestLine(CreditCardTransaction,EntryNo,TextSig);
                    // FOR I := 1 TO 2 DO BEGIN
                    //  EntryNo := EntryNo + 1;
                    //  WriteRequestLine(CreditCardTransaction,EntryNo,'');
                    // END;
                    for I := 1 to 4 do begin
                        EntryNo := EntryNo + 1;
                        WriteRequestLine(CreditCardTransaction, EntryNo, ReceiptType, '');
                    end;
                    EntryNo := EntryNo + 1;
                    WriteRequestLine(CreditCardTransaction, EntryNo, ReceiptType, TextDot);
                    EntryNo := EntryNo + 1;
                    WriteRequestLine(CreditCardTransaction, EntryNo, ReceiptType, TextSig);
                    for I := 1 to 2 do begin
                        EntryNo := EntryNo + 1;
                        WriteRequestLine(CreditCardTransaction, EntryNo, ReceiptType, '');
                    end;
                    //+NPR5.35 [285804]
                end;
            end;
        end;
        //+NPR5.28 [257214]
    end;

    local procedure WriteRequestLine(var ParCreditCardTransaction: Record "NPR EFT Receipt"; ParEntryNo: Integer; ReceiptType: Option CUSTOMER,MERCHANT; ParText: Text)
    begin
        with ParCreditCardTransaction do begin
            Validate("Register No.", SaleLinePOS."Register No.");
            Validate("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
            Validate("Line No.", SaleLinePOS."Line No.");
            Validate("Entry No.", ParEntryNo);

            //-NPR5.28 [257214]
            Validate(Date, Today);
            Validate("Transaction Time", Time);
            //+NPR5.28 [257214]

            //-NPR5.35 [285804]
            case ReceiptType of
                ReceiptType::MERCHANT:
                    Validate("Receipt No.", 1);
                ReceiptType::CUSTOMER:
                    Validate("Receipt No.", 2);
            end;
            //+NPR5.35 [285804]
            Validate(Type, 0);
            Validate(Text, ParText);
            Insert(true);
        end;
    end;

    local procedure WriteReceipts()
    var
        ReceiptType: Option Open,Close,EndOfDay,Customer,Merchant,Recovery;
        I: Integer;
    begin

        // OBSOLETE ??
        for I := 0 to 5 do begin
            ReceiptType := I;
            WriteReceipt(ReceiptType, PepperLibrary.GetReceiptText(ReceiptType));//Open,Close,EndOfDay,Customer,Merchart,Recovery
        end;
    end;

    local procedure WriteReceipt(ReceiptType: Option Open,Close,EndOfDay,Customer,Merchant,Recovery; ReceiptText: Text)
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        EntryNo: Integer;
        RemainingReceiptText: Text;
        ReceiptLineText: Text[100];
        SeparatorChar: Char;
        EndOfLinePos: Integer;
        LineLength: Integer;
    begin

        // OBSOLETE ??
        if ReceiptText = '' then
            exit;
        LineLength := PepperTerminal."Receipt Format";
        if (LineLength = 0) or (LineLength > MaxStrLen(CreditCardTransaction.Text)) then
            LineLength := 40;

        with CreditCardTransaction do begin
            Reset;
            SetRange("Register No.", SaleLinePOS."Register No.");
            SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
            if FindLast then
                EntryNo := "Entry No."
            else
                EntryNo := 0;
            SeparatorChar := 13;
            if StrPos(ReceiptText, Format(SeparatorChar)) = 0 then
                SeparatorChar := 10;
            RemainingReceiptText := ReceiptText;

            repeat
                EndOfLinePos := StrPos(ReceiptLineText, Format(SeparatorChar)) - 1;
                if EndOfLinePos < 0 then
                    EndOfLinePos := 99;
                if EndOfLinePos > LineLength then
                    EndOfLinePos := LineLength;
                ReceiptLineText := CopyStr(RemainingReceiptText, 1, EndOfLinePos);
                RemainingReceiptText := CopyStr(RemainingReceiptText, EndOfLinePos + 1);
                if StrLen(RemainingReceiptText) > 1 then
                    if RemainingReceiptText[1] = SeparatorChar then
                        RemainingReceiptText := CopyStr(RemainingReceiptText, 2);
                EntryNo := EntryNo + 1;
                Validate("Register No.", SaleLinePOS."Register No.");
                Validate("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                Validate("Line No.", SaleLinePOS."Line No.");
                Validate("Entry No.", EntryNo);
                Validate(Type, 0);
                Validate(Text, ReceiptLineText);
                Insert(true);
            until RemainingReceiptText = '';
        end;
    end;

    local procedure FindTerminalSetupFromRegister(RegisterNo: Code[10]; var VarPepperTerminal: Record "NPR Pepper Terminal"; var VarPepperInstance: Record "NPR Pepper Instance"; var VarPepperConfiguration: Record "NPR Pepper Config."; var VarPepperVersion: Record "NPR Pepper Version"): Boolean
    var
        ErrorText001: Label 'Register %1 is linked to multiple Pepper terminals.';
        ErrorText002: Label 'Register %1 is not linked to a Pepper terminal.';
    begin
        with VarPepperTerminal do begin
            Reset;
            SetRange("Register No.", RegisterNo);
            if Count > 1 then begin
                InitErrorText := (StrSubstNo(ErrorText001, RegisterNo));
                exit(false);
            end;
            if not FindFirst then begin
                InitErrorText := (StrSubstNo(ErrorText002, RegisterNo));
                exit(false);
            end;
        end;
        VarPepperInstance.Get(VarPepperTerminal."Instance ID");
        VarPepperInstance.TestField("Configuration Code");
        if VarPepperConfiguration.Code <> VarPepperInstance."Configuration Code" then
            VarPepperConfiguration.Get(PepperInstance."Configuration Code");
        VarPepperConfiguration.TestField(Version);
        if VarPepperVersion.Code <> VarPepperConfiguration.Version then
            VarPepperVersion.Get(PepperConfiguration.Version);
        exit(true);
    end;

    procedure InstallTerminal(RegisterNo: Code[10]): Boolean
    var
        TxtNoInstallFile: Label 'No install zip file is linked to Pepper Version %1 %2. Please upload the installation package to the Pepper Version before installing.';
        PepperDLLVersion: Text;
    begin
        //-NPR5.22
        Register.Get(RegisterNo);
        Register.TestField("Credit Card Solution", Register."Credit Card Solution"::Pepper);
        if not FindTerminalSetupFromRegister(RegisterNo, PepperTerminal, PepperInstance, PepperConfiguration, PepperVersion) then begin
            if not TerminalSetupWizard(RegisterNo) then
                exit(false);
            PepperInstance.Get(PepperTerminal."Instance ID");
            PepperInstance.TestField("Configuration Code");
            PepperConfiguration.Get(PepperInstance."Configuration Code");
            PepperConfiguration.TestField(Version);
            PepperVersion.Get(PepperConfiguration.Version);
        end;
        PepperVersion.CalcFields("Install Zip File");
        if not PepperVersion."Install Zip File".HasValue then begin
            //-NPR5.25
            Message(TxtNoInstallFile, PepperVersion.Code, PepperVersion.Description);
            //MESSAGE(TxtNoInstallFile);
            //+NPR5.25

            exit(false);
        end;

        PepperLibrary.SetPepperConfiguration(PepperTerminal, PepperInstance, PepperConfiguration, PepperVersion);
        //-NPR5.25
        if PepperLibrary.InstallPepperDLL(SaleLinePOS."Sales Ticket No.", PepperVersion.Code, PepperDLLVersion) then begin
            //IF PepperLibrary.InstallPepperDLL(SaleLinePOS."Sales Ticket No.",PepperConfigManagement.GetZipFileAsText(PepperVersion),PepperVersion."Install Directory",PepperDLLVersion) THEN BEGIN
            //+NPR5.25
            if (PepperDLLVersion <> '') and (PepperVersion."Pepper DLL Version" <> PepperDLLVersion) then begin
                PepperVersion."Pepper DLL Version" := PepperDLLVersion;
                PepperVersion.Modify(true);
            end;
        end else
            exit(false);
        exit(true);
        //+NPR5.22
    end;

    local procedure TerminalSetupWizard(RegisterNo: Code[10]): Boolean
    var
        TextNewExisting: Label 'This register is not linked to a terminal. Do you want to link to a terminal that is already set up?';
        TextNoTerminals: Label 'No terminals have been set up.';
        TextNoFreeExisting: Label 'All terminals that are set up are already linked to other registers. Would you like to select one of anyway?';
        TextPleaseChoose: Label 'Please select the %1.';
        TextPleaseChooseNew: Label 'Please select a %1 for the new Terminal.';
        TextNoRecords: Label 'No %1 records have been found. Please set up a %1 first.';
        TextChooseCode: Label 'Please complete the setup with a code and description.';
        PepperTerminalList: Page "NPR Pepper Terminal List";
        PepperVersionList: Page "NPR Pepper Version List";
        PepperConfigurationList: Page "NPR Pepper Config. List";
        PepperInstances: Page "NPR Pepper Instances";
        PepperTerminalCard: Page "NPR Pepper Terminal Card";
        PepperTerminalTypes: Page "NPR Pepper Terminal Types";
        PepperTerminalType: Record "NPR Pepper Terminal Type";
    begin
        if Confirm(TextNewExisting) then begin
            //Link to Existing
            PepperTerminal.Reset;
            if PepperTerminal.IsEmpty then begin
                Message(TextNoTerminals);
                exit(false);
            end;
            PepperTerminal.SetFilter("Register No.", '=%1', '');
            if PepperTerminal.IsEmpty then
                if not Confirm(TextNoFreeExisting) then
                    exit(false)
                else
                    PepperTerminal.SetRange("Register No.");
            PepperTerminalList.LookupMode(true);
            PepperTerminalList.Caption := StrSubstNo(TextPleaseChoose, PepperTerminal.TableCaption());
            PepperTerminalList.SetTableView(PepperTerminal);
            if PepperTerminalList.RunModal = ACTION::LookupOK then begin
                PepperTerminalList.GetRecord(PepperTerminal);
            end else
                exit(false);
        end else begin
            //Determine Parameters for new terminal
            PepperVersion.Reset;
            if PepperVersion.IsEmpty then begin
                Message(StrSubstNo(TextNoRecords, PepperVersion.TableCaption()));
                exit(false);
            end;
            if PepperVersion.Count = 1 then begin
                PepperVersion.FindFirst
            end else begin
                PepperVersionList.LookupMode(true);
                PepperVersionList.Caption := StrSubstNo(TextPleaseChooseNew, PepperVersion.TableCaption());
                PepperVersionList.SetTableView(PepperVersion);
                if PepperVersionList.RunModal = ACTION::LookupOK then begin
                    PepperVersionList.GetRecord(PepperVersion);
                end else
                    exit(false);
            end;
            PepperConfiguration.Reset;
            PepperConfiguration.SetRange(Version, PepperVersion.Code);
            if PepperConfiguration.IsEmpty then begin
                Message(StrSubstNo(TextNoRecords, PepperConfiguration.TableCaption()));
                exit(false);
            end;
            if PepperConfiguration.Count = 1 then begin
                PepperConfiguration.FindFirst
            end else begin
                PepperConfigurationList.LookupMode := true;
                PepperConfigurationList.Caption := StrSubstNo(TextPleaseChooseNew, PepperConfiguration.TableCaption());
                PepperConfigurationList.SetTableView(PepperConfiguration);
                if PepperConfigurationList.RunModal = ACTION::LookupOK then begin
                    PepperConfigurationList.GetRecord(PepperConfiguration);
                end else
                    exit(false);
            end;
            PepperInstance.Reset;
            PepperInstance.SetRange("Configuration Code", PepperConfiguration.Code);
            if PepperInstance.IsEmpty then begin
                Message(StrSubstNo(TextNoRecords, PepperInstance.TableCaption()));
                exit(false);
            end;
            if PepperInstance.Count = 1 then begin
                PepperInstance.FindFirst
            end else begin
                PepperInstances.LookupMode := true;
                PepperInstances.Caption := StrSubstNo(TextPleaseChooseNew, PepperInstance.TableCaption());
                PepperInstances.SetTableView(PepperInstance);
                if PepperInstances.RunModal = ACTION::LookupOK then begin
                    PepperInstances.GetRecord(PepperInstance);
                end else
                    exit(false);
            end;
            PepperTerminalType.Reset;
            PepperTerminalType.SetRange(PepperTerminalType.Active, true);
            if PepperTerminalType.IsEmpty then begin
                Message(StrSubstNo(TextNoRecords, PepperTerminalType.TableCaption()));
                exit(false);
            end;
            if PepperTerminalType.Count = 1 then begin
                PepperTerminalType.FindFirst
            end else begin
                PepperTerminalTypes.LookupMode := true;
                PepperTerminalTypes.Caption := StrSubstNo(TextPleaseChooseNew, PepperTerminalType.TableCaption());
                PepperTerminalTypes.SetTableView(PepperTerminalType);
                if PepperTerminalTypes.RunModal = ACTION::LookupOK then begin
                    PepperTerminalTypes.GetRecord(PepperTerminalType);
                end else
                    exit(false);
            end;

            //Create and show new terminal
            PepperTerminal.Init;
            PepperTerminal.Code := 'TERM00';
            repeat
                PepperTerminal.Code := IncStr(PepperTerminal.Code);
            until PepperTerminal.Insert(true) or (PepperTerminal.Code = 'TERM99');
            PepperTerminal.Validate("Instance ID", PepperInstance.ID);
            PepperTerminal.Validate("Register No.", RegisterNo);
            PepperTerminal.Validate("Terminal Type Code", PepperTerminalType.ID);
            PepperTerminal.Modify(true);
            Commit;
            PepperTerminalCard.SetRecord(PepperTerminal);
            PepperTerminalCard.Caption := TextChooseCode;
            PepperTerminalCard.LookupMode := true;
            if PepperTerminalCard.RunModal = ACTION::LookupOK then begin
                PepperTerminalCard.GetRecord(PepperTerminal);
            end else
                exit(false);
        end;
    end;

    procedure FindTerminalCode(Register: Record "NPR Register"): Code[10]
    begin
        //-NPR5.27 [255131]
        if FindTerminalSetupFromRegister(Register."Register No.", PepperTerminal, PepperInstance, PepperConfiguration, PepperVersion) then
            exit(PepperTerminal.Code)
        else
            exit('');
        //+NPR5.27 [255131]
    end;

    procedure GetAuthNoParameters(var MinCharacters: Integer; var MaxCharacters: Integer)
    begin
        //-NPR5.34 [268697]
        MinCharacters := PepperConfiguration."Min. Length Authorisation No.";
        if PepperConfiguration."Max. Length Authorisation No." > 0 then
            MaxCharacters := PepperConfiguration."Max. Length Authorisation No."
        else
            MaxCharacters := 16;
        //+NPR5.34 [268697]
    end;

    procedure CalcCashBackAmount(TransactionAmount: Decimal; RegisterNo: Code[10]; SalesTicketNo: Code[20]) CashBackAmount: Decimal
    var
        LocSaleLinePOS: Record "NPR Sale Line POS";
        SalesAmount: Decimal;
        PaymentAmount: Decimal;
    begin
        //-NPR5.35 [284379]
        if SalesTicketNo = '' then
            exit;
        if RegisterNo = '' then
            exit;
        LocSaleLinePOS.Reset;
        LocSaleLinePOS.SetRange("Register No.", RegisterNo);
        LocSaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        if LocSaleLinePOS.FindSet then
            repeat
                case LocSaleLinePOS."Sale Type" of
                    LocSaleLinePOS."Sale Type"::Sale:
                        SalesAmount := SalesAmount + LocSaleLinePOS."Amount Including VAT";
                    LocSaleLinePOS."Sale Type"::"Debit Sale":
                        SalesAmount := SalesAmount + LocSaleLinePOS."Amount Including VAT";
                    LocSaleLinePOS."Sale Type"::"Credit Voucher":
                        SalesAmount := SalesAmount + LocSaleLinePOS."Amount Including VAT";
                    LocSaleLinePOS."Sale Type"::"Gift Voucher":
                        SalesAmount := SalesAmount + LocSaleLinePOS."Amount Including VAT";
                    //-NPR5.38 [301053]
                    //LocSaleLinePOS."Sale Type"::"Debit Sale" :
                    //  SalesAmount := SalesAmount + LocSaleLinePOS."Amount Including VAT";
                    //+NPR5.38 [301053]
                    LocSaleLinePOS."Sale Type"::"Out payment":
                        PaymentAmount := PaymentAmount - LocSaleLinePOS."Amount Including VAT";
                    LocSaleLinePOS."Sale Type"::Payment:
                        PaymentAmount := PaymentAmount + LocSaleLinePOS."Amount Including VAT";
                end;
            until LocSaleLinePOS.Next = 0;
        CashBackAmount := PaymentAmount - SalesAmount;
        if CashBackAmount < 0 then
            CashBackAmount := 0;
        //+NPR5.35 [284379]
    end;
}

