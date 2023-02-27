codeunit 6151162 "NPR MM Loy. Point PSP (Client)"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        Description: Label 'Pay with member loyalty points';
        FailMessage: Label 'Transaction was declined with reason code %1 - %2. ';
        NoMember: Label 'This payment type requires that there is a member assigned to the sales prior to payment and that loyalty was setup and enabled for the membership.';

    procedure IntegrationName(): Code[20]
    begin
        exit('MM_LOYALTY_PWP');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin

        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationName();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR MM Loy. Point PSP (Client)";
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreatePaymentOfGoodsRequest', '', false, false)]
    local procedure OnCreatePaymentOfGoodsRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;

        Handled := true;

        if (not LoyaltyPointsMgrClient.AssignLoyaltyInformation(EftTransactionRequest)) then
            Error(NoMember);

        EftTransactionRequest."Transaction Date" := Today();
        EftTransactionRequest."Transaction Time" := Time;

        EftTransactionRequest.Recoverable := false;
        EftTransactionRequest."Auto Voidable" := false;
        EftTransactionRequest."Manual Voidable" := false;
        EftTransactionRequest."Processing Type" := EftTransactionRequest."Processing Type"::PAYMENT;
        EftTransactionRequest.Insert(true);

        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);

        LoyaltyPointsMgrClient.ValidateServiceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateRefundRequest', '', false, false)]
    local procedure OnCreateRefundRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;

        Handled := true;

        if (not LoyaltyPointsMgrClient.AssignLoyaltyInformation(EftTransactionRequest)) then
            Error(NoMember);

        EftTransactionRequest."Transaction Date" := Today();
        EftTransactionRequest."Transaction Time" := Time;

        EftTransactionRequest.Recoverable := false;
        EftTransactionRequest."Auto Voidable" := false;
        EftTransactionRequest."Manual Voidable" := false;
        EftTransactionRequest."Processing Type" := EftTransactionRequest."Processing Type"::REFUND;
        EftTransactionRequest.Insert(true);

        EftTransactionRequest."Reference Number Input" := Format(EftTransactionRequest."Entry No.");
        EftTransactionRequest.Modify(true);

        LoyaltyPointsMgrClient.ValidateServiceRequest(EftTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnCreateVoidRequest', '', false, false)]
    local procedure OnCreateVoidRequest(var EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;

        Handled := true;

        // CreateGenericRequest(EftTransactionRequest);
        // EftTransactionRequest.Recoverable := TRUE;
        // EftTransactionRequest.Insert(TRUE);
        // EftTransactionRequest."Reference Number Input" := FORMAT(EftTransactionRequest."Entry No.");
        // EftTransactionRequest.Modify(TRUE);

        Message('VOID');
    end;

#if not CLOUD
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnSendEftDeviceRequest', '', false, false)]
    local procedure OnSendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Handled: Boolean)
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LoyaltyPointsUIClient: Codeunit "NPR MM Loy. Point UI (Client)";
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;

        Handled := true;

        // If there is a UI, show the UI
        if (POSSession.IsActiveSession(POSFrontEnd)) then
            LoyaltyPointsUIClient.ShowTransactionDialog(EftTransactionRequest, POSFrontEnd);

        LoyaltyPointsMgrClient.MakeServiceRequest(EftTransactionRequest);
    end;
#endif

    procedure OnServiceRequestResponse(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        PlaceHolder1Lbl: Label '%1 xxxx%2', Locked = true;
        PlaceHolder2Lbl: Label '%1 %2 xxxx%3', Locked = true;
    begin
        if (EFTTransactionRequest.Successful) then begin
            EFTTransactionRequest."POS Description" :=
              CopyStr(
                StrSubstNo(PlaceHolder1Lbl,
                  EFTTransactionRequest."Card Name",
                  CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 2)),
                1, MaxStrLen(EFTTransactionRequest."POS Description"));
        end;

        if (not EFTTransactionRequest.Successful) then begin
            EFTTransactionRequest."POS Description" :=
              CopyStr(
                StrSubstNo(PlaceHolder2Lbl,
                  EFTTransactionRequest."Result Description",
                  EFTTransactionRequest."Card Name",
                  CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 2)),
                1, MaxStrLen(EFTTransactionRequest."POS Description"));

            EFTTransactionRequest."Result Amount" := 0;
            Message(FailMessage, EFTTransactionRequest."Result Code", EFTTransactionRequest."Result Description");
        end;

        // Resume POS
        EFTInterface.EftIntegrationResponse(EFTTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;

        EftTransactionRequest.PrintReceipts(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnBeforePauseFrontEnd', '', false, false)]
    local procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin

        if (not EFTTransactionRequest.IsType(IntegrationName())) then
            exit;

        //These requests are synchronous - which crashes the front end if we pause/resume.
        Skip := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnBeforeResumeFrontEnd', '', false, false)]
    local procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin

        if (not EFTTransactionRequest.IsType(IntegrationName())) then
            exit;

        //These requests are synchronous - which crashes the front end if we pause/resume.
        // but the result is checked from JS async UI
        Skip := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', true, true)]
    local procedure OnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale")
    var
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if (LoyaltyPointsMgrClient.CreateRegisterSalesEftTransaction(IntegrationName(), SaleHeader, EFTTransactionRequest)) then
            LoyaltyPointsMgrClient.PrepareServiceRequest(EFTTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale")
    var
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.", "Integration Type", "Processing Type");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        EFTTransactionRequest.SetRange("Integration Type", IntegrationName());
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::AUXILIARY);
        EFTTransactionRequest.SetRange("Auxiliary Operation ID", 1);
        EFTTransactionRequest.SetRange("Result Code", 119);
        if (EFTTransactionRequest.FindFirst()) then begin
            LoyaltyPointsMgrClient.MakeServiceRequest(EFTTransactionRequest);
            EFTTransactionRequest.PrintReceipts(false);
        end;
    end;
}

