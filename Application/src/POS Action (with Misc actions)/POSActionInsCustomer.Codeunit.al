codeunit 6150726 "NPR POSAction: Ins. Customer"
{
    Access = Internal;
    var
        ActionDescription: Label 'This is a built-in action for setting a customer on the current transaction';
        Text000: Label 'Required Customer select after Login';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Single)
        then begin
            Sender.RegisterWorkflowStep('CreateContact', 'if(param.CustomerType == 0) {respond()}');
            Sender.RegisterWorkflowStep('CreateCustomer', 'if(param.CustomerType == 1) {respond()}');

            Sender.RegisterOptionParameter('CustomerType', 'Contact,Customer', 'Contact');
            Sender.RegisterIntegerParameter('CardPageId', 0);

            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        JSON: Codeunit "NPR POS JSON Management";
        CardPageId: Integer;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        CardPageId := JSON.GetInteger('CardPageId');

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        case WorkflowStep of
            'CreateContact':
                OnActionCreateContact(CardPageId, SalePOS);
            'CreateCustomer':
                OnActionCreateCustomer(CardPageId, SalePOS);
            else
                exit;
        end;

        POSSale.Refresh(SalePOS);
        POSSale.Modify(false, false);
        POSSession.RequestRefreshData();
    end;

    local procedure OnActionCreateContact(CardPageId: Integer; var SalePOS: Record "NPR POS Sale")
    var
        Contact: Record Contact;
    begin
        if (SalePOS."Customer Type" = SalePOS."Customer Type"::Cash) and (SalePOS."Customer No." <> '') then
            Contact.Get(SalePOS."Customer No.")
        else begin
            Contact.Init();
            Contact."No." := '';
            Contact.Insert(true);
            Commit();
        end;

        Contact.SetRecFilter();
        if CardPageId > 0 then
            PAGE.RunModal(CardPageId, Contact)
        else
            PageRunModalWithFieldFocus(Contact, Contact.FieldNo(Name));

        SalePOS."Customer Type" := SalePOS."Customer Type"::Cash;
        SalePOS.Validate("Customer No.", Contact."No.");
    end;

    local procedure OnActionCreateCustomer(CardPageId: Integer; var SalePOS: Record "NPR POS Sale")
    var
        Customer: Record Customer;
    begin
        if (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) and (SalePOS."Customer No." <> '') then
            Customer.Get(SalePOS."Customer No.")
        else begin
            Customer.Init();
            Customer."No." := '';
            Customer.Insert(true);
            Commit();
        end;

        if CardPageId > 0 then
            PAGE.RunModal(CardPageId, Customer)
        else
            PageRunModalWithFieldFocus(Customer, Customer.FieldNo(Name));

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit('INSERT_CUSTOMER');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    procedure PageRunModalWithFieldFocus(RecRelatedVariant: Variant; FieldNumber: Integer): Boolean
    var
        RecordRef: RecordRef;
        RecordRefVariant: Variant;
        PageID: Integer;
        PageMgt: Codeunit "Page Management";
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        if not GuiAllowed then
            exit(false);

        if not DataTypeManagement.GetRecordRef(RecRelatedVariant, RecordRef) then
            exit(false);

        PageID := PageMgt.GetPageID(RecordRef);

        if PageID <> 0 then begin
            RecordRefVariant := RecordRef;
            PAGE.RunModal(PageID, RecordRefVariant, FieldNumber);
            exit(true);
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS View Change WF Mgt.", 'OnAfterLogin', '', true, true)]
    local procedure SelectCustomerRequired(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; var POSSession: Codeunit "NPR POS Session")
    var
        Customer: Record Customer;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        PrevRec: Text;
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'SelectCustomerRequired' then
            exit;

        while PAGE.RunModal(0, Customer) <> ACTION::LookupOK do
            Clear(Customer);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        PrevRec := Format(SalePOS);

        SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Ord);
        SalePOS.Validate("Customer No.", Customer."No.");

        if PrevRec <> Format(SalePOS) then
            SalePOS.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertPOSSalesWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'SelectCustomerRequired':
                begin
                    Rec.Description := CopyStr(Text000, 1, MaxStrLen(Rec.Description));
                    Rec."Sequence No." := CurrCodeunitId();
                    Rec.Enabled := false;
                end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POSAction: Ins. Customer");
    end;
}

