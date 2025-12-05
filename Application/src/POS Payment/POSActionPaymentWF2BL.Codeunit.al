codeunit 6059778 "NPR POS Action: Payment WF2 BL"
{
    Access = Internal;
    internal procedure PrepareForPayment(PaymentLine: Codeunit "NPR POS Payment Line"; PaymentMethodCode: Code[10]; var WorkflowNameOut: Code[20]; var POSPaymentMethodOut: Record "NPR POS Payment Method"; var AmountOut: Decimal; var ForceAmount: Boolean; var CollectReturnInformation: Boolean)
    var
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        PaymentLinePOS: Record "NPR POS Sale Line";
        PaymentProcessingEvents: Codeunit "NPR Payment Processing Events";
        IProcessingType: Interface "NPR POS IPaymentWFHandler";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        POSPaymentMethodOut.Get(PaymentMethodCode);
        ReturnPOSPaymentMethod.Get(POSPaymentMethodOut."Return Payment Method Code");
        POSPaymentMethodOut.TestField("Block POS Payment", false);
        ReturnPOSPaymentMethod.TestField("Block POS Payment", false);

        IProcessingType := POSPaymentMethodOut."Processing Type";
        WorkflowNameOut := IProcessingType.GetPaymentHandler();
        ForceAmount := POSPaymentMethodOut."Forced Amount";
        if not POSPaymentMethodOut."Zero as Default on Popup" then begin
            PaymentLine.CalculateBalance(POSPaymentMethodOut, SalesAmount, PaidAmount, ReturnAmount, SubTotal);
            AmountOut := PaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethodOut, ReturnPOSPaymentMethod, true);
        end else
            AmountOut := 0;

        PaymentLine.GetPaymentLine(PaymentLinePOS);
        PaymentProcessingEvents.OnAfterCalculateSuggestionPaymentAmount(PaymentLinePOS."Sales Ticket No.", SalesAmount, PaidAmount, POSPaymentMethodOut, ReturnPOSPaymentMethod, AmountOut, CollectReturnInformation);
    end;

    internal procedure PrepareForPayment(PaymentLine: Codeunit "NPR POS Payment Line"; PaymentMethodCode: Code[10]; var WorkflowNameOut: Code[20]; var POSPaymentMethodOut: Record "NPR POS Payment Method"; var AmountOut: Decimal)
    var
        ForceAmount: Boolean;
        CollectReturnInformation: Boolean;
    begin
        PrepareForPayment(PaymentLine, PaymentMethodCode, WorkflowNameOut, POSPaymentMethodOut, AmountOut, ForceAmount, CollectReturnInformation);
    end;

    internal procedure AttemptEndCurrentSale(PaymentMethodCode: Code[10]): Boolean
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSPaymentMethod.Get(PaymentMethodCode);
        POSPaymentMethod.TestField("Block POS Payment", false);
        if (not POSPaymentMethod."Auto End Sale") then
            exit(false);

        ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code");
        ReturnPOSPaymentMethod.TestField("Block POS Payment", false);

        POSSession.GetSale(POSSale);
        exit(POSSale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod));
    end;

    internal procedure CheckMMPaymentMethodAssigned(PaymentMethodCode: Code[10]; SalePOS: Record "NPR POS Sale") PaymentMethodAssigned: Boolean;
    var
        EFTSetup: Record "NPR EFT Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        if not POSPaymentMethod.Get(PaymentMethodCode) then
            exit;

        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::EFT then
            exit;

        EFTSetup.FindSetup(SalePOS."Register No.", PaymentMethodCode);
        case EFTSetup."EFT Integration Type" of
            EFTAdyenIntegration.CloudIntegrationType(),
            EFTAdyenIntegration.HWCIntegrationType():
                PaymentMethodAssigned := EFTAdyenIntegration.CheckMMPaymentMethodAssignedToPOSSale(EFTSetup, SalePOS."Sales Ticket No.");
        end;
    end;

    local procedure IsEFTSubscriptionPayment(POSPaymentMethod: Record "NPR POS Payment Method"; salePOS: Record "NPR POS Sale"): Boolean
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin

        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::EFT then
            exit(false);

        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);
        case EFTSetup."EFT Integration Type" of
            EFTAdyenIntegration.CloudIntegrationType(),
            EFTAdyenIntegration.HWCIntegrationType():
                exit(EFTAdyenIntegration.GetCreateRecurringContract(EFTSetup) <> 0);
        end;

        exit(false);
    end;

    internal procedure CheckMembershipSubscription(SalePOS: Record "NPR POS Sale"; PosPaymentMethod: Record "NPR POS Payment Method"; var MembershipEmail: Text): Boolean
    var
        NpPaySetup: Record "NPR Adyen Setup";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
    begin
        if not NpPaySetup.Get() then
            exit(false);

        if not NpPaySetup."Collect Subscr. Payer Email" then
            exit(false);

        if not IsEFTSubscriptionPayment(PosPaymentMethod, SalePOS) then
            exit(false);

        if (not MembershipMgtInternal.MemberInfoCaptureExist(SalePOS)) and (not MembershipMgtInternal.POSMembershipSelected(SalePOS)) then
            exit(false);

        MembershipMgtInternal.GetMemberEmail(SalePOS, MembershipEmail);
        exit(true);
    end;
}