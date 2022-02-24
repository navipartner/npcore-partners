codeunit 6059789 "NPR POS Action Pay-in Payout" implements "NPR IPOS Workflow", "NPR POS IPaymentWFHandler"
{

    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action handles pay-in and pay-out';
        OptionStr: Label 'PayOut,PayIn', Locked = true;
        OptionCaptions: Label 'Pay Out,Pay In';
        OptionCaption: Label 'Type of payment';
        OptionDescription: Label 'Pay-in will add money to the till, Payout will subtract money from the till.';
        FixedAccountCaption: Label 'Preset account number';
        FixedAccountDesc: Label 'Specifies the account number to use, without prompting the user.';
        FixedReasonCaption: Label 'Preset reason code';
        FixedReasonDesc: Label 'Specifies the reason code to apply on the posted document.';
        LookupReasonCodeCaption: Label 'Lookup Reason Code';
        LookupReasonCodeDesc: Label 'Specifies if the Pay-In / Pay Out requires a user selected reason code.';
        AmountLabel: Label 'Enter Amount';
        DescriptionLabel: Label 'Enter Description';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('PayOption', OptionStr, 'PayOut', OptionCaption, OptionDescription, OptionCaptions);
        WorkflowConfig.AddTextParameter('FixedAccountCode', '', FixedAccountCaption, FixedAccountDesc);
        WorkflowConfig.AddTextParameter('FixedReasonCode', '', FixedReasonCaption, FixedReasonDesc);
        WorkflowConfig.AddBooleanParameter('LookupReasonCode', false, LookupReasonCodeCaption, LookupReasonCodeDesc);
        WorkflowConfig.AddLabel('amountLabel', AmountLabel);
        WorkflowConfig.AddLabel('descriptionLabel', DescriptionLabel);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'GetAccount':
                FrontEnd.WorkflowResponse(SelectAccount(Context));
            'GetReason':
                FrontEnd.WorkflowResponse(SelectReason());
            'HandlePayment':
                FrontEnd.WorkflowResponse(HandlePayment(Context, SaleLine));
        end;
    end;

    local procedure SelectAccount(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        GLAccount: Record "G/L Account";
        AccountNo: Code[20];
    begin
        Response.ReadFrom('{}');
        AccountNo := UpperCase(Context.GetStringParameter('FixedAccountCode'));

        if (AccountNo <> '') then
            GLAccount.Get(AccountNo)
        else
            if PAGE.RunModal(PAGE::"NPR TouchScreen: G/L Accounts", GLAccount) <> ACTION::LookupOK then
                Error('');

        Response.Add('accountNumber', GLAccount."No.");
        Response.Add('description', GLAccount.Name);
    end;

    local procedure SelectReason() Response: JsonObject
    var
        ReasonCode: Record "Reason Code";
    begin
        Response.ReadFrom('{}');

        if (Page.RunModal(0, ReasonCode) <> ACTION::LookupOK) then
            Clear(ReasonCode);

        Response.Add('reasonCode', ReasonCode.Code);
    end;

#pragma warning disable AA0139 // warning AA0139: Possible overflow
    local procedure HandlePayment(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line") Result: JsonObject
    var
        PayInPayOutMgr: Codeunit "NPR Pay-in Payout Mgr";
        Success: Boolean;
    begin
        Result.ReadFrom('{}');
        Success := PayInPayOutMgr.CreatePayInOutPayment(SaleLine, Context.GetIntegerParameter('PayOption'), Context.GetString('accountNumber'), Context.GetString('description'), Context.GetDecimal('amount'), Context.GetString('reasonCode'));

        Result.Add('endSale', false);
        Result.Add('success', Success);
    end;
#pragma warning restore

    procedure GetPaymentHandler(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::PAYMENT_PAYIN_PAYOUT))
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPayinPayout.Codeunit.js###
'let main=async({workflow:n,context:o,popup:a,parameters:t,captions:i})=>{const e={accountNumber:t.FixedAccountCode??"",description:"<Specify payout description>",amount:o.suggestedAmount??0,reasonCode:t.FixedReasonCode??""};return e.amount==0&&(e.amount=await a.numpad({caption:i.amountLabel,title:""}),e.amount===null||e.amount==0)?{success:!1,endSale:!1}:(e.accountNumber==""&&({accountNumber:e.accountNumber,description:e.description}=await n.respond("GetAccount")),e.description=await a.input({caption:"Enter Description",title:"",value:e.description}),e.description===null?{success:!1,endSale:!1}:((t.LookupReasonCode??!1)&&({reasonCode:e.reasonCode}=await n.respond("GetReason"),e.reasonCode===null&&(e.reasonCode="")),await n.respond("HandlePayment",e)))};'
        );
    end;
}
