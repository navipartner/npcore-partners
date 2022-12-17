codeunit 6150868 "NPR POS Action: Layaway Create" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Create layaway of sales order via prepayment invoices.';
        CaptionCreationFeeItem: Label 'Creation Fee';
        CaptionDownpayPct: Label 'Downpayment Percent';
        CaptionInstalments: Label 'Instalments';
        CaptionOpenOrder: Label 'Open Sales Order';
        CaptionOrderPaymentTerms: Label 'Order Payment Terms';
        CaptionPrepaymentPayTerms: Label 'Prepayment Payment Terms';
        CaptionPromptDownpayment: Label 'Prompt Downpayment';
        CaptionReserveItems: Label 'Reserve Items';
        DescCreationFeeItem: Label 'Service item to insert as fee upon creation of layaway';
        DescDownpayPct: Label 'Fixed downpayment percent. Is prefilled in dialog if used together';
        DescInstalments: Label 'Number of instalments for layaway payment. Set to 1 if no fixed periods';
        DescOpenSalesOrder: Label 'Opens Sales Order after posting.';
        DescOrderPaymentTerms: Label 'Payment Terms to use for the created order. Is used for filtering';
        DescPromptDownpayment: Label 'Prompt for downpayment percent before creation';
        DescReserveItems: Label 'Reserve items in created sales order. Errors if not possible';
        TextDownpaymentPctLead: Label 'Please specify a down payment % to be paid';
        TextDownpaymentPctTitle: Label 'Down payment';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());

        WorkflowConfig.AddLabel('DownpaymentPctTitle', TextDownpaymentPctTitle);
        WorkflowConfig.AddLabel('DownpaymentPctLead', TextDownpaymentPctLead);

        WorkflowConfig.AddBooleanParameter(ParamPromptDownpay_Name(), false, CaptionPromptDownpayment, DescPromptDownpayment);
        WorkflowConfig.AddDecimalParameter(ParamDownpayPerc_Name(), 0, CaptionDownpayPct, DescDownpayPct);
        WorkflowConfig.AddTextParameter(ParamFeeItem_Name(), '', CaptionCreationFeeItem, DescCreationFeeItem);
        WorkflowConfig.AddBooleanParameter(ParamReserveItems_Name(), true, CaptionReserveItems, DescReserveItems);
        WorkflowConfig.AddIntegerParameter(ParamInstalments_Name(), 0, CaptionInstalments, DescInstalments);
        WorkflowConfig.AddTextParameter(ParamOrderPaymentTerms_Name(), '', CaptionOrderPaymentTerms, DescOrderPaymentTerms);
        WorkflowConfig.AddTextParameter(ParamPrepayPaymentTerms_Name(), '', CaptionPrepaymentPayTerms, DescOrderPaymentTerms);
        WorkflowConfig.AddBooleanParameter(ParamOpenSalesOrder_Name(), false, CaptionOpenOrder, DescOpenSalesOrder);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionLayawayCreate.js###
'let main=async({workflow:t,parameters:n,popup:m,captions:a})=>{let e;if(n.PromptDownpayment){if(e=await m.numpad({title:a.DownpaymentPctTitle,caption:a.DownpaymentPctLead,value:n.DownpaymentPercent}),e==null)return}else e=n.DownpaymentPercent;await t.respond("CreateLayaway",{PercDownpayment:e})};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        FrontEnd.GetSession(POSSession);
        case Step of
            'CreateLayaway':
                OnActionCreateLayaway(Context, POSSession);
        end;
    end;

    local procedure OnActionCreateLayaway(Context: Codeunit "NPR POS JSON Helper"; var POSSession: Codeunit "NPR POS Session")
    var
        LayawayCreateBLogic: Codeunit "NPR POS Act.: Layaway Create-B";
        OpenSalesOrder: Boolean;
        ReserveItems: Boolean;
        DownpaymentPct: Decimal;
        Instalments: Integer;
        CreationFeeItemNo: Text;
        OrderPaymentTerms: Text;
        PrepaymentPaymentTerms: Text;
    begin
        DownpaymentPct := Context.GetDecimal('PercDownpayment');
        CreationFeeItemNo := Context.GetStringParameter(ParamFeeItem_Name());
        ReserveItems := Context.GetBooleanParameter(ParamReserveItems_Name());
        Instalments := Context.GetIntegerParameter(ParamInstalments_Name());
        OrderPaymentTerms := Context.GetStringParameter(ParamOrderPaymentTerms_Name());
        PrepaymentPaymentTerms := Context.GetStringParameter(ParamPrepayPaymentTerms_Name());
        OpenSalesOrder := Context.GetBooleanParameter(ParamOpenSalesOrder_Name());

        LayawayCreateBLogic.CreateLayaway(POSSession, DownpaymentPct, Instalments, CreationFeeItemNo, OrderPaymentTerms, PrepaymentPaymentTerms, ReserveItems, OpenSalesOrder);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParamFeeItem_Name():
                begin
                    Item.SetRange(Type, Item.Type::Service);
                    if Page.RunModal(0, Item) = Action::LookupOK then
                        POSParameterValue.Value := Item."No.";
                end;
            ParamOrderPaymentTerms_Name():
                begin
                    if Page.RunModal(0, PaymentTerms) = Action::LookupOK then
                        POSParameterValue.Value := PaymentTerms.Code;
                end;
            ParamPrepayPaymentTerms_Name():
                begin
                    if Page.RunModal(0, PaymentTerms) = Action::LookupOK then
                        POSParameterValue.Value := PaymentTerms.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            ParamFeeItem_Name():
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Item.Get(POSParameterValue.Value);
                    Item.TestField(Type, Item.Type::Service);
                end;
            ParamOrderPaymentTerms_Name():
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    PaymentTerms.Get(POSParameterValue.Value);
                end;
            ParamPrepayPaymentTerms_Name():
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    PaymentTerms.Get(POSParameterValue.Value);
                end;
        end;
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(Enum::"NPR POS Workflow"::LAYAWAY_CREATE));
    end;

    local procedure ParamPromptDownpay_Name(): Text[30]
    begin
        exit('PromptDownpayment');
    end;

    local procedure ParamDownpayPerc_Name(): Text[30]
    begin
        exit('DownpaymentPercent');
    end;

    local procedure ParamFeeItem_Name(): Text[30]
    begin
        exit('CreationFeeItemNo');
    end;

    local procedure ParamReserveItems_Name(): Text[30]
    begin
        exit('ReserveItems');
    end;

    local procedure ParamInstalments_Name(): Text[30]
    begin
        exit('Instalments');
    end;

    local procedure ParamOrderPaymentTerms_Name(): Text[30]
    begin
        exit('OrderPaymentTerms');
    end;

    local procedure ParamPrepayPaymentTerms_Name(): Text[30]
    begin
        exit('PrepaymentPaymentTerms');
    end;

    local procedure ParamOpenSalesOrder_Name(): Text[30]
    begin
        exit('OpenSalesOrder');
    end;
}
