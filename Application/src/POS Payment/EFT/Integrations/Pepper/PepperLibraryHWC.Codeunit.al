codeunit 6184496 "NPR Pepper Library HWC"
{
    Access = Internal;

    var
        Text103: Label 'This result code was not found for Transaction Type %1, so taken from %2 %3.';
        ErrorText001: Label 'Payment Method %1 and POS Unit %2 resolves to multiple EFT terminal types.';

        _PepperSetupInitialized: Boolean;
        _PepperTerminal: Record "NPR Pepper Terminal";
        _PepperInstance: Record "NPR Pepper Instance";
        _PepperConfiguration: Record "NPR Pepper Config.";
        _PepperVersion: Record "NPR Pepper Version";
        CommentText: array[20] of Text;
        _AuxFunctionMenu: Label 'ABORT,PANSUPPRESSIONON,PANSUPPRESSIONOFF,CUSTOMMENU,TICKETREPRINT,SUMMARYREPORT,DIAGNOSTICS,SYSTEMINFO,DISPWITHNUMINPUT,TINAACTIVATION,TINADEACTIVATION,TINAQUERY,SHOWCUSTOMMENU';
        DEMO_TRANSACTION: Label '***** NOTICE *****\\This is a demo transaction.\\ *** DEMO *** DEMO *** DEMO ***';
        _SupportedAuxFunction: Option ,ABORT,PAN_SUPPRESSION_ON,PAN_SUPPRESSION_OFF,CUSTOM_MENU,TICKET_REPRINT,SUMMARY_REPORT,DIAGNOSTICS,SYSTEM_INFO,DISPLAY_WITH_NUM_INPUT,TINA_ACTIVATION,TINA_DEACTIVATION,TINA_QUERY,SHOW_CUSTOM_MENU,ACTIVATE_OFFLINE,DEACTIVATE_OFFLINE;
        _BeginWorkshiftRequired: Label 'Terminal must be open when attempting a transaction.';

    local procedure InitializePepperSetup(RegisterNo: Code[10])
    var
        PepperSetupNotFound: Label 'The Register No. %1 is not associated with a pepper terminal.\\Go to Pepper Terminals and assign register %1 to a Pepper Terminal.';
    begin

        if (_PepperSetupInitialized) then
            exit;

        _PepperSetupInitialized := DoInitializePepperSetup(RegisterNo);

        if (not _PepperSetupInitialized) then
            Error(PepperSetupNotFound, RegisterNo);
    end;

    local procedure DoInitializePepperSetup(RegisterNo: Code[10]): Boolean
    begin
        exit(FindTerminalSetupFromRegister(RegisterNo, _PepperTerminal, _PepperInstance, _PepperConfiguration, _PepperVersion));
    end;

    procedure MakeHwcDeviceRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var HwcRequest: JsonObject): Boolean
    begin

        InitializePepperSetup(EFTTransactionRequest."Register No.");

        // This function will make an out-of-transaction request that can't be rolled backed
        Commit();

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::OPEN:
                BeginWorkshift(EFTTransactionRequest, true, HwcRequest);

            EFTTransactionRequest."Processing Type"::PAYMENT,
            EFTTransactionRequest."Processing Type"::REFUND,
            EFTTransactionRequest."Processing Type"::OTHER:
                case EFTTransactionRequest."Pepper Trans. Subtype Code" of
                    '0':
                        TrxRecoverTransaction(EFTTransactionRequest, HwcRequest);
                    '10':
                        TrxPaymentOfGoods(EFTTransactionRequest, '', HwcRequest);
                    '20':
                        TrxVoidPaymentOfGoods(EFTTransactionRequest, HwcRequest);
                    '60':
                        TrxRefund(EFTTransactionRequest, HwcRequest);
                    else
                        exit(false);
                end;

            EFTTransactionRequest."Processing Type"::AUXILIARY:
                case EFTTransactionRequest."Pepper Transaction Type Code" of
                    _PepperConfiguration."Transaction Type Auxilary Code":
                        AuxFunctionRequest(EFTTransactionRequest, HwcRequest);
                    _PepperConfiguration."Transaction Type Install Code":
                        InstallPepperRequest(EFTTransactionRequest, HwcRequest);
                    else
                        exit(false);
                end;

            EFTTransactionRequest."Processing Type"::CLOSE:
                EndWorkshift(EFTTransactionRequest, HwcRequest);

            else
                exit(false);
        end;

        exit(true);
    end;

    procedure AppendAdditionalParameters(EntryNo: Integer; AdditionalParameters: Text; var HwcResponse: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        CurrentParameters: Text;
        OStream: OutStream;
        IStream: InStream;
    begin
        EFTTransactionRequest.SetAutoCalcFields("Additional Info");
        EFTTransactionRequest.Get(EntryNo);

        CurrentParameters := '';
        if (EFTTransactionRequest."Additional Info".HasValue()) then begin
            EFTTransactionRequest."Additional Info".CreateInStream(IStream);
            IStream.ReadText(CurrentParameters);
        end;

        EFTTransactionRequest."Additional Info".CreateOutStream(OStream);
        OStream.WriteText(CurrentParameters + AdditionalParameters);
        EFTTransactionRequest.Modify();

        MakeHwcDeviceRequest(EFTTransactionRequest, HwcResponse);
    end;

    local procedure TransferAdditionalInfo(SourceEntryNo: Integer; var TargetRequest: Record "NPR EFT Transaction Request")
    var
        SourceRequest: Record "NPR EFT Transaction Request";
        AdditionalInfo: Text;
        OStream: OutStream;
        IStream: InStream;
    begin
        SourceRequest.SetAutoCalcFields("Additional Info");
        SourceRequest.Get(SourceEntryNo);
        if (not SourceRequest."Additional Info".HasValue()) then
            exit;

        SourceRequest."Additional Info".CreateInStream(IStream);
        IStream.ReadText(AdditionalInfo);

        TargetRequest."Additional Info".CreateOutStream(OStream);
        OStream.WriteText(AdditionalInfo);
    end;

    local procedure BeginWorkshift(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ForceDownloadLicense: Boolean; var HwcRequest: JsonObject)
    var
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
        PepperBeginWorkshift: Codeunit "NPR Pepper Begin Workshift HWC";
        POSUnit: Record "NPR POS Unit";
        LicenseString: Text;
        CustomerID: Text[8];
        LicenseID: Text[8];
        OptionInt: Integer;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        if (CheckTestMode(_PepperConfiguration)) then begin
            BeginWorkshiftResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        // Initialize Protocol
        PepperBeginWorkshift.InitializeProtocol();
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperBeginWorkshift.SetHwcVerboseLogLevel();
        PepperBeginWorkshift.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
        PepperBeginWorkshift.SetPepperFolder(_PepperVersion."Install Directory");

        // Initialize Pepper Library (client side)
        PepperBeginWorkshift.SetILP_UseConfigurationInstanceId(_PepperInstance.ID);
        PepperBeginWorkshift.SetILP_XmlConfigurationString(PepperConfigManagement.GetConfigurationText(_PepperConfiguration, 1));

        LicenseString := PepperConfigManagement.GetTerminalText(_PepperTerminal, 0);

        if (ForceDownloadLicense or (LicenseString = '')) then begin
            CustomerID := PepperConfigManagement.GetCustomerID(_PepperTerminal);
            LicenseID := PepperConfigManagement.GetLicenseID(_PepperTerminal);
            if (CustomerID <> '') and (LicenseID <> '') then begin
                PepperBeginWorkshift.SetILP_ForceGetPepperLicense(LicenseID, CustomerID);
            end;
        end;

        if (LicenseString <> '') then
            PepperBeginWorkshift.SetILP_XmlLicenseString(LicenseString);

        // Configure Driver
        PepperBeginWorkshift.SetCDP_ComPort(_PepperTerminal."Com Port");
        PepperBeginWorkshift.SetCDP_IpAddressAndPort(_PepperTerminal."IP Address");
        Evaluate(OptionInt, Format(_PepperTerminal.Language, 20, '<Number>'));
        PepperBeginWorkshift.SetCDP_EftTerminalInformation(_PepperTerminal."Terminal Type Code", OptionInt, PepperConfigManagement.GetPepperRegisterNo(_PepperTerminal."Register No."), Format(_PepperTerminal."Receipt Format"));
        PepperBeginWorkshift.SetCDP_Filenames(_PepperTerminal."Print File Open", _PepperTerminal."Print File Close",
                                                _PepperTerminal."Print File Transaction", _PepperTerminal."Print File CC Transaction",
                                                _PepperTerminal."Print File Difference", _PepperTerminal."Print File End of Day",
                                                _PepperTerminal."Print File Journal", _PepperTerminal."Print File Initialisation");
        Evaluate(OptionInt, Format(_PepperTerminal."Matchbox Files", 20, '<Number>'));
        PepperBeginWorkshift.SetCDP_MatchboxInformation(OptionInt, _PepperTerminal."Matchbox Company ID", _PepperTerminal."Matchbox Shop ID", _PepperTerminal."Matchbox POS ID", _PepperTerminal."Matchbox File Name");

        PepperBeginWorkshift.SetCDP_AdditionalParameters(PepperConfigManagement.GetTerminalText(_PepperTerminal, 1));

        // Open EFT
        PepperBeginWorkshift.SetPOP_Operator(1);
        PepperBeginWorkshift.SetPOP_AdditionalParameters('');
        PepperBeginWorkshift.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Open Code"));
        PepperBeginWorkshift.SetReceiptEncoding(GetPepperReceiptEncoding(_PepperTerminal));

        // Header and footers to receipts by pepper on client side
        case _PepperConfiguration."Header and Footer Handling" of
            _PepperConfiguration."Header and Footer Handling"::"Manual Headers and Footers":
                begin
                    PepperBeginWorkshift.SetHeaderFooters(false, _PepperConfiguration."Ticket Directory", '', '', '', '', '', '');
                end;
            _PepperConfiguration."Header and Footer Handling"::"Send Headers and Footers to Terminal":
                begin
                    POSUnit.Get(_PepperTerminal."Register No.");
                    PepperBeginWorkshift.SetHeaderFooters(true, _PepperConfiguration."Ticket Directory",
                                                            PepperConfigManagement.GetHeaderFooterText(POSUnit, 0, 0), PepperConfigManagement.GetHeaderFooterText(POSUnit, 0, 1),
                                                            PepperConfigManagement.GetHeaderFooterText(POSUnit, 1, 0), PepperConfigManagement.GetHeaderFooterText(POSUnit, 1, 1),
                                                            PepperConfigManagement.GetHeaderFooterText(POSUnit, 2, 0), PepperConfigManagement.GetHeaderFooterText(POSUnit, 2, 1));
                end;
            _PepperConfiguration."Header and Footer Handling"::"Add Headers and Footers at Printing", _PepperConfiguration."Header and Footer Handling"::"No Headers and Footers":
                begin
                    PepperBeginWorkshift.SetHeaderFooters(true, _PepperConfiguration."Ticket Directory", '', '', '', '', '', '');
                end;
        end;
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        HwcRequest := PepperBeginWorkshift.AssembleHwcRequest();
    end;

    procedure BeginWorkshiftResponse(EFTTransactionRequest: Record "NPR EFT Transaction Request"; HwcResponse: JsonObject; var Result: JsonObject)
    var
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
        LicenseString: Text;
        EftRetryTransactionRequest: Record "NPR EFT Transaction Request";
        EftRecoverTransactionRequest: Record "NPR EFT Transaction Request";
        PepperBeginWorkshift: Codeunit "NPR Pepper Begin Workshift HWC";
        TerminalIsOpen: Label 'Terminal is Open.';
        RecoveryRequired: Label 'Pepper must recover last transaction.';
        ContinueTransaction: Label 'Continue original transaction';
    begin

        PepperBeginWorkshift.SetResponse(HwcResponse);
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        EFTTransactionRequest."Result Code" := PepperBeginWorkshift.GetPOP_ResultCode();
        EFTTransactionRequest."Result Description" := GetResultCodeDescription(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code", PepperBeginWorkshift.GetPOP_ResultString());

        AddReceipt(EFTTransactionRequest, PepperBeginWorkshift.GetPOP_OpenReceipt());
        EFTTransactionRequest.Successful := IsSuccessfulResultCode(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");

        EFTTransactionRequest.Finished := CurrentDateTime;
        EFTTransactionRequest."Number of Attempts" += 1;

        if (EFTTransactionRequest.Successful) then begin
            _PepperTerminal.Validate(Status, _PepperTerminal.Status::Open);
            _PepperTerminal.Modify(true);
        end;

        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        // Update the license information in BC
        LicenseString := PepperConfigManagement.GetTerminalText(_PepperTerminal, 0);
        if (LicenseString = '') then begin
            if (PepperBeginWorkshift.GetILP_XmlLicenseString(LicenseString)) then
                _PepperTerminal.StoreLicense(LicenseString);
        end;

        // Handle the RECOVERY scenario
        if (PepperBeginWorkshift.GetCDP_RecoveryRequired()) then begin
            CreateRecoveryTransactionRequest(EFTTransactionRequest, EftRecoverTransactionRequest);

            MakeHwcDeviceRequest(EftRecoverTransactionRequest, Result);
            Result.Add('Success', false);
            Result.Add('Message', RecoveryRequired);
            exit;
        end;

        // Continue any original request if it successfully opens
        if ((EFTTransactionRequest.Successful) and (EFTTransactionRequest."Initiated from Entry No." <> 0)) then begin
            EftRetryTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
            if (not EftRetryTransactionRequest.Successful) then begin
                EftRetryTransactionRequest."Entry No." := 0;
                if (EFTTransactionRequest."Initiated from Entry No." <> 0) then begin
                    EftRetryTransactionRequest."Initiated from Entry No." := EFTTransactionRequest."Initiated from Entry No.";
                    TransferAdditionalInfo(EFTTransactionRequest."Initiated from Entry No.", EftRetryTransactionRequest);
                end;

                EftRetryTransactionRequest.Started := CurrentDateTime;
                EftRetryTransactionRequest.Insert();

                MakeHwcDeviceRequest(EftRetryTransactionRequest, Result);
                Result.Add('Success', true);
                Result.Add('Message', ContinueTransaction);
                exit;
            end;
        end;

        EFTTransactionRequest.PrintReceipts(false);
        Result.Add('Success', EFTTransactionRequest.Successful);
        if (EFTTransactionRequest.Successful) then
            Result.Add('Message', TerminalIsOpen)
        else
            Result.Add('Message', EFTTransactionRequest."Result Description");
    end;

    local procedure BeginWorkshiftResponse_MOCK(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        EFTTransactionRequest."Result Code" := 10;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest.Finished := CurrentDateTime;

        AddReceipt(EFTTransactionRequest, '**** This is a DEMO Open Receipt ****');
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        AddToCommentBatch(DEMO_TRANSACTION);
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

    end;

    local procedure EndWorkshift(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var HwcRequest: JsonObject)
    var
        PepperEndWorkshift: Codeunit "NPR Pepper End Workshift HWC";
        EndOfDayReport: Boolean;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        if (CheckTestMode(_PepperConfiguration)) then begin
            EndWorkshiftResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        PepperEndWorkshift.InitializeProtocol();
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperEndWorkshift.SetHwcVerboseLogLevel();
        PepperEndWorkshift.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");

        if (_PepperConfiguration."End of Day on Close") then
            EndOfDayReport := true;

        PepperEndWorkshift.SetOptions(EndOfDayReport, _PepperConfiguration."Unload Library on Close");
        PepperEndWorkshift.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Close Code"));
        PepperEndWorkshift.SetReceiptEncoding(GetPepperReceiptEncoding(_PepperTerminal));

        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        HwcRequest := PepperEndWorkshift.AssembleHwcRequest();
    end;

    procedure EndWorkshiftResponse(EFTTransactionRequest: Record "NPR EFT Transaction Request"; HwcResponse: JsonObject; var Result: JsonObject)
    var
        PepperEndWorkshift: Codeunit "NPR Pepper End Workshift HWC";
        TerminalIsClosed: Label 'Terminal is closed.';
    begin
        PepperEndWorkshift.SetResponse(HwcResponse);
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        EFTTransactionRequest."Result Code" := PepperEndWorkshift.GetResultCode();
        EFTTransactionRequest."Result Description" := GetResultCodeDescription(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");
        EFTTransactionRequest.Successful := IsSuccessfulResultCode(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");

        AddReceipt(EFTTransactionRequest, PepperEndWorkshift.GetCloseReceipt());
        AddReceipt(EFTTransactionRequest, PepperEndWorkshift.GetEndOfDayReceipt());

        EFTTransactionRequest.Finished := CurrentDateTime;
        EFTTransactionRequest."Number of Attempts" += 1;

        if (EFTTransactionRequest.Successful) then begin
            _PepperTerminal.Validate(Status, _PepperTerminal.Status::Closed);
            _PepperTerminal.Modify(true);
        end;

        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        Commit();
        EFTTransactionRequest.PrintReceipts(false);

        Result.Add('Success', EFTTransactionRequest.Successful);
        if (EFTTransactionRequest.Successful) then
            Result.Add('Message', TerminalIsClosed)
        else
            Result.Add('Message', EFTTransactionRequest."Result Description");
    end;

    local procedure EndWorkshiftResponse_MOCK(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EFTTransactionRequest."Result Code" := 10;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest.Finished := CurrentDateTime;
        AddReceipt(EFTTransactionRequest, '**** This is a DEMO Close Receipt ****');
        AddReceipt(EFTTransactionRequest, '**** This is a DEMO End of Day Receipt ****');
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        AddToCommentBatch(DEMO_TRANSACTION);
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");
    end;

    local procedure TrxRecoverTransaction(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var HwcRequest: JsonObject)
    var
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction HWC";
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        PepperTrxTransaction.InitializeProtocol();
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperTrxTransaction.SetHwcVerboseLogLevel();
        PepperTrxTransaction.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
        PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding(_PepperTerminal));
        PepperTrxTransaction.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Recover Code"));

        EFTTransactionRequest."Result Code" := PepperTrxTransaction.SetRecovery();

        EFTTransactionRequest.Modify();

        if (CheckTestMode(_PepperConfiguration)) then begin
            TrxResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        HwcRequest := PepperTrxTransaction.AssembleHwcRequest();
    end;

    local procedure TrxPaymentOfGoods(EFTTransactionRequest: Record "NPR EFT Transaction Request"; MbxPosReference: Text[20]; var HwcRequest: JsonObject)
    var
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction HWC";
        ActivateOffline: Boolean;
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        PepperTrxTransaction.InitializeProtocol();
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperTrxTransaction.SetHwcVerboseLogLevel();

        PepperTrxTransaction.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
        PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding(_PepperTerminal));
        PepperTrxTransaction.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Payment Code"));
        ActivateOffline := (_PepperTerminal.Status = _PepperTerminal.Status::ActiveOffline);

#pragma warning disable AA0139
        EFTTransactionRequest."Result Code" := PepperTrxTransaction.SetPaymentOfGoods(EFTTransactionRequest."Amount Input",
          CalcAmountInCents(EFTTransactionRequest."Amount Input", EFTTransactionRequest."Currency Code"),
          CalcAmountInCents(EFTTransactionRequest."Cashback Amount", EFTTransactionRequest."Currency Code"),
          EFTTransactionRequest."Currency Code",
          EFTTransactionRequest."Track Presence Input",
          EFTTransactionRequest."Card Information Input",
          EFTTransactionRequest."Reference Number Input",
          MbxPosReference,
          ActivateOffline);
#pragma warning restore AA0139
        EFTTransactionRequest.Modify();

        if (CheckTestMode(_PepperConfiguration)) then begin
            TrxResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        HwcRequest := PepperTrxTransaction.AssembleHwcRequest();

    end;

    local procedure TrxVoidPaymentOfGoods(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var HwcRequest: JsonObject)
    var
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction HWC";
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        PepperTrxTransaction.InitializeProtocol();
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperTrxTransaction.SetHwcVerboseLogLevel();
        PepperTrxTransaction.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
        PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding(_PepperTerminal));
        PepperTrxTransaction.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Refund Code"));

#pragma warning disable AA0139
        EFTTransactionRequest."Result Code" := PepperTrxTransaction.SetVoidPaymentOfGoods(EFTTransactionRequest."Amount Input",
          CalcAmountInCents(EFTTransactionRequest."Amount Input", EFTTransactionRequest."Currency Code"),
          EFTTransactionRequest."Currency Code",
          EFTTransactionRequest."Reference Number Input");
#pragma warning restore AA0139

        EFTTransactionRequest.Modify();

        if (CheckTestMode(_PepperConfiguration)) then begin
            TrxResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        HwcRequest := PepperTrxTransaction.AssembleHwcRequest();
    end;

    local procedure TrxRefund(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var HwcRequest: JsonObject)
    var
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction HWC";
    begin

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        PepperTrxTransaction.InitializeProtocol();
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperTrxTransaction.SetHwcVerboseLogLevel();
        PepperTrxTransaction.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
        PepperTrxTransaction.SetReceiptEncoding(GetPepperReceiptEncoding(_PepperTerminal));
        PepperTrxTransaction.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Refund Code"));

#pragma warning disable AA0139
        EFTTransactionRequest."Result Code" := PepperTrxTransaction.SetRefund(EFTTransactionRequest."Amount Input",
          CalcAmountInCents(EFTTransactionRequest."Amount Input", EFTTransactionRequest."Currency Code"),
          EFTTransactionRequest."Currency Code",
          EFTTransactionRequest."Reference Number Input");
#pragma warning restore AA0139

        EFTTransactionRequest.Modify();

        if (CheckTestMode(_PepperConfiguration)) then begin
            TrxResponse_MOCK(EFTTransactionRequest);
            exit;
        end;

        HwcRequest := PepperTrxTransaction.AssembleHwcRequest();
    end;

    procedure TrxResponse(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; var HwcResponse: JsonObject; var Result: JsonObject)
    var
        EftBeginWorkshiftTransaction: Record "NPR EFT Transaction Request";
        EftRetryTransactionRequest: Record "NPR EFT Transaction Request";
        EftRecoveredTransactionRequest: Record "NPR EFT Transaction Request";
        EftVoidTransactionRequest: Record "NPR EFT Transaction Request";
        PepperTrxTransaction: Codeunit "NPR Pepper Transaction HWC";
        TransactionDateText: Text[8];
        TransactionTimeText: Text[6];
        LocalCommentText: Text;
        RetryTransaction: Boolean;
        FoundTrxToRecover: Boolean;
        PaymentType: Code[10];
        RetryOriginalTransaction: Label 'Retry original transaction.';
        VoidTransaction: Label 'Voiding transaction due to incorrect signature.';
        ConfirmSignature: Label 'Customer must sign the receipt. Does the signature on card and receipt match?';
    begin

        PepperTrxTransaction.SetResponse(HwcResponse);
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        if (EFTTransactionRequest."Pepper Trans. Subtype Code" = '0') then begin
            // Dress the recovery transaction and swap to lost transaction
            EftRecoveredTransactionRequest.SetFilter("Integration Type", '=%1', GetIntegrationType());
            EftRecoveredTransactionRequest.SetFilter("Register No.", '=%1', EFTTransactionRequest."Register No.");
            EftRecoveredTransactionRequest.SetFilter("Processing Type", '=%1|=%2', EftRecoveredTransactionRequest."Processing Type"::PAYMENT, EftRecoveredTransactionRequest."Processing Type"::REFUND);
            EftRecoveredTransactionRequest.SetFilter("Pepper Trans. Subtype Code", '<>%1 & <>%2', '0', '');
            EftRecoveredTransactionRequest.SetFilter("Financial Impact", '=%1', false);
            EftRecoveredTransactionRequest.SetFilter("Amount Output", '=%1', 0);
            EftRecoveredTransactionRequest.SetFilter("Result Code", '=%1', -910); // PENDING
            EftRecoveredTransactionRequest.SetFilter(Successful, '=%1', false);
            EftRecoveredTransactionRequest.SetFilter(Recovered, '=%1', false);
            EftRecoveredTransactionRequest.SetFilter("Sales Ticket No.", '=%1', EFTTransactionRequest."Sales Ticket No.");

            FoundTrxToRecover := EftRecoveredTransactionRequest.FindFirst();
            if (not FoundTrxToRecover) then begin
                EftRecoveredTransactionRequest.SetFilter("Sales Ticket No.", '=%1', '');
                FoundTrxToRecover := EftRecoveredTransactionRequest.FindLast();
            end;

            if (FoundTrxToRecover) then begin
                if (EFTTransactionRequest."Sales Ticket No." = EftRecoveredTransactionRequest."Sales Ticket No.") then
                    EFTTransactionRequest.TransferFields(EftRecoveredTransactionRequest, false);

                EftRecoveredTransactionRequest.Recovered := true;
                EftRecoveredTransactionRequest."Result Code" := PepperTrxTransaction.GetTrx_ResultCode();
                EftRecoveredTransactionRequest."Result Description" := StrSubstNo('RECOVERED %1', EFTTransactionRequest."Entry No.");
                EftRecoveredTransactionRequest.Finished := CurrentDateTime;
                EftRecoveredTransactionRequest."Transaction Date" := Today();
                EftRecoveredTransactionRequest."Transaction Time" := Time();
                EftRecoveredTransactionRequest.Successful := true;
                EftRecoveredTransactionRequest.Modify();
            end;
        end;

        EFTTransactionRequest."Result Code" := PepperTrxTransaction.GetTrx_ResultCode();
        EFTTransactionRequest."Result Description" := GetResultCodeDescription(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");
        EFTTransactionRequest.Successful := IsSuccessfulResultCode(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");
        if (EFTTransactionRequest.Successful) then
            EFTTransactionRequest."Amount Output" := CalcAmountInCurrency(PepperTrxTransaction.GetTrx_Amount(), EFTTransactionRequest."Currency Code");

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then
            EFTTransactionRequest."Result Amount" := Abs(EFTTransactionRequest."Amount Output");

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::REFUND) then
            EFTTransactionRequest."Result Amount" := Abs(EFTTransactionRequest."Amount Output") * -1;

        EFTTransactionRequest."Number of Attempts" += 1;

        // State machine error will not have correct data in some of these fields
        if (EFTTransactionRequest."Result Code" <> -50) then begin
            PepperTrxTransaction.GetTrx_CardInformation(EFTTransactionRequest."Card Type", EFTTransactionRequest."Card Name", EFTTransactionRequest."Card Number", EFTTransactionRequest."Card Expiry Date");
            CheckCardInformation(EFTTransactionRequest."Card Type", EFTTransactionRequest."Card Name", EFTTransactionRequest."Card Number", EFTTransactionRequest."Card Expiry Date");

#pragma warning disable AA0139
            PepperTrxTransaction.GetTrx_AuthorizationInfo(EFTTransactionRequest."Reference Number Output",
              TransactionDateText,
              TransactionTimeText,
              EFTTransactionRequest."Authorisation Number",
              EFTTransactionRequest."Hardware ID",
              EFTTransactionRequest."Authentication Method",
              EFTTransactionRequest."Bookkeeping Period");
#pragma warning restore AA0139
            EFTTransactionRequest."Transaction Date" := GetTransactionDate(TransactionDateText);
            EFTTransactionRequest."Transaction Time" := GetTransactionTime(TransactionTimeText);

            AddReceipt(EFTTransactionRequest, PepperTrxTransaction.GetTrx_CustomerReceipt());
            AddReceipt(EFTTransactionRequest, PepperTrxTransaction.GetTrx_MerchantReceipt());

            PaymentType := GetPaymentTypePOS(EFTTransactionRequest."Card Type");
            if (PaymentType <> '') then
                EFTTransactionRequest."POS Payment Type Code" := PaymentType;

            EFTTransactionRequest."Result Display Text" := CopyStr(PepperTrxTransaction.GetTrx_DisplayText(), 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
            EFTTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EFTTransactionRequest), 1, MaxStrLen(EFTTransactionRequest."POS Description"));
        end;
#pragma warning disable AA0139
        if (PepperTrxTransaction.GetTrx_JournalLevel(LocalCommentText)) then
            AddToCommentBatch(StrSubstNo('Journal: %1', LocalCommentText));

        if (PepperTrxTransaction.GetTrx_ReferralText(LocalCommentText)) then
            AddToCommentBatch(StrSubstNo('Referral: %1', LocalCommentText));
#pragma warning restore AA0139
        if (PepperTrxTransaction.GetTrx_AdditionalParameters(LocalCommentText)) then
            AddToCommentBatch(StrSubstNo('Additional Parameters: %1', LocalCommentText));

        EFTTransactionRequest.Finished := CurrentDateTime;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest."Manual Voidable" := true;
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        // Handle BeginWorkshift not performed
        // Attempt an auto-open if result code allows it
        if (not EFTTransactionRequest.Successful) then begin
            if (AttemptOpenAndRetry(EFTTransactionRequest)) then begin
                CreateBeginWorkshiftRequest(EFTTransactionRequest."Register No.", EftBeginWorkshiftTransaction);
                EftBeginWorkshiftTransaction."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
                EftBeginWorkshiftTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
                EftBeginWorkshiftTransaction.Modify();

                MakeHwcDeviceRequest(EftBeginWorkshiftTransaction, Result);
                Result.Add('Success', false);
                Result.Add('Message', _BeginWorkshiftRequired);
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
                TransferAdditionalInfo(EFTTransactionRequest."Initiated from Entry No.", EftRetryTransactionRequest);
                EftRetryTransactionRequest.Insert();

                MakeHwcDeviceRequest(EftBeginWorkshiftTransaction, Result);
                Result.Add('Success', false);
                Result.Add('Message', RetryOriginalTransaction);
                exit;
            end;
        end;

        // Check signature requirement and take action
        if (EftTransactionRequest."Authentication Method" = EftTransactionRequest."Authentication Method"::Signature) then
            if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::PAYMENT) then
                if (_PepperTerminal."Cancel at Wrong Signature") then begin
                    if (not Confirm(ConfirmSignature)) then begin
#pragma warning disable AA0139
                        CreateVoidPaymentOfGoodsRequest(EftTransactionRequest."Register No.",
                            EftTransactionRequest."Sales Ticket No.",
                            EftTransactionRequest."Currency Code",
                            EftTransactionRequest."Amount Output",
                            EftTransactionRequest."Reference Number Output",
                            EftTransactionRequest."POS Payment Type Code",
                            EftVoidTransactionRequest);
#pragma warning restore AA0139
                        MakeHwcDeviceRequest(EftVoidTransactionRequest, Result);
                        Result.Add('Success', false);
                        Result.Add('Message', VoidTransaction);
                        exit;
                    end;
                end else begin
                    Message(ConfirmSignature);
                end;

        Result.Add('Success', EFTTransactionRequest.Successful);
        Result.Add('Message', EFTTransactionRequest."Result Description");
    end;

    local procedure TrxResponse_MOCK(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        EFTTransactionRequest."Result Code" := 10;
        EFTTransactionRequest.Successful := true;

        EFTTransactionRequest."Card Type" := '9999';
        EFTTransactionRequest."Card Name" := 'DEMO Card Name';
        EFTTransactionRequest."Card Number" := '555444333222';
        EFTTransactionRequest."Card Expiry Date" := '1220';
        CheckCardInformation(EFTTransactionRequest."Card Type", EFTTransactionRequest."Card Name", EFTTransactionRequest."Card Number", EFTTransactionRequest."Card Expiry Date");

        EFTTransactionRequest."Reference Number Output" := IncStr(EFTTransactionRequest."Reference Number Input");
        EFTTransactionRequest."Authorisation Number" := '9999';
        EFTTransactionRequest."Hardware ID" := '9999';
        EFTTransactionRequest."Transaction Date" := Today();
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest."Authentication Method" := 1;

        AddReceipt(EFTTransactionRequest, '**** This is a DEMO Customer Receipt ****');
        AddReceipt(EFTTransactionRequest, '**** This is a DEMO Merchant Receipt ****');

        EFTTransactionRequest."Amount Output" := EFTTransactionRequest."Amount Input";

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then
            EFTTransactionRequest."Result Amount" := Abs(EFTTransactionRequest."Amount Output");

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::REFUND) then
            EFTTransactionRequest."Result Amount" := Abs(EFTTransactionRequest."Amount Output") * -1;

        EFTTransactionRequest.Finished := CurrentDateTime;
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        AddToCommentBatch(DEMO_TRANSACTION);
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");
    end;

    local procedure AuxFunctionRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var HwcRequest: JsonObject)
    var
        PepperAuxFunctions: Codeunit "NPR Pepper Auxiliary Func HWC";
        AuxFunction: Option;
        AuxFunctionLbl: Label 'Auxilary function: %1', Locked = true;
    begin

        PepperAuxFunctions.InitializeProtocol();
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperAuxFunctions.SetHwcVerboseLogLevel();

        PepperAuxFunctions.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
        PepperAuxFunctions.SetReceiptEncoding(GetPepperReceiptEncoding(_PepperTerminal));
        PepperAuxFunctions.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Auxilary Code"));

        Evaluate(AuxFunction, EFTTransactionRequest."Pepper Trans. Subtype Code");
        case AuxFunction of
            _SupportedAuxFunction::ABORT:
                PepperAuxFunctions.SetAbort();
            _SupportedAuxFunction::CUSTOM_MENU:
                PepperAuxFunctions.SetShowCustomMenu();
            _SupportedAuxFunction::DIAGNOSTICS:
                PepperAuxFunctions.SetGetDiagnostics(false); // setup required ?
            _SupportedAuxFunction::DISPLAY_WITH_NUM_INPUT:
                PepperAuxFunctions.SetDisplayShowText('TEXT'); // custom text;
            _SupportedAuxFunction::PAN_SUPPRESSION_OFF:
                PepperAuxFunctions.SetPanSuppressionOff();
            _SupportedAuxFunction::PAN_SUPPRESSION_ON:
                PepperAuxFunctions.SetPanSuppressionOn();
            _SupportedAuxFunction::SUMMARY_REPORT:
                PepperAuxFunctions.SetGetSummaryReport(false); //setup required ?
            _SupportedAuxFunction::SYSTEM_INFO:
                PepperAuxFunctions.SetGetSystemInfoTicket(false); // setup required ?
            _SupportedAuxFunction::TICKET_REPRINT:
                PepperAuxFunctions.SetReprintLastTicket(true);
            _SupportedAuxFunction::TINA_ACTIVATION:
                PepperAuxFunctions.SetTinaActivation(''); // Setup required
            _SupportedAuxFunction::TINA_DEACTIVATION:
                PepperAuxFunctions.SetTinaDeactivation(''); // Setup required
            _SupportedAuxFunction::TINA_QUERY:
                PepperAuxFunctions.SetTinaQuery(''); // Setup Required
            _SupportedAuxFunction::SHOW_CUSTOM_MENU:
                PepperAuxFunctions.SetShowCustomMenu();

            // in backend only
            _SupportedAuxFunction::ACTIVATE_OFFLINE:
                begin
                    EFTTransactionRequest.Successful := SetTerminalToOfflineMode(EFTTransactionRequest."Register No.", 0); //Activate
                    EFTTransactionRequest."External Result Known" := true;
                    EFTTransactionRequest.Modify();
                end;
            _SupportedAuxFunction::DEACTIVATE_OFFLINE:
                begin
                    EFTTransactionRequest.Successful := SetTerminalToOfflineMode(EFTTransactionRequest."Register No.", 0); //Deactivate
                    EFTTransactionRequest."External Result Known" := true;
                    EFTTransactionRequest.Modify();
                end;
        end;

        AddToCommentBatch(StrSubstNo(AuxFunctionLbl, EFTTransactionRequest."Pepper Trans. Subtype Code"));
        AddToCommentBatch(StrSubstNo(AuxFunctionLbl, SelectStr(AuxFunction, _AuxFunctionMenu)));

        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        if (not EFTTransactionRequest."External Result Known") then
            HwcRequest := PepperAuxFunctions.AssembleHwcRequest();
    end;

    procedure AuxFunctionResponse(EFTTransactionRequest: Record "NPR EFT Transaction Request"; HwcResponse: JsonObject; var Result: JsonObject)
    var
        PepperAuxFunctions: Codeunit "NPR Pepper Auxiliary Func HWC";
        AuxFunction: Option;
        EftBeginWorkshiftTransaction: Record "NPR EFT Transaction Request";
    begin

        PepperAuxFunctions.SetResponse(HwcResponse);

        EFTTransactionRequest."Result Code" := PepperAuxFunctions.GetResultCode();
        EFTTransactionRequest."Result Description" := GetResultCodeDescription(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");
        EFTTransactionRequest.Successful := IsSuccessfulResultCode(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");

        Evaluate(AuxFunction, EFTTransactionRequest."Pepper Trans. Subtype Code");
        case AuxFunction of
            _SupportedAuxFunction::DIAGNOSTICS,
            _SupportedAuxFunction::SUMMARY_REPORT,
            _SupportedAuxFunction::SYSTEM_INFO,
            _SupportedAuxFunction::TICKET_REPRINT:
                begin
                    AddReceipt(EFTTransactionRequest, PepperAuxFunctions.GetClientReceipt());
                    AddReceipt(EFTTransactionRequest, PepperAuxFunctions.GetMerchantReceipt());
                end;

            _SupportedAuxFunction::TINA_ACTIVATION,
            _SupportedAuxFunction::TINA_DEACTIVATION,
            _SupportedAuxFunction::TINA_QUERY:
                begin
                    Message('%1', PepperAuxFunctions.GetXmlResponse());
                    AddToCommentBatch(PepperAuxFunctions.GetXmlResponse());
                end;
            else
                AddToCommentBatch(PepperAuxFunctions.GetXmlResponse());
        end;

        _SupportedAuxFunction := AuxFunction;
        EFTTransactionRequest."Auxiliary Operation Desc." := Format(_SupportedAuxFunction, 0, 0);
        EFTTransactionRequest."Auxiliary Operation Id" := AuxFunction;

        EFTTransactionRequest.Finished := CurrentDateTime;
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Modify();
        ReadyReceiptsForPrint(EFTTransactionRequest);

        // Attempt an auto-open if result code allows it
        if (not EFTTransactionRequest.Successful) then begin
            if (AttemptOpenAndRetry(EFTTransactionRequest)) then begin
                CreateBeginWorkshiftRequest(EFTTransactionRequest."Register No.", EftBeginWorkshiftTransaction);
                EftBeginWorkshiftTransaction."Initiated from Entry No." := EFTTransactionRequest."Entry No.";
                EftBeginWorkshiftTransaction.Modify();

                MakeHwcDeviceRequest(EftBeginWorkshiftTransaction, Result);
                Result.Add('Success', false);
                Result.Add('Message', _BeginWorkshiftRequired);
                exit;
            end;
        end;

        Commit();
        EFTTransactionRequest.PrintReceipts(false);

        Result.Add('Success', EFTTransactionRequest.Successful);
        Result.Add('Message', EFTTransactionRequest."Result Description");

    end;

    local procedure InstallPepperRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var HwcRequest: JsonObject)
    var
        PepperInstall: Codeunit "NPR Pepper Install HWC";
    begin

        PepperInstall.InitializeProtocol();
        PepperInstall.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");

        PepperInstall.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Install Code"));
        PepperInstall.SetPepperVersionToInstall(EFTTransactionRequest."Pepper Trans. Subtype Code");
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperInstall.SetHwcVerboseLogLevel();
        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");

        HwcRequest := PepperInstall.AssembleHwcRequest('PrepareForInstall');
    end;

    procedure InstallPepperResponse(EFTTransactionRequest: Record "NPR EFT Transaction Request"; HwcResponse: JsonObject; var Result: JsonObject)
    var
        PepperInstall: Codeunit "NPR Pepper Install HWC";
        Text001: Label 'DLL version: %1';
        Text002: Label 'Previous DLL version: %1';
        Text003: Label 'Install failed with error: %1';
        OperationDescription: Label 'Installation', MaxLength = 50;
    begin

        PepperInstall.SetResponse(HwcResponse);

        EFTTransactionRequest."Result Code" := PepperInstall.GetResultCode();
        EFTTransactionRequest."Result Description" := GetResultCodeDescription(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");
        EFTTransactionRequest.Successful := IsSuccessfulResultCode(EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code");
        EFTTransactionRequest."Auxiliary Operation Desc." := OperationDescription;

        EFTTransactionRequest.Finished := CurrentDateTime;

        if (not EFTTransactionRequest.Successful) then
            AddToCommentBatch(StrSubstNo(Text003, PepperInstall.GetExceptionText()));

        AddToCommentBatch(StrSubstNo(Text001, PepperInstall.GetInstalledVersion()));
        AddToCommentBatch(StrSubstNo(Text002, PepperInstall.GetPreviousVersion()));

        UpdateEftTransactionRequestCommentBatch(EFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Modify();

        Result.Add('Success', EFTTransactionRequest.Successful);
        Result.Add('Message', EFTTransactionRequest."Result Description");
    end;

    procedure DownloadFileToClient(EFTTransactionRequest: Record "NPR EFT Transaction Request"; Path: Text; var Result: JsonObject)
    var
        PepperInstall: Codeunit "NPR Pepper Install HWC";
    begin
        InitializePepperSetup(EFTTransactionRequest."Register No.");

        PepperInstall.InitializeProtocol();
        PepperInstall.SetTransactionEntryNo(EFTTransactionRequest."Entry No.");
        PepperInstall.SetTimeout(GetTimeout(_PepperConfiguration.Code, _PepperConfiguration."Transaction Type Install Code"));
        PepperInstall.SetPepperVersionToInstall(_PepperVersion.Code);
        if (_PepperConfiguration."Logging Level" = _PepperConfiguration."Logging Level"::debug) then
            PepperInstall.SetHwcVerboseLogLevel();

        PepperInstall.DownloadFileToClient(Path);

        Result := PepperInstall.AssembleHwcRequest('InstallPepper');
    end;

    procedure GetIntegrationType(): Code[10]
    begin

        exit('PEPPER');
    end;

    #region CreateRequests
    procedure CreateBeginWorkshiftRequest(RegisterNo: Code[10]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        _PepperConfiguration.TestField("Transaction Type Open Code");

        EFTTransactionRequest."Pepper Transaction Type Code" := _PepperConfiguration."Transaction Type Open Code";
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::OPEN;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateEndWorkshiftRequest(RegisterNo: Code[10]; SalesReceiptNo: Code[20]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        _PepperConfiguration.TestField("Transaction Type Close Code");

        EFTTransactionRequest."Sales Ticket No." := SalesReceiptNo;
        EFTTransactionRequest."Reference Number Input" := SalesReceiptNo;

        EFTTransactionRequest."Pepper Transaction Type Code" := _PepperConfiguration."Transaction Type Close Code";
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::CLOSE;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreatePaymentOfGoodsRequest(RegisterNo: Code[10]; SalesReceiptNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin

        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        _PepperConfiguration.TestField("Transaction Type Payment Code");

        if (CurrencyCode = '') then begin
            GLSetup.Get();
            CurrencyCode := GLSetup."LCY Code";
        end;

        EFTTransactionRequest."Sales Ticket No." := SalesReceiptNo;
        EFTTransactionRequest."Reference Number Input" := SalesReceiptNo;

        EFTTransactionRequest."Currency Code" := CurrencyCode;
        EFTTransactionRequest."Amount Input" := Amount;
        SetTrxProcessingType('10', RegisterNo, EFTTransactionRequest);
        EFTTransactionRequest."Auto Voidable" := true;
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateRecoveryTransactionRequest(SourceTransactionRequest: Record "NPR EFT Transaction Request"; var RecoveryTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        Clear(RecoveryTransactionRequest);
        InitializeGenericRequest(SourceTransactionRequest."Register No.", RecoveryTransactionRequest);

        _PepperConfiguration.TestField("Transaction Type Recover Code");

        SetTrxProcessingType('0', SourceTransactionRequest."Register No.", RecoveryTransactionRequest);

        RecoveryTransactionRequest."Initiated from Entry No." := SourceTransactionRequest."Entry No.";
        if (RecoveryTransactionRequest."Initiated from Entry No." <> 0) then
            RecoveryTransactionRequest."Initiated from Entry No." := SourceTransactionRequest."Initiated from Entry No.";

        RecoveryTransactionRequest."Sales Ticket No." := SourceTransactionRequest."Sales Ticket No.";

        exit(RecoveryTransactionRequest.Insert());
    end;

    local procedure CreateRefundRequest(RegisterNo: Code[10]; SalesReceiptNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; ReferenceNumber: Code[12]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin

        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        _PepperConfiguration.TestField("Transaction Type Refund Code");

        if (CurrencyCode = '') then begin
            GLSetup.Get();
            CurrencyCode := GLSetup."LCY Code";
        end;

        EFTTransactionRequest."Sales Ticket No." := SalesReceiptNo;
        EFTTransactionRequest."Reference Number Input" := ReferenceNumber;
        EFTTransactionRequest."Currency Code" := CurrencyCode;
        EFTTransactionRequest."Amount Input" := Abs(Amount); // Amount should be positive

        SetTrxProcessingType('60', RegisterNo, EFTTransactionRequest);
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateVoidPaymentOfGoodsRequest(RegisterNo: Code[10]; SalesReceiptNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; ReferenceNumber: Code[12]; PaymentTypeCode: Code[10]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        _PepperConfiguration.TestField("Transaction Type Refund Code");

        if (CurrencyCode = '') then begin
            GLSetup.Get();
            CurrencyCode := GLSetup."LCY Code";
        end;

        EFTTransactionRequest."Sales Ticket No." := SalesReceiptNo;
        EFTTransactionRequest."Reference Number Input" := ReferenceNumber;

        EFTTransactionRequest."POS Payment Type Code" := PaymentTypeCode;
        EFTTransactionRequest."Original POS Payment Type Code" := PaymentTypeCode;
        EFTTransactionRequest."Currency Code" := CurrencyCode;
        EFTTransactionRequest."Amount Input" := Amount;

        SetTrxProcessingType('20', RegisterNo, EFTTransactionRequest);
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateAuxRequest(RegisterNo: Code[10]; AuxFunction: Option; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        ChooseAuxFunction: Label 'Please choose an Auxiliary Function to send to the terminal.';
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        _PepperConfiguration.TestField("Transaction Type Auxilary Code");

        if (AuxFunction = 0) then begin
            AuxFunction := DIALOG.StrMenu(_AuxFunctionMenu, 1, ChooseAuxFunction);
            if (AuxFunction = 0) then
                Error('Aborted.');
        end;

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::AUXILIARY;
        EFTTransactionRequest."Pepper Transaction Type Code" := _PepperConfiguration."Transaction Type Auxilary Code";

        EFTTransactionRequest."Pepper Trans. Subtype Code" := Format(AuxFunction);
        exit(EFTTransactionRequest.Insert());
    end;

    local procedure CreateInstallRequest(RegisterNo: Code[10]; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        Clear(EFTTransactionRequest);
        InitializeGenericRequest(RegisterNo, EFTTransactionRequest);

        _PepperConfiguration.TestField("Transaction Type Install Code");

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::AUXILIARY;
        EFTTransactionRequest."Pepper Transaction Type Code" := _PepperConfiguration."Transaction Type Install Code";

        EFTTransactionRequest."Pepper Trans. Subtype Code" := _PepperVersion.Code;
        exit(EFTTransactionRequest.Insert());
    end;
    #endregion CreateRequests

    #region Helpers
    local procedure InitializeGenericRequest(RegisterNo: Code[10]; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        InitializePepperSetup(RegisterNo);

        EFTTransactionRequest."Result Code" := -900; // Request created
        EFTTransactionRequest."Result Description" := 'PENDING...';
        EFTTransactionRequest."Register No." := RegisterNo;

        EFTTransactionRequest.Token := CreateGuid();
        EFTTransactionRequest.Mode := _PepperConfiguration.Mode;

        EFTTransactionRequest."Track Presence Input" := EFTTransactionRequest."Track Presence Input"::"From EFT";
        EFTTransactionRequest."Card Information Input" := '';

        EFTTransactionRequest."Integration Type" := GetIntegrationType();
        EFTTransactionRequest."Pepper Terminal Code" := _PepperTerminal.Code;
        EFTTransactionRequest."Integration Version Code" := _PepperConfiguration.Version;

        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest."User ID" := CopyStr(UserId, 1, MaxStrLen(EFTTransactionRequest."User ID"));
    end;

    procedure SetTrxProcessingType(TransactionSubtypeCode: Code[10]; RegisterNo: Code[10]; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        InitializePepperSetup(RegisterNo);

        EFTTransactionRequest."Pepper Trans. Subtype Code" := TransactionSubtypeCode;
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::OTHER;
        EFTTransactionRequest."Pepper Transaction Type Code" := '';

        case TransactionSubtypeCode of
            '0':
                begin
                    EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::OTHER;
                    EFTTransactionRequest."Pepper Transaction Type Code" := _PepperConfiguration."Transaction Type Recover Code";
                end;
            '10':
                begin
                    EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::PAYMENT;
                    EFTTransactionRequest."Pepper Transaction Type Code" := _PepperConfiguration."Transaction Type Payment Code";
                end;
            '20', '60':
                begin
                    EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::REFUND;
                    EFTTransactionRequest."Pepper Transaction Type Code" := _PepperConfiguration."Transaction Type Refund Code";
                end;
            else
                Error('The "Transaction Subtype Code" %1 has not been handled in function SetTrxProcessingType.');
        end;
    end;

    local procedure FindTerminalSetupFromRegister(RegisterNo: Code[10]; var VarPepperTerminal: Record "NPR Pepper Terminal"; var VarPepperInstance: Record "NPR Pepper Instance"; var VarPepperConfiguration: Record "NPR Pepper Config."; var VarPepperVersion: Record "NPR Pepper Version"): Boolean
    begin

        VarPepperTerminal.Reset();
        VarPepperTerminal.SetFilter("Register No.", '=%1', RegisterNo);

        if (VarPepperTerminal.Count() <> 1) then
            exit(false);

        VarPepperTerminal.FindFirst();

        VarPepperInstance.Get(VarPepperTerminal."Instance ID");
        VarPepperInstance.TestField("Configuration Code");

        VarPepperConfiguration.Get(VarPepperInstance."Configuration Code");
        VarPepperConfiguration.TestField(Version);

        VarPepperVersion.Get(VarPepperConfiguration.Version);

        exit(true);
    end;

    local procedure CalcAmountInCents(ParDecimalAmount: Decimal; ParCurrencyCode: Code[10]): Integer
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CentFactor: Integer;
        AmountInCents: Integer;
    begin
        if (ParDecimalAmount = 0) then
            exit(0);
        if (Currency.Get(ParCurrencyCode)) then begin
            CentFactor := CalcCentFactor(Currency."Amount Decimal Places");
        end else begin
            GeneralLedgerSetup.Get();
            CentFactor := CalcCentFactor(GeneralLedgerSetup."Amount Decimal Places");
        end;
        if (Evaluate(AmountInCents, Format(Round(CentFactor * ParDecimalAmount, 1)))) then
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
        if (ParAmountInCents = 0) then
            exit(0);
        if (Currency.Get(ParCurrencyCode)) then begin
            CentFactor := CalcCentFactor(Currency."Amount Decimal Places");
        end else begin
            GeneralLedgerSetup.Get();
            CentFactor := CalcCentFactor(GeneralLedgerSetup."Amount Decimal Places");
        end;
        exit(ParAmountInCents / CentFactor);
    end;

    local procedure CalcCentFactor(TextFormat: Text): Integer
    var
        DecimalPlaces: Integer;
    begin
        if (StrPos(TextFormat, ':') > 0) then
            if (StrLen(TextFormat) > StrPos(TextFormat, ':')) then
                if (Evaluate(DecimalPlaces, CopyStr(TextFormat, StrPos(TextFormat, ':') + 1))) then
                    if (DecimalPlaces > 0) then
                        exit(Power(10, DecimalPlaces));
        exit(1);
    end;

    local procedure CheckTestMode(PepperConfiguration: Record "NPR Pepper Config."): Boolean
    var
        TxtLocalTestMode: Label 'WARNING: Local test mode cuts communication with the terminal and simulates succesful transactions.';
        TxtRemoteTestMode: Label 'WARNING: Remote test mode processes transactions to the terminal as normal but logs them as test. Make sure the terminal is set to test manually!';
    begin
        case PepperConfiguration.Mode of
            PepperConfiguration.Mode::"TEST Local":
                begin
                    Message(TxtLocalTestMode);
                    AddToCommentBatch(TxtLocalTestMode);
                    exit(true);
                end;
            PepperConfiguration.Mode::"TEST Remote":
                begin
                    Message(TxtRemoteTestMode);
                    AddToCommentBatch(TxtRemoteTestMode);
                    exit(false);
                end;
        end;
        exit(false);
    end;

    local procedure CheckCardInformation(ParCardTypeText: Text[4]; ParCardNameText: Text[24]; ParCardNumberText: Text[30]; ParCardExpiryDate: Text[4])
    var
        CardTypeNotRcvdLbl: Label 'Card Type not received from Terminal.';
        CardNameNotRcvdLbl: Label 'Card Name not received from Terminal.';
        CardNoNotRcvdLbl: Label 'Card Number not received from Terminal';
        CardExpNotRcvdLbl: Label 'Card Expiry Date not received from Terminal';
        PepperCardType: Record "NPR Pepper Card Type";
        Month: Integer;
        Year: Integer;
        CardExpDateFormatLbl: Label 'Card Expiry Date should be MMYY';
        CardExpInPastLbl: Label 'Card Expiry Date is in the past.';
        NoInfoRcvdLbl: Label 'No Card Information received from Terminal.';
    begin
        if (ParCardTypeText = '') and (ParCardNameText = '') and (ParCardNumberText = '') and (ParCardExpiryDate = '') then begin
            AddToCommentBatch(NoInfoRcvdLbl);
            exit;
        end;
        if (ParCardTypeText = '') then
            AddToCommentBatch(CardTypeNotRcvdLbl)
        else
            if (not PepperCardType.Get(ParCardTypeText)) then
                if (ParCardNameText = '') then
                    AddToCommentBatch(CardNameNotRcvdLbl);

        if (ParCardNumberText = '') then
            AddToCommentBatch(CardNoNotRcvdLbl);

        if (StrLen(ParCardExpiryDate) < 4) then begin
            AddToCommentBatch(CardExpNotRcvdLbl);
        end else begin
            if (Evaluate(Month, CopyStr(ParCardExpiryDate, 1, 2))) and (Evaluate(Year, CopyStr(ParCardExpiryDate, 3, 2))) then begin
                if (Month < 1) or (Month > 12) then begin
                    AddToCommentBatch(CardExpDateFormatLbl);
                end else begin
                    if ((2000 + Year) < Date2DMY(Today, 3)) or (((2000 + Year) = Date2DMY(Today, 3)) and (Month < Date2DMY(Today, 2))) then begin
                        AddToCommentBatch(CardExpInPastLbl);
                    end;
                end;
            end else begin
                AddToCommentBatch(CardExpDateFormatLbl);
            end;
        end;
    end;

    local procedure GetTimeout(PepperConfigurationCode: Code[10]; PepperTransactionCode: Code[10]): Integer
    var
        PepperTransactionType: Record "NPR Pepper EFT Trx Type";
        PepperConfig: Record "NPR Pepper Config.";
    begin

        //TODO EFT Transaction Type
        if (PepperTransactionType.Get(PepperTransactionCode)) then
            if (PepperTransactionType."POS Timeout (Seconds)" <> 0) then
                exit(PepperTransactionType."POS Timeout (Seconds)" * 1000);

        PepperConfig.Get(PepperConfigurationCode);
        exit(PepperConfig."Default POS Timeout (Seconds)" * 1000);
    end;

    local procedure GetPepperReceiptEncoding(PepperTerminal: Record "NPR Pepper Terminal"): Code[20]
    begin

        if (PepperTerminal."Pepper Receipt Encoding" = 0) then
            exit('')
        else
            exit(CopyStr(UpperCase(Format(PepperTerminal."Pepper Receipt Encoding", 0)), 1, 20));
    end;

    local procedure GetResultCodeDescription(ParTransactionType: Code[10]; ParTransactionSubtypeCode: Code[10]; ParResultCode: Integer): Text[50]
    begin
        exit(GetResultCodeDescription(ParTransactionType, ParTransactionSubtypeCode, ParResultCode, ''));
    end;

    local procedure GetResultCodeDescription(ParTransactionType: Code[10]; ParTransactionSubtypeCode: Code[10]; ParResultCode: Integer; ResultString: Text): Text[50]
    var
        PepperResultCode: Record "NPR Pepper EFT Result Code";
        Text104: Label 'Result code not found!', MaxLength = 50;
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

        if (ResultString <> '') then
            exit(CopyStr(ResultString, 1, 50));

        exit(Text104);
    end;

    local procedure GetTransactionDate(DateText: Text): Date
    var
        TransDateNotSpecifiedLbl: Label 'Transaction Date not specified.';
        TransDateNotFormattedLbl: Label 'Transaction Date not formatted DDMMYYYY. Value received: %1';
        TDate: Date;
    begin

        if (DateText = '') then begin
            AddToCommentBatch(TransDateNotSpecifiedLbl);
            exit(Today);
        end;

        TDate := GetDateFromText(DateText);
        if (TDate = 0D) then
            AddToCommentBatch(StrSubstNo(TransDateNotFormattedLbl, DateText));

        if (TDate = 0D) then
            TDate := Today();

        exit(TDate);
    end;

    local procedure GetTransactionTime(TimeText: Text): Time
    var
        TTime: Time;
        TransTimeNotSpecifiedLbl: Label 'Transaction Time not specified.';
        TransTimeNotFormattedLbl: Label 'Transaction Time not formatted HHMMSS. Value received: %1';
    begin
        if (TimeText = '') then begin
            AddToCommentBatch(TransTimeNotSpecifiedLbl);
            exit(0T);
        end;
        TTime := GetTimeFromText(TimeText);
        if (TTime = 0T) then
            AddToCommentBatch(StrSubstNo(TransTimeNotFormattedLbl, TimeText));
        exit(TTime);
    end;

    local procedure GetDateFromText(DateText: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        if (DateText = '') then
            exit(0D);

        // Dateformat is DDMMYYYY according to documentation.
        if (StrLen(DateText) <> 8) then
            exit(0D);

        if (CopyStr(DateText, 5, 2) <> '20') then // 2018 now
            exit(0D);

        if (not Evaluate(Day, CopyStr(DateText, 1, 2))) then
            exit(0D);

        if (not Evaluate(Month, CopyStr(DateText, 3, 2))) then
            exit(0D);

        if (not Evaluate(Year, CopyStr(DateText, 5, 4))) then
            exit(0D);

        exit(DMY2Date(Day, Month, Year));
    end;

    local procedure GetTimeFromText(TimeText: Text): Time
    var
        TempTime: Time;
    begin
        if (TimeText = '') then
            exit(0T);
        if (not Evaluate(TempTime, TimeText)) then
            exit(0T);
        exit(TempTime);
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        PepperCardType: Record "NPR Pepper Card Type";
        TextDescription: Label '%1:%2';
        TextUnknown: Label 'Card: %1';
        Declined: Label 'Declined: (%1)';
    begin

        if (not (EFTTransactionRequest.Successful)) then
            exit(StrSubstNo(Declined, EFTTransactionRequest."Result Code"));

        if (EFTTransactionRequest."Card Name" <> '') then begin
            if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                exit(StrSubstNo(TextDescription, CopyStr(EFTTransactionRequest."Card Name", 1, 8), CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
            else
                exit(StrSubstNo(EFTTransactionRequest."Card Name"));

        end else begin
            if (PepperCardType.Get(EFTTransactionRequest."Card Type")) then
                if (PepperCardType.Description <> '') and (StrLen(EFTTransactionRequest."Card Number") > 8) then
                    exit(StrSubstNo(TextDescription, CopyStr(EFTTransactionRequest."Card Name", 1, 8), CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
                else
                    exit(StrSubstNo(TextUnknown, PepperCardType.Description))
            else
                exit(StrSubstNo(TextUnknown, EFTTransactionRequest."Card Number"));
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

        if (ArrayContent = '') then begin
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

        EFTTransactReqComment.Reset();
        EFTTransactReqComment.SetFilter("Entry No.", '=%1', EftRequestEntryNo);
        if (EFTTransactReqComment.FindLast()) then
            LastLine := EFTTransactReqComment."Line No."
        else
            LastLine := 0;

        CompressArray(CommentText);

        repeat
            I := I + 1;
            if (CommentText[I] <> '') then begin
                EFTTransactReqComment.Init();
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
        PepperTerminal: Record "NPR Pepper Terminal";
    begin

        if (EFTTransactionRequest.Successful) then
            exit(false);

        if (EFTTransactionRequest."Offline mode") then
            exit(false);

        if (not PepperTerminal.Get(EFTTransactionRequest."Pepper Terminal Code")) then
            exit(false);

        if (not PepperTerminal."Open Automatically") then
            exit(false);

        if (not EFTResultCode.Get(EFTTransactionRequest."Integration Type", EFTTransactionRequest."Pepper Transaction Type Code", EFTTransactionRequest."Pepper Trans. Subtype Code", EFTTransactionRequest."Result Code")) then
            if (not EFTResultCode.Get(EFTTransactionRequest."Integration Type", EFTTransactionRequest."Pepper Transaction Type Code", '', EFTTransactionRequest."Result Code")) then
                exit(false);

        exit(EFTResultCode."Open Terminal and Retry");
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

        CreditCardTransaction.Reset();
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");

        if (CreditCardTransaction.FindLast()) then
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
        I: Integer;
        TextDot: Label '______________________________';
        TextSig: Label 'Customer Signature';
    begin
        POSUnit.Get(EFTTransactionRequest."Register No.");

        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction.Date := Today();
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        if (EFTTransactionRequest."Initiated from Entry No." <> 0) then
            CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Initiated from Entry No.";

        CreditCardTransaction."Receipt No." := ReceiptType;

        if (_PepperConfiguration."Header and Footer Handling" = _PepperConfiguration."Header and Footer Handling"::"Add Headers and Footers at Printing") then begin
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
                if (_PepperTerminal."Add Customer Signature Space") then begin
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
        ParCreditCardTransaction.Validate("Entry No.", ParEntryNo);
        ParCreditCardTransaction.Validate("Line No.", 0);
        ParCreditCardTransaction.Validate(Type, 0);
        ParCreditCardTransaction.Validate(Text, ParText);
        ParCreditCardTransaction.Insert(true);
    end;

    procedure SetTerminalToOfflineMode(POSUnit: Record "NPR POS Unit"; CommandType: Option Activate,Deactivate) Success: Boolean
    begin
        SetTerminalToOfflineMode(POSUnit."No.", CommandType);
    end;

    procedure SetTerminalToOfflineMode(POSUnitCode: Code[10]; CommandType: Option Activate,Deactivate) Success: Boolean
    var
        NPRPepperTerminal: Record "NPR Pepper Terminal";
    begin
        InitializePepperSetup(POSUnitCode);
        Success := false;
        case CommandType of
            CommandType::Activate:
                begin
                    if (NPRPepperTerminal.Status = NPRPepperTerminal.Status::ActiveOffline) then begin
                        exit(true);
                    end;
                    if (NPRPepperTerminal.Status <> NPRPepperTerminal.Status::Open) then begin
                        exit(false)
                    end;
                    NPRPepperTerminal.Validate(Status, NPRPepperTerminal.Status::ActiveOffline);
                    NPRPepperTerminal.Modify(true);
                    Commit();
                end;
            CommandType::Deactivate:
                begin
                    if (NPRPepperTerminal.Status = NPRPepperTerminal.Status::Open) then begin
                        exit(true);
                    end;
                    if (NPRPepperTerminal.Status <> NPRPepperTerminal.Status::ActiveOffline) then begin
                        exit(false);
                    end;
                    NPRPepperTerminal.Validate(Status, NPRPepperTerminal.Status::Open);
                    NPRPepperTerminal.Modify(true);
                    Commit();
                end;
        end;
        exit(true);
    end;

    procedure GetKeyFromLicenseText(LicenseText: Text): Text[8]
    var
        KeyText: Text;
        XmlDoc: XmlDocument;
        Node: XmlNode;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin

        if (not XmlDocument.ReadFrom(LicenseText, XmlDoc)) then
            exit('');

        if (not NpXmlDomMgt.FindNode(XmlDoc.AsXmlNode(), '/License/Information/Key', Node)) then
            exit('');

        KeyText := Node.AsXmlElement().InnerText();
        exit(CopyStr(KeyText, 1, 8));
    end;

    procedure GetTerminalTypeFromLicenseText(LicenseText: Text): Integer
    var
        TerminalTypeID: Integer;
        TerminalTypeText: Text;
        PepperTerminalType: Record "NPR Pepper Terminal Type";
        XmlDoc: XmlDocument;
        Node: XmlNode;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        if (not XmlDocument.ReadFrom(LicenseText, XmlDoc)) then
            exit(0);

        if (not NpXmlDomMgt.FindNode(XmlDoc.AsXmlNode(), '/License/Options/TerminalTypeList', Node)) then
            exit(0);

        TerminalTypeText := Node.AsXmlElement().InnerText;

        if (Evaluate(TerminalTypeID, TerminalTypeText)) then
            if (PepperTerminalType.Get(TerminalTypeID)) then
                if (PepperTerminalType.Active) then
                    exit(PepperTerminalType.ID);

        exit(0);
    end;

    procedure GetEFTSetup(POSUnit: Record "NPR POS UNit"; var EFTSetup: Record "NPR EFT Setup")
    begin
        GetEFTSetup(POSUnit."No.", EFTSetup);
    end;

    procedure GetEFTSetup(POSUnitNo: Code[10]; var EFTSetup: Record "NPR EFT Setup")
    begin
        EFTSetup.SetRange("POS Unit No.", POSUnitNo);
        EFTSetup.SetRange("EFT Integration Type", GetIntegrationType());
        if (EFTSetup.FindFirst()) then
            exit;

        EFTSetup.SetRange("POS Unit No.", '');
        EFTSetup.FindFirst();
    end;

    #endregion Helpers

    #region Subscribers
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnCreateHwcEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    var
        JToken: JsonToken;
    begin
        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        RequestMechanism := RequestMechanism::POSWorkflow;
        MakeHwcDeviceRequest(EftTransactionRequest, Request);
        Request.Get('WorkflowName', JToken);
        Workflow := JToken.AsValue().AsText();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateBeginWorkshiftRequest', '', false, false)]
    local procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;
        Handled := CreateBeginWorkshiftRequest(EftTransactionRequest."Register No.", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateEndWorkshiftRequest', '', false, false)]
    local procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;
        Handled := CreateEndWorkshiftRequest(EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        Handled := CreatePaymentOfGoodsRequest(EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", EftTransactionRequest."Currency Code", EftTransactionRequest."Amount Input", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        if (OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.")) then;
#pragma warning disable AA0139
        Handled := CreateRefundRequest(EftTransactionRequest."Register No.",
            EftTransactionRequest."Sales Ticket No.",
            EftTransactionRequest."Currency Code",
            EftTransactionRequest."Amount Input",
            OriginalTransactionRequest."Reference Number Output",
            EftTransactionRequest);
#pragma warning restore AA0139
        if (Handled) then begin
            if (OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.")) then begin
                OriginalTransactionRequest.Reversed := true;
                OriginalTransactionRequest."Reversed by Entry No." := EftTransactionRequest."Entry No.";
                OriginalTransactionRequest.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidPaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        if (OriginalTransactionRequest."Processing Type" <> OriginalTransactionRequest."Processing Type"::PAYMENT) then
            exit;
#pragma warning disable AA0139
        Handled := CreateVoidPaymentOfGoodsRequest(EftTransactionRequest."Register No.",
            EftTransactionRequest."Sales Ticket No.",
            OriginalTransactionRequest."Currency Code",
            OriginalTransactionRequest."Amount Output",
            OriginalTransactionRequest."Reference Number Output",
            OriginalTransactionRequest."POS Payment Type Code",
            EftTransactionRequest);
#pragma warning restore AA0139
        if (Handled) then begin
            if (OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.")) then begin
                OriginalTransactionRequest.Reversed := true;
                OriginalTransactionRequest."Reversed by Entry No." := EftTransactionRequest."Entry No.";
                OriginalTransactionRequest.Modify();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        Handled := CreateAuxRequest(EftTransactionRequest."Register No.", EftTransactionRequest."Auxiliary Operation ID", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVerifySetupRequest', '', false, false)]
    local procedure OnCreateInstallRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        Handled := CreateInstallRequest(EftTransactionRequest."Register No.", EftTransactionRequest);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        EftTransactionRequest.PrintReceipts(false);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    begin

        if (not EftTransactionRequest.IsType(GetIntegrationType())) then
            exit;
        if (not EftTransactionRequest.Successful) then
            exit;
        if (not (EftTransactionRequest."Authentication Method" = EftTransactionRequest."Authentication Method"::Signature)) then
            exit;

        InitializePepperSetup(EftTransactionRequest."Register No.");

        if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::REFUND) then
            Message('Customer must sign the receipt.');

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnEndOfDayCloseEft', '', false, false)]
    local procedure OnEndOfDayCloseEft(EndOfDayType: Option "X-Report","Z-Report",CloseWorkShift; var EftWorkflows: Dictionary of [Text, JsonObject])
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSSession: Codeunit "NPR POS Session";
        Sale: codeunit "NPR POS Sale";
        PosSale: Record "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        EftWorkflow, Request : JsonObject;
        EftTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
    begin
        if (EndOfDayType = EndOfDayType::"X-Report") then
            exit;

        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(Sale);
        Sale.GetCurrentSale(PosSale);

        EFTSetup.SetFilter("POS Unit No.", POSSetup.GetPOSUnitNo());
        EFTSetup.SetRange("EFT Integration Type", GetIntegrationType());
        if (not EFTSetup.FindFirst()) then begin
            EFTSetup.SetRange("POS Unit No.", '');
            if (not EFTSetup.FindFirst()) then
                exit;
        end;

        if (not DoInitializePepperSetup(POSSetup.GetPOSUnitNo())) then
            exit;

        if (not _PepperTerminal."Close Automatically") then
            exit;

        EftTransactionMgt.PrepareEndWorkshift(EFTSetup, PosSale, Request, Mechanism, Workflow);
        EftWorkflow.Add('showSuccessMessage', false);
        EftWorkflow.Add('hideFailureMessage', true);
        EftWorkflow.Add('request', Request);
        EftWorkflows.Add(Workflow, EftWorkflow);
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDisplayReceipt', '', false, false)]
    local procedure OnDisplayReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptNo: Integer; var Handled: Boolean)
    var
        PepperConfigManagement: Codeunit "NPR Pepper Config. Mgt.";
    begin

        if (not EFTTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        Handled := true;
        Message(PepperConfigManagement.GetReceiptText(EFTTransactionRequest, ReceiptNo, true));

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrintReceipt', '', false, false)]
    local procedure OnPrintReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin

        if (not EFTTransactionRequest.IsType(GetIntegrationType())) then
            exit;

        Handled := true;

        CreditCardTransaction.SetCurrentKey("EFT Trans. Request Entry No.", "Receipt No.");
        if (EFTTransactionRequest."Initiated from Entry No." <> 0) then
            CreditCardTransaction.SetFilter("EFT Trans. Request Entry No.", '=%1', EFTTransactionRequest."Initiated from Entry No.")
        else
            CreditCardTransaction.SetFilter("EFT Trans. Request Entry No.", '=%1', EFTTransactionRequest."Entry No.");
        CreditCardTransaction.PrintTerminalReceipt();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    var
        EFTIntegrationTypeDescriptionLbl: Label '%1 %2 %3', Locked = true;
        PepperDescription: Label 'Interface';
    begin

        tmpEFTIntegrationType.Code := GetIntegrationType();
        tmpEFTIntegrationType.Description := StrSubstNo(EFTIntegrationTypeDescriptionLbl, 'Treibauf', 'Pepper', PepperDescription);
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR Pepper Library HWC";
        tmpEFTIntegrationType."Version 2" := true;
        tmpEFTIntegrationType.Insert();

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin

        tmpEFTAuxOperation."Integration Type" := GetIntegrationType();

        tmpEFTAuxOperation."Auxiliary ID" := 0;
        tmpEFTAuxOperation.Description := 'StrMenu';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := 'Abort';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 2;
        tmpEFTAuxOperation.Description := 'PAN Suppression ON';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 3;
        tmpEFTAuxOperation.Description := 'PAN Suppression OFF';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 4;
        tmpEFTAuxOperation.Description := 'Custom Menu';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 5;
        tmpEFTAuxOperation.Description := 'Ticket Reprint';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 6;
        tmpEFTAuxOperation.Description := 'Summary Report';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 7;
        tmpEFTAuxOperation.Description := 'Diagnostics';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 8;
        tmpEFTAuxOperation.Description := 'System Info';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 9;
        tmpEFTAuxOperation.Description := 'Display with Num Input';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 10;
        tmpEFTAuxOperation.Description := 'TINA Activation';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 11;
        tmpEFTAuxOperation.Description := 'TINA Query';
        tmpEFTAuxOperation.Insert();

        tmpEFTAuxOperation."Auxiliary ID" := 12;
        tmpEFTAuxOperation.Description := 'Show Custom Menu';
        tmpEFTAuxOperation.Insert();

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnConfigureIntegrationUnitSetup', '', false, false)]
    local procedure OnConfigureIntegrationUnitSetup(EFTSetup: Record "NPR EFT Setup")
    var
        PepperTerm: Record "NPR Pepper Terminal";
    begin
        if (EFTSetup."EFT Integration Type" <> GetIntegrationType()) then
            exit;

        if (EFTSetup."POS Unit No." <> '') then
            PepperTerm.SetRange("Register No.", EFTSetup."POS Unit No.");

        PAGE.RunModal(0, PepperTerm);

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR EFT Setup", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterEFTSetupInsert(var Rec: Record "NPR EFT Setup"; RunTrigger: Boolean)
    var
        EFTSetup: Record "NPR EFT Setup";
        EftSetup2: Record "NPR EFT Setup";
    begin

        if (Rec.IsTemporary or (not RunTrigger)) then
            exit;

        // If there is no Pepper setup, exit fast
        EFTSetup.SetFilter("POS Unit No.", '=%1', Rec."POS Unit No.");
        EFTSetup.SetFilter("EFT Integration Type", '=%1', GetIntegrationType());
        if (not EFTSetup.FindSet()) then
            exit;

        // Check that same payment type is not shared across different integrations. 'T' can't be not be both Pepper and Nets at the same time.
        EFTSetup2.SetFilter("POS Unit No.", '=%1', Rec."POS Unit No.");
        repeat
            EftSetup2.SetFilter("Payment Type POS", '=%1', EFTSetup."Payment Type POS");
            EftSetup2.SetFilter("EFT Integration Type", '<>%1', GetIntegrationType());
            if (not EFTSetup2.IsEmpty) then
                Error(ErrorText001, EFTSetup."Payment Type POS", Rec."POS Unit No.");
        until (EFTSetup.Next() = 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR EFT Setup", 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterEFTSetupRename(var Rec: Record "NPR EFT Setup"; var xRec: Record "NPR EFT Setup"; RunTrigger: Boolean)
    var
        EFTSetup: Record "NPR EFT Setup";
        EftSetup2: Record "NPR EFT Setup";
    begin

        if (Rec.IsTemporary or (not RunTrigger)) then
            exit;

        // If there is no Pepper setup, exit fast
        EFTSetup.SetFilter("POS Unit No.", '=%1', Rec."POS Unit No.");
        EFTSetup.SetFilter("EFT Integration Type", '=%1', GetIntegrationType());
        if (not EFTSetup.FindSet()) then
            exit;

        // Check that same payment type is not shared across different integrations. 'T' can't be not be both Pepper and Nets at the same time.
        EFTSetup2.SetFilter("POS Unit No.", '=%1', Rec."POS Unit No.");
        repeat
            EftSetup2.SetFilter("Payment Type POS", '=%1', EFTSetup."Payment Type POS");
            EftSetup2.SetFilter("EFT Integration Type", '<>%1', GetIntegrationType());
            if (not EFTSetup2.IsEmpty) then
                Error(ErrorText001, EFTSetup."Payment Type POS", Rec."POS Unit No.");
        until (EFTSetup.Next() = 0);
    end;
    #endregion Subscribers
}


