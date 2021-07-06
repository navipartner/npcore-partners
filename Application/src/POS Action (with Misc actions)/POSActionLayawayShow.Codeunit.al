codeunit 6150871 "NPR POS Action: LayawayShow"
{

    var
        ActionDescription: Label 'Show layaway orders and all associated prepayment invoices';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionOrderPayTermsFilter: Label 'Order Payment Term';
        DescOrderPayTermsFilter: Label 'Payment Terms to use for filtering layaway orders.';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';

    local procedure ActionCode(): Text
    begin
        exit('LAYAWAY_SHOW');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('ShowLayawayInvoices', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterTextParameter('OrderPaymentTermsFilter', '');
            Sender.RegisterBooleanParameter('SelectCustomer', true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        OrderPaymentTerms: Text;
        SelectCustomer: Boolean;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        OrderPaymentTerms := JSON.GetStringParameterOrFail('OrderPaymentTermsFilter', ActionCode());
        SelectCustomer := JSON.GetBooleanParameterOrFail('SelectCustomer', ActionCode());

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Payment Terms Code", OrderPaymentTerms);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);

        if not PromptSalesOrderList(SalesHeader) then
            exit;

        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        PAGE.RunModal(PAGE::"NPR POS Prepaym. Invoices", SalesInvoiceHeader);
    end;

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            exit(true);
        end;

        if not SelectCustomer then
            exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit();
        exit(true);
    end;

    local procedure PromptSalesOrderList(var SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(PAGE.RunModal(PAGE::"Sales Order List", SalesHeader) = ACTION::LookupOK);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'OrderPaymentTermsFilter':
                Caption := CaptionOrderPayTermsFilter;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'OrderPaymentTermsFilter':
                Caption := DescOrderPayTermsFilter;
            'SelectCustomer':
                Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'OrderPaymentTermsFilter':
                begin
                    if PAGE.RunModal(0, PaymentTerms) = ACTION::LookupOK then
                        POSParameterValue.Value := PaymentTerms.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'OrderPaymentTermsFilter':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    PaymentTerms.Get(POSParameterValue.Value);
                end;
        end;
    end;
}

