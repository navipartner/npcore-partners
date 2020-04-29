codeunit 6184480 "Pepper Library"
{
    // NPR5.20/BR/20160322 Pepper Library
    // NPR5.22/BR/20160329 Support DDMMYYYY and YYYYMMDD
    // NPR5.22\BR\20160407  CASE 231481 Added Result Display Text
    // NPR5.22\BR\20160412  CASE 231481 Added Support for offline mode
    // NPR5.22\BR\20160412  CASE 231481 Change the way recoveries work
    // NPR5.22\BR\20160422  CASE 231481 Fixed the TINA Deactivation
    // NPR5.25\BR\20160504  CASE 231481 Bugfixed the refund/void, changed order of parameters
    // NPR5.25/BR/20160509  CASE 231481 Added Check on Fixed Currency Code
    // NPR5.25/BR/20160509  CASE 231481 Set default codeunits
    // NPR5.25/BR/20160608  CASE 231481 Get License from Terminal instead of Configuration
    // NPR5.27/BR/20161025  CASE 256257 Only display signature text if there are 2 receipts.
    // NPR5.28/BR/20161130  CASE 259563 Do not display error message for a first attempt that will be retried
    // NPR5.28/BR/20161205  CASE 260190 Fix the displaying Error Messages: moved local text constants to Global
    // NPR5.29/BR/20161221  CASE 261673 Added Nets requirement for signature confirmation
    // NPR5.29/BR/20161230  CASE 262269 Added Functions GetKeyFromLicenseText and GetTerminalTypeFromLicenseText
    // NPR5.30/BR/20170113  CASE 263458 Added support for Integration Type
    // NPR5.30.02/BR/20170424  CASE 273339 Bugfix processing Pepper Payments
    // NPR5.34/BR /20170608  CASE 268698 Added support for voiding refunds
    // NPR5.35/BR /20170815  CASE 284379 Added support for Cashback
    // NPR5.38/BR /20171129  CASE 298176 Error when processing Transaction Request with multiple updates and multiple comments


    trigger OnRun()
    var
        Choice: Integer;
    begin
        SetConfigFromTerminal('TERMINAL1');
        Choice := StrMenu ('Open Eft,Recovery,Payment Of Goods,Ticket Reprint,Close',1,'Select EFT Function to test');
        case Choice of
          1 : EftOpen ('1',false);
          2 : Error ('not available now.');
          //-NPR5.35 [284379]
          //3 : EftPayment ('SALESTICKET1', 1753.67, 'EUR', '1234567890');
          3 : EftPayment ('SALESTICKET1', 1753.67, 0, 'EUR', '1234567890');
          //+NPR5.35 [284379]
          4 : EftAuxFunction ('SALESTICKET1',AuxFunctions::TICKETREPRINT);
          5 : EftClose ('SALESTICKET1',true);
        end;
    end;

    var
        PepperTerminal: Record "Pepper Terminal";
        PepperInstance: Record "Pepper Instance";
        PepperConfiguration: Record "Pepper Configuration";
        PepperVersion: Record "Pepper Version";
        EFTTransactionType: Record "Pepper EFT Transaction Type";
        Register: Record Register;
        CommentText: array [20] of Text;
        OpenReceiptText: Text;
        CloseReceiptText: Text;
        EndOfDayReceiptText: Text;
        CustomerReceiptText: Text;
        MerchantReceiptText: Text;
        RecoveryReceiptText: Text;
        CardNameText: Text[24];
        CardNumberText: Text[30];
        CardExpiryDate: Text[4];
        CardTypeText: Text[4];
        ReferenceNumberIn: Text[12];
        AmountIn: Decimal;
        CurrencyCodeIn: Code[10];
        ReferenceNumberOut: Text[12];
        AmountOut: Decimal;
        AuthorizationNumber: Text[16];
        TerminalID: Text[30];
        TransactionDateText: Text[8];
        TransactionTimeText: Text[6];
        TransactionDate: Date;
        TransactionTime: Time;
        ReceiptSignature: Option "0","1","2";
        BookkeepingPeriod: Text[4];
        TransactionStarted: DateTime;
        RecoveryStarted: DateTime;
        ProxyDialog: Page "Proxy Dialog";
        TransactionRequestEntryNo: Integer;
        TransactionRequestRecoveryEntryNo: Integer;
        Text100: Label 'Pepper terminal setup not found.';
        Text101: Label 'Pepper Transaction Type %1 is not allowed for Testing! Please check the Pepper Configuration %2.';
        AuxFunctions: Option ,ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINADEACTIVATION,TINAQUERY,SHOWCUSTOMMENU;
        DisplayText: Text;
        Text102: Label 'Please set up a fixed Currency code for this terminal to allow Refunds of recovered transactions.';
        Text103: Label 'This result code was not found for Transaction Type %1, so taken from  %2.';
        Text104: Label 'Result code not found! ';
        Text105: Label 'This result code was not found for Transaction Type %1, so taken from %2. The detailed description is: %3.';
        TextErrorMessage: Label 'The terminal transaction %1 failed\Error: %2 %3\%4\This error is logged in Transaction Request Entry %5';
        Text200: Label 'Treibauf Pepper EFT Universal Connector';
        TextUnsupportedRefund: Label 'Unsupported refund option.';
        CashBackAmount: Decimal;

    procedure SetPepperConfiguration(ParPepperTerminal: Record "Pepper Terminal";ParPepperInstance: Record "Pepper Instance";ParPepperConfiguration: Record "Pepper Configuration";ParPepperVersion: Record "Pepper Version")
    begin
        PepperTerminal := ParPepperTerminal;
        PepperInstance := ParPepperInstance;
        PepperConfiguration := ParPepperConfiguration;
        PepperVersion := ParPepperVersion;
    end;

    procedure InstallPepperDLL(SalesTicketNo: Text;PepperVersionCode: Code[10];var DLLVersion: Text): Boolean
    var
        ResultCode: Integer;
        PepperClientInstall: Codeunit "Pepper File Mgmt. Functions";
        PreviousDLLVersion: Text;
        Text001: Label 'DLL version: %1';
        Text002: Label 'Previous DLL version: %1';
        Text003: Label 'Install failed with error: %1';
    begin
        TransactionStarted := CurrentDateTime;
        TestConfig(0);
        CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Install Code",SalesTicketNo);
        Commit;

        PepperClientInstall.InitializeProtocol ();
        PepperClientInstall.SetTimout (GetTimeout(PepperConfiguration."Transaction Type Install Code"));
        PepperClientInstall.SetPepperVersionToInstall (PepperVersionCode);
        if PepperVersion."Codeunit Install" = 0 then
          PepperVersion."Codeunit Install" := CODEUNIT::"Pepper File Mgmt. Functions";
        ProxyDialog.RunProtocolModal(PepperVersion."Codeunit Install");

        Clear(ProxyDialog);
        ResultCode := PepperClientInstall.GetResultCode ();
        DLLVersion :=  PepperClientInstall.GetInstalledVersion ();
        PreviousDLLVersion := PepperClientInstall.GetPreviousVersion;
        //-NPR5.30 [263458]
        //IF NOT IsSuccessfulResultCode(PepperConfiguration."Transaction Type Open Code",ResultCode) THEN
        if not IsSuccessfulResultCode(PepperConfiguration."Transaction Type Install Code",'',ResultCode) then
        //+NPR5.30 [263458]
          AddCommentText(StrSubstNo(Text003,PepperClientInstall.GetExceptionText));
        AddCommentText(StrSubstNo(Text001,DLLVersion));
        AddCommentText(StrSubstNo(Text002,PreviousDLLVersion));

        UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Install Code",ResultCode);
        Commit;
        //-NPR5.30 [263458]
        //EXIT (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Open Code",ResultCode));
        exit (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Install Code",'',ResultCode));
        //+NPR5.30 [263458]
    end;

    procedure EftOpen(SalesTicketNo: Code[20];ForceDownloadLicense: Boolean) Success: Boolean
    var
        RecoveredEFTTransactionRequest: Record "EFT Transaction Request";
        PepperConfigManagement: Codeunit "Pepper Config. Management";
        PepperBeginWorkshift: Codeunit "Pepper Begin Workshift";
        ResultCode: Integer;
        OptionInt: Integer;
        Recovered: Boolean;
        MaxAttempts: Integer;
        Attempt: Integer;
        RecoveryAmount: Decimal;
        RecoveryCurrency: Code[10];
        RecoveryReferenceNo: Text[12];
        Text001: Label 'Transaction %1 of amount %2 %3 was succesfully recovered but could not be refunded.';
        RecoveryState: Option Failed,"Not Paid",Paid;
        Text002: Label 'Transaction was succesfully recovered and refunded.';
        LicenseString: Text;
        CustomerID: Text[8];
        LicenseID: Text[8];
        BText: BigText;
        OStream: OutStream;
    begin
        RecoveryStarted := 0DT;
        TransactionStarted := CurrentDateTime;
        TestConfig(0);

        PepperVersion.TestField("Codeunit Begin Workshift");

        // Initialize Stargate Protocol
        PepperBeginWorkshift.InitializeProtocol ();
        PepperBeginWorkshift.SetPepperFolder(PepperVersion."Install Directory");

        // Initialize Pepper Library (client side)
        PepperBeginWorkshift.SetILP_UseConfigurationInstanceId (PepperInstance.ID);
        PepperBeginWorkshift.SetILP_XmlConfigurationString (PepperConfigManagement.GetConfigurationText(PepperConfiguration,1));
        //-NPR5.25 [231481]
        //PepperBeginWorkshift.SetILP_XmlLicenseString (PepperConfigManagement.GetConfigurationText(PepperConfiguration,0));
        LicenseString := PepperConfigManagement.GetTerminalText(PepperTerminal,0);
        if ForceDownloadLicense or (LicenseString = '') then begin
          CustomerID := PepperConfigManagement.GetCustomerID(PepperTerminal);
          LicenseID := PepperConfigManagement.GetLicenseID(PepperTerminal);
          if (CustomerID <> '') and (LicenseID <> '') then begin
            PepperBeginWorkshift.SetILP_ForceGetPepperLicense(LicenseID,CustomerID);
          end;
        end;
        if LicenseString <> '' then
          PepperBeginWorkshift.SetILP_XmlLicenseString (LicenseString);
        //+NPR5.25 [231481]

        // Configure Driver
        PepperBeginWorkshift.SetCDP_ComPort (PepperTerminal."Com Port");
        PepperBeginWorkshift.SetCDP_IpAddressAndPort (PepperTerminal."IP Address");
        Evaluate(OptionInt,Format(PepperTerminal.Language,20,'<Number>'));
        PepperBeginWorkshift.SetCDP_EftTerminalInformation (PepperTerminal."Terminal Type Code",OptionInt, PepperConfigManagement.GetPepperRegisterNo(PepperTerminal."Register No."),Format(PepperTerminal."Receipt Format"));
        PepperBeginWorkshift.SetCDP_Filenames (PepperTerminal."Print File Open",PepperTerminal."Print File Close",
                                               PepperTerminal."Print File Transaction",PepperTerminal."Print File CC Transaction",
                                               PepperTerminal."Print File Difference",PepperTerminal."Print File End of Day",
                                               PepperTerminal."Print File Journal",PepperTerminal."Print File Initialisation");
        Evaluate(OptionInt,Format(PepperTerminal."Matchbox Files",20,'<Number>'));
        PepperBeginWorkshift.SetCDP_MatchboxInformation (OptionInt, PepperTerminal."Matchbox Company ID", PepperTerminal."Matchbox Shop ID", PepperTerminal."Matchbox POS ID", PepperTerminal."Matchbox File Name");
        //-NPR5.25 [231481]
        //PepperBeginWorkshift.SetCDP_AdditionalParameters (PepperConfigManagement.GetTerminalText(PepperTerminal,0));
        PepperBeginWorkshift.SetCDP_AdditionalParameters (PepperConfigManagement.GetTerminalText(PepperTerminal,1));
        //+NPR5.25 [231481]

        // Open EFT
        PepperBeginWorkshift.SetPOP_Operator (1);
        PepperBeginWorkshift.SetPOP_AdditionalParameters ('');
        PepperBeginWorkshift.SetTimout(GetTimeout(PepperConfiguration."Transaction Type Open Code"));
        PepperBeginWorkshift.SetReceiptEncoding(GetPepperReceiptEncoding,GetNavReceiptEncoding);

        // Header and footers to receipts by pepper on client side
        case PepperConfiguration."Header and Footer Handling" of
            PepperConfiguration."Header and Footer Handling"::"Manual Headers and Footers" :
            begin
              PepperBeginWorkshift.SetHeaderFooters (false, PepperConfiguration."Ticket Directory",'', '', '', '', '', '');
            end;
          PepperConfiguration."Header and Footer Handling"::"Send Headers and Footers to Terminal":
            begin
              GetRegister(PepperTerminal."Register No.");
              PepperBeginWorkshift.SetHeaderFooters (true, PepperConfiguration."Ticket Directory",
                                                     PepperConfigManagement.GetHeaderFooterText(Register,0,0), PepperConfigManagement.GetHeaderFooterText(Register,0,1),
                                                     PepperConfigManagement.GetHeaderFooterText(Register,1,0), PepperConfigManagement.GetHeaderFooterText(Register,1,1),
                                                     PepperConfigManagement.GetHeaderFooterText(Register,2,0), PepperConfigManagement.GetHeaderFooterText(Register,2,1));
            end;
          PepperConfiguration."Header and Footer Handling"::"Add Headers and Footers at Printing",PepperConfiguration."Header and Footer Handling"::"No Headers and Footers" :
            begin
              PepperBeginWorkshift.SetHeaderFooters (true, PepperConfiguration."Ticket Directory",'', '', '', '', '', '');
            end;
        end;

        if CheckTestMode then begin
          ResultCode := 10;
          OpenReceiptText := '**** This is a TEST Open Receipt ****';
          CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Open Code",SalesTicketNo);
          UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Open Code",ResultCode);
          exit(true);
        end;
        CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Open Code",SalesTicketNo);
        Commit;
        if PepperVersion."Codeunit Begin Workshift" = 0 then
          PepperVersion."Codeunit Begin Workshift" := CODEUNIT::"Pepper Begin Workshift";
        ProxyDialog.RunProtocolModal(PepperVersion."Codeunit Begin Workshift");
        Clear(ProxyDialog);
        ResultCode := PepperBeginWorkshift.GetPOP_ResultCode ();
        OpenReceiptText := PepperBeginWorkshift.GetPOP_OpenReceipt ();
        UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Open Code",ResultCode);

        //-NPR5.25 [231481]
        if (LicenseString = '') or ForceDownloadLicense then begin
          if PepperBeginWorkshift.GetILP_XmlLicenseString(LicenseString) then begin
            PepperTerminal.StoreLicense(LicenseString);
          end;
        end;
        //+NPR5.25 [231481]

        if (PepperBeginWorkshift.GetCDP_RecoveryRequired ()) then begin
          Recovered := false;
          MaxAttempts := PepperConfiguration."Recovery Retry Attempts";
          if (MaxAttempts <= 0) or (MaxAttempts > 99) then
            MaxAttempts := 3;
          Attempt := 0;
          repeat
            //-NPR5.28 [259563]
            ClearGlobals;
            //+NPR5.28 [259563]
            Attempt := Attempt + 1;
            Commit;
            Recovered := EftRecovery(SalesTicketNo,RecoveryAmount,RecoveryCurrency,RecoveryReferenceNo,RecoveryState);
            if Recovered then begin
              Commit;
              if RecoveryState = RecoveryState :: Paid then begin
                //-NPR5.28 [259563]
                if RecoveryCurrency = '' then begin
                  RecoveryCurrency := PepperTerminal."Fixed Currency Code";
                  if RecoveryCurrency = '' then
                    AddCommentText(Text102);
                end;
                //+NPR5.28 [259563]
                RecoveredEFTTransactionRequest.SetRange("Processing Type",RecoveredEFTTransactionRequest."Processing Type"::PAYMENT);
                RecoveredEFTTransactionRequest.SetRange("Pepper Terminal Code",PepperTerminal.Code);
                if RecoveredEFTTransactionRequest.FindLast then begin
                  if RecoveredEFTTransactionRequest.Finished = 0DT then begin
                    if not EftRefund (SalesTicketNo,RecoveryAmount,1,RecoveredEFTTransactionRequest."Currency Code",RecoveryReferenceNo) then begin
                      AddCommentText(StrSubstNo(Text001,RecoveryAmount,RecoveryCurrency,RecoveryReferenceNo));
                    end else begin
                      AddCommentText(StrSubstNo(Text002,RecoveryAmount,RecoveryCurrency,RecoveryReferenceNo));
                      TransactionRequestEntryNo := RecoveredEFTTransactionRequest."Entry No.";
                      UpdateEFTTransactionRequestLine(RecoveredEFTTransactionRequest."Pepper Transaction Type Code",ResultCode);
                    end;
                  end else begin
                    if not EftRefund (SalesTicketNo,RecoveryAmount,0,RecoveryCurrency,RecoveryReferenceNo) then begin
                      AddCommentText(StrSubstNo(Text001,RecoveryAmount,RecoveryCurrency,RecoveryReferenceNo));
                    end;
                  end;
                end else begin
                  if not EftRefund (SalesTicketNo,RecoveryAmount,0,RecoveryCurrency,RecoveryReferenceNo) then begin
                    AddCommentText(StrSubstNo(Text001,RecoveryAmount,RecoveryCurrency,RecoveryReferenceNo));
                  end;
                end;
              end;
            end;
          until (Attempt = MaxAttempts) or Recovered;
        end;
        Commit;
        //-NPR5.30 [263458]
        //EXIT (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Open Code",ResultCode));
        exit (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Open Code",'',ResultCode));
        //+NPR5.30 [263458]
    end;

    procedure EftClose(SalesTicketNo: Code[20];EndOfDayReport: Boolean) Success: Boolean
    var
        PepperEndWorkshift: Codeunit "Pepper End Workshift";
        ResultCode: Integer;
    begin
        TransactionStarted := CurrentDateTime;
        TestConfig(2);
        PepperEndWorkshift.InitializeProtocol ();
        PepperVersion.TestField("Codeunit End Workshift");
        //-NPR5.22
        //PepperEndWorkshift.SetOptions (EndOfDayReport ,FALSE);
        //PepperEndWorkshift.SetOptions (EndOfDayReport ,FALSE, FALSE);
        if PepperConfiguration."End of Day on Close" then
          EndOfDayReport := true;
        PepperEndWorkshift.SetOptions (EndOfDayReport, PepperConfiguration."Unload Library on Close", PepperConfiguration."End of Day Receipt Mandatory");
        //+NPR5.22
        PepperEndWorkshift.SetTimout(GetTimeout(PepperConfiguration."Transaction Type Close Code"));
        PepperEndWorkshift.SetReceiptEncoding(GetPepperReceiptEncoding,GetNavReceiptEncoding);
        if CheckTestMode then begin
          ResultCode := 10;
          CloseReceiptText :=  '**** This is a TEST Close Receipt ****';
          EndOfDayReceiptText := '**** This is a TEST End of Day Receipt ****';
          CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Close Code",SalesTicketNo);
          UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Close Code",ResultCode);
          exit(true);
        end;
        CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Close Code",SalesTicketNo);
        Commit;
        if PepperVersion."Codeunit End Workshift" = 0 then
          PepperVersion."Codeunit End Workshift" := CODEUNIT::"Pepper End Workshift";
        ProxyDialog.RunProtocolModal(PepperVersion."Codeunit End Workshift");
        Clear(ProxyDialog);
        ResultCode := PepperEndWorkshift.GetResultCode ();

        CloseReceiptText := PepperEndWorkshift.GetCloseReceipt ();
        EndOfDayReceiptText := PepperEndWorkshift.GetEndOfDayReceipt ();

        UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Close Code",ResultCode);

        //-NPR5.30 [263458]
        //EXIT (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Close Code",ResultCode));
        exit (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Close Code",'',ResultCode));
        //+NPR5.30 [263458]
    end;

    procedure EftPayment(SalesTicketNo: Code[20];Amount: Decimal;pCashbackAmount: Decimal;CurrencyCode: Code[10];ReferenceNumber: Text[12]) Success: Boolean
    var
        PepperTrxTransaction: Codeunit "Pepper Trx Transaction";
    begin
        //-NPR5.35 [284379]
        //EXIT (EftPaymentComplete (SalesTicketNo, Amount, CurrencyCode, ReferenceNumber, 0, '', ''));
        exit (EftPaymentComplete (SalesTicketNo, Amount, pCashbackAmount, CurrencyCode, ReferenceNumber, 0, '', ''));
        //+NPR5.35 [284379]
    end;

    procedure EftPaymentComplete(SalesTicketNo: Code[20];Amount: Decimal;pCashbackAmount: Decimal;CurrencyCode: Code[10];ReferenceNumber: Text[12];MsrTrackPresence: Integer;CardInformation: Text;MbxPosReference: Text[20]) Success: Boolean
    var
        PepperTrxTransaction: Codeunit "Pepper Trx Transaction";
        ResultCode: Integer;
        Approved: Boolean;
        AmountInCents: Integer;
        Timeout: Integer;
        Offline: Boolean;
        CashBackAmountInCents: Integer;
    begin
        TransactionStarted := CurrentDateTime;
        TestConfig(1);
        //-NPR5.25
        if PepperTerminal."Fixed Currency Code" <> '' then begin
          PepperTerminal.TestField("Fixed Currency Code",CurrencyCode);
        end;
        //+NPR5.25
        PepperTrxTransaction.InitializeProtocol ();
        ReferenceNumberIn := ReferenceNumber;
        AmountIn := Amount;
        //-NPR5.35 [284379]
        CashBackAmount := pCashbackAmount;
        //+NPR5.35 [284379]
        CurrencyCodeIn := CurrencyCode;
        //PepperVersion.TESTFIELD(PepperVersion."Codeunit Transaction");
        AmountInCents := CalcAmountInCents(Amount,CurrencyCode);
        PepperTrxTransaction.SetTimout(GetTimeout(PepperConfiguration."Transaction Type Payment Code"));
        PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding,GetNavReceiptEncoding);
        //-NPR5.22
        //ResultCode := PepperTrxTransaction.SetPaymentOfGoods (Amount, AmountInCents, CurrencyCode, MsrTrackPresence, CardInformation, ReferenceNumber, MbxPosReference);
        Offline := (PepperTerminal.Status = PepperTerminal.Status::ActiveOffline);
        //-NPR5.35 [284379]
        //ResultCode := PepperTrxTransaction.SetPaymentOfGoods (Amount, AmountInCents, CurrencyCode, MsrTrackPresence, CardInformation, ReferenceNumber, MbxPosReference, Offline);
        CashBackAmountInCents := CalcAmountInCents(pCashbackAmount,CurrencyCode);
        ResultCode := PepperTrxTransaction.SetPaymentOfGoods (Amount, AmountInCents, CashBackAmountInCents, CurrencyCode, MsrTrackPresence, CardInformation, ReferenceNumber, MbxPosReference, Offline);
        //+NPR5.35 [284379]
        //+NPR5.22
        if ResultCode <= 0 then
          exit(false);
        Amount := CalcAmountInCurrency(AmountInCents,CurrencyCode);
        if CheckTestMode then begin
          ResultCode := 10;

          CardTypeText := '9999';
          CardNameText :=  'TEST Card Name';
          CardNumberText := '555444333222';
          CardExpiryDate := '1220';
          CheckCardInformation(CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
          ReferenceNumber := IncStr(ReferenceNumberIn);
          AuthorizationNumber := '9999';
          TerminalID := '9999';
          TransactionDateText := '31122017';
          TransactionTimeText := '173015';
          ReceiptSignature := 1;
          TransactionDate := GetTransactionDate(TransactionDateText);
          TransactionTime := GetTransactionTime(TransactionTimeText);
          CustomerReceiptText :=  '**** This is a TEST Customer Receipt ****';
          MerchantReceiptText :=  '**** This is a TEST Merchant Receipt ****';
          ReferenceNumberOut := ReferenceNumber;
          AmountOut := Amount;
          CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Payment Code",SalesTicketNo);
          UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Payment Code",ResultCode);
          exit(true);
        end;
        CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Payment Code",SalesTicketNo);
        Commit;
        if PepperVersion."Codeunit Transaction" = 0 then
          PepperVersion."Codeunit Transaction" := CODEUNIT::"Pepper Trx Transaction";
        ProxyDialog.RunProtocolModal(PepperVersion."Codeunit Transaction");
        Clear(ProxyDialog);
        ResultCode := PepperTrxTransaction.GetTrx_ResultCode ();

        //-NPR5.30 [263458]
        //Approved := (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Payment Code",ResultCode));
        Approved := (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Payment Code",'',ResultCode));
        //-NPR5.30 [263458]
        Amount := CalcAmountInCurrency(PepperTrxTransaction.GetTrx_Amount,CurrencyCode);
        PepperTrxTransaction.GetTrx_CardInformation (CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
        CheckCardInformation(CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
        PepperTrxTransaction.GetTrx_AuthorizationInfo (ReferenceNumber,TransactionDateText,TransactionTimeText,AuthorizationNumber,TerminalID,ReceiptSignature,BookkeepingPeriod);
        //-NPR5.22
        DisplayText := PepperTrxTransaction.GetTrx_DisplayText;
        //+NPR5.22
        TransactionDate := GetTransactionDate(TransactionDateText);
        TransactionTime := GetTransactionTime(TransactionTimeText);
        CustomerReceiptText := PepperTrxTransaction.GetTrx_CustomerReceipt ();
        MerchantReceiptText := PepperTrxTransaction.GetTrx_MerchantReceipt ();
        ReferenceNumberOut := ReferenceNumber;
        AmountOut := Amount;
        UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Payment Code",ResultCode);

        exit (Approved);
    end;

    procedure EftRefund(SalesTicketNo: Code[20];Amount: Decimal;RefundOrCancel: Option Refund,VoidPayment,VoidRefund;CurrencyCode: Code[10];ReferenceNumber: Text[12]) Success: Boolean
    var
        PepperTrxTransaction: Codeunit "Pepper Trx Transaction";
        ResultCode: Integer;
        Approved: Boolean;
        AmountInCents: Integer;
    begin
        TransactionStarted := CurrentDateTime;
        TestConfig(3);
        PepperTrxTransaction.InitializeProtocol ();
        ReferenceNumberIn := ReferenceNumber;
        AmountIn := Amount;
        CurrencyCodeIn := CurrencyCode;
        //PepperVersion.TESTFIELD(PepperVersion."Codeunit Transaction");
        AmountInCents := CalcAmountInCents(Amount,CurrencyCode);
        //-NPR5.22
        //IF ReferenceNumber  = LastReference(PepperTerminal.Code) THEN
        //-NPR5.34 [268698]
        //IF RefundOrCancel = RefundOrCancel :: Cancel THEN
        //+NPR5.22
        //  PepperTrxTransaction.SetVoidPaymentOfGoods (Amount, AmountInCents, CurrencyCode, ReferenceNumber)
        //ELSE
        //  PepperTrxTransaction.SetRefund  (Amount, AmountInCents, CurrencyCode, ReferenceNumber);
        case RefundOrCancel of
          RefundOrCancel::Refund :
            PepperTrxTransaction.SetRefund  (Amount, AmountInCents, CurrencyCode, ReferenceNumber);
          RefundOrCancel::VoidPayment :
            PepperTrxTransaction.SetVoidPaymentOfGoods (Amount, AmountInCents, CurrencyCode, ReferenceNumber);
          RefundOrCancel::VoidRefund :
            PepperTrxTransaction.SetVoidRefund (Amount, AmountInCents, CurrencyCode, ReferenceNumber);
          else
            Error(TextUnsupportedRefund);
        end;
        //+NPR5.34 [268698]
        PepperTrxTransaction.SetTimout(GetTimeout(PepperConfiguration."Transaction Type Refund Code"));
        PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding,GetNavReceiptEncoding);
        if CheckTestMode then begin
          ResultCode := 10;

          CardTypeText := '9999';
          CardNameText :=  'TEST Card Name';
          CardNumberText := '555444333222';
          CardExpiryDate := '1220';
          CheckCardInformation(CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
          ReferenceNumber := IncStr(ReferenceNumberIn);
          AuthorizationNumber := '9999';
          TerminalID := '9999';
          TransactionDateText := '31122017';
          TransactionTimeText := '173015';
          ReceiptSignature := 1;
          TransactionDate := GetTransactionDate(TransactionDateText);
          TransactionTime := GetTransactionTime(TransactionTimeText);
          CustomerReceiptText :=  '**** This is a TEST Customer Receipt ****';
          MerchantReceiptText :=  '**** This is a TEST Merchant Receipt ****';
          ReferenceNumberOut := ReferenceNumber;
          AmountOut := Amount;
          CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Refund Code",SalesTicketNo);
          UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Refund Code",ResultCode);
          exit(true);
        end;
        CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Refund Code", SalesTicketNo);
        Commit;
        if PepperVersion."Codeunit Transaction" = 0 then
          PepperVersion."Codeunit Transaction" := CODEUNIT::"Pepper Trx Transaction";
        ProxyDialog.RunProtocolModal(PepperVersion."Codeunit Transaction");
        Clear(ProxyDialog);
        ResultCode := PepperTrxTransaction.GetTrx_ResultCode ();

        //-NPR5.30 [263458]
        //Approved := (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Refund Code",ResultCode));
        Approved := (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Refund Code",'',ResultCode));
        //+NPR5.30 [263458]

        Amount := CalcAmountInCurrency(PepperTrxTransaction.GetTrx_Amount,CurrencyCode);
        PepperTrxTransaction.GetTrx_CardInformation (CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
        CheckCardInformation(CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
        PepperTrxTransaction.GetTrx_AuthorizationInfo (ReferenceNumber,TransactionDateText,TransactionTimeText,AuthorizationNumber,TerminalID,ReceiptSignature,BookkeepingPeriod);
        TransactionDate := GetTransactionDate(TransactionDateText);
        TransactionTime := GetTransactionTime(TransactionTimeText);

        CustomerReceiptText := PepperTrxTransaction.GetTrx_CustomerReceipt ();
        MerchantReceiptText := PepperTrxTransaction.GetTrx_MerchantReceipt ();
        ReferenceNumberOut := ReferenceNumber;
        AmountOut := Amount;
        UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Refund Code",ResultCode);

        exit (Approved);
    end;

    local procedure EftRecovery(SalesTicketNo: Code[20];var Amount: Decimal;var CurrencyCode: Code[10];var ReferenceNumber: Text[12];var State: Option Failed,"Not Paid",Paid) Success: Boolean
    var
        PepperTrxTransaction: Codeunit "Pepper Trx Transaction";
        ResultCode: Integer;
        ReceiptText: Text;
        Approved: Boolean;
    begin
        RecoveryStarted := CurrentDateTime;
        TestConfig(4);
        PepperTrxTransaction.InitializeProtocol ();
        ReferenceNumberIn := ReferenceNumber;
        AmountIn := Amount;
        CurrencyCodeIn := CurrencyCode;
        PepperTrxTransaction.SetRecovery ();
        PepperTrxTransaction.SetTimout(GetTimeout(PepperConfiguration."Transaction Type Recover Code"));
        PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding,GetNavReceiptEncoding);
        if CheckTestMode then begin
          ResultCode := 30;

          CardTypeText := '9999';
          CardNameText :=  'TEST Card Name';
          CardNumberText := '555444333222';
          CardExpiryDate := '1220';
          CheckCardInformation(CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
          ReferenceNumber := IncStr(ReferenceNumberIn);
          AuthorizationNumber := '9999';
          TerminalID := '9999';
          TransactionDateText := '31122017';
          TransactionTimeText := '173015';
          ReceiptSignature := 1;
          TransactionDate := GetTransactionDate(TransactionDateText);
          TransactionTime := GetTransactionTime(TransactionTimeText);
          CustomerReceiptText :=  '**** This is a TEST Customer Receipt ****';
          MerchantReceiptText :=  '**** This is a TEST Merchant Receipt ****';
          ReferenceNumberOut := ReferenceNumber;
          AmountOut := Amount;
          CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Recover Code",SalesTicketNo);
          UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Recover Code",ResultCode);
          exit(true);
        end;
        CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Recover Code", SalesTicketNo);
        Commit;
        if PepperVersion."Codeunit Transaction" = 0 then
          PepperVersion."Codeunit Transaction" := CODEUNIT::"Pepper Trx Transaction";
        ProxyDialog.RunProtocolModal(PepperVersion."Codeunit Transaction");
        Clear(ProxyDialog);
        ResultCode := PepperTrxTransaction.GetTrx_ResultCode ();
        //-NPR5.30 [263458]
        //Approved := IsSuccessfulResultCode(PepperConfiguration."Transaction Type Recover Code",ResultCode);
        Approved := IsSuccessfulResultCode(PepperConfiguration."Transaction Type Recover Code",'',ResultCode);
        //+NPR5.30 [263458]
        //-NPR5.22
        CustomerReceiptText := PepperTrxTransaction.GetTrx_CustomerReceipt ();
        //+NPR5.22
        case ResultCode of
          -10 : State := State :: "Not Paid" ;
          //-NPR5.22
          //30  : State := State :: Paid ;
          30  :  if CustomerReceiptText =  '' then
                   State := State :: "Not Paid"
                 else
                   State := State :: Paid;
          //+NPR5.22
          else
            State := State :: Failed;
        end;
        PepperTrxTransaction.GetTrx_CardInformation (CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
        CheckCardInformation(CardTypeText,CardNameText,CardNumberText,CardExpiryDate);
        PepperTrxTransaction.GetTrx_AuthorizationInfo (ReferenceNumber,TransactionDateText,TransactionTimeText,AuthorizationNumber,TerminalID,ReceiptSignature,BookkeepingPeriod);
        Amount := PepperTrxTransaction.GetTrx_Amount ();
        Amount := CalcAmountInCurrency(Amount ,CurrencyCode);
        //-NPR5.22
        //CustomerReceiptText := PepperTrxTransaction.GetTrx_CustomerReceipt ();
        //-NPR5.22
        ReferenceNumberOut := ReferenceNumber;
        AmountOut := Amount;
        UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Recover Code",ResultCode);

        exit (Approved);
    end;

    procedure EftTinaFunction(SalesTicketNo: Code[20]) Success: Boolean
    var
        TinaOptionText: Label 'Activate TINA,Deactivate TINA,TINA Status';
        ChooseTinaText: Label 'Please choose an TINA Function to send to the terminal.';
        TinaFunction: Option TINAACTIVATION,TINADEACTIVATION,TINAQUERY;
        AuxFunction: Option ,ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINADEACTIVATION,TINAQUERY;
    begin
        TinaFunction := DIALOG.StrMenu(TinaOptionText,3,ChooseTinaText);
        case TinaFunction of
          1 : AuxFunction := AuxFunction :: TINAACTIVATION;
          2 : AuxFunction := AuxFunction :: TINADEACTIVATION;
          3 : AuxFunction := AuxFunction :: TINAQUERY;
        end;
        Success := EftAuxFunction(SalesTicketNo,AuxFunction);
        exit(Success);
    end;

    procedure EftAuxFunction(SalesTicketNo: Code[20];Func: Option ,ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINADEACTIVATION,TINAQUERY,SHOWCUSTOMMENU) Succes: Boolean
    var
        PepperAuxFunctions: Codeunit "Pepper Aux Functions";
        ResultCode: Integer;
        StartResultText: Integer;
        EndResultText: Integer;
        AuxFunction: Label 'Auxiliary Function %1 called.';
        OptionText: Label 'ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINADEACTIVATION,TINAQUERY';
        ChooseAuxText: Label 'Please choose an Auxiliary Function to send to the terminal.';
        TextVar: Text;
    begin
        TransactionStarted := CurrentDateTime;
        TestConfig(5);
        Commit;
        if Func = 0 then begin
          Func := DIALOG.StrMenu(OptionText,1,ChooseAuxText);
        end;
        AddCommentText(StrSubstNo(AuxFunction,Format(Func)));
        CreateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Auxilary Code",SalesTicketNo);
        Commit;

        PepperAuxFunctions.InitializeProtocol ();
        PepperAuxFunctions.SetTimout(GetTimeout(PepperConfiguration."Transaction Type Auxilary Code"));
        PepperAuxFunctions.SetReceiptEncoding(GetPepperReceiptEncoding,GetNavReceiptEncoding);

        case Func of
          AuxFunctions::ABORT :
            PepperAuxFunctions.SetAbort();
          AuxFunctions::CUSTOMMENU :
            PepperAuxFunctions.SetShowCustomMenu ();
          AuxFunctions::DIAGNOSTICS :
            PepperAuxFunctions.SetGetDiagnostics (false); // setup required ?
          AuxFunctions::DISPWITHNUMINPUT :
            PepperAuxFunctions.SetDisplayShowText ('TEXT'); // custom text;
          AuxFunctions::PANSUPPRESSIONOFF :
            PepperAuxFunctions.SetPanSuppressionOff ();
          AuxFunctions::PANSUPPRESSIONON :
            PepperAuxFunctions.SetPanSuppressionOn ();
          AuxFunctions::SUMMARYREPORT :
            PepperAuxFunctions.SetGetSummaryReport (false); //setup required ?
          AuxFunctions::SYSTEMINFO :
            PepperAuxFunctions.SetGetSystemInfoTicket (false); // setup required ?
          AuxFunctions::TICKETREPRINT :
            PepperAuxFunctions.SetReprintLastTicket (true);
          AuxFunctions::TINAACTIVATION :
            PepperAuxFunctions.SetTinaActivation (''); // Setup required
          AuxFunctions::TINADEACTIVATION :
            //-NPR5.22
            //PepperAuxFunctions.SetTinaDeActivation (''); // Setup required
            PepperAuxFunctions.SetTinaDeactivation (''); // Setup required
            //+NPR5.22
          AuxFunctions::TINAQUERY :
            PepperAuxFunctions.SetTinaQuery (''); // Setup Required
          AuxFunctions::SHOWCUSTOMMENU :
            PepperAuxFunctions.SetShowCustomMenu ();
        end;

        Commit;
        ProxyDialog.RunProtocolModal (CODEUNIT::"Pepper Aux Functions");
        Clear(ProxyDialog);
        ResultCode := PepperAuxFunctions.GetResultCode ();

        case Func of
          AuxFunctions::DIAGNOSTICS,
          AuxFunctions::SUMMARYREPORT,
          AuxFunctions::SYSTEMINFO,
          AuxFunctions::TICKETREPRINT: begin
            CustomerReceiptText := PepperAuxFunctions.GetClientReceipt ();
            MerchantReceiptText := PepperAuxFunctions.GetMerchantReceipt ();
          end;

          AuxFunctions::TINAACTIVATION,
          AuxFunctions::TINADEACTIVATION,
          AuxFunctions::TINAQUERY : begin
            Message(PepperAuxFunctions.GetXmlResponse ());
            //CustomerReceiptText := PepperAuxFunctions.Get_XmlResponse ();
            //StartResultText := STRPOS(CustomerReceiptText,'<ResultText>') + 13;
            ///EndResultText := STRPOS(CustomerReceiptText,'</ResultText>');
        //    IF (EndResultText > 14) AND
        //       (StartResultText <> 0) THEN
        //       MESSAGE(CustomerReceiptText,StartResultText,EndResultText-StartResultText);
          end;
        end;

        UpdateEFTTransactionRequestLine(PepperConfiguration."Transaction Type Auxilary Code",ResultCode);

        //-NPR5.30 [263458]
        //EXIT (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Auxilary Code",ResultCode));
        exit (IsSuccessfulResultCode(PepperConfiguration."Transaction Type Auxilary Code",'',ResultCode));
        //+NPR5.30 [263458]
    end;

    procedure ReverseTransactionRequest(ParSalesTicketNo: Code[20];ParTransactionEntryNoToReverse: Integer) Success: Boolean
    var
        EFTTransactionRequestToReverse: Record "EFT Transaction Request";
    begin
        if not EFTTransactionRequestToReverse.Get(ParTransactionEntryNoToReverse) then
          exit(false);
        if not (EFTTransactionRequestToReverse."Processing Type" = EFTTransactionRequestToReverse."Processing Type"::PAYMENT) then
          exit(false);
        if not EFTTransactionRequestToReverse.Successful then
          exit(false);
        //-NPR5.22
        //IF EftRefund(ParSalesTicketNo,EFTTransactionRequestToReverse."Amount Output",EFTTransactionRequestToReverse."Currency Code",EFTTransactionRequestToReverse."Reference Number Output") THEN BEGIN
        if EftRefund(ParSalesTicketNo,EFTTransactionRequestToReverse."Amount Output",0,EFTTransactionRequestToReverse."Currency Code",EFTTransactionRequestToReverse."Reference Number Output") then begin
        //-NPR5.22
          if AmountOut <> EFTTransactionRequestToReverse."Amount Output" then begin
            exit(false);
          end else begin
            EFTTransactionRequestToReverse.Reversed := true;
            EFTTransactionRequestToReverse."Reversed by Entry No." := TransactionRequestEntryNo;
            EFTTransactionRequestToReverse.Modify(true);
            Commit;
            exit(true);
          end;
        end else begin
          exit(false);
        end;
    end;

    procedure GetReceiptText(ReceiptType: Option Open,Close,EndOfDay,Customer,Merchart,Recovery): Text
    begin
        case ReceiptType of
          ReceiptType::Open :
            exit(OpenReceiptText);
          ReceiptType::Close :
            exit(CloseReceiptText);
          ReceiptType::EndOfDay :
            exit(EndOfDayReceiptText);
          ReceiptType::Customer :
            exit(CustomerReceiptText);
          ReceiptType::Merchart :
            exit(MerchantReceiptText);
          ReceiptType::Recovery :
            exit(RecoveryReceiptText);
          else
            exit('');
        end;
    end;

    procedure GetEFTTransactionRequest(var VarEFTTransactionRequest: Record "EFT Transaction Request")
    begin
        if TransactionRequestEntryNo = 0 then
          exit;
        VarEFTTransactionRequest.Get(TransactionRequestEntryNo);
    end;

    procedure GetEFTRecoveryTransactionRequest(var VarEFTTransactionRequest: Record "EFT Transaction Request")
    begin
        if TransactionRequestRecoveryEntryNo = 0 then
          exit;
        VarEFTTransactionRequest.Get(TransactionRequestRecoveryEntryNo);
    end;

    local procedure IsSuccessfulResultCode(ParTransactionType: Code[10];ParTransactionSubtype: Code[10];ParResultCode: Integer): Boolean
    var
        EFTResultCode: Record "Pepper EFT Result Code";
    begin
        //-NPR5.30 [263458]
        //IF PepperResultCode.GET(ParTransactionType,ParResultCode) THEN
        if EFTResultCode.Get(GetPepperIntegrationTypeCode,ParTransactionType,ParTransactionSubtype,ParResultCode) then
        //-NPR5.30 [263458]
          exit(EFTResultCode.Successful)
        else
          //-NPR5.30 [263458]
          //IF EFTResultCode.GET('',ParResultCode) THEN
          //  EXIT(EFTResultCode.Successful)
          if EFTResultCode.Get(GetPepperIntegrationTypeCode,ParTransactionType,'',ParResultCode) then
            exit(EFTResultCode.Successful)
          else
            if EFTResultCode.Get(GetPepperIntegrationTypeCode,'','',ParResultCode) then
              exit(EFTResultCode.Successful)
          //-NPR5.30 [263458]
          else begin
            EFTResultCode.Reset;
            EFTResultCode.SetRange(Code,ParResultCode);
            if EFTResultCode.FindFirst then
              exit(EFTResultCode.Successful)
          end;
        exit(ParResultCode > 0);
    end;

    local procedure GetResultCodeDescription(ParTransactionType: Code[10];ParTransactionSubType: Code[10];ParResultCode: Integer): Text
    var
        EFTResultCode: Record "Pepper EFT Result Code";
    begin
        //-NPR5.30 [263458]
        //IF PepperResultCode.GET(ParTransactionType,ParResultCode) THEN
        if EFTResultCode.Get(GetPepperIntegrationTypeCode,ParTransactionType,ParTransactionSubType,ParResultCode) then
        //-NPR5.30 [263458]
          exit(EFTResultCode.Description)
        else
          //-NPR5.30 [263458]
          //IF PepperResultCode.GET('',ParResultCode) THEN
          //  EXIT(PepperResultCode.Description)
          if EFTResultCode.Get(GetPepperIntegrationTypeCode,ParTransactionType,'',ParResultCode) then
            exit(EFTResultCode.Description)
          else
            if EFTResultCode.Get(GetPepperIntegrationTypeCode,'','',ParResultCode) then
              exit(EFTResultCode.Description)
          //+NPR5.30 [263458]
          else begin
            EFTResultCode.Reset;
            //-NPR5.30 [263458]
            EFTResultCode.SetRange("Integration Type",GetPepperIntegrationTypeCode);
            //+NPR5.30 [263458]
            EFTResultCode.SetRange(Code,ParResultCode);
            if EFTResultCode.FindFirst then begin
              //-NPR5.28 [260190]
              //AddCommentText(STRSUBSTNO(Text100,ParTransactionType,PepperResultCode."Transaction Type Code"));
              AddCommentText(StrSubstNo(Text103,ParTransactionType,EFTResultCode."Transaction Type Code"));
              //+NPR5.28 [260190]
              exit(EFTResultCode.Description);
            end;
          end;
        //-NPR5.28 [260190]
        //EXIT(Text101);
        exit(Text104);
        //+NPR5.28 [260190]
    end;

    local procedure ShowErrorMessage(ParTransactionRequestNo: Integer;ParTransactionType: Code[10];ParResultCode: Integer;ParDisplayText: Text)
    var
        PepperResultCode: Record "Pepper EFT Result Code";
        ErrorDescription: Text;
        LongDescription: Text;
        ErrorMessage: Text;
        PepperTransactionRequest: Record "EFT Transaction Request";
    begin
        //-NPR5.30 [263458]
        //IF PepperResultCode.GET(ParTransactionType,ParResultCode) THEN
        if PepperResultCode.Get(GetPepperIntegrationTypeCode,ParTransactionType,ParResultCode) then begin
        //+NPR5.30 [263458]
          //-NPR5.28 [259563]
          if PepperResultCode."Open Terminal and Retry" then begin
            PepperTransactionRequest.Get(ParTransactionRequestNo);
            PepperTransactionRequest.SetRange("Sales Ticket No.",PepperTransactionRequest."Sales Ticket No.");
            PepperTransactionRequest.SetRange("Pepper Terminal Code",PepperTransactionRequest."Pepper Terminal Code");
            PepperTransactionRequest.SetRange("Pepper Transaction Type Code",PepperTransactionRequest."Pepper Transaction Type Code");
            if PepperTransactionRequest.Count = 1 then
              exit;
          end;
          //-NPR5.28 [259563]
          ErrorDescription := PepperResultCode.Description;
          LongDescription := PepperResultCode."Long Description";
        end else begin
          if PepperResultCode.Get('',ParResultCode) then begin
            ErrorDescription := PepperResultCode.Description;
            LongDescription := PepperResultCode."Long Description";
          end else begin
            PepperResultCode.Reset;
            PepperResultCode.SetRange(Code,ParResultCode);
            if PepperResultCode.FindFirst then begin
              ErrorDescription := PepperResultCode.Description;
              //-NPR5.28 [260190]
              //LongDescription := STRSUBSTNO(Text100,ParTransactionType,PepperResultCode."Transaction Type Code",PepperResultCode."Long Description");
              LongDescription := StrSubstNo(Text105,ParTransactionType,PepperResultCode."Transaction Type Code",PepperResultCode."Long Description");
              //+NPR5.28 [260190]
            end else begin
              //-NPR5.28 [260190]
              //ErrorDescription := Text101;
              ErrorDescription := Text104;
              //+NPR5.28 [260190]
            end;
          end;
        end;
        //-NPR5.22
        if ParDisplayText <> '' then begin
          ErrorDescription := '';
          LongDescription := ParDisplayText;
        end;
        //+NPR5.22
        ErrorMessage := StrSubstNo(TextErrorMessage,ParTransactionType,ParResultCode,ErrorDescription,LongDescription,ParTransactionRequestNo);
        Message(ErrorMessage);
    end;

    local procedure CalcAmountInCents(ParDecimalAmount: Decimal;ParCurrencyCode: Code[10]): Integer
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DecimalPlaces: Integer;
        CentFactor: Integer;
        AmountInCents: Integer;
    begin
        if ParDecimalAmount = 0 then
          exit(0);
        if Currency.Get(ParCurrencyCode) then begin
          CentFactor := CalcCentFactor(Currency."Amount Decimal Places");
        end else begin
          GeneralLedgerSetup.Get;
          CentFactor := CalcCentFactor(GeneralLedgerSetup."Amount Decimal Places");
        end;
        if Evaluate(AmountInCents,Format(Round(CentFactor * ParDecimalAmount,1))) then
          exit(AmountInCents)
        else
          exit(0);
    end;

    local procedure CalcAmountInCurrency(ParAmountInCents: Integer;ParCurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CentFactor: Integer;
    begin
        if ParAmountInCents = 0 then
          exit(0);
        if Currency.Get(ParCurrencyCode) then begin
          CentFactor := CalcCentFactor(Currency."Amount Decimal Places");
        end else begin
          GeneralLedgerSetup.Get;
          CentFactor := CalcCentFactor(GeneralLedgerSetup."Amount Decimal Places");
        end;
        exit(ParAmountInCents/CentFactor);
    end;

    local procedure CalcCentFactor(TextFormat: Text): Integer
    var
        DecimalPlaces: Integer;
        I: Integer;
    begin
        if StrPos(TextFormat,':') > 0 then
          if StrLen(TextFormat) > StrPos(TextFormat,':')  then
            if Evaluate(DecimalPlaces,CopyStr(TextFormat, StrPos(TextFormat,':') + 1)) then
              if DecimalPlaces > 0 then
                exit(Power(10,DecimalPlaces));
        exit(1);
    end;

    procedure HasRecovery(): Boolean
    begin
        exit(RecoveryStarted <> 0DT);
    end;

    local procedure GetRegister(RegisterNo: Code[10])
    begin
        if RegisterNo <> Register."Register No." then
          Register.Get(RegisterNo);
    end;

    local procedure CreateEFTTransactionRequestLine(TransactionCode: Code[20];SalesTicketNo: Code[20])
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTTransactionComment: Record "EFT Transact. Req. Comment";
        TransactionType: Record "Pepper EFT Transaction Type";
        EntryNo: Integer;
        I: Integer;
        RcptText: Text;
        OStream: OutStream;
    begin
        //-NPR5.28 [259563]
        Clear(EFTTransactionRequest);
        //+NPR5.28 [259563]
        //-NPR5.22
        DisplayText := '';
        //+NPR5.22
        with EFTTransactionRequest do begin
          LockTable;
          if FindLast then
            EntryNo := "Entry No." + 1
          else
            EntryNo := 1;
          Init;
          "Entry No." := EntryNo;
          Insert(true);
          //-NPR5.30 [263458]
          "Integration Type" := GetPepperIntegrationTypeCode;
          //+NPR5.30 [263458]
          "Pepper Terminal Code" := PepperTerminal.Code;
          "Pepper Transaction Type Code" := TransactionCode;
          //-NPR5.30 [263458]
          //IF TransactionType.GET("Transaction Type Code") THEN
          if TransactionType.Get(GetPepperIntegrationTypeCode,"Pepper Transaction Type Code") then
          //+NPR5.30 [263458]
            "Processing Type"  := TransactionType."Processing Type";
          Started := CurrentDateTime;
          "User ID" := UserId;
          "Integration Version Code" := PepperConfiguration.Version;
          "Sales Ticket No." := SalesTicketNo;
          "Register No." := PepperTerminal."Register No.";
          "Card Type" := CardTypeText;
          "Card Name" := CardNameText;
          "Card Number" := CardNumberText;
          "Card Expiry Date" := CardExpiryDate;
          "Reference Number Input" := ReferenceNumberIn;
          "Reference Number Output" := ReferenceNumberOut;
          "Authorisation Number" := AuthorizationNumber;
          "Hardware ID" := TerminalID;
          "Transaction Date" := TransactionDate;
          "Transaction Time" := TransactionTime;
          "Authentication Method" := ReceiptSignature;
          "Bookkeeping Period" := BookkeepingPeriod;
          "Amount Input" := AmountIn;
          "Amount Output"  := AmountOut;
          "Currency Code" := CurrencyCodeIn;
          //-NPR5.35 [284379]
          "Cashback Amount" := CashBackAmount;
          //+NPR5.35 [284379]
          Mode := PepperConfiguration.Mode;
          //-NPR5.22
          "Offline mode" := (PepperTerminal.Status = PepperTerminal.Status::ActiveOffline);
          //+NPR5.22
          Modify;

          case TransactionCode of
            'EFTRECOVER':
              TransactionRequestRecoveryEntryNo := EntryNo
            else
              TransactionRequestEntryNo := EntryNo
          end;
        end;
    end;

    local procedure UpdateEFTTransactionRequestLine(TransactionCode: Code[20];Resultcode: Integer)
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTTransactionComment: Record "EFT Transact. Req. Comment";
        TransactionType: Record "Pepper EFT Transaction Type";
        EntryNo: Integer;
        I: Integer;
        RcptText: Text;
        OStream: OutStream;
        TextCustSig: Label 'Customer''s signature is required on the terminal payment receipt!';
        LastLine: Integer;
    begin
        with EFTTransactionRequest do begin
          case TransactionCode of
            'EFTRECOVER':
              Get(TransactionRequestRecoveryEntryNo)
            else
              Get(TransactionRequestEntryNo);
          end;
          Finished := CurrentDateTime;
          "Result Code" := Resultcode;
          "Card Type" := CardTypeText;
          "Card Name" := CardNameText;
          "Card Number" := CardNumberText;
          "Card Expiry Date" := CardExpiryDate;
          "Reference Number Input" := ReferenceNumberIn;
          "Reference Number Output" := ReferenceNumberOut;
          "Authorisation Number" := AuthorizationNumber;
          "Hardware ID" := TerminalID;
          "Transaction Date" := TransactionDate;
          "Transaction Time" := TransactionTime;
          "Authentication Method" := ReceiptSignature;
          "Bookkeeping Period" := BookkeepingPeriod;
          "Amount Input" := AmountIn;
          "Amount Output"  := AmountOut;
          "Currency Code" := CurrencyCodeIn;
          //-NPR5.30 [263458]
          //Successful := IsSuccessfulResultCode("Transaction Type Code","Result Code");
          //"Result Description" := GetResultCodeDescription("Transaction Type Code","Result Code");
          Successful := IsSuccessfulResultCode("Pepper Transaction Type Code",'',"Result Code");
          "Result Description" := GetResultCodeDescription("Pepper Transaction Type Code",'',"Result Code");
          //+NPR5.30 [263458]
          //-NPR5.22
          "Result Display Text" := CopyStr(DisplayText,1,MaxStrLen("Result Display Text"));
          //+NPR5.22
          if PepperConfiguration."Show Detailed Error Messages" and (not Successful) then
            //-NPR5.22
            //ShowErrorMessage("Entry No.","Transaction Type Code","Result Code");
            ShowErrorMessage("Entry No.","Pepper Transaction Type Code","Result Code","Result Display Text");
            //+NPR5.22
          I:= 0;
          repeat
            RcptText := GetReceiptText(I);
            if RcptText <> '' then begin
              if not "Receipt 1".HasValue then begin
                "Receipt 1".CreateOutStream(OStream);
              end else begin
                if not "Receipt 2".HasValue then begin
                  "Receipt 2".CreateOutStream(OStream);
                  I := 99;
                end;
              end;
              OStream.Write(RcptText);
            end;
            I:= I + 1;
          until (I > 6) ;
          Modify;
          //-NPR5.27 [256257]
          if "Receipt 2".HasValue then
          //+NPR5.27 [256257]
            if  "Authentication Method" = "Authentication Method"::Signature then
              //-NPR5.29 [261673]
              if not PepperTerminal."Cancel at Wrong Signature" then
              //+NPR5.29 [261673]
                Message(TextCustSig);
        end;
        CompressArray(CommentText);
        //-NPR5.38 [298176]
        EFTTransactionComment.Reset;
        EFTTransactionComment.SetRange("Entry No.", EFTTransactionRequest."Entry No.");
        if EFTTransactionComment.FindLast then
          LastLine := EFTTransactionComment."Line No."
        else
          LastLine := 0;
        //+NPR5.38 [298176]
        I:= 0;
        repeat
          I:= I + 1;
          if CommentText[I] <> '' then begin
            EFTTransactionComment.Init;
            //-#NPR5.30.02 [273339]
            //EFTTransactionComment."Entry No." := EFTTransactionComment."Entry No.";
            EFTTransactionComment."Entry No." := EFTTransactionRequest."Entry No.";
            //-#NPR5.30.02 [273339]
            //-NPR5.38 [298176]
            //EFTTransactionComment."Line No." := I;
            EFTTransactionComment."Line No." := I + LastLine;
            //+NPR5.38 [298176]
            EFTTransactionComment.Comment := CommentText[I];
            EFTTransactionComment.Insert(true);
          end;
        until (I = ArrayLen(CommentText)) or (CommentText[I] = '');
    end;

    local procedure AddCommentText(Comment: Text)
    var
        I: Integer;
        ArrayContent: Text;
        PepperLogComment: Record "EFT Transact. Req. Comment";
    begin
        I:= 0;
        repeat
          I:= I + 1;
          ArrayContent := CommentText[I];
        until (I = ArrayLen(CommentText,1)) or (ArrayContent = '');
        if ArrayContent = '' then begin
          CommentText[I] := CopyStr(Comment,1,MaxStrLen(PepperLogComment.Comment));
        end;
    end;

    local procedure CheckCardInformation(ParCardTypeText: Text[4];ParCardNameText: Text[24];ParCardNumberText: Text[30];ParCardExpiryDate: Text[4])
    var
        Text001: Label 'Card Type not received from Terminal.';
        Text002: Label 'Card Name not received from Terminal.';
        Text003: Label 'Card Number not received from Terminal';
        Text004: Label 'Card Expiry Date not received from Terminal';
        PepperCardType: Record "Pepper Card Type";
        Month: Integer;
        Year: Integer;
        Text005: Label 'Card Expiry Date should be MMYY';
        Text006: Label 'Card Expiry Date is in the past.';
        Text007: Label 'Card Type not recognized.';
        Text008: Label 'No Card Information received from Terminal.';
    begin
        if (ParCardTypeText = '') and (ParCardNameText = '') and (ParCardNumberText = '') and (ParCardExpiryDate = '') then begin
          AddCommentText(Text008);
          exit;
        end;
        if ParCardTypeText = '' then
          AddCommentText(Text001)
        else
          if not PepperCardType.Get(ParCardTypeText)then
        if ParCardNameText = '' then
          AddCommentText(Text002);
        if ParCardNumberText = '' then
          AddCommentText(Text003);
        if StrLen(ParCardExpiryDate) < 4 then begin
          AddCommentText(Text004)
        end else begin
          if (Evaluate(Month,CopyStr(ParCardExpiryDate,1,2))) and (Evaluate(Year,CopyStr(ParCardExpiryDate,3,2))) then begin
            if (Month < 1) or (Month > 12) then begin
               AddCommentText(Text005);
            end else begin
              if ((2000 + Year) < Date2DMY(Today,3))  or (((2000 + Year) = Date2DMY(Today,3)) and (Month < Date2DMY(Today,2))) then begin
                AddCommentText(Text006);
              end;
            end;
          end else begin
            AddCommentText(Text005);
          end;
        end;
    end;

    local procedure GetTimeout(ParPepperTransactionCode: Code[10]): Integer
    begin
        //-NPR5.30 [263458]
        //IF EFTTransactionType.GET(ParPepperTransactionCode) THEN
        if EFTTransactionType.Get(GetPepperIntegrationTypeCode,ParPepperTransactionCode) then
        //+NPR5.30 [263458]
          if EFTTransactionType."POS Timeout (Seconds)" <> 0  then
            exit(EFTTransactionType."POS Timeout (Seconds)" * 1000);
        exit(PepperConfiguration."Default POS Timeout (Seconds)" * 1000);
    end;

    local procedure GetTransactionDate(DateText: Text): Date
    var
        Text001: Label 'Transaction Date not specified.';
        Text002: Label 'Transaction Date not formatted DDMMYYYY. Value received: %1';
        TDate: Date;
    begin
        if DateText = '' then begin
          AddCommentText(Text001);
          exit(0D);
        end;
        TDate := GetDateFromText(DateText);
        if TDate = 0D then
          AddCommentText(StrSubstNo(Text002,DateText));
        exit(TDate);
    end;

    local procedure GetTransactionTime(TimeText: Text): Time
    var
        TTime: Time;
        Text001: Label 'Transaction Time not specified.';
        Text002: Label 'Transaction Time not formatted HHMMSS. Value received: %1';
    begin
        if TimeText = '' then begin
          AddCommentText(Text001);
          exit(0T);
        end;
        TTime := GetTimeFromText(TimeText);
        if TTime = 0T then
          AddCommentText(StrSubstNo(Text002,TimeText));
        exit(TTime);
    end;

    local procedure GetDateFromText(DateText: Text): Date
    var
        Text001: Label 'Transaction Date not specified';
        Text002: Label 'Transaction Date format not DDMMYYY';
        Day: Integer;
        Month: Integer;
        Year: Integer;
        FifthandSixthPos: Integer;
    begin
        if DateText = '' then
          exit(0D);

        //-NPR5.22
        if not Evaluate(FifthandSixthPos, CopyStr(DateText,5,2)) then
          exit(0D);
        if (FifthandSixthPos >=1) and (FifthandSixthPos <= 12) then begin
           //Try Format YYYYMMDD
        //+NPR5.22
          if not Evaluate(Day,CopyStr(DateText,7,2)) then
            exit(0D);

          if not Evaluate(Month, CopyStr(DateText,5,2)) then
            exit(0D);

          if not Evaluate(Year, CopyStr(DateText,1,4)) then
            exit(0D);
        //-NPR5.22
        end else begin
          //Try Format DDMMYYY
            if not Evaluate(Day,CopyStr(DateText,1,2)) then
            exit(0D);

          if not Evaluate(Month, CopyStr(DateText,3,2)) then
            exit(0D);

          if not Evaluate(Year, CopyStr(DateText,5,4)) then
            exit(0D);
        end;
        //+NPR5.22

        if (Year < 1) or (Year > 9999) then
          exit(0D);

        if (Month < 1) or (Month > 12) then
          exit(0D);

        if (Day < 1) or (Day > Date2DMY(CalcDate('<+1M-1D>',DMY2Date(1,Month,Year)),1)) then
          exit(0D);

        exit(DMY2Date(Day,Month,Year));
    end;

    local procedure GetTimeFromText(TimeText: Text): Time
    var
        Text001: Label 'Transaction Time not specified';
        Text002: Label 'Transaction Time format not HHMMSS';
        TempTime: Time;
    begin
        if TimeText = '' then
          exit(0T);
        if not Evaluate(TempTime,TimeText) then
          exit(0T);
        exit(TempTime);
    end;

    local procedure LastReference(ParPepperTerminalCode: Code[10]): Text[12]
    var
        LocPepperTransactionRequest: Record "EFT Transaction Request";
    begin
        LocPepperTransactionRequest.SetRange("Processing Type",LocPepperTransactionRequest."Processing Type"::PAYMENT);
        LocPepperTransactionRequest.SetRange("Pepper Terminal Code",ParPepperTerminalCode);
        if LocPepperTransactionRequest.FindLast then
          exit(LocPepperTransactionRequest."Reference Number Output");
        exit('');
    end;

    local procedure CheckTestMode(): Boolean
    var
        TxtLocaltestmode: Label 'WARNING: Local test mode cuts communication with the terminal and simulates succesful transactions.';
        TxtRemotetestmode: Label 'WARNING: Remote test mode processes transactions to the terminal as normal but logs them as test. Make sure the terminal is set to test manually!';
    begin
        case PepperConfiguration.Mode of
          PepperConfiguration.Mode :: "TEST Local" :
            begin
              Message(TxtLocaltestmode );
              AddCommentText(TxtLocaltestmode);
              exit(true);
            end;
          PepperConfiguration.Mode :: "TEST Remote" :
            begin
              Message(TxtRemotetestmode );
              AddCommentText(TxtRemotetestmode);
              exit(false);
            end;
        end;
        exit(false);
    end;

    local procedure TestConfig(ParTransactionType: Option Open,Payment,Close,Refund,Recover,Auxiliary)
    var
        PepperTerminalType: Record "Pepper Terminal Type";
    begin
        if PepperVersion.Code = '' then
          Error(Text100);
        case ParTransactionType of
          ParTransactionType:: Open :
            begin
              PepperConfiguration.TestField("Transaction Type Open Code");
              //-NPR5.30 [263458]
              //EFTTransactionType.GET(PepperConfiguration."Transaction Type Open Code");
              EFTTransactionType.Get(GetPepperIntegrationTypeCode,PepperConfiguration."Transaction Type Open Code");
              //+NPR5.30 [263458]
              //-NPR5.25
              PepperTerminal.TestField("Terminal Type Code");
              PepperTerminalType.Get(PepperTerminal."Terminal Type Code");
              if PepperTerminalType."Force Fixed Currency Check" then
                PepperTerminal.TestField(PepperTerminal."Fixed Currency Code");
              //+NPR5.25
            end;
          ParTransactionType:: Payment :
            begin
              PepperConfiguration.TestField("Transaction Type Payment Code");
              //-NPR5.30 [263458]
              //EFTTransactionType.GET(PepperConfiguration."Transaction Type Payment Code");
              EFTTransactionType.Get(GetPepperIntegrationTypeCode,PepperConfiguration."Transaction Type Payment Code");
              //+NPR5.30 [263458]
            end;
          ParTransactionType:: Close :
            begin
              PepperConfiguration.TestField("Transaction Type Close Code");
              //-NPR5.30 [263458]
              //EFTTransactionType.GET(PepperConfiguration."Transaction Type Close Code");
              EFTTransactionType.Get(GetPepperIntegrationTypeCode,PepperConfiguration."Transaction Type Close Code");
              //+NPR5.30 [263458]
            end;
          ParTransactionType:: Refund :
            begin
              PepperConfiguration.TestField("Transaction Type Refund Code");
              //-NPR5.30 [263458]
              //EFTTransactionType.GET(PepperConfiguration."Transaction Type Refund Code");
              EFTTransactionType.Get(GetPepperIntegrationTypeCode,PepperConfiguration."Transaction Type Refund Code");
              //+NPR5.30 [263458]
            end;
          ParTransactionType:: Recover :
            begin
              PepperConfiguration.TestField("Transaction Type Recover Code");
              //-NPR5.30 [263458]
              //EFTTransactionType.GET(PepperConfiguration."Transaction Type Recover Code");
              EFTTransactionType.Get(GetPepperIntegrationTypeCode,PepperConfiguration."Transaction Type Recover Code");
              //+NPR5.30 [263458]
            end;
          ParTransactionType:: Auxiliary :
            begin
              PepperConfiguration.TestField("Transaction Type Recover Code");
              //-NPR5.30 [263458]
              //EFTTransactionType.GET(PepperConfiguration."Transaction Type Auxilary Code");
              EFTTransactionType.Get(GetPepperIntegrationTypeCode,PepperConfiguration."Transaction Type Auxilary Code");
              //+NPR5.30 [263458]
            end;
        end;
        if PepperConfiguration.Mode <> PepperConfiguration.Mode then
          if not EFTTransactionType."Allow Test Modes" then
            Error(StrSubstNo(Text101,EFTTransactionType.Code,PepperConfiguration.Code));
    end;

    local procedure SetConfigFromTerminal(ParTerminalCode: Code[20])
    begin
        PepperTerminal.Get(ParTerminalCode);
        PepperInstance.Get(PepperTerminal."Instance ID");
        PepperConfiguration.Get(PepperInstance."Configuration Code");
        PepperVersion.Get(PepperConfiguration.Version);
    end;

    local procedure GetPepperReceiptEncoding(): Code[50]
    begin
        if PepperTerminal."Pepper Receipt Encoding" = 0 then
          exit('')
        else
          exit(UpperCase(Format(PepperTerminal."Pepper Receipt Encoding",0)));
    end;

    local procedure GetNavReceiptEncoding(): Code[50]
    begin
        if PepperTerminal."NAV Receipt Encoding" = 0 then
          exit('')
        else
          exit(UpperCase(Format(PepperTerminal."NAV Receipt Encoding",0)));
    end;

    local procedure ClearGlobals()
    begin
        //-NPR5.28 [259563]
        Clear(CommentText);
        Clear(OpenReceiptText);
        Clear(CloseReceiptText);
        Clear(CustomerReceiptText);
        Clear(RecoveryReceiptText);
        Clear(MerchantReceiptText);
        Clear(EndOfDayReceiptText);
        //+NPR5.28 [259563]
    end;

    procedure GetKeyFromLicenseText(LicenseText: Text): Text[8]
    var
        KeyText: Text;
        XMLDOMManagement: Codeunit "XML DOM Management";
        XMLRootNode: DotNet npNetXmlNode;
    begin
        //-NPR5.29 [262269]
        if not XMLDOMManagement.LoadXMLDocumentFromText(LicenseText,XMLRootNode) then
          exit('');
        KeyText := XMLDOMManagement.FindNodeText(XMLRootNode,'/License/Information/Key');
        if StrLen(KeyText) <> 8 then
          exit('');
        exit(KeyText);
        //+NPR5.29 [262269]
    end;

    procedure GetTerminalTypeFromLicenseText(LicenseText: Text): Integer
    var
        TerminalTypeID: Integer;
        TerminalTypeText: Text;
        XMLDOMManagement: Codeunit "XML DOM Management";
        XMLRootNode: DotNet npNetXmlNode;
        PepperTerminalType: Record "Pepper Terminal Type";
    begin
        //-NPR5.29 [262269]
        if not XMLDOMManagement.LoadXMLDocumentFromText(LicenseText,XMLRootNode) then
          exit(0);
        TerminalTypeText := XMLDOMManagement.FindNodeText(XMLRootNode,'/License/Options/TerminalTypeList');
        if Evaluate(TerminalTypeID,TerminalTypeText) then
          if PepperTerminalType.Get(TerminalTypeID) then
            if PepperTerminalType.Active then
              exit(PepperTerminalType.ID);
        exit(0);
        //+NPR5.29 [262269]
    end;

    procedure GetPepperIntegrationTypeCode(): Code[10]
    var
        EFTIntegrationType: Record "EFT Integration Type";
    begin
        //-NPR5.30 [263458]
        if EFTIntegrationType.IsEmpty then
          exit('');
        exit('PEPPER');
        //+NPR5.30 [263458]
    end;

    local procedure InsertPepperIntegrationType()
    var
        EFTIntegrationType: Record "EFT Integration Type";
    begin
        //-NPR5.30 [263458]
        if EFTIntegrationType.Get(GetPepperIntegrationTypeCode) then
          exit;
        EFTIntegrationType.Init;
        EFTIntegrationType.Code := GetPepperIntegrationTypeCode;
        EFTIntegrationType.Description := Text200;
        EFTIntegrationType.Insert;
        //+NPR5.30 [263458]
    end;
}

