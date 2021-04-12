codeunit 6151162 "NPR MM Loy. Point PSP (Client)"
{

    trigger OnRun()
    begin
    end;

    var
        Description: Label 'Pay with member loyalty points';
        FailMessage: Label 'Transaction was declined with reason code %1 - %2. ';
        NoMember: Label 'This payment type requires that there is a member assigned to the sales prior to payment and that loyalty was setup and enabled for the membership.';

    procedure IntegrationName(): Text
    begin
        exit('MM_LOYALTY_PWP');
    end;

    local procedure "--"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnDiscoverIntegrations', '', false, false)]
    local procedure OnDiscoverIntegrations(var tmpEFTIntegrationType: Record "NPR EFT Integration Type" temporary)
    begin

        tmpEFTIntegrationType.Init();
        tmpEFTIntegrationType.Code := IntegrationName();
        tmpEFTIntegrationType.Description := Description;
        tmpEFTIntegrationType."Codeunit ID" := CODEUNIT::"NPR MM Loy. Point PSP (Client)";
        tmpEFTIntegrationType.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreatePaymentOfGoodsRequest', '', false, false)]
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

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateRefundRequest', '', false, false)]
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

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnCreateVoidRequest', '', false, false)]
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

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnSendEftDeviceRequest', '', false, false)]
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

    procedure OnServiceRequestResponse(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin

        if (EFTTransactionRequest.Successful) then begin
            EFTTransactionRequest."POS Description" :=
              CopyStr(
                StrSubstNo('%1 xxxx%2',
                  EFTTransactionRequest."Card Name",
                  CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 2)),
                1, MaxStrLen(EFTTransactionRequest."POS Description"));
        end;

        if (not EFTTransactionRequest.Successful) then begin
            EFTTransactionRequest."POS Description" :=
              CopyStr(
                StrSubstNo('%1 %2 xxxx%3',
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

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;

        EftTransactionRequest.PrintReceipts(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnAfterPaymentConfirm', '', false, false)]
    local procedure OnAfterPaymentConfirm(EftTransactionRequest: Record "NPR EFT Transaction Request"; var DoNotResume: Boolean)
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforePauseFrontEnd', '', false, false)]
    local procedure OnBeforePauseFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin

        if (not EFTTransactionRequest.IsType(IntegrationName())) then
            exit;

        //These requests are synchronous - which crashes the front end if we pause/resume.
        Skip := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6184479, 'OnBeforeResumeFrontEnd', '', false, false)]
    local procedure OnBeforeResumeFrontEnd(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Skip: Boolean)
    begin

        if (not EFTTransactionRequest.IsType(IntegrationName())) then
            exit;

        //These requests are synchronous - which crashes the front end if we pause/resume.
        // but the result is checked from JS async UI
        Skip := false;
    end;

    local procedure "---"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnBeforeEndSale', '', true, true)]
    local procedure OnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale")
    var
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        if (LoyaltyPointsMgrClient.CreateRegisterSalesEftTransaction(IntegrationName(), SaleHeader, EFTTransactionRequest)) then
            LoyaltyPointsMgrClient.PrepareServiceRequest(EFTTransactionRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale")
    var
        LoyaltyPointsMgrClient: Codeunit "NPR MM Loy. Point Mgr (Client)";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin

        EFTTransactionRequest.SetFilter("Integration Type", '=%1', IntegrationName());
        EFTTransactionRequest.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
        EFTTransactionRequest.SetFilter("Processing Type", '=%1', EFTTransactionRequest."Processing Type"::AUXILIARY);
        EFTTransactionRequest.SetFilter("Auxiliary Operation ID", '=%1', 1);
        EFTTransactionRequest.SetFilter("Result Code", '=%1', 119);
        if (EFTTransactionRequest.FindFirst()) then begin
            LoyaltyPointsMgrClient.MakeServiceRequest(EFTTransactionRequest);
            EFTTransactionRequest.PrintReceipts(false);
        end;
    end;
}

