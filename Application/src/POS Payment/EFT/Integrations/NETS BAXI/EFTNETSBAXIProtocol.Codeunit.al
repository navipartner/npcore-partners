codeunit 6184541 "NPR EFT NETS BAXI Protocol"
{
    Access = Internal;

    var
        ERR_RESPONSE_CRITICAL: Label 'Critical error when parsing %1 response. Could not establish transaction context.\%2';
        BALANCE_ENQUIRY: Label 'Balance Enquiry';

    procedure ConstructHwcRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var Workflow: Text)
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::OPEN:
                OpenTerminal(EftTransactionRequest, Request, Workflow);
            EftTransactionRequest."Processing Type"::CLOSE:
                CloseTerminal(EftTransactionRequest, Request, Workflow);
            EftTransactionRequest."Processing Type"::LOOK_UP:
                LookupTransaction(EftTransactionRequest, Request, Workflow);
            EftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                DepositTransaction(EftTransactionRequest, Request, Workflow);
            EftTransactionRequest."Processing Type"::REFUND:
                RefundTransaction(EftTransactionRequest, Request, Workflow);
            EftTransactionRequest."Processing Type"::PAYMENT:
                PaymentTransaction(EftTransactionRequest, Request, Workflow);
            EftTransactionRequest."Processing Type"::VOID:
                VoidTransaction(EftTransactionRequest, Request, Workflow);
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1:
                        BalanceEnquiry(EftTransactionRequest, Request, Workflow);
                    2:
                        DownloadDataset(EftTransactionRequest, Request, Workflow);
                    3:
                        DownloadSoftware(EftTransactionRequest, Request, Workflow);
                    4:
                        Reconciliation(EftTransactionRequest, Request, Workflow);
                end;
        end;
    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        TrxParameters: JsonObject;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Transaction');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        HwcRequest.Add('OfflinePhoneAuth', EFTNETSBAXIPaymentSetup."Force Offline");
        HwcRequest.Add('TypeCaption', Format(EftTransactionRequest."Processing Type"));
        HwcRequest.Add('AmountCaption', Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));

        case true of
            EftTransactionRequest."Cashback Amount" > 0:
                begin
                    TrxParameters.Add('Amount1', EftTransactionRequest."Amount Input" * 100);
                    TrxParameters.Add('Amount2', (EftTransactionRequest."Amount Input" - EftTransactionRequest."Cashback Amount") * 100);
                    TrxParameters.Add('Type1', 51);
                    TrxParameters.Add('Type2', 48);
                    TrxParameters.Add('Type3', 48);
                end;

            EFTNETSBAXIPaymentSetup."Force Offline":
                begin
                    TrxParameters.Add('Amount1', EftTransactionRequest."Amount Input" * 100);
                    TrxParameters.Add('Type1', 64);
                    TrxParameters.Add('Type2', 48);
                    TrxParameters.Add('Type3', 48);
                end;

            else begin
                TrxParameters.Add('Amount1', EftTransactionRequest."Amount Input" * 100);
                TrxParameters.Add('Type1', 48);
                TrxParameters.Add('Type2', 48);
                TrxParameters.Add('Type3', 48);
            end;
        end;
        TrxParameters.Add('OptionalData', GetOptionalDataTrx(EftTransactionRequest, EFTNETSBAXIPaymentSetup));
        //TrxParameters.Add('GetStoreboxToken', false); //TODO: implement storebox integration
        HwcRequest.Add('TransactionParameters', TrxParameters);
    end;

    local procedure RefundTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        TrxParameters: JsonObject;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Transaction');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        HwcRequest.Add('OfflinePhoneAuth', EFTNETSBAXIPaymentSetup."Force Offline");
        HwcRequest.Add('TypeCaption', Format(EftTransactionRequest."Processing Type"));
        HwcRequest.Add('AmountCaption', Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));

        TrxParameters.Add('Amount1', Abs(EftTransactionRequest."Amount Input") * 100);
        TrxParameters.Add('Type1', 49);
        TrxParameters.Add('Type2', 48);
        TrxParameters.Add('Type3', 48);
        TrxParameters.Add('OptionalData', GetOptionalDataTrx(EftTransactionRequest, EFTNETSBAXIPaymentSetup));
        HwcRequest.Add('TransactionParameters', TrxParameters);
    end;

    local procedure DepositTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        TrxParameters: JsonObject;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Transaction');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        HwcRequest.Add('OfflinePhoneAuth', EFTNETSBAXIPaymentSetup."Force Offline");
        HwcRequest.Add('TypeCaption', Format(EftTransactionRequest."Processing Type"));
        HwcRequest.Add('AmountCaption', Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));

        TrxParameters.Add('Amount1', Abs(EftTransactionRequest."Amount Input") * 100);
        TrxParameters.Add('Type1', 56);
        TrxParameters.Add('Type2', 48);
        TrxParameters.Add('Type3', 48);
        TrxParameters.Add('OptionalData', GetOptionalDataTrx(EftTransactionRequest, EFTNETSBAXIPaymentSetup));
        HwcRequest.Add('TransactionParameters', TrxParameters);
    end;

    local procedure VoidTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        TrxParameters: JsonObject;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Transaction');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        HwcRequest.Add('OfflinePhoneAuth', EFTNETSBAXIPaymentSetup."Force Offline");
        HwcRequest.Add('TypeCaption', Format(EftTransactionRequest."Processing Type"));
        HwcRequest.Add('AmountCaption', Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));

        TrxParameters.Add('Amount1', Abs(EftTransactionRequest."Amount Input") * 100);
        TrxParameters.Add('Type1', 50);
        TrxParameters.Add('Type2', 48);
        TrxParameters.Add('Type3', 48);
        TrxParameters.Add('OptionalData', GetOptionalDataTrx(EftTransactionRequest, EFTNETSBAXIPaymentSetup));
        HwcRequest.Add('TransactionParameters', TrxParameters);
    end;

    local procedure BalanceEnquiry(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        TrxParameters: JsonObject;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Transaction');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        HwcRequest.Add('OfflinePhoneAuth', EFTNETSBAXIPaymentSetup."Force Offline");
        HwcRequest.Add('TypeCaption', BALANCE_ENQUIRY);
        HwcRequest.Add('AmountCaption', Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>'));

        TrxParameters.Add('Amount1', Abs(EftTransactionRequest."Amount Input") * 100);
        TrxParameters.Add('Type1', 54);
        TrxParameters.Add('Type2', 48);
        TrxParameters.Add('Type3', 48);
        TrxParameters.Add('OptionalData', GetOptionalDataTrx(EftTransactionRequest, EFTNETSBAXIPaymentSetup));
        HwcRequest.Add('TransactionParameters', TrxParameters);
    end;

    local procedure BuildOpenParameters(EFTTransactionRequest: Record "NPR EFT Transaction Request"): JsonObject
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        RegisterID: Text;
        OpenParameters: JsonObject;
    begin
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);

        OpenParameters.Add('ComPort', EFTNETSBAXIPaymentSetup."COM Port");
        OpenParameters.Add('BaudRate', EFTNETSBAXIPaymentSetup."Baud Rate");
        OpenParameters.Add('LogAutoDeleteDays', EFTNETSBAXIPaymentSetup."Log Auto Delete Days");
        OpenParameters.Add('LogFilePath', EFTNETSBAXIPaymentSetup."Log File Path");
        OpenParameters.Add('TraceLevel', EFTNETSBAXIPaymentSetup."Trace Level");
        if EFTNETSBAXIPaymentSetup."Cutter Support" then
            OpenParameters.Add('CutterSupport', 1);
        OpenParameters.Add('PrinterWidth', EFTNETSBAXIPaymentSetup."Printer Width");
        OpenParameters.Add('DisplayWidth', EFTNETSBAXIPaymentSetup."Display Width");
        if EFTNETSBAXIPaymentSetup."Socket Listener" then
            OpenParameters.Add('SocketListener', 1);
        OpenParameters.Add('SocketListenerPort', EFTNETSBAXIPaymentSetup."Socket Listener Port");
        OpenParameters.Add('BluetoothTunnel', EFTNETSBAXIPaymentSetup."Bluetooth Tunnel");
        OpenParameters.Add('LinkControlTimeout', EFTNETSBAXIPaymentSetup."Link Control Timeout Seconds");
        OpenParameters.Add('OpenTimeoutMs', EFTNETSBAXIPaymentSetup."Open Timeout Seconds" * 1000);

        //Hardcoded parameters below:

        OpenParameters.Add('LogFilePrefix', 'baxi');
        OpenParameters.Add('UseMultiInstance', 0);
        OpenParameters.Add('MultiInstanceConfigFile', '');
        OpenParameters.Add('ClientID', 'ECR1');
        OpenParameters.Add('AlwaysUseTotalAmountInExtendedLM', 1);
        OpenParameters.Add('Use2KBuffer', 1);
        OpenParameters.Add('UseSplitDisplayText', 0);
        OpenParameters.Add('MsgRouterOn', 0);
        OpenParameters.Add('MsgRouterIpAddress', '');
        OpenParameters.Add('MsgRouterPort', 6000);
        OpenParameters.Add('SerialDriver', 'Nets');
        OpenParameters.Add('UseExtendedLocalMode', 1);
        OpenParameters.Add('UseDisplayTextID', 1);
        OpenParameters.Add('TerminalID', '');
        OpenParameters.Add('SplitAcquiring', 0);
        OpenParameters.Add('DelegateCommunication', 0);
        OpenParameters.Add('PinByPass', 0);
        OpenParameters.Add('PreventLoyaltyFromPurchase', 1);
        OpenParameters.Add('MultiCurrencyPath', '');
        OpenParameters.Add('UseMultiCurrency', 0);
        OpenParameters.Add('CurrencyCode', ''); //Controlled exclusively by NETS - contact them for switching a terminal currency
        OpenParameters.Add('TerminalReady', 1);
        OpenParameters.Add('TidSupervision', 0);
        OpenParameters.Add('DeviceString', 'SAGEM Telium');
        OpenParameters.Add('PowerCycleCheck', 0);
        OpenParameters.Add('AutoGetCustomerInfo', 0);
        OpenParameters.Add('IndicateEotTransaction', 0);

        if EFTTransactionRequest.Mode = EFTTransactionRequest.Mode::Production then begin
            OpenParameters.Add('HostIpAddress', '91.102.24.142');
            OpenParameters.Add('HostPort', 9670);
        end else begin
            OpenParameters.Add('HostIpAddress', '91.102.24.111');
            OpenParameters.Add('HostPort', 9670);
        end;

        RegisterID := DelChr(EFTTransactionRequest."Register No.", '=', DelChr(EFTTransactionRequest."Register No.", '=', '0123456789abcdefhijklmnopqrstuvwxyz_-.,'));
        if StrLen(RegisterID) < 15 then begin
            OpenParameters.Add('VendorInfoExtended', 'NPR;Retail;17.00;' + RegisterID + ';');
        end else begin
            OpenParameters.Add('VendorInfoExtended', 'NPR;Retail;17.00;;');
        end;

        exit(OpenParameters);
    end;

    local procedure OpenTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        OpenTerminalLbl: Label 'Open Terminal';
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Open');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        HwcRequest.Add('TypeCaption', OpenTerminalLbl);
        HwcRequest.Add('AmountCaption', ' ');
    end;

    local procedure CloseTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        CloseParameters: JsonObject;
        CloseTerminalLbl: Label 'Close Terminal';
        AdminParameters: JsonObject;
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Close');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        CloseParameters.Add('TimeoutMs', EFTNETSBAXIPaymentSetup."Close Timeout Seconds" * 1000);
        CloseParameters.Add('AutoReconcileBeforeClose', EFTNETSBAXIPaymentSetup."Auto Reconcile On EOD");
        CloseParameters.Add('AutoReconcileTimeoutMs', EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000);
        HwcRequest.Add('CloseParameters', CloseParameters);
        HwcRequest.Add('TypeCaption', CloseTerminalLbl);
        HwcRequest.Add('AmountCaption', ' ');
        AdminParameters.Add('AdmCode', 12592);
        AdminParameters.Add('TimeoutMs', EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000);
        HwcRequest.Add('AdministrationParameters', AdminParameters);
    end;

    local procedure Reconciliation(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        AdminParameters: JsonObject;
        ReconciliationLbl: Label 'Reconciliation';
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Administration');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        AdminParameters.Add('AdmCode', 12592);
        AdminParameters.Add('TimeoutMs', EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000);
        HwcRequest.Add('AdministrationParameters', AdminParameters);
        HwcRequest.Add('TypeCaption', ReconciliationLbl);
        HwcRequest.Add('AmountCaption', ' ');
    end;

    local procedure DownloadSoftware(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        AdminParameters: JsonObject;
        UpdateFirmwareLbl: Label 'Updating firmware';
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Administration');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        AdminParameters.Add('AdmCode', 12606);
        AdminParameters.Add('TimeoutMs', EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000);
        HwcRequest.Add('AdministrationParameters', AdminParameters);
        HwcRequest.Add('TypeCaption', UpdateFirmwareLbl);
        HwcRequest.Add('AmountCaption', ' ');
    end;

    local procedure DownloadDataset(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        AdminParameters: JsonObject;
        DownloadDatasetLbl: Label 'Downloading dataset';
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'Administration');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        AdminParameters.Add('AdmCode', 12607);
        AdminParameters.Add('TimeoutMs', EFTNETSBAXIPaymentSetup."Administration Timeout Seconds" * 1000);
        HwcRequest.Add('AdministrationParameters', AdminParameters);
        HwcRequest.Add('TypeCaption', DownloadDatasetLbl);
        HwcRequest.Add('AmountCaption', ' ');
    end;

    local procedure LookupTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject; var Workflow: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        EFTNETSBAXIPaymentSetup: Record "NPR EFT NETS BAXI Paym. Setup";
        GetLastResultParameters: JsonObject;
        LookupLbl: Label 'Transaction Lookup';
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
        EFTNETSBAXIIntegration.GetPaymentTypeParameters(EFTSetup, EFTNETSBAXIPaymentSetup);
        Workflow := Format(Enum::"NPR POS Workflow"::EFT_NETS_BAXI_NATIVE);

        HwcRequest.Add('Type', 'GetLastResult');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('OpenParameters', BuildOpenParameters(EftTransactionRequest));
        GetLastResultParameters.Add('TimeoutMs', EFTNETSBAXIPaymentSetup."Lookup Timeout Seconds" * 1000);
        HwcRequest.Add('GetLastResultParameters', GetLastResultParameters);
        HwcRequest.Add('TypeCaption', LookupLbl);
        HwcRequest.Add('AmountCaption', ' ');
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
                    '"ver": "1.00"';
        if EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::VOID then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            if OriginalEFTTransactionRequest.Recovered then
                OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Recovered by Entry No.");
            OptionalData += ',"txnref": "' + Format(OriginalEFTTransactionRequest."Authorisation Number") + '"';
        end;

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
        EFTTransactionRequest."Result Amount" := 0;
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
        EFTTransactionRequest.Modify(true);

        EFTNETSBAXIIntegration.HandleProtocolResponse(EFTTransactionRequest);
    end;

    procedure ProcessResponse(Response: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ResponseObject: JsonObject;
        EFTNETSBAXIRespPars: Codeunit "NPR EFT NETS BAXI Resp. Pars.";
        EntryNo: Integer;
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
        SignatureApprovalLbl: Label 'Approve signature?';
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EFTSetup: Record "NPR EFT Setup";
        POSSale: Record "NPR POS Sale";
        VoidRequest: JsonObject;
        VoidMechanism: Enum "NPR EFT Request Mechanism";
        VoidWorkflow: Text;
        Rejected: Boolean;
    begin
        ClearLastError();

        EFTNETSBAXIRespPars.SetResponse(Response.GetString('Type'), Response);
        if (EFTNETSBAXIRespPars.Run() and EFTNETSBAXIRespPars.TryGetEftTransactionEntryNo(EntryNo)) then begin
            EFTTransactionRequest.Get(EntryNo);
            EFTNETSBAXIIntegration.HandleProtocolResponse(EFTTransactionRequest);
        end else begin
            HandleParseError(EFTNETSBAXIRespPars);
        end;

        //Construct response JSON
        EFTTransactionRequest.Get(EntryNo);
        ResponseObject.Add('BCSuccess', EFTTransactionRequest.Successful);

        if (EFTTransactionRequest.Successful) and (EFTTransactionRequest."Signature Type" <> EFTTransactionRequest."Signature Type"::" ") then begin
            Rejected := EFTTransactionRequest."Self Service";
            if not Rejected then
                Rejected := not Confirm(SignatureApprovalLbl, false);

            if Rejected then begin
                ResponseObject.Add('voidTransaction', true);
                //prepare void workflow, json so the payment can be voided right away
                EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
                POSSale.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.");
                EFTTransactionMgt.PrepareVoid(EFTSetup, POSSale, EFTTransactionRequest."Entry No.", false, VoidRequest, VoidMechanism, VoidWorkflow);
                Commit();
                ResponseObject.Add('voidWorkflow', VoidWorkflow);
                ResponseObject.Add('voidWorkflowRequest', VoidRequest);
            end
        end;

        exit(ResponseObject);
    end;

    procedure PhoneAuthCancelled(Response: Codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PhoneAuthCancelledLbl: Label 'Phone authorization cancelled. Aborted transaction';
        EFTNETSBAXIIntegration: Codeunit "NPR EFT NETS BAXI Integration";
    begin
        //Transaction never started if phone auth was cancelled. In this case we set a 0 amount result.

        Response.SetScope('request');
        EFTTransactionRequest.Get(Response.GetInteger('EntryNo'));
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."Result Amount" := 0;
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest."Result Display Text" := CopyStr(PhoneAuthCancelledLbl, 1, MaxStrLen(EFTTransactionRequest."Result Display Text"));
        EFTTransactionRequest.Modify();
        EFTNETSBAXIIntegration.HandleProtocolResponse(EFTTransactionRequest);
    end;
}