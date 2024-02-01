codeunit 6151162 "NPR MM Loy. Point PSP (Client)"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        Description: Label 'Pay with member loyalty points';
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
        tmpEFTIntegrationType."Version 2" := true;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnPrepareRequestSend', '', false, false)]
    local procedure OnCreateHwcEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Request: JsonObject; var RequestMechanism: Enum "NPR EFT Request Mechanism"; var Workflow: Text)
    var
        LoyaltyPointsProtocol: Codeunit "NPR EFT LoyaltyPointsProtocol";
    begin
        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;

        RequestMechanism := RequestMechanism::POSWorkflow;
        LoyaltyPointsProtocol.CreateHwcEftDeviceRequest(EftTransactionRequest, Request, Workflow);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnAfterFinancialCommit', '', false, false)]
    local procedure OnAfterFinancialCommit(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        if (not EftTransactionRequest.IsType(IntegrationName())) then
            exit;

        EftTransactionRequest.PrintReceipts(false);
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

