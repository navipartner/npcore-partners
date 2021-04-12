codeunit 6184514 "NPR EFT MobilePay Prot."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.47/MMV /20181030 CASE 334510 Added string length check
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object
    // NPR5.53/MMV /20191112 CASE 375566 Do not clear activemodelID to prevent handling of late events.
    // NPR5.54/MMV /20200206 CASE 388507 Attempt auto cancel if new purchase cannot be started.

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        Model: DotNet NPRNetModel;
        ActiveModelID: Guid;
        EntryNo: Integer;
        EFTMobilePayIntegration: Codeunit "NPR EFT MobilePay Integ.";
        TransactionDone: Boolean;
        CloseOnIdle: Boolean;
        ProtocolError: Label 'An unexpected error ocurred in the %1 protocol:\%2';
        ERROR_SESSION: Label 'Critical Error: Session object could not be retrieved for %1 payment. ';
        DialogOpen: Boolean;

    local procedure IntegrationType(): Text
    begin
        exit('MOBILEPAY');
    end;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        InitState();

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT:
                PaymentTransaction(EftTransactionRequest);
        end;
    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        ErrorText: Text;
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            Error(ERROR_SESSION, IntegrationType());

        EntryNo := EftTransactionRequest."Entry No.";
        EFTMobilePayIntegration.InitializeGlobals(EftTransactionRequest."POS Payment Type Code", EftTransactionRequest."Register No.");
        if not EFTMobilePayIntegration.PaymentStart(EftTransactionRequest) then begin
            //-NPR5.54 [388507]
            ErrorText := GetLastErrorText;
            if not EFTMobilePayIntegration.PaymentCancel(EftTransactionRequest) then begin
                HandleProtocolError(POSFrontEnd, ErrorText);
                //+NPR5.54 [388507]
                exit;
            end;

            //-NPR5.54 [388507]
            if not EFTMobilePayIntegration.PaymentStart(EftTransactionRequest) then begin
                HandleProtocolError(POSFrontEnd, ErrorText);
                exit;
            end;
            //+NPR5.54 [388507]
        end;

        CreateUserInterface(EftTransactionRequest);
        ActiveModelID := POSFrontEnd.ShowModel(Model);
        //-NPR5.53 [375566]
        DialogOpen := true;
        //+NPR5.53 [375566]
    end;

    local procedure CreateUserInterface(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        WebClientDependency: Record "NPR Web Client Dependency";
        Factory: DotNet NPRNetControlFactory;
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
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
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

    local procedure RequestClose(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);

        if CloseOnIdle and (EFTTransactionRequest."Result Code" = 10) then begin
            TransactionDone := true;
            EFTTransactionRequest."External Result Known" := true;
            FrontEnd.CloseModel(ActiveModelID);
            //-NPR5.53 [375566]
            //  CLEAR(ActiveModelID);
            DialogOpen := false;
            //+NPR5.53 [375566]
            OnAfterProtocolResponse(EFTTransactionRequest);
        end;

        if not EFTMobilePayIntegration.PaymentCancel(EFTTransactionRequest) then begin
            //-NPR5.54 [388507]
            HandleProtocolError(FrontEnd, GetLastErrorText());
            //+NPR5.54 [388507]
            exit;
        end;

        CloseOnIdle := true;
    end;

    local procedure UpdatePaymentStatus(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PaymentStatus: Text;
        WebClientDependency: Record "NPR Web Client Dependency";
    begin
        EFTTransactionRequest.Get(EntryNo);
        if not EFTMobilePayIntegration.GetPaymentStatus(EFTTransactionRequest) then begin
            //-NPR5.54 [388507]
            HandleProtocolError(FrontEnd, GetLastErrorText());
            //+NPR5.54 [388507]
            exit;
        end;

        if (EFTTransactionRequest.Successful) or (CloseOnIdle and (EFTTransactionRequest."Result Code" = 10)) then begin
            TransactionDone := true;
            EFTTransactionRequest."External Result Known" := true;
            FrontEnd.CloseModel(ActiveModelID);
            //-NPR5.53 [375566]
            //  CLEAR(ActiveModelID);
            DialogOpen := false;
            //+NPR5.53 [375566]
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
        MPOSProfile: Record "NPR MPOS Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        exit(POSUnit.Get(RegisterId) and POSUnit.GetProfile(MPOSProfile));
    end;

    local procedure InitState()
    begin
        Clear(Model);
        Clear(ActiveModelID);
        Clear(EntryNo);
        Clear(EFTMobilePayIntegration);
        Clear(TransactionDone);
        Clear(CloseOnIdle);
        //-NPR5.53 [375566]
        Clear(DialogOpen);
        //+NPR5.53 [375566]
    end;

    local procedure HandleProtocolError(FrontEnd: Codeunit "NPR POS Front End Management"; ErrorText: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        TransactionDone := true;
        //-NPR5.54 [388507]
        ErrorText := StrSubstNo(ProtocolError, IntegrationType(), ErrorText);
        //+NPR5.54 [388507]

        EFTTransactionRequest.Get(EntryNo);
        EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
        //-NPR5.53 [375566]
        //IF NOT ISNULLGUID(ActiveModelID) THEN
        if DialogOpen then begin
            //+NPR5.53 [375566]
            FrontEnd.CloseModel(ActiveModelID);
            //-NPR5.53 [375566]
            DialogOpen := false;
            //+NPR5.53 [375566]
        end;

        OnAfterProtocolResponse(EFTTransactionRequest);
        Message(ErrorText);
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
    end;
}

