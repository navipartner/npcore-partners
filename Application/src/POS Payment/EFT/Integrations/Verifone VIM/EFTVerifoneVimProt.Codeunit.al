#if not CLOUD
codeunit 6184527 "NPR EFT Verifone Vim Prot."
{
    Access = Internal;
    // NPR5.53/MMV /20191204 CASE 349520 Added object
    // NPR5.54/MMV /20200414 CASE 364340 Handle lookups correctly for refund and voids


    trigger OnRun()
    begin
    end;

    var
        ERR_RESPONSE_CRITICAL: Label 'Critical error when parsing %1 response. Could not establish transaction context.\%2';
        DIALOG_ABORT: Label 'Abort';
        DIALOG_TYPE_PURCHASE: Label 'Purchase';
        DIALOG_TYPE_REFUND: Label 'Refund';
        DIALOG_TYPE_REVERSAL: Label 'Reversal';
        DIALOG_CONFIRM: Label 'Confirm';
        DIALOG_REJECT: Label 'Reject';
        DIALOG_FORCE_ABORT: Label 'Force Abort';
        FORCE_ABORT_DESC: Label 'Transaction was force aborted. Use lookup to check result.';
        BALANCE_ENQUIRY: Label 'Balance Enquiry';

    local procedure IntegrationType(): Text
    begin
        exit('VERIFONE_VIM');
    end;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::OPEN:
                OpenTerminal(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::CLOSE:
                CloseTerminal(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::LOOK_UP:
                LookupTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::SETUP:
                VerifySetup();
            EftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                RefundTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::REFUND:
                RefundTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::PAYMENT:
                PaymentTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::VOID:
                VoidTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1:
                        BalanceEnquiry(EftTransactionRequest);
                    2:
                        Reconciliation(EftTransactionRequest);
                end;
        end;
    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionRequest: DotNet NPRNetTransactionRequest2;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        TransactionRequest.Amount := EftTransactionRequest."Amount Input";
        TransactionRequest.CashbackAmount := EftTransactionRequest."Cashback Amount";
        TransactionRequest.TransactionType := 'PURCHASE';
        TransactionRequest.TransactionTypeCaption := DIALOG_TYPE_PURCHASE;

        PrepareGenericTransaction(EftTransactionRequest, EFTSetup, TransactionRequest);

        POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'Purchase');
    end;

    local procedure RefundTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionRequest: DotNet NPRNetTransactionRequest2;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        OriginalEftTrxRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        TransactionRequest.Amount := Abs(EftTransactionRequest."Amount Input");
        TransactionRequest.TransactionType := 'REFUND';
        TransactionRequest.TransactionTypeCaption := DIALOG_TYPE_REFUND;

        if EftTransactionRequest."Processed Entry No." <> 0 then begin
            OriginalEftTrxRequest.Get(EftTransactionRequest."Processed Entry No.");
            //-NPR5.54 [364340]
            if OriginalEftTrxRequest.Recovered then
                OriginalEftTrxRequest.Get(OriginalEftTrxRequest."Recovered by Entry No.");
            //+NPR5.54 [364340]
            TransactionRequest.TransactionToRevertTerminalTrxID := OriginalEftTrxRequest."External Transaction ID";
            TransactionRequest.TransactionToRevertTerminalID := OriginalEftTrxRequest."Hardware ID";
            TransactionRequest.TransactionToRevertTerminalTrxTimestamp := CreateDateTime(OriginalEftTrxRequest."Transaction Date", OriginalEftTrxRequest."Transaction Time");
        end;

        PrepareGenericTransaction(EftTransactionRequest, EFTSetup, TransactionRequest);

        POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'Refund');
    end;

    local procedure VoidTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionRequest: DotNet NPRNetTransactionRequest2;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        OriginalEftTrxRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        TransactionRequest.Amount := Abs(EftTransactionRequest."Amount Input");
        TransactionRequest.TransactionType := 'REVERSAL';
        TransactionRequest.TransactionTypeCaption := DIALOG_TYPE_REVERSAL;

        OriginalEftTrxRequest.Get(EftTransactionRequest."Processed Entry No.");
        //-NPR5.54 [364340]
        if OriginalEftTrxRequest.Recovered then
            OriginalEftTrxRequest.Get(OriginalEftTrxRequest."Recovered by Entry No.");
        //+NPR5.54 [364340]
        TransactionRequest.TransactionToRevertTerminalTrxID := OriginalEftTrxRequest."External Transaction ID";
        TransactionRequest.TransactionToRevertTerminalID := OriginalEftTrxRequest."Hardware ID";
        TransactionRequest.TransactionToRevertTerminalTrxTimestamp := CreateDateTime(OriginalEftTrxRequest."Transaction Date", OriginalEftTrxRequest."Transaction Time");

        PrepareGenericTransaction(EftTransactionRequest, EFTSetup, TransactionRequest);

        POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'Reversal');
    end;

    local procedure PrepareGenericTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var TransactionRequest: DotNet NPRNetTransactionRequest2)
    var
        EFTVerifoneVimIntegration: Codeunit "NPR EFT Verifone Vim Integ.";
        Licenceinformation: Codeunit "NPR License Information";
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
        EcrToGatewayDataLbl: Label '%1 | %2', Locked = true;
    begin
        TransactionRequest.EcrToGatewayData := StrSubstNo(EcrToGatewayDataLbl, EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.");
        TransactionRequest.EcrID := EftTransactionRequest."Register No.";
        TransactionRequest.Currency := EftTransactionRequest."Currency Code";
        TransactionRequest.EftEntryTimestamp := EftTransactionRequest.Started;
        TransactionRequest.ForceAbortDelayMs := EFTVerifoneVimIntegration.GetForceAbortMinimumDelay(EFTSetup) * 1000;

        TransactionRequest.AbortCaption := DIALOG_ABORT;
        TransactionRequest.AmountCaption := Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>');
        TransactionRequest.ConfirmSignatureCaption := DIALOG_CONFIRM;
        TransactionRequest.RejectSignatureCaption := DIALOG_REJECT;
        TransactionRequest.ForceAbortCaption := DIALOG_FORCE_ABORT;
        TransactionRequest.ForceAbortDescriptionCaption := FORCE_ABORT_DESC;

        if EFTVerifoneVimIntegration.GetAutoOpenOnTransaction(EFTSetup) then begin
            TransactionRequest.AutoInitAndLoginBeforeTrx := true;
            TransactionRequest.LoginTimeoutMs := EFTVerifoneVimIntegration.GetLoginTimeout(EFTSetup) * 1000;
            TransactionRequest.EcrSerial := 'cloud';
            TransactionRequest.ConnectionBrokenDetection := true;
            TransactionRequest.InitTimeoutMs := EFTVerifoneVimIntegration.GetInitTimeout(EFTSetup) * 1000;
            TransactionRequest.SoftwareManufacturer := 'NaviPartner ApS';
            TransactionRequest.SoftwareName := 'NP Retail';
            TransactionRequest.SoftwareVersion := Licenceinformation.GetRetailVersion();
            TransactionRequest.SoftwareCertificationCode := 'prod';
            TransactionRequest.LogLocation := EFTVerifoneVimIntegration.GetLogLocation(EFTSetup);
            TransactionRequest.TerminalListeningPort := EFTVerifoneVimIntegration.GetListeningPort(EFTSetup);
            TransactionRequest.TerminalLANAddress := EFTVerifoneVimIntegration.GetTerminalLANAddress(EFTSetup);
            TransactionRequest.TerminalPort := EFTVerifoneVimIntegration.GetTerminalLANPort(EFTSetup);
            TransactionRequest.TerminalSerialNumber := EFTVerifoneVimIntegration.GetTerminalSerialNumber(EFTSetup);
            TransactionRequest.DebugMode := EFTVerifoneVimIntegration.GetDebugMode(EFTSetup);
            TransactionRequest.PreLoginDelayMs := EFTVerifoneVimIntegration.GetPreLoginDelay(EFTSetup) * 1000;
            TransactionRequest.AutoLoginAfterReconnect := EFTVerifoneVimIntegration.GetAutoLoginAfterReconnect(EFTSetup);


            case EFTVerifoneVimIntegration.GetLogLevel(EFTSetup) of
                EFTVerifoneUnitParameter."Terminal Log Level"::ALL:
                    TransactionRequest.LogLevel := 'ALL';
                EFTVerifoneUnitParameter."Terminal Log Level"::DEBUG:
                    TransactionRequest.LogLevel := 'DEBUG';
                EFTVerifoneUnitParameter."Terminal Log Level"::ERROR:
                    TransactionRequest.LogLevel := 'ERROR';
                EFTVerifoneUnitParameter."Terminal Log Level"::INFO:
                    TransactionRequest.LogLevel := 'INFO';
                EFTVerifoneUnitParameter."Terminal Log Level"::WARN:
                    TransactionRequest.LogLevel := 'WARN';
            end;

            case EFTVerifoneVimIntegration.GetDefautlLanguage(EFTSetup) of
                EFTVerifoneUnitParameter."Terminal Default Language"::ENGLISH:
                    TransactionRequest.DefaultLanguage := 'ENGLISH';
                EFTVerifoneUnitParameter."Terminal Default Language"::NORWEGIAN:
                    TransactionRequest.DefaultLanguage := 'NORWEGIAN';
                EFTVerifoneUnitParameter."Terminal Default Language"::SWEDISH:
                    TransactionRequest.DefaultLanguage := 'SWEDISH';
                EFTVerifoneUnitParameter."Terminal Default Language"::FINNISH:
                    TransactionRequest.DefaultLanguage := 'FINNISH';
                EFTVerifoneUnitParameter."Terminal Default Language"::DANISH:
                    TransactionRequest.DefaultLanguage := 'DANISH';
            end;

            case EFTVerifoneVimIntegration.GetConnectionMode(EFTSetup) of
                EFTVerifoneUnitParameter."Terminal Connection Mode"::TERMINAL_CONNECT:
                    TransactionRequest.ConnectionMode := 'TERMINALCONNECTMODE';
                EFTVerifoneUnitParameter."Terminal Connection Mode"::ECR_CONNECT:
                    TransactionRequest.ConnectionMode := 'ECRCONNECTMODE';
            end;
        end;
    end;

    local procedure OpenTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        LoginRequest: DotNet NPRNetLoginRequest;
        EFTSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTVerifoneVimIntegration: Codeunit "NPR EFT Verifone Vim Integ.";
        Licenceinformation: Codeunit "NPR License Information";
        EFTVerifoneUnitParameter: Record "NPR EFT Verifone Unit Param.";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        LoginRequest := LoginRequest.LoginRequest();
        LoginRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        LoginRequest.LoginTimeoutMs := EFTVerifoneVimIntegration.GetLoginTimeout(EFTSetup) * 1000;
        LoginRequest.EcrID := EftTransactionRequest."Register No.";
        LoginRequest.EcrSerial := 'cloud';
        LoginRequest.ConnectionBrokenDetection := true;
        LoginRequest.InitTimeoutMs := EFTVerifoneVimIntegration.GetInitTimeout(EFTSetup) * 1000;
        LoginRequest.SoftwareManufacturer := 'NaviPartner ApS';
        LoginRequest.SoftwareName := 'NP Retail';
        LoginRequest.SoftwareVersion := Licenceinformation.GetRetailVersion();
        LoginRequest.SoftwareCertificationCode := 'prod';
        LoginRequest.LogLocation := EFTVerifoneVimIntegration.GetLogLocation(EFTSetup);
        LoginRequest.TerminalListeningPort := EFTVerifoneVimIntegration.GetListeningPort(EFTSetup);
        LoginRequest.TerminalLANAddress := EFTVerifoneVimIntegration.GetTerminalLANAddress(EFTSetup);
        LoginRequest.TerminalPort := EFTVerifoneVimIntegration.GetTerminalLANPort(EFTSetup);
        LoginRequest.TerminalSerialNumber := EFTVerifoneVimIntegration.GetTerminalSerialNumber(EFTSetup);
        LoginRequest.DebugMode := EFTVerifoneVimIntegration.GetDebugMode(EFTSetup);
        LoginRequest.PreLoginDelayMs := EFTVerifoneVimIntegration.GetPreLoginDelay(EFTSetup) * 1000;
        LoginRequest.AutoLoginAfterReconnect := EFTVerifoneVimIntegration.GetAutoLoginAfterReconnect(EFTSetup);

        case EFTVerifoneVimIntegration.GetLogLevel(EFTSetup) of
            EFTVerifoneUnitParameter."Terminal Log Level"::ALL:
                LoginRequest.LogLevel := 'ALL';
            EFTVerifoneUnitParameter."Terminal Log Level"::DEBUG:
                LoginRequest.LogLevel := 'DEBUG';
            EFTVerifoneUnitParameter."Terminal Log Level"::ERROR:
                LoginRequest.LogLevel := 'ERROR';
            EFTVerifoneUnitParameter."Terminal Log Level"::INFO:
                LoginRequest.LogLevel := 'INFO';
            EFTVerifoneUnitParameter."Terminal Log Level"::WARN:
                LoginRequest.LogLevel := 'WARN';
        end;

        case EFTVerifoneVimIntegration.GetDefautlLanguage(EFTSetup) of
            EFTVerifoneUnitParameter."Terminal Default Language"::ENGLISH:
                LoginRequest.DefaultLanguage := 'ENGLISH';
            EFTVerifoneUnitParameter."Terminal Default Language"::NORWEGIAN:
                LoginRequest.DefaultLanguage := 'NORWEGIAN';
            EFTVerifoneUnitParameter."Terminal Default Language"::SWEDISH:
                LoginRequest.DefaultLanguage := 'SWEDISH';
            EFTVerifoneUnitParameter."Terminal Default Language"::FINNISH:
                LoginRequest.DefaultLanguage := 'FINNISH';
            EFTVerifoneUnitParameter."Terminal Default Language"::DANISH:
                LoginRequest.DefaultLanguage := 'DANISH';
        end;

        case EFTVerifoneVimIntegration.GetConnectionMode(EFTSetup) of
            EFTVerifoneUnitParameter."Terminal Connection Mode"::TERMINAL_CONNECT:
                LoginRequest.ConnectionMode := 'TERMINALCONNECTMODE';
            EFTVerifoneUnitParameter."Terminal Connection Mode"::ECR_CONNECT:
                LoginRequest.ConnectionMode := 'ECRCONNECTMODE';
        end;

        POSFrontEnd.InvokeDevice(LoginRequest, ActionCode(), 'Login');
    end;

    local procedure CloseTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        LogoutRequest: DotNet NPRNetLogoutRequest;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTVerifoneVimIntegration: Codeunit "NPR EFT Verifone Vim Integ.";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        LogoutRequest := LogoutRequest.LogoutRequest();
        LogoutRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        LogoutRequest.TimeoutMs := EFTVerifoneVimIntegration.GetLogoutTimeout(EFTSetup) * 1000;
        LogoutRequest.EcrID := EftTransactionRequest."Register No.";
        LogoutRequest.AutoReconcileBeforeLogout := EFTVerifoneVimIntegration.GetAutoReconciliationOnClose(EFTSetup);
        LogoutRequest.ReconciliationTimeoutMs := EFTVerifoneVimIntegration.GetReconciliationTimeout(EFTSetup) * 1000;
        LogoutRequest.PostReconcileDelayMs := EFTVerifoneVimIntegration.GetPostReconcileDelay(EFTSetup) * 1000;

        POSFrontEnd.InvokeDevice(LogoutRequest, ActionCode(), 'Logout');
    end;

    local procedure BalanceEnquiry(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        BalanceEnquiryRequest: DotNet NPRNetBalanceEnquiryRequest0;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTVerifoneVimIntegration: Codeunit "NPR EFT Verifone Vim Integ.";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        BalanceEnquiryRequest := BalanceEnquiryRequest.BalanceEnquiryRequest();
        BalanceEnquiryRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        BalanceEnquiryRequest.EcrID := EftTransactionRequest."Register No.";
        BalanceEnquiryRequest.ForceAbortDelayMs := EFTVerifoneVimIntegration.GetForceAbortMinimumDelay(EFTSetup) * 1000;
        BalanceEnquiryRequest.ForceAbortCaption := DIALOG_FORCE_ABORT;
        BalanceEnquiryRequest.AbortCaption := DIALOG_ABORT;
        BalanceEnquiryRequest.AmountCaption := '';
        BalanceEnquiryRequest.TransactionTypeCaption := BALANCE_ENQUIRY;
        BalanceEnquiryRequest.ForceAbortDescriptionCaption := FORCE_ABORT_DESC;

        POSFrontEnd.InvokeDevice(BalanceEnquiryRequest, ActionCode(), 'BalanceEnquiry');
    end;

    local procedure Reconciliation(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        ReconciliationRequest: DotNet NPRNetReconciliationRequest;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTVerifoneVimIntegration: Codeunit "NPR EFT Verifone Vim Integ.";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        ReconciliationRequest := ReconciliationRequest.ReconciliationRequest();
        ReconciliationRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        ReconciliationRequest.EcrID := EftTransactionRequest."Register No.";
        ReconciliationRequest.TimeoutMs := EFTVerifoneVimIntegration.GetReconciliationTimeout(EFTSetup) * 1000;
        ReconciliationRequest.ReconciliationType := 'ACQUIRER';

        POSFrontEnd.InvokeDevice(ReconciliationRequest, ActionCode(), 'Reconciliation');
    end;

    local procedure LookupTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionStatusRequest: DotNet NPRNetTransactionStatusRequest;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        OriginalEftTrxRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTVerifoneVimIntegration: Codeunit "NPR EFT Verifone Vim Integ.";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        TransactionStatusRequest := TransactionStatusRequest.TransactionStatusRequest();
        TransactionStatusRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        TransactionStatusRequest.EcrID := EftTransactionRequest."Register No.";

        OriginalEftTrxRequest.Get(EftTransactionRequest."Processed Entry No.");
        case OriginalEftTrxRequest."Processing Type" of
            OriginalEftTrxRequest."Processing Type"::PAYMENT:
                TransactionStatusRequest.TransactionType := 'PURCHASE';
            OriginalEftTrxRequest."Processing Type"::REFUND:
                TransactionStatusRequest.TransactionType := 'REFUND';
            OriginalEftTrxRequest."Processing Type"::VOID:
                TransactionStatusRequest.TransactionType := 'REVERSAL';
            else
                OriginalEftTrxRequest.FieldError("Processing Type");
        end;

        TransactionStatusRequest.ReferenceServiceID := OriginalEftTrxRequest."Reference Number Output";
        TransactionStatusRequest.StatusTimeoutMs := EFTVerifoneVimIntegration.GetTransactionStatusTimeout(EFTSetup) * 1000;

        POSFrontEnd.InvokeDevice(TransactionStatusRequest, ActionCode(), 'TransactionStatus');
    end;

    local procedure VerifySetup()
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        //POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'VerifySetup');
    end;

    local procedure ActionCode(): Text
    begin
        exit('EFT_' + IntegrationType());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnDeviceResponse', '', false, false)]
    local procedure Device_Response(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTVerifoneVimResponseParser: Codeunit "NPR EFT VerifoneVim Resp.Parse";
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if ActionName <> ActionCode() then
            exit;

        ClearLastError();

        EFTVerifoneVimResponseParser.SetResponseEnvelope(Step, Envelope);
        if (EFTVerifoneVimResponseParser.Run() and EFTVerifoneVimResponseParser.TryGetEftTransactionEntryNo(EntryNo)) then begin
            EFTTransactionRequest.Get(EntryNo);
            OnAfterProtocolResponse(EFTTransactionRequest);
        end else begin
            HandleParseError(EFTVerifoneVimResponseParser);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnAppGatewayProtocol', '', false, false)]
    local procedure AppGateway_Response(ActionName: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
    var
        EFTVerifoneVimResponseParser: Codeunit "NPR EFT VerifoneVim Resp.Parse";
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if (ActionName <> ActionCode()) then
            exit;

        Handled := true;

        ClearLastError();

        EFTVerifoneVimResponseParser.SetResponseEvent(EventName, Data);

        if (EFTVerifoneVimResponseParser.Run() and EFTVerifoneVimResponseParser.TryGetEftTransactionEntryNo(EntryNo)) then begin
            case EventName of
                'TransactionResponse':
                    begin
                        EFTTransactionRequest.Get(EntryNo);
                        OnAfterProtocolResponse(EFTTransactionRequest);
                    end;
                'PrintSignatureReceipt':
                    begin
                        EFTTransactionRequest.Get(EntryNo);
                        if CODEUNIT.Run(CODEUNIT::"NPR EFT Try Print Receipt", EFTTransactionRequest) then begin
                            ReturnData := 'true';
                        end else begin
                            Message(GetLastErrorText);
                            ReturnData := 'false';
                        end;
                    end;
                'SaveTrxReferenceNumber':
                    begin
                        ReturnData := 'true';
                    end;
                'BalanceEnquiryResponse':
                    begin
                        EFTTransactionRequest.Get(EntryNo);
                        OnAfterProtocolResponse(EFTTransactionRequest);
                    end;
            end;
        end else begin
            HandleParseError(EFTVerifoneVimResponseParser);
        end;
    end;

    local procedure HandleParseError(var EFTVerifoneVimResponseParser: Codeunit "NPR EFT VerifoneVim Resp.Parse")
    var
        EftEntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTVerifoneVimResponseParser.TryGetEftTransactionEntryNo(EftEntryNo) then
            Error(ERR_RESPONSE_CRITICAL, IntegrationType(), GetLastErrorText);

        EFTTransactionRequest.Get(EftEntryNo);
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."External Result Known" := false; //Could not parse response correctly - needs to go to lookup.
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
        EFTTransactionRequest.Modify(true);

        OnAfterProtocolResponse(EFTTransactionRequest);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
    end;
}
#endif
