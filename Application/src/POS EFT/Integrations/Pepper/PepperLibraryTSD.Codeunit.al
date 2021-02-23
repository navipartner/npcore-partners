codeunit 6184487 "NPR Pepper Library TSD"
{
    var
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
        Text001: Label 'DLL version: %1';
        Text002: Label 'Previous DLL version: %1';
        Text003: Label 'Install failed with error: %1';
        Text103: Label 'This result code was not found for Transaction Type %1, so taken from %2 %3.';
        Text104: Label 'Result code not found! ';
        ErrorText001: Label 'Register %1 is linked to multiple Pepper terminals.';
        ErrorText002: Label 'Register %1 is not linked to a Pepper terminal.';
        PepperSetupInitialized: Boolean;
        PepperTerminal: Record "NPR Pepper Terminal";
        PepperInstance: Record "NPR Pepper Instance";
        PepperConfiguration: Record "NPR Pepper Config.";
        PepperVersion: Record "NPR Pepper Version";
        CommentText: array[20] of Text;
        PepperSetupNotFound: Label 'The Register No. %1 is not associated with a pepper terminal.\\Go to Pepper Terminals and assign register %1 to a Pepper Terminal.';
        AuxFunctionMenu: Label 'ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINADEACTIVATION,TINAQUERY,SHOWCUSTOMMENU';
        ChooseAuxFunction: Label 'Please choose an Auxiliary Function to send to the terminal.';
        DEMO_TRANSACTION: Label '***** NOTICE *****\\This is a demo transaction.\\ *** DEMO *** DEMO *** DEMO ***';
        SupportedAuxFunction: Option ,ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINADEACTIVATION,TINAQUERY,SHOWCUSTOMMENU;
        PepperDescription: Label 'Interface';
        EftPaymentFailed: Label 'Payment was declined.\\%2 (%1)';
        EFTSetup: Record "NPR EFT Setup";

    local procedure InitializePepperSetup(RegisterNo: Code[20])
    begin

        if (PepperSetupInitialized) then
            exit;

        PepperSetupInitialized := FindTerminalSetupFromRegister(RegisterNo, PepperTerminal, PepperInstance, PepperConfiguration, PepperVersion, EFTSetup);

        if (not PepperSetupInitialized) then
            Error(PepperSetupNotFound, RegisterNo);
    end;

    local procedure MakeDeviceRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        InitializePepperSetup(EFTTransactionRequest."Register No.");

        // This function will make an out-of-transaction request that can't be rollbacked
        Commit;

        with EFTTransactionRequest do begin

            if (PepperTerminal."Open Automatically") then
                if (AutomaticallyBeginWorkshift(EFTTransactionRequest)) then
                    exit(true);

            case "Processing Type" of
                "Processing Type"::OPEN:
                    BeginWorkshift(EFTTransactionRequest, true);

                "Processing Type"::PAYMENT,
              "Processing Type"::REFUND,
              "Processing Type"::OTHER:
                    case "Pepper Trans. Subtype Code" of
                        '0':
                            TrxRecoverTransaction(EFTTransactionRequest);
                        '10':
                            TrxPaymentOfGoods(EFTTransactionRequest, '');
                        '20':
                            TrxVoidPaymentOfGoods(EFTTransactionRequest);
                        '60':
                            TrxRefund(EFTTransactionRequest);
                        else
                            exit(false);
                    end;

                "Processing Type"::AUXILIARY:
                    case EFTTransactionRequest."Pepper Transaction Type Code" of
                        PepperConfiguration."Transaction Type Auxilary Code":
                            AuxFunctionRequest(EFTTransactionRequest);
                        PepperConfiguration."Transaction Type Install Code":
                            InstallPepperRequest(EFTTransactionRequest);
                        else
                            exit(false);
                    end;

                "Processing Type"::CLOSE:
                    EndWorkshift(EFTTransactionRequest);

                else
                    exit(false);
            end;
        end;

        exit(true);
    end;

    local procedure AutomaticallyBeginWorkshift(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EftBeginWorkshiftRequest: Record "NPR EFT Transaction Request";
    begin

        InitializePepperSetup(EFTTransactionRequest."Register No.");

        if (EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::OPEN) then begin
            if (not (PepperTerminal.Status in [PepperTerminal.Status::Open, PepperTerminal.Status::ActiveOffline])) then begin

                CreateBeginWorkshiftRequest(EFTTransactionRequest."Register No.", EftBeginWorkshiftRequest);
                EftBeginWorkshiftRequest."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
                EftBeginWorkshiftRequest.Modify();

                MakeDeviceRequest(EftBeginWorkshiftRequest);
                exit(true);
            end;
        end;
        exit(false);
    end;

    local procedure BeginWorkshift(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ForceDownloadLicense: Boolean)
    var
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
        PepperBeginWorkshift: Codeunit "NPR Pepper Begin Workshift TSD";
        POSUnit: Record "NPR POS Unit";
        LicenseString: Text;
        CustomerID: Text;
        LicenseID: Text;
        OptionInt: Integer;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        if (CheckTestMode(PepperConfiguration)) then begin
            BeginWorkshiftResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        // Initialize Stargate Protocol
        PepperBeginWorkshift.InitializeProtocol();
        PepperBeginWorkshift.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");

        PepperBeginWorkshift.SetPepperFolder(PepperVersion."Install Directory");

        // Initialize Pepper Library (client side)
        PepperBeginWorkshift.SetILP_UseConfigurationInstanceId(PepperInstance.ID);
        PepperBeginWorkshift.SetILP_XmlConfigurationString(PepperConfigManagement.GetConfigurationText(PepperConfiguration, 1));

        LicenseString := PepperConfigManagement.GetTerminalText(PepperTerminal, 0);

        if ForceDownloadLicense or (LicenseString = '') then begin
            CustomerID := PepperConfigManagement.GetCustomerID(PepperTerminal);
            LicenseID := PepperConfigManagement.GetLicenseID(PepperTerminal);
            if (CustomerID <> '') and (LicenseID <> '') then begin
                PepperBeginWorkshift.SetILP_ForceGetPepperLicense(LicenseID, CustomerID);
            end;
        end;

        if LicenseString <> '' then
            PepperBeginWorkshift.SetILP_XmlLicenseString(LicenseString);

        // Configure Driver
        PepperBeginWorkshift.SetCDP_ComPort(PepperTerminal."Com Port");
        PepperBeginWorkshift.SetCDP_IpAddressAndPort(PepperTerminal."IP Address");
        Evaluate(OptionInt, Format(PepperTerminal.Language, 20, '<Number>'));
        PepperBeginWorkshift.SetCDP_EftTerminalInformation(PepperTerminal."Terminal Type Code", OptionInt, PepperConfigManagement.GetPepperRegisterNo(PepperTerminal."Register No."), Format(PepperTerminal."Receipt Format"));
        PepperBeginWorkshift.SetCDP_Filenames(PepperTerminal."Print File Open", PepperTerminal."Print File Close",
                                                PepperTerminal."Print File Transaction", PepperTerminal."Print File CC Transaction",
                                                PepperTerminal."Print File Difference", PepperTerminal."Print File End of Day",
                                                PepperTerminal."Print File Journal", PepperTerminal."Print File Initialisation");
        Evaluate(OptionInt, Format(PepperTerminal."Matchbox Files", 20, '<Number>'));
        PepperBeginWorkshift.SetCDP_MatchboxInformation(OptionInt, PepperTerminal."Matchbox Company ID", PepperTerminal."Matchbox Shop ID", PepperTerminal."Matchbox POS ID", PepperTerminal."Matchbox File Name");

        PepperBeginWorkshift.SetCDP_AdditionalParameters(PepperConfigManagement.GetTerminalText(PepperTerminal, 1));

        // Open EFT
        PepperBeginWorkshift.SetPOP_Operator(1);
        PepperBeginWorkshift.SetPOP_AdditionalParameters('');
        PepperBeginWorkshift.SetTimout(GetTimeout(PepperConfiguration.Code, PepperConfiguration."Transaction Type Open Code"));
        PepperBeginWorkshift.SetReceiptEncoding(GetPepperReceiptEncoding(PepperTerminal), GetNavReceiptEncoding(PepperTerminal));

        // Header and footers to receipts by pepper on client side
        case PepperConfiguration."Header and Footer Handling" of
            PepperConfiguration."Header and Footer Handling"::"Manual Headers and Footers":
                begin
                    PepperBeginWorkshift.SetHeaderFooters(false, PepperConfiguration."Ticket Directory", '', '', '', '', '', '');
                end;
            PepperConfiguration."Header and Footer Handling"::"Send Headers and Footers to Terminal":
                begin
                    POSUnit.Get(PepperTerminal."Register No.");
                    PepperBeginWorkshift.SetHeaderFooters(true, PepperConfiguration."Ticket Directory",
                                                            PepperConfigManagement.GetHeaderFooterText(POSUnit, 0, 0), PepperConfigManagement.GetHeaderFooterText(POSUnit, 0, 1),
                                                            PepperConfigManagement.GetHeaderFooterText(POSUnit, 1, 0), PepperConfigManagement.GetHeaderFooterText(POSUnit, 1, 1),
                                                            PepperConfigManagement.GetHeaderFooterText(POSUnit, 2, 0), PepperConfigManagement.GetHeaderFooterText(POSUnit, 2, 1));
                end;
            PepperConfiguration."Header and Footer Handling"::"Add Headers and Footers at Printing", PepperConfiguration."Header and Footer Handling"::"No Headers and Footers":
                begin
                    PepperBeginWorkshift.SetHeaderFooters(true, PepperConfiguration."Ticket Directory", '', '', '', '', '', '');
                end;
        end;
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        if (POSSession.IsActiveSession(FrontEnd)) then
            PepperBeginWorkshift.InvokeBeginWorkshift(FrontEnd, POSSession);
    end;

    local procedure BeginWorkshiftResponse(PepperBeginWorkshift: Codeunit "NPR Pepper Begin Workshift TSD"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
        LicenseString: Text;
        EftRetryTransactionRequest: Record "NPR EFT Transaction Request";
        EftRecoverTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        InitializePepperSetup(EFTTransactionRequest."Register No.");

        with EFTTransactionRequest do begin
            "Result Code" := PepperBeginWorkshift.GetPOP_ResultCode();
            "Result Description" := GetResultCodeDescription("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");

            AddReceipt(EFTTransactionRequest, PepperBeginWorkshift.GetPOP_OpenReceipt());
            Successful := IsSuccessfulResultCode("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");

            Finished := CurrentDateTime;
            "Number of Attempts" += 1;

            if (Successful) then begin
                PepperTerminal.Validate(Status, PepperTerminal.Status::Open);
                PepperTerminal.Modify(true);
            end;

            UpdateEftTransactionRequestCommentBatch("Entry No.");
        end;
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        // Update the licence information in NAV
        LicenseString := PepperConfigManagement.GetTerminalText(PepperTerminal, 0);
        if (LicenseString = '') then begin
            if (PepperBeginWorkshift.GetILP_XmlLicenseString(LicenseString)) then
                PepperTerminal.StoreLicense(LicenseString);
        end;

        // Handle the RECOVERY scenario
        if (PepperBeginWorkshift.GetCDP_RecoveryRequired()) then begin
            CreateRecoveryTransactionRequest(EFTTransactionRequest."Register No.", '', '', 0, EftRecoverTransactionRequest);
            EftRecoverTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
            if (EFTTransactionRequest."Initiated from Entry No." <> 0) then
                EftRecoverTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Initiated from Entry No.";

            EftRecoverTransactionRequest.Modify();
            MakeDeviceRequest(EftRecoverTransactionRequest);
            exit;
        end;

        // Continue any original request if it successful open
        if ((EFTTransactionRequest.Successful) and (EFTTransactionRequest."Initiated from Entry No." <> 0)) then begin
            EftRetryTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
            if (not EftRetryTransactionRequest.Successful) then begin
                EftRetryTransactionRequest."Entry No." := 0;
                if (EFTTransactionRequest."Initiated from Entry No." <> 0) then
                    EftRetryTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Initiated from Entry No.";

                EftRetryTransactionRequest.Started := CurrentDateTime;
                EftRetryTransactionRequest.Insert();

                MakeDeviceRequest(EftRetryTransactionRequest);
                exit;
            end;
        end;

        Commit;
        EFTTransactionRequest.PrintReceipts(false);

        if (POSSession.IsActiveSession(FrontEnd)) then
            FrontEnd.ResumeWorkflow();
    end;

    local procedure BeginWorkshiftResponse_MOCK(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        with EFTTransactionRequest do begin
            "Result Code" := 10;
            Successful := true;
            Finished := CurrentDateTime;

            AddReceipt(EFTTransactionRequest, '**** This is a DEMO Open Receipt ****');
        end;
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        AddToCommentBatch(DEMO_TRANSACTION);
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        if (POSSession.IsActiveSession(FrontEnd)) then
            FrontEnd.ResumeWorkflow();
    end;

    local procedure EndWorkshift(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PepperEndWorkshift: Codeunit "NPR Pepper End Workshift TSD";
        EndOfDayReport: Boolean;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        PepperVersion.TestField("Codeunit End Workshift");

        if (CheckTestMode(PepperConfiguration)) then begin
            EndWorkshiftResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        PepperEndWorkshift.InitializeProtocol();
        PepperEndWorkshift.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");

        if PepperConfiguration."End of Day on Close" then
            EndOfDayReport := true;

        PepperEndWorkshift.SetOptions(EndOfDayReport, PepperConfiguration."Unload Library on Close", PepperConfiguration."End of Day Receipt Mandatory");
        PepperEndWorkshift.SetTimout(GetTimeout(PepperConfiguration.Code, PepperConfiguration."Transaction Type Close Code"));
        PepperEndWorkshift.SetReceiptEncoding(GetPepperReceiptEncoding(PepperTerminal), GetNavReceiptEncoding(PepperTerminal));

        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        if (POSSession.IsActiveSession(FrontEnd)) then
            PepperEndWorkshift.InvokeEndWorkshiftRequest(FrontEnd, POSSession);
    end;

    local procedure EndWorkshiftResponse(PepperEndWorkshift: Codeunit "NPR Pepper End Workshift TSD"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        InitializePepperSetup(EFTTransactionRequest."Register No.");

        with EFTTransactionRequest do begin

            "Result Code" := PepperEndWorkshift.GetResultCode();
            "Result Description" := GetResultCodeDescription("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");
            Successful := IsSuccessfulResultCode("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");

            AddReceipt(EFTTransactionRequest, PepperEndWorkshift.GetCloseReceipt());
            AddReceipt(EFTTransactionRequest, PepperEndWorkshift.GetEndOfDayReceipt());

            Finished := CurrentDateTime;
            "Number of Attempts" += 1;

            if (Successful) then begin
                PepperTerminal.Validate(Status, PepperTerminal.Status::Closed);
                PepperTerminal.Modify(true);
            end;

            UpdateEftTransactionRequestCommentBatch("Entry No.");

        end;
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        Commit;
        EFTTransactionRequest.PrintReceipts(false);

        if (POSSession.IsActiveSession(FrontEnd)) then
            FrontEnd.ResumeWorkflow();
    end;

    local procedure EndWorkshiftResponse_MOCK(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        with EFTTransactionRequest do begin
            "Result Code" := 10;
            Successful := true;
            Finished := CurrentDateTime;
            AddReceipt(EFTTransactionRequest, '**** This is a DEMO Close Receipt ****');
            AddReceipt(EFTTransactionRequest, '**** This is a DEMO End of Day Receipt ****');
        end;
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        AddToCommentBatch(DEMO_TRANSACTION);
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        if (POSSession.IsActiveSession(FrontEnd)) then
            FrontEnd.ResumeWorkflow();
    end;

    local procedure TrxRecoverTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction TSD";
        ActivateOffline: Boolean;
        ResultCode: Integer;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        with EFTTransactionRequest do begin
            PepperTrxTransaction.InitializeProtocol();
            PepperTrxTransaction.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
            PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding(PepperTerminal), GetNavReceiptEncoding(PepperTerminal));
            PepperTrxTransaction.SetTimout(GetTimeout(PepperConfiguration.Code, PepperConfiguration."Transaction Type Recover Code"));
            ActivateOffline := (PepperTerminal.Status = PepperTerminal.Status::ActiveOffline);

            "Result Code" := PepperTrxTransaction.SetRecovery();
        end;

        EFTTransactionRequest.Modify();

        if (CheckTestMode(PepperConfiguration)) then begin
            TrxResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        if (POSSession.IsActiveSession(FrontEnd)) then
            PepperTrxTransaction.InvokeDevice(FrontEnd, POSSession);
    end;

    local procedure TrxPaymentOfGoods(EFTTransactionRequest: Record "NPR EFT Transaction Request"; MbxPosReference: Text[20])
    var
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction TSD";
        ActivateOffline: Boolean;
        ResultCode: Integer;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        with EFTTransactionRequest do begin
            PepperTrxTransaction.InitializeProtocol();
            PepperTrxTransaction.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
            PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding(PepperTerminal), GetNavReceiptEncoding(PepperTerminal));
            PepperTrxTransaction.SetTimout(GetTimeout(PepperConfiguration.Code, PepperConfiguration."Transaction Type Payment Code"));
            ActivateOffline := (PepperTerminal.Status = PepperTerminal.Status::ActiveOffline);

            "Result Code" := PepperTrxTransaction.SetPaymentOfGoods("Amount Input",
              CalcAmountInCents("Amount Input", "Currency Code"),
              CalcAmountInCents("Cashback Amount", "Currency Code"),
              "Currency Code",
              "Track Presence Input",
              "Card Information Input",
              "Reference Number Input",
              MbxPosReference,
              ActivateOffline);
        end;
        EFTTransactionRequest.Modify();

        if (CheckTestMode(PepperConfiguration)) then begin
            TrxResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        if (POSSession.IsActiveSession(FrontEnd)) then
            PepperTrxTransaction.InvokeDevice(FrontEnd, POSSession);
    end;

    local procedure TrxVoidPaymentOfGoods(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction TSD";
        ActivateOffline: Boolean;
        ResultCode: Integer;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        with EFTTransactionRequest do begin
            PepperTrxTransaction.InitializeProtocol();
            PepperTrxTransaction.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
            PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding(PepperTerminal), GetNavReceiptEncoding(PepperTerminal));
            PepperTrxTransaction.SetTimout(GetTimeout(PepperConfiguration.Code, PepperConfiguration."Transaction Type Refund Code"));
            ActivateOffline := (PepperTerminal.Status = PepperTerminal.Status::ActiveOffline);

            "Result Code" := PepperTrxTransaction.SetVoidPaymentOfGoods("Amount Input",
              CalcAmountInCents("Amount Input", "Currency Code"),
              "Currency Code",
              "Reference Number Input")
        end;

        EFTTransactionRequest.Modify();

        if (CheckTestMode(PepperConfiguration)) then begin
            TrxResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        if (POSSession.IsActiveSession(FrontEnd)) then
            PepperTrxTransaction.InvokeDevice(FrontEnd, POSSession);
    end;

    local procedure TrxRefund(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction TSD";
        ActivateOffline: Boolean;
        ResultCode: Integer;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        with EFTTransactionRequest do begin
            PepperTrxTransaction.InitializeProtocol();
            PepperTrxTransaction.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
            PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding(PepperTerminal), GetNavReceiptEncoding(PepperTerminal));
            PepperTrxTransaction.SetTimout(GetTimeout(PepperConfiguration.Code, PepperConfiguration."Transaction Type Refund Code"));
            ActivateOffline := (PepperTerminal.Status = PepperTerminal.Status::ActiveOffline);

            "Result Code" := PepperTrxTransaction.SetRefund("Amount Input",
              CalcAmountInCents("Amount Input", "Currency Code"),
              "Currency Code",
              "Reference Number Input")
        end;

        EFTTransactionRequest.Modify();

        if (CheckTestMode(PepperConfiguration)) then begin
            TrxResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        if (POSSession.IsActiveSession(FrontEnd)) then
            PepperTrxTransaction.InvokeDevice(FrontEnd, POSSession);
    end;

    local procedure TrxResponse(PepperTrxTransaction: Codeunit "NPR Pepper Transaction TSD"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EftBeginWorkshiftTransaction: Record "NPR EFT Transaction Request";
        EftRetryTransactionRequest: Record "NPR EFT Transaction Request";
        TransactionDateText: Text;
        TransactionTimeText: Text;
        RetryTransaction: Boolean;
        EFTInterface: Codeunit "NPR EFT Interface";
        PaymentType: Text;
    begin

        InitializePepperSetup(EFTTransactionRequest."Register No.");

        with EFTTransactionRequest do begin

            if (PepperTrxTransaction.GetTrx_AbandonedTransaction()) then begin
                SetTrxProcessingType("Pepper Trans. Subtype Code", "Register No.", EFTTransactionRequest);
                AddToCommentBatch('This Transaction Request was recreated since user abandoned the original request.');
            end;

            "Result Code" := PepperTrxTransaction.GetTrx_ResultCode();
            "Result Description" := GetResultCodeDescription("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");
            Successful := IsSuccessfulResultCode("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");
            if (Successful) then
                "Amount Output" := CalcAmountInCurrency(PepperTrxTransaction.GetTrx_Amount(), "Currency Code");

            if ("Processing Type" = "Processing Type"::PAYMENT) then
                "Result Amount" := Abs("Amount Output");

            if ("Processing Type" = "Processing Type"::REFUND) then
                "Result Amount" := Abs("Amount Output") * -1;

            "Number of Attempts" += 1;

            // State machine error will not have correct data in some of these fields
            if ("Result Code" <> -50) then begin
                PepperTrxTransaction.GetTrx_CardInformation("Card Type", "Card Name", "Card Number", "Card Expiry Date");
                CheckCardInformation("Card Type", "Card Name", "Card Number", "Card Expiry Date");

                PepperTrxTransaction.GetTrx_AuthorizationInfo("Reference Number Output",
                  TransactionDateText,
                  TransactionTimeText,
                  "Authorisation Number",
                  "Hardware ID",
                  "Authentication Method",
                  "Bookkeeping Period");

                "Transaction Date" := GetTransactionDate(TransactionDateText);
                "Transaction Time" := GetTransactionTime(TransactionTimeText);

                AddReceipt(EFTTransactionRequest, PepperTrxTransaction.GetTrx_CustomerReceipt());
                AddReceipt(EFTTransactionRequest, PepperTrxTransaction.GetTrx_MerchantReceipt());

                PaymentType := GetPaymentTypePOS("Card Type");
                if PaymentType <> '' then
                    "POS Payment Type Code" := PaymentType;

                "Result Display Text" := CopyStr(PepperTrxTransaction.GetTrx_DisplayText(), 1, MaxStrLen("Result Display Text"));
                "POS Description" := GetPOSDescription(EFTTransactionRequest);
            end;

            Finished := CurrentDateTime;

            UpdateEftTransactionRequestCommentBatch("Entry No.");
        end;
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        // When transaction was abandoned, there is only logging to be done.
        if (PepperTrxTransaction.GetTrx_AbandonedTransaction()) then
            exit;

        // Handle Transaction Recovery when needed
        if (EFTTransactionRequest."Pepper Transaction Type Code" = PepperConfiguration."Transaction Type Recover Code") then
            if (HandleRecoveryOfTransaction(EFTTransactionRequest)) then
                exit;

        // Handle BeginWorkshift not performed
        // Attempt an auto-open if result code allows it
        if (not EFTTransactionRequest.Successful) then begin
            if (AttemptOpenAndRetry(EFTTransactionRequest)) then begin
                CreateBeginWorkshiftRequest(EFTTransactionRequest."Register No.", EftBeginWorkshiftTransaction);
                EftBeginWorkshiftTransaction."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
                EftBeginWorkshiftTransaction.Modify();

                MakeDeviceRequest(EftBeginWorkshiftTransaction);
                exit;
            end;
        end;

        // Retry the original transaction
        if (EFTTransactionRequest."Initiated from Entry No." <> 0) then begin

            EftRetryTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");

            RetryTransaction := (EFTTransactionRequest."Pepper Transaction Type Code" <> EftRetryTransactionRequest."Pepper Transaction Type Code") and
                                (EFTTransactionRequest."Pepper Trans. Subtype Code" <> EftRetryTransactionRequest."Pepper Trans. Subtype Code") and
                                (EftRetryTransactionRequest.Successful = false);

            if (RetryTransaction) then begin
                EftRetryTransactionRequest."Entry No." := 0;
                EftRetryTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Initiated from Entry No.";
                EftRetryTransactionRequest.Started := CurrentDateTime;
                EftRetryTransactionRequest.Insert();

                MakeDeviceRequest(EftRetryTransactionRequest);
                exit;
            end;

        end;

        // Get us back to our calling workflow, we are done!
        EFTInterface.EftIntegrationResponse(EFTTransactionRequest);

    end;

    local procedure TrxResponse_MOCK(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        with EFTTransactionRequest do begin
            "Result Code" := 10;
            Successful := true;

            "Card Type" := '9999';
            "Card Name" := 'DEMO Card Name';
            "Card Number" := '555444333222';
            "Card Expiry Date" := '1220';
            CheckCardInformation("Card Type", "Card Name", "Card Number", "Card Expiry Date");

            "Reference Number Output" := IncStr("Reference Number Input");
            "Authorisation Number" := '9999';
            "Hardware ID" := '9999';
            "Transaction Date" := Today;
            "Transaction Time" := Time;
            "Authentication Method" := 1;

            AddReceipt(EFTTransactionRequest, '**** This is a DEMO Customer Receipt ****');
            AddReceipt(EFTTransactionRequest, '**** This is a DEMO Merchant Receipt ****');

            "Amount Output" := "Amount Input";

            if ("Processing Type" = "Processing Type"::PAYMENT) then
                "Result Amount" := Abs("Amount Output");

            if ("Processing Type" = "Processing Type"::REFUND) then
                "Result Amount" := Abs("Amount Output") * -1;

            Finished := CurrentDateTime;
        end;
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        AddToCommentBatch(DEMO_TRANSACTION);
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");
    end;

    local procedure HandleRecoveryOfTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EftRefundTransaction: Record "NPR EFT Transaction Request";
    begin
        // Handle RECOVERY scenarioes
        with EFTTransactionRequest do begin

            // When recovered transaction was successful and we have a receipt - refund that transaction
            if ("Pepper Trans. Subtype Code" = '0') and (Successful) then begin

                if ("Result Code" = -10) then; // Recovered transaction "Not Paid", recovery was successful

                if (("Result Code" = 30) and ("Receipt 1".HasValue())) then begin // Recovered Transaction was paid, recovery was successful, attempt a refund
                                                                                  // CreateRefundRequest ("Register No.", "Sales Ticket No.", "Currency Code", "Amount Output", "Reference Number Output", EftRefundTransaction);
                    CreateVoidPaymentOfGoodsRequest("Register No.", "Sales Ticket No.", "Currency Code", "Amount Output", "Reference Number Output", EftRefundTransaction);

                    EftRefundTransaction."Initiated from Entry No." := "Entry No.";
                    if ("Initiated from Entry No." <> 0) then
                        EftRefundTransaction."Initiated from Entry No." := "Initiated from Entry No.";
                    EftRefundTransaction.Modify();

                    MakeDeviceRequest(EftRefundTransaction);
                    exit(true);
                end;

            end;

            // Protocol require at least 3 recovery attempts
            if ("Pepper Trans. Subtype Code" = '0') and (not EFTTransactionRequest.Successful) then begin
                if ("Number of Attempts" < 3) then begin
                    "Entry No." := 0;
                    Started := CurrentDateTime;
                    Insert();

                    MakeDeviceRequest(EFTTransactionRequest);
                    exit(true);
                end;
            end;

        end;

        exit(false);
    end;

    local procedure AuxFunctionRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PepperAuxFunctions: Codeunit "NPR Pepper Aux Func. TSD";
        AuxFunction: Option;
    begin

        PepperAuxFunctions.InitializeProtocol();
        PepperAuxFunctions.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
        PepperAuxFunctions.SetReceiptEncoding(GetPepperReceiptEncoding(PepperTerminal), GetNavReceiptEncoding(PepperTerminal));
        PepperAuxFunctions.SetTimout(GetTimeout(PepperConfiguration.Code, PepperConfiguration."Transaction Type Auxilary Code"));

        Evaluate(AuxFunction, EFTTransactionRequest."Pepper Trans. Subtype Code");
        case AuxFunction of
            SupportedAuxFunction::ABORT:
                PepperAuxFunctions.SetAbort();
            SupportedAuxFunction::CUSTOMMENU:
                PepperAuxFunctions.SetShowCustomMenu();
            SupportedAuxFunction::DIAGNOSTICS:
                PepperAuxFunctions.SetGetDiagnostics(false); // setup required ?
            SupportedAuxFunction::DISPWITHNUMINPUT:
                PepperAuxFunctions.SetDisplayShowText('TEXT'); // custom text;
            SupportedAuxFunction::PANSUPPRESSIONOFF:
                PepperAuxFunctions.SetPanSuppressionOff();
            SupportedAuxFunction::PANSUPPRESSIONON:
                PepperAuxFunctions.SetPanSuppressionOn();
            SupportedAuxFunction::SUMMARYREPORT:
                PepperAuxFunctions.SetGetSummaryReport(false); //setup required ?
            SupportedAuxFunction::SYSTEMINFO:
                PepperAuxFunctions.SetGetSystemInfoTicket(false); // setup required ?
            SupportedAuxFunction::TICKETREPRINT:
                PepperAuxFunctions.SetReprintLastTicket(true);
            SupportedAuxFunction::TINAACTIVATION:
                PepperAuxFunctions.SetTinaActivation(''); // Setup required
            SupportedAuxFunction::TINADEACTIVATION:
                PepperAuxFunctions.SetTinaDeactivation(''); // Setup required
            SupportedAuxFunction::TINAQUERY:
                PepperAuxFunctions.SetTinaQuery(''); // Setup Required
            SupportedAuxFunction::SHOWCUSTOMMENU:
                PepperAuxFunctions.SetShowCustomMenu();
        end;

        AddToCommentBatch(StrSubstNo('Auxilary function: %1', EFTTransactionRequest."Pepper Trans. Subtype Code"));
        AddToCommentBatch(StrSubstNo('Auxilary function: %1', SelectStr(AuxFunction, AuxFunctionMenu)));

        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        if (POSSession.IsActiveSession(FrontEnd)) then
            PepperAuxFunctions.InvokeAuxRequest(FrontEnd, POSSession);
    end;

    local procedure AuxFunctionResponse(PepperAuxFunctions: Codeunit "NPR Pepper Aux Func. TSD"; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        AuxFunction: Option;
        EftBeginWorkshiftTransaction: Record "NPR EFT Transaction Request";
    begin

        with EFTTransactionRequest do begin

            "Result Code" := PepperAuxFunctions.GetResultCode();
            "Result Description" := GetResultCodeDescription("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");
            Successful := IsSuccessfulResultCode("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");

            Evaluate(AuxFunction, EFTTransactionRequest."Pepper Trans. Subtype Code");
            case AuxFunction of
                SupportedAuxFunction::DIAGNOSTICS,
                SupportedAuxFunction::SUMMARYREPORT,
                SupportedAuxFunction::SYSTEMINFO,
                SupportedAuxFunction::TICKETREPRINT:
                    begin
                        AddReceipt(EFTTransactionRequest, PepperAuxFunctions.GetClientReceipt());
                        AddReceipt(EFTTransactionRequest, PepperAuxFunctions.GetMerchantReceipt());
                    end;

                SupportedAuxFunction::TINAACTIVATION,
                SupportedAuxFunction::TINADEACTIVATION,
                SupportedAuxFunction::TINAQUERY:
                    begin
                        Message('%1', PepperAuxFunctions.GetXmlResponse());
                        AddToCommentBatch(PepperAuxFunctions.GetXmlResponse());
                    end;
                else
                    AddToCommentBatch(PepperAuxFunctions.GetXmlResponse());
            end;

            Finished := CurrentDateTime;
            UpdateEftTransactionRequestCommentBatch("Entry No.");

        end;
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        // Attempt an auto-open if result code allows it
        if (not EFTTransactionRequest.Successful) then begin
            if (AttemptOpenAndRetry(EFTTransactionRequest)) then begin
                CreateBeginWorkshiftRequest(EFTTransactionRequest."Register No.", EftBeginWorkshiftTransaction);
                EftBeginWorkshiftTransaction."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
                EftBeginWorkshiftTransaction.Modify();

                MakeDeviceRequest(EftBeginWorkshiftTransaction);
                exit;
            end;
        end;

        Commit;
        EFTTransactionRequest.PrintReceipts(false);

        // Get us back to our calling workflow, we are done!
        if (POSSession.IsActiveSession(FrontEnd)) then
            FrontEnd.ResumeWorkflow();
    end;

    local procedure InstallPepperRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PepperFileMgmtFunctions: Codeunit "NPR Pepper FileMgmt. Func. TSD";
        AuxFunction: Option;
    begin

        PepperFileMgmtFunctions.InitializeProtocol();
        PepperFileMgmtFunctions.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");

        PepperFileMgmtFunctions.SetTimout(GetTimeout(PepperConfiguration.Code, PepperConfiguration."Transaction Type Install Code"));
        PepperFileMgmtFunctions.SetPepperVersionToInstall(EFTTransactionRequest."Pepper Trans. Subtype Code");

        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        if (POSSession.IsActiveSession(FrontEnd)) then
            PepperFileMgmtFunctions.InvokeFileMgtRequest(FrontEnd, POSSession);
    end;

    local procedure InstallPepperResponse(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        PepperFileMgmtFunctions: Codeunit "NPR Pepper FileMgmt. Func. TSD";
    begin

        with EFTTransactionRequest do begin

            "Result Code" := PepperFileMgmtFunctions.GetResultCode();
            "Result Description" := GetResultCodeDescription("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");
            Successful := IsSuccessfulResultCode("Pepper Transaction Type Code", "Pepper Trans. Subtype Code", "Result Code");

            Finished := CurrentDateTime;

            if (not Successful) then
                AddToCommentBatch(StrSubstNo(Text003, PepperFileMgmtFunctions.GetExceptionText));

            AddToCommentBatch(StrSubstNo(Text001, PepperFileMgmtFunctions.GetInstalledVersion()));
            AddToCommentBatch(StrSubstNo(Text002, PepperFileMgmtFunctions.GetPreviousVersion()));

            UpdateEftTransactionRequestCommentBatch("Entry No.");

        end;
        EFTTransactionRequest.Modify();

        // Get us back to our calling workflow, we are done!
        if (POSSession.IsActiveSession(FrontEnd)) then
            FrontEnd.ResumeWorkflow();
    end;

    procedure GetIntegrationType(): Code[10]
    begin

        exit('PEPPER');
    end;

    local procedure "--*** Create Request"()
    begin
    end;

    local procedure CreateBeginWorkshiftRequest(RegisterNo: Code[20]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        PepperVersion.TestField("Codeunit Begin Workshift");
        PepperConfiguration.TestField("Transaction Type Open Code");

        with EFTTransactionRequest do begin
            "Pepper Transaction Type Code" := PepperConfiguration."Transaction Type Open Code";
            "Processing Type" := EFTTransactionRequest."Processing Type"::OPEN;
        end;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateEndWorkshiftRequest(RegisterNo: Code[20]; SalesReceiptNo: Code[20]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        PepperVersion.TestField("Codeunit End Workshift");
        PepperConfiguration.TestField("Transaction Type Close Code");

        with EFTTransactionRequest do begin
            "Sales Ticket No." := SalesReceiptNo;
            "Reference Number Input" := SalesReceiptNo;

            "Pepper Transaction Type Code" := PepperConfiguration."Transaction Type Close Code";
            "Processing Type" := EFTTransactionRequest."Processing Type"::CLOSE;
        end;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreatePaymentOfGoodsRequest(RegisterNo: Code[20]; SalesReceiptNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin

        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        PepperVersion.TestField("Codeunit Transaction");
        PepperConfiguration.TestField("Transaction Type Payment Code");

        if (CurrencyCode = '') then begin
            GLSetup.Get;
            CurrencyCode := GLSetup."LCY Code";
        end;

        with EFTTransactionRequest do begin
            "Sales Ticket No." := SalesReceiptNo;
            "Reference Number Input" := SalesReceiptNo;

            "Currency Code" := CurrencyCode;
            "Amount Input" := Amount;
            SetTrxProcessingType('10', RegisterNo, EFTTransactionRequest);
            "Auto Voidable" := true;

        end;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateRecoveryTransactionRequest(RegisterNo: Code[20]; SalesReceiptNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        PepperVersion.TestField("Codeunit Transaction");
        PepperConfiguration.TestField("Transaction Type Recover Code");

        if (CurrencyCode = '') then begin
            GLSetup.Get;
            CurrencyCode := GLSetup."LCY Code";
        end;

        with EFTTransactionRequest do begin
            "Sales Ticket No." := SalesReceiptNo;
            "Reference Number Input" := SalesReceiptNo;

            SetTrxProcessingType('0', RegisterNo, EFTTransactionRequest);

        end;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateRefundRequest(RegisterNo: Code[20]; SalesReceiptNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; ReferenceNumber: Code[12]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin

        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        PepperVersion.TestField("Codeunit Transaction");
        PepperConfiguration.TestField("Transaction Type Refund Code");

        if (CurrencyCode = '') then begin
            GLSetup.Get;
            CurrencyCode := GLSetup."LCY Code";
        end;

        with EFTTransactionRequest do begin
            "Sales Ticket No." := SalesReceiptNo;
            "Reference Number Input" := ReferenceNumber;
            "Currency Code" := CurrencyCode;
            "Amount Input" := Abs(Amount); // Amount should be positiv

            SetTrxProcessingType('60', RegisterNo, EFTTransactionRequest);

        end;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateVoidPaymentOfGoodsRequest(RegisterNo: Code[20]; SalesReceiptNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; ReferenceNumber: Code[12]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        PepperVersion.TestField("Codeunit Transaction");
        PepperConfiguration.TestField("Transaction Type Refund Code");

        if (CurrencyCode = '') then begin
            GLSetup.Get;
            CurrencyCode := GLSetup."LCY Code";
        end;

        with EFTTransactionRequest do begin
            "Sales Ticket No." := SalesReceiptNo;
            "Reference Number Input" := ReferenceNumber;

            "Currency Code" := CurrencyCode;
            "Amount Input" := Amount;

            SetTrxProcessingType('20', RegisterNo, EFTTransactionRequest);

        end;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateAuxRequest(RegisterNo: Code[20]; AuxFunction: Option; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        PepperVersion.TestField("Codeunit Auxiliary Functions");
        PepperConfiguration.TestField("Transaction Type Auxilary Code");

        if (AuxFunction = 0) then begin
            AuxFunction := DIALOG.StrMenu(AuxFunctionMenu, 1, ChooseAuxFunction);
            if (AuxFunction = 0) then
                Error('Aborted.');
        end;

        with EFTTransactionRequest do begin

            "Processing Type" := EFTTransactionRequest."Processing Type"::AUXILIARY;
            "Pepper Transaction Type Code" := PepperConfiguration."Transaction Type Auxilary Code";

            "Pepper Trans. Subtype Code" := Format(AuxFunction);

        end;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateInstallRequest(RegisterNo: Code[20]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        PepperVersion.TestField("Codeunit Auxiliary Functions");
        PepperConfiguration.TestField("Transaction Type Install Code");

        with EFTTransactionRequest do begin

            "Processing Type" := EFTTransactionRequest."Processing Type"::AUXILIARY;
            "Pepper Transaction Type Code" := PepperConfiguration."Transaction Type Install Code";

            "Pepper Trans. Subtype Code" := PepperVersion.Code;

        end;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure InitializeGenericRequest(RegisterNo: Code[20]; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        InitializePepperSetup(RegisterNo);

        with EFTTransactionRequest do begin
            "Result Code" := -900; // Request created
            "Result Description" := 'PENDING...';
            "Register No." := RegisterNo;

            Token := CreateGuid();
            Mode := PepperConfiguration.Mode;

            "Track Presence Input" := "Track Presence Input"::"From EFT";
            "Card Information Input" := '';

            "Integration Type" := GetIntegrationType();
            "Pepper Terminal Code" := PepperTerminal.Code;
            "Integration Version Code" := PepperConfiguration.Version;

            Started := CurrentDateTime;
            "User ID" := UserId;
        end;
    end;

    local procedure "--*** Supporting Functions"()
    begin
    end;

    procedure SetTrxProcessingType(TransactionSubtypeCode: Code[10]; RegisterNo: Code[10]; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        InitializePepperSetup(RegisterNo);

        with EFTTransactionRequest do begin
            "Pepper Trans. Subtype Code" := TransactionSubtypeCode;
            "Processing Type" := "Processing Type"::OTHER;
            "Pepper Transaction Type Code" := '';

            case TransactionSubtypeCode of
                '0':
                    begin
                        "Processing Type" := EFTTransactionRequest."Processing Type"::OTHER;
                        "Pepper Transaction Type Code" := PepperConfiguration."Transaction Type Recover Code";
                    end;
                '10':
                    begin
                        "Processing Type" := EFTTransactionRequest."Processing Type"::PAYMENT;
                        "Pepper Transaction Type Code" := PepperConfiguration."Transaction Type Payment Code";
                    end;
                '20', '60':
                    begin
                        "Processing Type" := EFTTransactionRequest."Processing Type"::REFUND;
                        "Pepper Transaction Type Code" := PepperConfiguration."Transaction Type Refund Code";
                    end;
                else
                    Error('The "Transaction Subtype Code" %1 has not been handled in function SetTrxProcessingType.');
            end;
        end;
    end;

    local procedure FindTerminalSetupFromRegister(RegisterNo: Code[10]; var VarPepperTerminal: Record "NPR Pepper Terminal"; var VarPepperInstance: Record "NPR Pepper Instance"; var VarPepperConfiguration: Record "NPR Pepper Config."; var VarPepperVersion: Record "NPR Pepper Version"; var VarEFTSetup: Record "NPR EFT Setup"): Boolean
    begin

        VarPepperTerminal.Reset;
        VarPepperTerminal.SetRange("Register No.", RegisterNo);

        if (VarPepperTerminal.Count > 1) then
            Error(ErrorText001, RegisterNo);

        if (not VarPepperTerminal.FindFirst()) then
            Error(ErrorText002, RegisterNo);

        VarPepperInstance.Get(VarPepperTerminal."Instance ID");
        VarPepperInstance.TestField("Configuration Code");

        VarPepperConfiguration.Get(VarPepperInstance."Configuration Code");
        VarPepperConfiguration.TestField(Version);

        VarPepperVersion.Get(VarPepperConfiguration.Version);

        VarEFTSetup.SetRange("EFT Integration Type", GetIntegrationType());
        VarEFTSetup.SetRange("POS Unit No.", RegisterNo);
        if not VarEFTSetup.FindFirst then begin
            VarEFTSetup.SetRange("POS Unit No.", '');
            VarEFTSetup.FindFirst;
        end;

        exit(true);
    end;

    local procedure CalcAmountInCents(ParDecimalAmount: Decimal; ParCurrencyCode: Code[10]): Integer
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
        if Evaluate(AmountInCents, Format(Round(CentFactor * ParDecimalAmount, 1))) then
            exit(AmountInCents)
        else
            exit(0);
    end;

    local procedure CalcAmountInCurrency(ParAmountInCents: Integer; ParCurrencyCode: Code[10]): Decimal
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
        exit(ParAmountInCents / CentFactor);
    end;

    local procedure CalcCentFactor(TextFormat: Text): Integer
    var
        DecimalPlaces: Integer;
        I: Integer;
    begin
        if StrPos(TextFormat, ':') > 0 then
            if StrLen(TextFormat) > StrPos(TextFormat, ':') then
                if Evaluate(DecimalPlaces, CopyStr(TextFormat, StrPos(TextFormat, ':') + 1)) then
                    if DecimalPlaces > 0 then
                        exit(Power(10, DecimalPlaces));
        exit(1);
    end;

    local procedure CheckTestMode(PepperConfiguration: Record "NPR Pepper Config."): Boolean
    var
        TxtLocaltestmode: Label 'WARNING: Local test mode cuts communication with the terminal and simulates succesful transactions.';
        TxtRemotetestmode: Label 'WARNING: Remote test mode processes transactions to the terminal as normal but logs them as test. Make sure the terminal is set to test manually!';
    begin
        case PepperConfiguration.Mode of
            PepperConfiguration.Mode::"TEST Local":
                begin
                    Message(TxtLocaltestmode);
                    AddToCommentBatch(TxtLocaltestmode);
                    exit(true);
                end;
            PepperConfiguration.Mode::"TEST Remote":
                begin
                    Message(TxtRemotetestmode);
                    AddToCommentBatch(TxtRemotetestmode);
                    exit(false);
                end;
        end;
        exit(false);
    end;

    local procedure CheckCardInformation(ParCardTypeText: Text[4]; ParCardNameText: Text[24]; ParCardNumberText: Text[30]; ParCardExpiryDate: Text[4])
    var
        Text001: Label 'Card Type not received from Terminal.';
        Text002: Label 'Card Name not received from Terminal.';
        Text003: Label 'Card Number not received from Terminal';
        Text004: Label 'Card Expiry Date not received from Terminal';
        PepperCardType: Record "NPR Pepper Card Type";
        Month: Integer;
        Year: Integer;
        Text005: Label 'Card Expiry Date should be MMYY';
        Text006: Label 'Card Expiry Date is in the past.';
        Text008: Label 'No Card Information received from Terminal.';
    begin
        if (ParCardTypeText = '') and (ParCardNameText = '') and (ParCardNumberText = '') and (ParCardExpiryDate = '') then begin
            AddToCommentBatch(Text008);
            exit;
        end;
        if ParCardTypeText = '' then
            AddToCommentBatch(Text001)
        else
            if not PepperCardType.Get(ParCardTypeText) then
                if ParCardNameText = '' then
                    AddToCommentBatch(Text002);

        if ParCardNumberText = '' then
            AddToCommentBatch(Text003);

        if StrLen(ParCardExpiryDate) < 4 then begin
            AddToCommentBatch(Text004);
        end else begin
            if (Evaluate(Month, CopyStr(ParCardExpiryDate, 1, 2))) and (Evaluate(Year, CopyStr(ParCardExpiryDate, 3, 2))) then begin
                if (Month < 1) or (Month > 12) then begin
                    AddToCommentBatch(Text005);
                end else begin
                    if ((2000 + Year) < Date2DMY(Today, 3)) or (((2000 + Year) = Date2DMY(Today, 3)) and (Month < Date2DMY(Today, 2))) then begin
                        AddToCommentBatch(Text006);
                    end;
                end;
            end else begin
                AddToCommentBatch(Text005);
            end;
        end;
    end;

    local procedure GetTimeout(PepperConfigurationCode: Code[10]; PepperTransactionCode: Code[10]): Integer
    var
        PepperTransactionType: Record "NPR Pepper EFT Trx Type";
        PepperConfiguration: Record "NPR Pepper Config.";
    begin

        //TODO EFT Transaction Type
        if PepperTransactionType.Get(PepperTransactionCode) then
            if PepperTransactionType."POS Timeout (Seconds)" <> 0 then
                exit(PepperTransactionType."POS Timeout (Seconds)" * 1000);

        PepperConfiguration.Get(PepperConfigurationCode);
        exit(PepperConfiguration."Default POS Timeout (Seconds)" * 1000);
    end;

    local procedure GetPepperReceiptEncoding(PepperTerminal: Record "NPR Pepper Terminal"): Code[50]
    begin

        if PepperTerminal."Pepper Receipt Encoding" = 0 then
            exit('')
        else
            exit(UpperCase(Format(PepperTerminal."Pepper Receipt Encoding", 0)));
    end;

    local procedure GetNavReceiptEncoding(PepperTerminal: Record "NPR Pepper Terminal"): Code[50]
    begin

        if PepperTerminal."NAV Receipt Encoding" = 0 then
            exit('')
        else
            exit(UpperCase(Format(PepperTerminal."NAV Receipt Encoding", 0)));
    end;

    local procedure GetResultCodeDescription(ParTransactionType: Code[10]; ParTransactionSubtypeCode: Code[10]; ParResultCode: Integer) Description: Text
    var
        PepperResultCode: Record "NPR Pepper EFT Result Code";
    begin

        if (PepperResultCode.Get(GetIntegrationType(), ParTransactionType, ParTransactionSubtypeCode, ParResultCode)) then
            exit(PepperResultCode.Description);

        if (PepperResultCode.Get(GetIntegrationType(), ParTransactionType, '', ParResultCode)) then begin
            AddToCommentBatch(StrSubstNo(Text103, ParTransactionType, PepperResultCode."Transaction Type Code", PepperResultCode."Transaction Subtype Code"));
            exit(PepperResultCode.Description);
        end;

        if (PepperResultCode.Get(GetIntegrationType(), '', '', ParResultCode)) then begin
            AddToCommentBatch(StrSubstNo(Text103, ParTransactionType, PepperResultCode."Transaction Type Code", PepperResultCode."Transaction Subtype Code"));
            exit(PepperResultCode.Description);
        end;

        exit(Text104);
    end;

    local procedure GetTransactionDate(DateText: Text): Date
    var
        Text001: Label 'Transaction Date not specified.';
        Text002: Label 'Transaction Date not formatted DDMMYYYY. Value received: %1';
        TDate: Date;
    begin

        if DateText = '' then begin
            AddToCommentBatch(Text001);
            exit(Today);
        end;

        TDate := GetDateFromText(DateText);
        if TDate = 0D then
            AddToCommentBatch(StrSubstNo(Text002, DateText));

        if (TDate = 0D) then
            TDate := Today;

        exit(TDate);
    end;

    local procedure GetTransactionTime(TimeText: Text): Time
    var
        TTime: Time;
        Text001: Label 'Transaction Time not specified.';
        Text002: Label 'Transaction Time not formatted HHMMSS. Value received: %1';
    begin
        if TimeText = '' then begin
            AddToCommentBatch(Text001);
            exit(0T);
        end;
        TTime := GetTimeFromText(TimeText);
        if TTime = 0T then
            AddToCommentBatch(StrSubstNo(Text002, TimeText));
        exit(TTime);
    end;

    local procedure GetDateFromText(DateText: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        FifthandSixthPos: Integer;
    begin
        if DateText = '' then
            exit(0D);

        // Dateformat is DDMMYYYY according to documentation.
        if (StrLen(DateText) <> 8) then
            exit(0D);

        if (CopyStr(DateText, 5, 2) <> '20') then // 2018 now
            exit(0D);

        if not Evaluate(Day, CopyStr(DateText, 1, 2)) then
            exit(0D);

        if not Evaluate(Month, CopyStr(DateText, 3, 2)) then
            exit(0D);

        if not Evaluate(Year, CopyStr(DateText, 5, 4)) then
            exit(0D);

        exit(DMY2Date(Day, Month, Year));
    end;

    local procedure GetTimeFromText(TimeText: Text): Time
    var
        TempTime: Time;
    begin
        if TimeText = '' then
            exit(0T);
        if not Evaluate(TempTime, TimeText) then
            exit(0T);
        exit(TempTime);
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        PepperCardType: Record "NPR Pepper Card Type";
        TextDescription: Label '%1:%2';
        TextUnknown: Label 'Card: %1';
    begin

        with EFTTransactionRequest do begin

            if ("Card Name" <> '') then begin
                if (StrLen("Card Number") > 8) then
                    exit(StrSubstNo(TextDescription, CopyStr("Card Name", 1, 8), CopyStr("Card Number", StrLen("Card Number") - 7)))
                else
                    exit(StrSubstNo("Card Name"));

            end else begin
                if PepperCardType.Get("Card Type") then
                    if (PepperCardType.Description <> '') and (StrLen("Card Number") > 8) then
                        exit(StrSubstNo(TextDescription, CopyStr("Card Name", 1, 8), CopyStr("Card Number", StrLen("Card Number") - 7)))
                    else
                        exit(StrSubstNo(TextUnknown, PepperCardType.Description))
                else
                    exit(StrSubstNo(TextUnknown, "Card Number"));

            end;

        end;
    end;

    procedure GetPaymentTypePOS(CardType: Code[10]): Code[10]
    var
        PepperCardType: Record "NPR Pepper Card Type";
    begin

        if (CardType <> '') then
            if (PepperCardType.Get(CardType)) then
                exit(PepperCardType."Payment Type POS");

        exit('');
    end;

    local procedure IsSuccessfulResultCode(ParTransactionType: Code[10]; ParTransactionSubtypeCode: Code[10]; ParResultCode: Integer): Boolean
    var
        EFTResultCode: Record "NPR Pepper EFT Result Code";
    begin

        if (EFTResultCode.Get(GetIntegrationType(), ParTransactionType, ParTransactionSubtypeCode, ParResultCode)) then
            exit(EFTResultCode.Successful);

        if (EFTResultCode.Get(GetIntegrationType(), ParTransactionType, '', ParResultCode)) then
            exit(EFTResultCode.Successful);

        if (EFTResultCode.Get(GetIntegrationType(), '', '', ParResultCode)) then
            exit(EFTResultCode.Successful);

        exit(ParResultCode > 0);
    end;

    procedure AddComment(EftRequestEntryNo: Integer; Comment: Text)
    var
        EFTTransactReqComment: Record "NPR EFT Transact. Req. Comment";
    begin

        if (Comment = '') then
            exit;

        EFTTransactReqComment.SetFilter("Entry No.", '=%1', EftRequestEntryNo);
        if (EFTTransactReqComment.FindLast) then;

        EFTTransactReqComment.Init;
        EFTTransactReqComment."Entry No." := EftRequestEntryNo;
        EFTTransactReqComment."Line No." := EFTTransactReqComment."Line No." + 1;
        EFTTransactReqComment.Comment := Comment;
        EFTTransactReqComment.Insert(true);
    end;

    local procedure AddToCommentBatch(Comment: Text)
    var
        I: Integer;
        ArrayContent: Text;
        PepperLogComment: Record "NPR EFT Transact. Req. Comment";
    begin

        I := 0;
        repeat
            I := I + 1;
            ArrayContent := CommentText[I];
        until (I = ArrayLen(CommentText, 1)) or (ArrayContent = '');

        if ArrayContent = '' then begin
            CommentText[I] := CopyStr(Comment, 1, MaxStrLen(PepperLogComment.Comment));
        end;
    end;

    local procedure UpdateEftTransactionRequestCommentBatch(EftRequestEntryNo: Integer)
    var
        EFTTransactReqComment: Record "NPR EFT Transact. Req. Comment";
        I: Integer;
        LastLine: Integer;
    begin
        I := 0;

        EFTTransactReqComment.Reset;
        EFTTransactReqComment.SetFilter("Entry No.", '=%1', EftRequestEntryNo);
        if EFTTransactReqComment.FindLast then
            LastLine := EFTTransactReqComment."Line No."
        else
            LastLine := 0;

        CompressArray(CommentText);

        repeat
            I := I + 1;
            if CommentText[I] <> '' then begin
                EFTTransactReqComment.Init;
                EFTTransactReqComment."Entry No." := EftRequestEntryNo;
                EFTTransactReqComment."Line No." := I + LastLine;
                EFTTransactReqComment.Comment := CommentText[I];
                EFTTransactReqComment.Insert(true);
            end;

        until (I = ArrayLen(CommentText)) or (CommentText[I] = '');
    end;

    local procedure AddReceipt(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptText: Text): Boolean
    var
        OStream: OutStream;
    begin

        if (ReceiptText = '') then
            exit(false);

        if (not EFTTransactionRequest."Receipt 1".HasValue) then begin
            EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);
            OStream.Write(ReceiptText);
            exit(true);
        end;

        if (not EFTTransactionRequest."Receipt 2".HasValue) then begin
            EFTTransactionRequest."Receipt 2".CreateOutStream(OStream);
            OStream.Write(ReceiptText);
            exit(true);
        end;

        exit(false);
    end;

    local procedure AttemptOpenAndRetry(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        EFTResultCode: Record "NPR Pepper EFT Result Code";
    begin

        with EFTTransactionRequest do begin
            if (Successful) then
                exit(false);

            if ("Offline mode") then
                exit(false);

            if (not EFTResultCode.Get("Integration Type", "Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", "Result Code")) then
                exit(false);

            exit(EFTResultCode."Open Terminal and Retry");

        end;
    end;

    local procedure "--***Printing"()
    begin
    end;

    local procedure ReadyReceiptsForPrint(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        EntryNo: Integer;
        StreamIn: InStream;
        EFTTransactionType: Record "NPR Pepper EFT Trx Type";
    begin

        InitializePepperSetup(EFTTransactionRequest."Register No.");

        CreditCardTransaction.SetFilter("EFT Trans. Request Entry No.", '=%1', EFTTransactionRequest."Entry No.");
        if (not CreditCardTransaction.IsEmpty()) then
            exit;

        if (EFTTransactionType.Get(GetIntegrationType(), EFTTransactionRequest."Pepper Transaction Type Code")) then
            if (EFTTransactionType."Suppress Receipt Print") then
                exit;

        CreditCardTransaction.Reset;
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");

        if (CreditCardTransaction.FindLast) then
            EntryNo := CreditCardTransaction."Entry No.";

        EFTTransactionRequest.CalcFields("Receipt 1", "Receipt 2");

        if (EFTTransactionRequest."Receipt 1".HasValue) then begin
            EFTTransactionRequest."Receipt 1".CreateInStream(StreamIn);
            MakeReceipt(EFTTransactionRequest, StreamIn, EntryNo, 0);
        end;

        if (EFTTransactionRequest."Receipt 2".HasValue) then begin
            EFTTransactionRequest."Receipt 2".CreateInStream(StreamIn);
            MakeReceipt(EFTTransactionRequest, StreamIn, EntryNo, 1);
        end;
    end;

    local procedure MakeReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var StreamIn: InStream; var EntryNo: Integer; ReceiptType: Option CUSTOMER,MERCHANT)
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        POSUnit: Record "NPR POS Unit";
        Utility: Codeunit "NPR Receipt Footer Mgt.";
        TicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        ReceiptLineText: Text;
        Encoding: TextEncoding;
        I: Integer;
        TextDot: Label '______________________________';
        TextSig: Label 'Customer Signature';
    begin
        POSUnit.Get(EFTTransactionRequest."Register No.");

        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction.Date := Today;
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        if (EFTTransactionRequest."Initiated from Entry No." <> 0) then
            CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Initiated from Entry No.";

        CreditCardTransaction."Receipt No." := ReceiptType;

        if (PepperConfiguration."Header and Footer Handling" = PepperConfiguration."Header and Footer Handling"::"Add Headers and Footers at Printing") then begin
            Utility.GetSalesTicketReceiptText(TicketRcptText, POSUnit);
            repeat
                EntryNo := EntryNo + 1;
                WriteRequestLine(CreditCardTransaction, EntryNo, CopyStr(TicketRcptText."Receipt Text", 1, MaxStrLen(CreditCardTransaction.Text)));
            until TicketRcptText.next() = 0;
        end;

        repeat
            StreamIn.ReadText(ReceiptLineText);
            EntryNo := EntryNo + 1;
            WriteRequestLine(CreditCardTransaction, EntryNo, CopyStr(ReceiptLineText, 1, MaxStrLen(CreditCardTransaction.Text)));
        until StreamIn.EOS;

        if (ReceiptType = ReceiptType::MERCHANT) then begin
            if (EFTTransactionRequest."Authentication Method" = EFTTransactionRequest."Authentication Method"::Signature) then begin
                if PepperTerminal."Add Customer Signature Space" then begin
                    for I := 1 to 4 do begin
                        EntryNo := EntryNo + 1;
                        WriteRequestLine(CreditCardTransaction, EntryNo, '');
                    end;
                    EntryNo := EntryNo + 1;
                    WriteRequestLine(CreditCardTransaction, EntryNo, TextDot);
                    EntryNo := EntryNo + 1;
                    WriteRequestLine(CreditCardTransaction, EntryNo, TextSig);
                    for I := 1 to 2 do begin
                        EntryNo := EntryNo + 1;
                        WriteRequestLine(CreditCardTransaction, EntryNo, '');
                    end;
                end;
            end;
        end;
    end;

    local procedure WriteRequestLine(var ParCreditCardTransaction: Record "NPR EFT Receipt"; ParEntryNo: Integer; ParText: Text)
    begin

        with ParCreditCardTransaction do begin
            Validate("Entry No.", ParEntryNo);
            Validate("Line No.", 0);
            Validate(Type, 0);
            Validate(Text, ParText);
            Insert(true);
        end;
    end;

    procedure SetTerminalToOfflineMode(Register: Record "NPR Register"; CommandType: Option Activate,Deactivate) Success: Boolean
    var
        PepperTerminal: Record "NPR Pepper Terminal";
    begin
        InitializePepperSetup(Register."Register No.");
        Success := false;
        case CommandType of
            CommandType::Activate:
                begin
                    if (PepperTerminal.Status = PepperTerminal.Status::ActiveOffline) then begin
                        exit(true);
                    end;
                    if (PepperTerminal.Status <> PepperTerminal.Status::Open) then begin
                        exit(false)
                    end;
                    PepperTerminal.Validate(Status, PepperTerminal.Status::ActiveOffline);
                    PepperTerminal.Modify(true);
                    Commit;
                end;
            CommandType::Deactivate:
                begin
                    if (PepperTerminal.Status = PepperTerminal.Status::Open) then begin
                        exit(true);
                    end;
                    if (PepperTerminal.Status <> PepperTerminal.Status::ActiveOffline) then begin
                        exit(false);
                    end;
                    PepperTerminal.Validate(Status, PepperTerminal.Status::Open);
                    PepperTerminal.Modify(true);
                    Commit;
                end;
        end;
        exit(true);
    end;

    local procedure "--*** Integration Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if (EftTransactionRequest."Integration Type" <> GetIntegrationType()) then
            exit;

        Handled := MakeDeviceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateBeginWorkshiftRequest', '', false, false)]
    local procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;
        Handled := CreateBeginWorkshiftRequest(EftTransactionRequest."Register No.", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateEndWorkshiftRequest', '', false, false)]
    local procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;
        Handled := CreateEndWorkshiftRequest(EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;

        with EftTransactionRequest do
            Handled := CreatePaymentOfGoodsRequest("Register No.", "Sales Ticket No.", "Currency Code", EftTransactionRequest."Amount Input", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;

        if (OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.")) then;

        with EftTransactionRequest do
            Handled := CreateRefundRequest("Register No.", "Sales Ticket No.", "Currency Code", "Amount Input", OriginalTransactionRequest."Reference Number Output", EftTransactionRequest);

        if (Handled) then begin
            if (OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.")) then begin
                OriginalTransactionRequest.Reversed := true;
                OriginalTransactionRequest."Reversed by Entry No." := EftTransactionRequest."Entry No.";
                OriginalTransactionRequest.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidPaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;

        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        if OriginalTransactionRequest."Processing Type" <> OriginalTransactionRequest."Processing Type"::PAYMENT then
            exit;

        with OriginalTransactionRequest do
            Handled := CreateVoidPaymentOfGoodsRequest(EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", "Currency Code", "Amount Output", "Reference Number Output", EftTransactionRequest);

        if (Handled) then begin
            if (OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.")) then begin
                OriginalTransactionRequest.Reversed := true;
                OriginalTransactionRequest."Reversed by Entry No." := EftTransactionRequest."Entry No.";
                OriginalTransactionRequest.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;

        Handled := CreateAuxRequest(EftTransactionRequest."Register No.", EftTransactionRequest."Auxiliary Operation ID", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVerifySetupRequest', '', false, false)]
    local procedure OnCreateInstallRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;

        Handled := CreateInstallRequest(EftTransactionRequest."Register No.", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        AlternativeTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;

        EftTransactionRequest.PrintReceipts(false);

        if (not EftTransactionRequest.Successful) then
            Message(EftPaymentFailed, EftTransactionRequest."Result Code", EftTransactionRequest."Result Description");

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    var
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if not EftTransactionRequest.IsType(GetIntegrationType()) then
            exit;
        if not EftTransactionRequest.Successful then
            exit;
        if not (EftTransactionRequest."Authentication Method" = EftTransactionRequest."Authentication Method"::Signature) then
            exit;

        InitializePepperSetup(EftTransactionRequest."Register No.");

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::PAYMENT) then
            if (PepperTerminal."Cancel at Wrong Signature") then
                if (not Confirm('Customer must sign the receipt.\\Confirm signature.')) then begin
                    DoNotResume := true;
                    InitializePepperSetup(EftTransactionRequest."Register No.");
                    EFTFrameworkMgt.CreateVoidRequest(VoidEFTTransactionRequest, EFTSetup, EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", EftTransactionRequest."Entry No.", false);
                    EFTFrameworkMgt.SendRequest(VoidEFTTransactionRequest);
                end;

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::REFUND) then
            Message('Customer must sign the receipt.');

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnQueueCloseBeforeRegisterBalance', '', false, false)]
    local procedure OnQueueCloseBeforeRegisterBalance(POSSession: Codeunit "NPR POS Session"; var tmpEFTSetup: Record "NPR EFT Setup" temporary)
    var
        POSSetup: Codeunit "NPR POS Setup";
        EFTSetup: Record "NPR EFT Setup";
    begin

        POSSession.GetSetup(POSSetup);

        EFTSetup.SetFilter("POS Unit No.", POSSetup.Register());
        EFTSetup.SetRange("EFT Integration Type", GetIntegrationType());
        if not EFTSetup.FindFirst then begin
            EFTSetup.SetRange("POS Unit No.", '');
            if not EFTSetup.FindFirst then
                exit;
        end;

        tmpEFTSetup := EFTSetup;
        tmpEFTSetup.Insert;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDisplayReceipt', '', false, false)]
    local procedure OnDisplayReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptNo: Integer; var Handled: Boolean)
    var
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
    begin

        if not EFTTransactionRequest.IsType(GetIntegrationType()) then
            exit;

        Handled := true;
        Message(PepperConfigManagement.GetReceiptText(EFTTransactionRequest, ReceiptNo, true));

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnPrintReceipt', '', false, false)]
    local procedure OnPrintReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin

        if not EFTTransactionRequest.IsType(GetIntegrationType()) then
            exit;

        Handled := true;

        CreditCardTransaction.SetFilter("EFT Trans. Request Entry No.", '=%1', EFTTransactionRequest."Entry No.");
        if (EFTTransactionRequest."Initiated from Entry No." <> 0) then
            CreditCardTransaction.SetFilter("EFT Trans. Request Entry No.", '=%1', EFTTransactionRequest."Initiated from Entry No.");

        if not CreditCardTransaction.FindSet then
            exit;

        CreditCardTransaction.PrintTerminalReceipt();

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin

        tmpEFTIntegrationType.Code := GetIntegrationType();
        tmpEFTIntegrationType.Description := StrSubstNo('%1 %2 %3', 'Treibauf', 'Pepper', PepperDescription);
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR Pepper Library TSD";
        tmpEFTIntegrationType.Insert;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin

        tmpEFTAuxOperation."Integration Type" := GetIntegrationType();

        tmpEFTAuxOperation."Auxiliary ID" := 0;
        tmpEFTAuxOperation.Description := 'StrMenu';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := 'Abort';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := 'PAN Suppression ON';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := 'PAN Suppression OFF';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := 'Custom Menu';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 5;
        tmpEFTAuxOperation.Description := 'Ticket Reprint';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 6;
        tmpEFTAuxOperation.Description := 'Summary Report';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 7;
        tmpEFTAuxOperation.Description := 'Diagnostics';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 8;
        tmpEFTAuxOperation.Description := 'System Info';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 9;
        tmpEFTAuxOperation.Description := 'Display with Num Input';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 10;
        tmpEFTAuxOperation.Description := 'TINA Activation';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 11;
        tmpEFTAuxOperation.Description := 'TINA Query';
        tmpEFTAuxOperation.Insert;

        tmpEFTAuxOperation."Auxiliary ID" := 12;
        tmpEFTAuxOperation.Description := 'Show Custom Menu';
        tmpEFTAuxOperation.Insert;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        PepperTerminal: Record "NPR Pepper Terminal";
    begin
        if EFTSetup."EFT Integration Type" <> GetIntegrationType() then
            exit;

        if EFTSetup."POS Unit No." <> '' then
            PepperTerminal.SetRange("Register No.", EFTSetup."POS Unit No.");

        PAGE.RunModal(0, PepperTerminal);

    end;

    [EventSubscriber(ObjectType::Table, 6184485, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterEFTSetupInsert(var Rec: Record "NPR EFT Setup"; RunTrigger: Boolean)
    var
        EFTSetup: Record "NPR EFT Setup";
    begin

        if Rec.IsTemporary or (not RunTrigger) then
            exit;
        EFTSetup.SetRange("POS Unit No.", Rec."POS Unit No.");
        EFTSetup.SetRange("EFT Integration Type", GetIntegrationType());
        EFTSetup.SetFilter("Payment Type POS", '<>%1', Rec."Payment Type POS");
        if not EFTSetup.IsEmpty then
            Error(ErrorText001, Rec."POS Unit No.");

    end;

    [EventSubscriber(ObjectType::Table, 6184485, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterEFTSetupRename(var Rec: Record "NPR EFT Setup"; var xRec: Record "NPR EFT Setup"; RunTrigger: Boolean)
    var
        EFTSetup: Record "NPR EFT Setup";
    begin

        if Rec.IsTemporary or (not RunTrigger) then
            exit;
        EFTSetup.SetRange("POS Unit No.", Rec."POS Unit No.");
        EFTSetup.SetRange("EFT Integration Type", GetIntegrationType());
        EFTSetup.SetFilter("Payment Type POS", '<>%1', Rec."Payment Type POS");
        if not EFTSetup.IsEmpty then
            Error(ErrorText001, Rec."POS Unit No.");

    end;

    local procedure "--*** Device Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184491, 'OnBeginWorkshiftReponse', '', false, false)]
    local procedure OnBeginWorkshiftResponse(var Sender: Codeunit "NPR Pepper Begin Workshift TSD"; EFTPaymentRequestID: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        EFTTransactionRequest.Get(EFTPaymentRequestID);
        BeginWorkshiftResponse(Sender, EFTTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184492, 'OnTransactionReponse', '', false, false)]
    local procedure OnTransactionResponse(var Sender: Codeunit "NPR Pepper Transaction TSD"; EFTPaymentRequestID: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        EFTTransactionRequest.Get(EFTPaymentRequestID);
        TrxResponse(Sender, EFTTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184493, 'OnEndWorkshiftResponse', '', false, false)]
    local procedure OnEndWorkshiftResponse(var Sender: Codeunit "NPR Pepper End Workshift TSD"; EFTPaymentRequestID: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        EFTTransactionRequest.Get(EFTPaymentRequestID);
        EndWorkshiftResponse(Sender, EFTTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184494, 'OnAuxResponse', '', false, false)]
    local procedure OnAuxResponse(var Sender: Codeunit "NPR Pepper Aux Func. TSD"; EFTPaymentRequestID: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        EFTTransactionRequest.Get(EFTPaymentRequestID);
        AuxFunctionResponse(Sender, EFTTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184495, 'OnFileMgtResponse', '', false, false)]
    local procedure OnFileMgtResponse(EFTPaymentRequestID: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        EFTTransactionRequest.Get(EFTPaymentRequestID);
        InstallPepperResponse(EFTTransactionRequest);
    end;

    procedure GetKeyFromLicenseText(LicenseText: Text): Text[8]
    var
        KeyText: Text;
        XMLDOMManagement: Codeunit "XML DOM Management";
        XMLRootNode: DotNet NPRNetXmlNode;
    begin
        if not XMLDOMManagement.LoadXMLDocumentFromText(LicenseText, XMLRootNode) then
            exit('');
        KeyText := XMLDOMManagement.FindNodeText(XMLRootNode, '/License/Information/Key');
        if StrLen(KeyText) <> 8 then
            exit('');
        exit(KeyText);
    end;

    procedure GetTerminalTypeFromLicenseText(LicenseText: Text): Integer
    var
        TerminalTypeID: Integer;
        TerminalTypeText: Text;
        XMLDOMManagement: Codeunit "XML DOM Management";
        XMLRootNode: DotNet NPRNetXmlNode;
        PepperTerminalType: Record "NPR Pepper Terminal Type";
    begin
        if not XMLDOMManagement.LoadXMLDocumentFromText(LicenseText, XMLRootNode) then
            exit(0);
        TerminalTypeText := XMLDOMManagement.FindNodeText(XMLRootNode, '/License/Options/TerminalTypeList');
        if Evaluate(TerminalTypeID, TerminalTypeText) then
            if PepperTerminalType.Get(TerminalTypeID) then
                if PepperTerminalType.Active then
                    exit(PepperTerminalType.ID);
        exit(0);

    end;
}

