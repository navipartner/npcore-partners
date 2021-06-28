codeunit 6184543 "NPR EFT Test Mock Integrat."
{
    // NPR5.54/MMV /20200129 CASE 364340 Created object

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        DeviceResponseMode: Option SUCCESS,FAILURE,HANDLED_ERROR;
        CreateRequestMode: Option SUCCESS,UNHANDLED_ERROR;
        PaymentConfirmationMode: Option APPROVE,DECLINE;
        TipAmount: Decimal;
        SurchargeAmount: Decimal;
        LookupAmount: Decimal;

    procedure IntegrationType(): Text
    begin
        exit('TEST_MOCK');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverAuxiliaryOperations', '', false, false)]
    local procedure OnDiscoverAuxiliaryOperations(var tmpEFTAuxOperation: Record "NPR EFT Aux Operation" temporary)
    begin
        //Any non standard EFT operations are registered here:

        tmpEFTAuxOperation.Init();
        tmpEFTAuxOperation."Integration Type" := IntegrationType();
        tmpEFTAuxOperation."Auxiliary ID" := 1;
        tmpEFTAuxOperation.Description := 'Aux operation';
        tmpEFTAuxOperation.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        HandleCreateRequestRecord(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateGiftCardLoadRequest', '', false, false)]
    local procedure OnCreateGiftcardLoadRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Manual Voidable" := true;
        HandleCreateRequestRecord(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateLookupTransactionRequest', '', false, false)]
    local procedure OnCreateLookupTransactionRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        HandleCreateRequestRecord(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EftTransactionRequest.Recoverable := true;
        EftTransactionRequest."Auto Voidable" := true;
        EftTransactionRequest."Manual Voidable" := true;
        HandleCreateRequestRecord(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        EftTransactionRequest.Recoverable := true;
        HandleCreateRequestRecord(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateBeginWorkshiftRequest', '', false, false)]
    local procedure OnCreateBeginWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        HandleCreateRequestRecord(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateEndWorkshiftRequest', '', false, false)]
    local procedure OnCreateEndWorkshiftRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        HandleCreateRequestRecord(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateAuxRequest', '', false, false)]
    local procedure OnCreateAuxRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        HandleCreateRequestRecord(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;
        Handled := true;

        HandleSendEftDeviceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        if not CODEUNIT.Run(CODEUNIT::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    begin
        if not EftTransactionRequest.IsType(IntegrationType()) then
            exit;

        HandlePaymentConfirmation(EftTransactionRequest, DoNotResume);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforePauseFrontEnd', '', false, false)]
    local procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin
        if not EFTTransactionRequest.IsType(IntegrationType()) then
            exit;

        Skip := true; //There is no front end to pause
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforeResumeFrontEnd', '', false, false)]
    local procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
    begin
        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit;
        if not EFTTransactionRequest.IsType(IntegrationType()) then
            exit;

        Skip := true; //There is no front end to pause
    end;

    local procedure HandleSendEftDeviceRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        case DeviceResponseMode of
            DeviceResponseMode::FAILURE:
                begin
                    EFTTransactionRequest."External Result Known" := true;
                    EFTTransactionRequest.Successful := false;
                end;

            DeviceResponseMode::SUCCESS:
                begin
                    EFTTransactionRequest."External Result Known" := true;
                    EFTTransactionRequest.Successful := true;
                    EFTTransactionRequest."Amount Output" := EFTTransactionRequest."Amount Input";
                    EFTTransactionRequest."Tip Amount" := TipAmount;
                    EFTTransactionRequest."Fee Amount" := SurchargeAmount;
                    EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Input";

                    case EFTTransactionRequest."Processing Type" of
                        EFTTransactionRequest."Processing Type"::PAYMENT:
                            EFTTransactionRequest."Result Amount" += TipAmount + SurchargeAmount; //Tip & Surcharge was unknown on payments.

                        EFTTransactionRequest."Processing Type"::REFUND,
                        EFTTransactionRequest."Processing Type"::VOID:
                            begin
                                if EFTTransactionRequest."Processed Entry No." <> 0 then begin //Tip & Surcharge being reversed is known
                                    OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
                                    EFTTransactionRequest."Tip Amount" := OriginalEFTTransactionRequest."Tip Amount";
                                    EFTTransactionRequest."Fee Amount" := OriginalEFTTransactionRequest."Fee Amount";
                                end;
                            end;

                        EFTTransactionRequest."Processing Type"::LOOK_UP:
                            EFTTransactionRequest."Result Amount" := LookupAmount;
                    end;
                end;

            DeviceResponseMode::HANDLED_ERROR:
                begin
                    EFTTransactionRequest."Client Error" := 'Simulated error. Needs recovery';
                    EFTTransactionRequest."External Result Known" := false;
                end;
        end;

        EFTInterface.EftIntegrationResponse(EFTTransactionRequest);
    end;

    local procedure HandleCreateRequestRecord(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        case CreateRequestMode of
            CreateRequestMode::SUCCESS:
                begin
                    EFTTransactionRequest."Reference Number Input" := Format(CreateGuid());
                    EFTTransactionRequest.Insert(true);
                end;

            CreateRequestMode::UNHANDLED_ERROR:
                begin
                    Error('Unhandled error');
                end;
        end;
    end;

    local procedure HandlePaymentConfirmation(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EFTSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        case PaymentConfirmationMode of
            PaymentConfirmationMode::APPROVE:
                ;
            PaymentConfirmationMode::DECLINE:
                begin
                    DoNotResume := true;
                    EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");
                    POSSession.GetSession(POSSession, true);
                    POSSession.GetSale(POSSale);
                    POSSale.GetCurrentSale(SalePOS);
                    EFTTransactionMgt.StartVoid(EFTSetup, SalePOS, EftTransactionRequest."Entry No.", false);
                end;
        end;
    end;

    procedure SetDeviceResponseHandler(ModeIn: Option SUCCESS,FAILURE,HANDLED_ERROR)
    begin
        DeviceResponseMode := ModeIn;
    end;

    procedure SetCreateRequestHandler(ModeIn: Option SUCCESS,UNHANDLED_ERROR)
    begin
        CreateRequestMode := ModeIn;
    end;

    procedure SetPaymentConfirmationHandler(ModeIn: Option APPROVE,DECLINE)
    begin
        PaymentConfirmationMode := ModeIn;
    end;

    procedure SetExternalTipAmount(Amount: Decimal)
    begin
        TipAmount := Amount;
    end;

    procedure SetExternalSurchargeAmount(Amount: Decimal)
    begin
        SurchargeAmount := Amount;
    end;

    procedure SetLookupAmount(Amount: Decimal)
    begin
        LookupAmount := Amount;
    end;
}

