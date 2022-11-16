codeunit 6150726 "NPR POSAction: Ins. Customer" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for setting a customer on the current transaction';
        ParameterCustomerType_OptionsLbl: Label 'Contact,Customer', Locked = true;
        ParamCardPageId_NameCaptionLbl: Label 'CardPageId';
        ParamCustomerType_NameCaptionLbl: Label 'CustomerType';
        ParameterCustomerType_CaptionOptionsLbl: Label 'Contact,Customer';
        ParamCardPageId_DescrptionLbl: Label 'Card Page Id';
        ParamCustomerType_DescrptionLbl: Label 'Customer Type';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddIntegerParameter(ParameterCardPageId_Name(), 0, ParamCardPageId_NameCaptionLbl, ParamCardPageId_DescrptionLbl);
        WorkflowConfig.AddOptionParameter(
            ParameterCustomerType_Name(),
            ParameterCustomerType_OptionsLbl,
            SelectStr(2, ParameterCustomerType_OptionsLbl),
            ParamCustomerType_NameCaptionLbl,
            ParamCustomerType_DescrptionLbl,
            ParameterCustomerType_CaptionOptionsLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        SalePOS: Record "NPR POS Sale";
        PosActionBusinessLogic: Codeunit "NPR POSAction: Ins. Customer-B";
        CustomerType: Option Contact,Customer;
        CardPageId: Integer;
    begin
        CardPageId := Context.GetIntegerParameter(ParameterCardPageId_Name());
        CustomerType := Context.GetIntegerParameter(ParameterCustomerType_Name());

        Sale.GetCurrentSale(SalePOS);
        case CustomerType of
            CustomerType::Contact:
                PosActionBusinessLogic.OnActionCreateContact(CardPageId, SalePOS);
            CustomerType::Customer:
                PosActionBusinessLogic.OnActionCreateCustomer(CardPageId, SalePOS);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCustInsert.js###
'let main=async({})=>await workflow.respond();'
        );
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
    var
        Text000: Label 'Required Customer select after Login';
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

    local procedure ParameterCardPageId_Name(): Text[30]
    begin
        exit('CardPageId');
    end;

    local procedure ParameterCustomerType_Name(): Text[30]
    begin
        exit('CustomerType');
    end;
}

