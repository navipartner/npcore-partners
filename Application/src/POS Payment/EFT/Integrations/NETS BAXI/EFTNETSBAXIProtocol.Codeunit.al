codeunit 6184541 "NPR EFT NETS BAXI Protocol"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        ERR_RESPONSE_CRITICAL: Label 'Critical error when parsing %1 response. Could not establish transaction context.\%2';
        DIALOG_ABORT: Label 'Abort';
        DIALOG_CONFIRM: Label 'Confirm';
        DIALOG_REJECT: Label 'Reject';
        DIALOG_FORCE_ABORT: Label 'Force Abort';
        FORCE_ABORT_DESC: Label 'Transaction was force aborted. Use lookup to check result.';
        BALANCE_ENQUIRY: Label 'Balance Enquiry';

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::OPEN:
                OpenTerminal(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::CLOSE:
                CloseTerminal(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::LOOK_UP:
                LookupTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                DepositTransaction(EftTransactionRequest);
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
                        DownloadDataset(EftTransactionRequest);
                    3:
                        DownloadSoftware(EftTransactionRequest);
                    4:
                        Reconciliation(EftTransactionRequest);
                end;
        end;
    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionRequest: DotNet NPRNetTransactionRequest3;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.EftEntryNo := EftTransactionRequest."Entry No.";

        case true of
            EftTransactionRequest."Cashback Amount" > 0:
                begin
                    TransactionRequest.Amount1 := EftTransactionRequest."Amount Input" * 100;
                    TransactionRequest.Amount2 := (EftTransactionRequest."Amount Input" - EftTransactionRequest."Cashback Amount") * 100;
                    TransactionRequest.Type1 := 51;
                    TransactionRequest.Type2 := 48;
                    TransactionRequest.Type3 := 48;
                end;

            EFTNETSBAXIPaymentSetup."Force Offline":
                begin
                    TransactionRequest.Amount1 := EftTransactionRequest."Amount Input" * 100;
                    TransactionRequest.Type1 := 64;
                    TransactionRequest.Type2 := 48;
                    TransactionRequest.Type3 := 48;
                end;

            else begin
                    TransactionRequest.Amount1 := EftTransactionRequest."Amount Input" * 100;
                    TransactionRequest.Type1 := 48;
                    TransactionRequest.Type2 := 48;
                    TransactionRequest.Type3 := 48;
                end;
        end;

        TransactionRequest.OptionalData := GetOptionalDataTrx(EftTransactionRequest, EFTNETSBAXIPaymentSetup);

        TransactionRequest.ForceAbortDelayMs := EFTNETSBAXIPaymentSetup."Force Abort Minimum Seconds" * 1000;
        TransactionRequest.AbortCaption := DIALOG_ABORT;
        TransactionRequest.AmountCaption := Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>');
        TransactionRequest.ConfirmSignatureCaption := DIALOG_CONFIRM;
        TransactionRequest.RejectSignatureCaption := DIALOG_REJECT;
        TransactionRequest.ForceAbortCaption := DIALOG_FORCE_ABORT;
        TransactionRequest.ForceAbortDescriptionCaption := FORCE_ABORT_DESC;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        TransactionRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'Purchase');
    end;

    local procedure RefundTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionRequest: DotNet NPRNetTransactionRequest3;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        TransactionRequest.Amount1 := Abs(EftTransactionRequest."Amount Input") * 100;
        TransactionRequest.Type1 := 49;
        TransactionRequest.Type2 := 48;
        TransactionRequest.Type3 := 48;
        TransactionRequest.OptionalData := GetOptionalDataTrx(EftTransactionRequest, EFTNETSBAXIPaymentSetup);
        TransactionRequest.ForceAbortDelayMs := EFTNETSBAXIPaymentSetup."Force Abort Minimum Seconds" * 1000;

        TransactionRequest.AbortCaption := DIALOG_ABORT;
        TransactionRequest.AmountCaption := Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>');
        TransactionRequest.ConfirmSignatureCaption := DIALOG_CONFIRM;
        TransactionRequest.RejectSignatureCaption := DIALOG_REJECT;
        TransactionRequest.ForceAbortCaption := DIALOG_FORCE_ABORT;
        TransactionRequest.ForceAbortDescriptionCaption := FORCE_ABORT_DESC;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        TransactionRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'Refund');
    end;

    local procedure DepositTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionRequest: DotNet NPRNetTransactionRequest3;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        TransactionRequest.Amount1 := Abs(EftTransactionRequest."Amount Input") * 100;
        TransactionRequest.Type1 := 56;
        TransactionRequest.Type2 := 48;
        TransactionRequest.Type3 := 48;
        TransactionRequest.OptionalData := GetOptionalDataTrx(EftTransactionRequest, EFTNETSBAXIPaymentSetup);
        TransactionRequest.ForceAbortDelayMs := EFTNETSBAXIPaymentSetup."Force Abort Minimum Seconds" * 1000;

        TransactionRequest.AbortCaption := DIALOG_ABORT;
        TransactionRequest.AmountCaption := Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>');
        TransactionRequest.ConfirmSignatureCaption := DIALOG_CONFIRM;
        TransactionRequest.RejectSignatureCaption := DIALOG_REJECT;
        TransactionRequest.ForceAbortCaption := DIALOG_FORCE_ABORT;
        TransactionRequest.ForceAbortDescriptionCaption := FORCE_ABORT_DESC;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        TransactionRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'Deposit');
    end;

    local procedure VoidTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionRequest: DotNet NPRNetTransactionRequest3;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        TransactionRequest.Amount1 := Abs(EftTransactionRequest."Amount Input") * 100;
        TransactionRequest.Type1 := 50;
        TransactionRequest.Type2 := 48;
        TransactionRequest.Type3 := 48;
        TransactionRequest.ForceAbortDelayMs := EFTNETSBAXIPaymentSetup."Force Abort Minimum Seconds" * 1000;

        TransactionRequest.AbortCaption := DIALOG_ABORT;
        TransactionRequest.AmountCaption := Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>');
        TransactionRequest.ConfirmSignatureCaption := DIALOG_CONFIRM;
        TransactionRequest.RejectSignatureCaption := DIALOG_REJECT;
        TransactionRequest.ForceAbortCaption := DIALOG_FORCE_ABORT;
        TransactionRequest.ForceAbortDescriptionCaption := FORCE_ABORT_DESC;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        TransactionRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'Reversal');
    end;

    local procedure BalanceEnquiry(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        TransactionRequest: DotNet NPRNetTransactionRequest3;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        TransactionRequest.Type1 := 54;
        TransactionRequest.Type2 := 48;
        TransactionRequest.Type3 := 48;
        TransactionRequest.ForceAbortDelayMs := EFTNETSBAXIPaymentSetup."Force Abort Minimum Seconds" * 1000;

        TransactionRequest.AbortCaption := DIALOG_ABORT;
        TransactionRequest.AmountCaption := BALANCE_ENQUIRY;
        TransactionRequest.ConfirmSignatureCaption := DIALOG_CONFIRM;
        TransactionRequest.RejectSignatureCaption := DIALOG_REJECT;
        TransactionRequest.ForceAbortCaption := DIALOG_FORCE_ABORT;
        TransactionRequest.ForceAbortDescriptionCaption := FORCE_ABORT_DESC;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        TransactionRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(TransactionRequest, ActionCode(), 'BalanceEnquiry');
    end;

    local procedure BuildOpenParameterObject(var OpenParameters: DotNet NPRNetOpenParameters; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        RegisterID: Text;
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        OpenParameters := OpenParameters.OpenParameters();
        OpenParameters.ComPort := EFTNETSBAXIPaymentSetup."COM Port";
        OpenParameters.BaudRate := EFTNETSBAXIPaymentSetup."Baud Rate";
        OpenParameters.LogAutoDeleteDays := EFTNETSBAXIPaymentSetup."Log Auto Delete Days";
        OpenParameters.LogFilePath := EFTNETSBAXIPaymentSetup."Log File Path";
        OpenParameters.TraceLevel := EFTNETSBAXIPaymentSetup."Trace Level";
        if EFTNETSBAXIPaymentSetup."Cutter Support" then
            OpenParameters.CutterSupport := 1;
        OpenParameters.PrinterWidth := EFTNETSBAXIPaymentSetup."Printer Width";
        OpenParameters.DisplayWidth := EFTNETSBAXIPaymentSetup."Display Width";
        if EFTNETSBAXIPaymentSetup."Socket Listener" then
            OpenParameters.SocketListener := 1;
        OpenParameters.SocketListenerPort := EFTNETSBAXIPaymentSetup."Socket Listener Port";
        OpenParameters.BluetoothTunnel := EFTNETSBAXIPaymentSetup."Bluetooth Tunnel";
        OpenParameters.LinkControlTimeout := EFTNETSBAXIPaymentSetup."Link Control Timeout Seconds";
        OpenParameters.OpenTimeoutMs := EFTNETSBAXIPaymentSetup."Open Timeout Seconds" * 1000;

        //Hardcoded parameters below:

        OpenParameters.LogFilePrefix := 'baxi';
        OpenParameters.UseMultiInstance := 0;
        OpenParameters.MultiInstanceConfigFile := '';
        OpenParameters.ClientID := 'ECR1';
        OpenParameters.AlwaysUseTotalAmountInExtendedLM := 1;
        OpenParameters.Use2KBuffer := 1;
        OpenParameters.UseSplitDisplayText := 0;
        OpenParameters.MsgRouterOn := 0;
        OpenParameters.MsgRouterIpAddress := '';
        OpenParameters.MsgRouterPort := 6000;
        OpenParameters.SerialDriver := 'Nets';
        OpenParameters.UseExtendedLocalMode := 1;
        OpenParameters.UseDisplayTextID := 1;
        OpenParameters.TerminalID := '';
        OpenParameters.StoreBoxAPIHost := 'https://api.storebox.com/api/receipt-receiver/v2/receipts';
        OpenParameters.StoreBoxAuthToken := '';
        OpenParameters.EnableStoreBox := 0;
        OpenParameters.SplitAcquiring := 0;
        OpenParameters.DelegateCommunication := 0;
        OpenParameters.PinByPass := 0;
        OpenParameters.PreventLoyaltyFromPurchase := 1;
        OpenParameters.MultiCurrencyPath := '';
        OpenParameters.UseMultiCurrency := 0;
        OpenParameters.CurrencyCode := ''; //Controlled exclusively by NETS - contact them for switching a terminal currency
        OpenParameters.TerminalReady := 1;
        OpenParameters.TidSupervision := 0;
        OpenParameters.DeviceString := 'SAGEM Telium';
        OpenParameters.PowerCycleCheck := 0;
        OpenParameters.AutoGetCustomerInfo := 0;
        OpenParameters.IndicateEotTransaction := 0;

        if EFTTransactionRequest.Mode = EFTTransactionRequest.Mode::Production then begin
            OpenParameters.HostIpAddress := '91.102.24.142';
            OpenParameters.HostPort := 9670;
        end else begin
            OpenParameters.HostIpAddress := '91.102.24.111';
            OpenParameters.HostPort := 9670;
        end;

        RegisterID := DelChr(EFTTransactionRequest."Register No.", '=', DelChr(EFTTransactionRequest."Register No.", '=', '0123456789abcdefhijklmnopqrstuvwxyz_-.,'));
        if StrLen(RegisterID) < 15 then begin
            OpenParameters.VendorInfoExtended := 'NPR;Retail;5.54;' + RegisterID + ';';
        end else begin
            OpenParameters.VendorInfoExtended := 'NPR;Retail;5.54;;'
        end;
    end;

    local procedure OpenTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OpenRequest: DotNet NPRNetOpenRequest0;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        OpenRequest := OpenRequest.OpenRequest();
        OpenRequest.EftEntryNo := EftTransactionRequest."Entry No.";

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        OpenRequest.Parameters := OpenParameters;

        POSFrontEnd.InvokeDevice(OpenRequest, ActionCode(), 'Open');
    end;

    local procedure CloseTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        CloseRequest: DotNet NPRNetCloseRequest0;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        CloseRequest := CloseRequest.CloseRequest();
        CloseRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        CloseRequest.TimeoutMs := EFTNETSBAXIPaymentSetup."Close Timeout Seconds" * 1000;
        CloseRequest.AutoReconcileBeforeClose := EFTNETSBAXIPaymentSetup."Auto Reconcile On EOD";
        CloseRequest.AutoReconcileTimeoutMs := EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000;

        POSFrontEnd.InvokeDevice(CloseRequest, ActionCode(), 'Close');
    end;

    local procedure Reconciliation(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        AdminRequest: DotNet NPRNetAdministrationRequest;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        AdminRequest := AdminRequest.AdministrationRequest();
        AdminRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        AdminRequest.AdmCode := 12592;
        AdminRequest.OptionalData := '';
        AdminRequest.TimeoutMs := EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        AdminRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(AdminRequest, ActionCode(), 'Reconciliation');
    end;

    local procedure DownloadSoftware(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        AdminRequest: DotNet NPRNetAdministrationRequest;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        AdminRequest := AdminRequest.AdministrationRequest();
        AdminRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        AdminRequest.AdmCode := 12606;
        AdminRequest.OptionalData := '';
        AdminRequest.TimeoutMs := EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        AdminRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(AdminRequest, ActionCode(), 'DownloadSoftware');
    end;

    local procedure DownloadDataset(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        AdminRequest: DotNet NPRNetAdministrationRequest;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        AdminRequest := AdminRequest.AdministrationRequest();
        AdminRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        AdminRequest.AdmCode := 12607;
        AdminRequest.OptionalData := '';
        AdminRequest.TimeoutMs := EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        AdminRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(AdminRequest, ActionCode(), 'DownloadDataset');
    end;

    local procedure LookupTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        GetLastRequest: DotNet NPRNetGetLastRequest;
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        OpenParameters: DotNet NPRNetOpenParameters;
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetFrontEnd(POSFrontEnd, true);

        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        GetLastRequest := GetLastRequest.GetLastRequest();
        GetLastRequest.EftEntryNo := EftTransactionRequest."Entry No.";
        GetLastRequest.AdmCode := 12607;
        GetLastRequest.OptionalData := '';
        GetLastRequest.TimeoutMs := EFTNETSBAXIPaymentSetup."Lookup Timeout Seconds" * 1000;

        BuildOpenParameterObject(OpenParameters, EftTransactionRequest);
        GetLastRequest.OpenParameters := OpenParameters;

        POSFrontEnd.InvokeDevice(GetLastRequest, ActionCode(), 'GetLastResult');
    end;

    local procedure GetOptionalDataTrx(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup"): Text
    var
        OptionalData: Text;
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        OptionalData :=
        '{' +
          '"od": {' +
            '"ver": "1.01",' +
            '"nets": {' +
              '"ver": "1.00",' +
              '"ch13": {' +
                '"ver": "1.00",' +
                '"ta": {' +
                  '"ver": "1.00",' +
                  '"o": {' +
                    '"ver": "1.00",' +
                    '"txnref": "' + Format(EFTTransactionRequest."Entry No.") + '"';
        if EFTNETSBAXIPaymentSetup.DCC then begin
            case EFTTransactionRequest."Processing Type" of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    OptionalData += ',"autodcc": 0';
                EFTTransactionRequest."Processing Type"::REFUND:
                    begin
                        if EFTTransactionRequest."Processed Entry No." <> 0 then begin
                            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
                            if OriginalEFTTransactionRequest.Recovered then begin
                                OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Recovered by Entry No.");
                            end;
                            if OriginalEFTTransactionRequest."DCC Used" then begin
                                OptionalData += ',"autodcc": 1' //Force DCC on refund
                            end else begin
                                OptionalData += ',"autodcc": 2'; //Force no DCC on refund
                            end;
                        end;
                    end;
            end;
        end;
        OptionalData +=
                  '}' +
                '}' +
              '}' +
            '}' +
          '}' +
        '}';

        exit(OptionalData);
    end;

    local procedure ActionCode(): Text
    var
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
    begin
        exit('EFT_' + EFTNETSBAXIIntegration.IntegrationType());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnDeviceResponse', '', false, false)]
    local procedure Device_Response(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTNETSBAXIRespParser: Codeunit "NPR EFT NETS BAXI Resp. Pars.";
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
    begin
        if ActionName <> ActionCode() then
            exit;

        ClearLastError();

        EFTNETSBAXIRespParser.SetResponseEnvelope(Step, Envelope);
        if (EFTNETSBAXIRespParser.Run() and EFTNETSBAXIRespParser.TryGetEftTransactionEntryNo(EntryNo)) then begin
            EFTTransactionRequest.Get(EntryNo);
            EFTNETSBAXIIntegration.HandleProtocolResponse(EFTTransactionRequest);
        end else begin
            HandleParseError(EFTNETSBAXIRespParser);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Stargate Management", 'OnAppGatewayProtocol', '', false, false)]
    local procedure AppGateway_Response(ActionName: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
    var
        EFTNETSBAXIRespParser: Codeunit "NPR EFT NETS BAXI Resp. Pars.";
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
    begin
        if (ActionName <> ActionCode()) then
            exit;

        Handled := true;

        ClearLastError();

        EFTNETSBAXIRespParser.SetResponseEvent(EventName, Data);

        if (EFTNETSBAXIRespParser.Run() and EFTNETSBAXIRespParser.TryGetEftTransactionEntryNo(EntryNo)) then begin
            case EventName of
                'TransactionResponse':
                    begin
                        EFTTransactionRequest.Get(EntryNo);
                        EFTNETSBAXIIntegration.HandleProtocolResponse(EFTTransactionRequest);
                    end;
            end;
        end else begin
            HandleParseError(EFTNETSBAXIRespParser);
        end;
    end;

    local procedure HandleParseError(var EFTNETSBAXIRespParser: Codeunit "NPR EFT NETS BAXI Resp. Pars.")
    var
        EftEntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
    begin
        if not EFTNETSBAXIRespParser.TryGetEftTransactionEntryNo(EftEntryNo) then
            Error(ERR_RESPONSE_CRITICAL, EFTNETSBAXIIntegration.IntegrationType(), GetLastErrorText);

        EFTTransactionRequest.Get(EftEntryNo);
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."External Result Known" := false; //Could not parse response correctly - needs to go to lookup.
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
        EFTTransactionRequest.Modify(true);

        EFTNETSBAXIIntegration.HandleProtocolResponse(EFTTransactionRequest);
    end;
}

