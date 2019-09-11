codeunit 6184514 "EFT MobilePay Protocol"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.47/MMV /20181030 CASE 334510 Added string length check
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Model: DotNet npNetModel;
        ActiveModelID: Guid;
        EntryNo: Integer;
        EFTMobilePayIntegration: Codeunit "EFT MobilePay Integration";
        TransactionDone: Boolean;
        CloseOnIdle: Boolean;
        ProtocolError: Label 'An unexpected error ocurred in the %1 protocol:\%2';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for %1 payment. ';

    local procedure IntegrationType(): Text
    begin
        exit('MOBILEPAY');
    end;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "EFT Transaction Request")
    begin
        InitState();

        case EftTransactionRequest."Processing Type" of
          EftTransactionRequest."Processing Type"::PAYMENT : PaymentTransaction(EftTransactionRequest);
        end;
    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error(ERROR_SESSION, IntegrationType());

        EntryNo := EftTransactionRequest."Entry No.";
        EFTMobilePayIntegration.InitializeGlobals(EftTransactionRequest."POS Payment Type Code", EftTransactionRequest."Register No.");
        if not EFTMobilePayIntegration.PaymentStart(EftTransactionRequest) then begin
            HandleProtocolError(POSFrontEnd);
            exit;
        end;

        CreateUserInterface(EftTransactionRequest);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
    end;

    local procedure CreateUserInterface(EFTTransactionRequest: Record "EFT Transaction Request")
    var
        WebClientDependency: Record "Web Client Dependency";
        Factory: DotNet npNetControlFactory;
    begin
        Model := Model.Model();
        Model.Append(
          Factory.Panel().Set('Id', 'model')
            .Append(
              Factory.Label().Set('Visible', false).Set('Id', 'timerLabel').SubscribeEvent('click'),
              Factory.Panel().Set('Id', 'btnClosePanel')
                .Append(
                  Factory.Panel().Set('Id', 'btnClose').SubscribeEvent('click')
                ),
              Factory.Panel().Set('Class', 'main')
                .Append(
                  Factory.Panel().Set('Class', 'mobilePay')
                    .Append(
                      Factory.Panel().Set('Class', 'mobilePayContent')
                        .Append(
                          Factory.Panel()
                            .Append(
                              Factory.Image().Set('Id', 'mobilePayLogo').Set('Source', WebClientDependency.GetDataUri('MBP-LOGO'))
                            ),
                          Factory.Panel().Set('Id', 'qrcode')
                        )
                    ),
                  Factory.Panel().Set('Class', 'body')
                    .Append(
                      Factory.Label(''),
                      Factory.Label(Format(EFTTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,0>')).Set('Id', 'lb-amount')
                    ),
                  Factory.Panel().Set('Class', 'bottom')
                    .Append(
                      Factory.Image().Set('Id', 'imgStatus').Set('Source', WebClientDependency.GetDataUri('MBP-10')),
                      Factory.Label('').Set('Id', 'lb-status')
                    )
                )
            )
        );

        if IsMPOSDevice(EFTTransactionRequest."Register No.") then
            Model.AddStyle(WebClientDependency.GetStyleSheet('MBP-MINI'))
        else
            Model.AddStyle(WebClientDependency.GetStyleSheet('MBP'));

        Model.AddStyle('#btnClose{background: url(''' + WebClientDependency.GetDataUri('MBP-CLOSE0') + ''')');
        Model.AddStyle('#btnClose:hover{background: url(''' + WebClientDependency.GetDataUri('MBP-CLOSE1') + ''')');

        Model.AddScript('setInterval(function() { $("#timerLabel").click(); }, 1000);');
        Model.AddScript(WebClientDependency.GetJavaScript('QRCODE'));
        Model.AddScript('new QRCode(document.getElementById("qrcode"), { width: 146, height: 146, colorDark: "#003f63", colorLight: "white", text: "' + EFTMobilePayIntegration.GetQRUri() + '" });');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', false, false)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    var
        WebClientDependency: Record "Web Client Dependency";
        ModelIDVar: Variant;
        EFTTransactionRequest: Record "EFT Transaction Request";
        EFTInterface: Codeunit "EFT Interface";
    begin
        if ModelID <> ActiveModelID then
            exit;
        Handled := true;

        if TransactionDone then //The event is late, we have already acted on a result.
            exit;

        case Sender of
            'btnClose':
                RequestClose(FrontEnd);
            'timerLabel':
                UpdatePaymentStatus(FrontEnd);
        end;
    end;

    local procedure RequestClose(FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);

        if CloseOnIdle and (EFTTransactionRequest."Result Code" = 10) then begin
            TransactionDone := true;
            EFTTransactionRequest."External Result Received" := true;
            FrontEnd.CloseModel(ActiveModelID);
            Clear(ActiveModelID);
            OnAfterProtocolResponse(EFTTransactionRequest);
        end;

        if not EFTMobilePayIntegration.PaymentCancel(EFTTransactionRequest) then begin
            HandleProtocolError(FrontEnd);
            exit;
        end;

        CloseOnIdle := true;
    end;

    local procedure UpdatePaymentStatus(FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        PaymentStatus: Text;
        LastErrorText: Text;
        WebClientDependency: Record "Web Client Dependency";
    begin
        EFTTransactionRequest.Get(EntryNo);
        if not EFTMobilePayIntegration.GetPaymentStatus(EFTTransactionRequest) then begin
            HandleProtocolError(FrontEnd);
            exit;
        end;

        if (EFTTransactionRequest.Successful) or (CloseOnIdle and (EFTTransactionRequest."Result Code" = 10)) then begin
            TransactionDone := true;
            EFTTransactionRequest."External Result Received" := true;
            FrontEnd.CloseModel(ActiveModelID);
            Clear(ActiveModelID);
            OnAfterProtocolResponse(EFTTransactionRequest);
        end else begin
            PaymentStatus := EFTTransactionRequest."Result Description";

            Model.GetControlById('imgStatus').Set('Source', WebClientDependency.GetDataUri(StrSubstNo('MBP-%1', EFTTransactionRequest."Result Code")));
            Model.GetControlById('lb-status').Set('Caption', PaymentStatus);

            FrontEnd.UpdateModel(Model, ActiveModelID);
        end;
    end;

    local procedure IsMPOSDevice(RegisterId: Code[10]): Boolean
    var
        MPOSAppSetup: Record "MPOS App Setup";
    begin
        if MPOSAppSetup.Get(RegisterId) then
            exit(MPOSAppSetup.Enable);
        exit(false);
    end;

    local procedure InitState()
    begin
        Clear(Model);
        Clear(ActiveModelID);
        Clear(EntryNo);
        Clear(EFTMobilePayIntegration);
        Clear(TransactionDone);
        Clear(CloseOnIdle);
    end;

    local procedure HandleProtocolError(FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionRequest: Record "EFT Transaction Request";
        ErrorText: Text;
    begin
        TransactionDone := true;
        ErrorText := StrSubstNo(ProtocolError, IntegrationType(), GetLastErrorText);

        EFTTransactionRequest.Get(EntryNo);
        //-NPR5.47 [334510]
        //EFTTransactionRequest."NST Error" := ErrorText;
        EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
        //+NPR5.47 [334510]
        if not IsNullGuid(ActiveModelID) then
            FrontEnd.CloseModel(ActiveModelID);

        OnAfterProtocolResponse(EFTTransactionRequest);
        Message(ErrorText);
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "EFT Transaction Request")
    begin
    end;
}

