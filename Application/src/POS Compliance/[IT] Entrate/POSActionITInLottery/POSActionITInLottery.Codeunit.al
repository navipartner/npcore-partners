codeunit 6184738 "NPR POS Action: IT In. Lottery" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert a Customer''s Lottery Code';
        Prompt_EnterCustomersLotteryCode: Label 'Enter Customer''s Lottery Code';
        TitleLbl: Label 'Lottery Code';
        LotteryCodeFormatErr: Label 'The Lottery Code you''ve inserted contains special characters. Please insert a Lottery Code using only alphanumeric characters (A-Z, a-z, 0-9)';
        LotteryCodeLengthErr: Label 'Lottery Code must contain minimum of 2 characters and a maximum of 16. Please try again.';
        CannotInsertLotteryCodeErr: Label 'You cannot use a Lottery Code for the current sale. Amount must be at least 1 EUR';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('lotteryCodePrompt', Prompt_EnterCustomersLotteryCode);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('codeFormatError', LotteryCodeFormatErr);
        WorkflowConfig.AddLabel('codeLengthError', LotteryCodeLengthErr);
        WorkflowConfig.AddLabel('recAmountError', CannotInsertLotteryCodeErr);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'SetupWorkflow':
                SetupWorkflowContext(Context, Sale);
            'InsertCustomerLotteryCode':
                InsertCustomerLotteryCodeOnPOSSale(Context, Sale);
        end;
    end;

    local procedure InsertCustomerLotteryCodeOnPOSSale(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        ITPOSSale: Record "NPR IT POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        ITPOSSale."POS Sale SystemId" := POSSale.SystemId;
        ITPOSSale."IT Customer Lottery Code" := CopyStr(Context.GetString('CustomerLotteryCode'), 1, MaxStrLen(ITPOSSale."IT Customer Lottery Code"));
        if not ITPOSSale.Insert() then
            ITPOSSale.Modify();
    end;

    local procedure SetupWorkflowContext(var Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        POSSale.CalcFields("Amount Including VAT");
        Context.SetContext('ReceiptAmount', POSSale."Amount Including VAT");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionITInLottery.js###
        'let main = async ({ workflow, context, captions, parameters }) => { let CustomerLotteryCode; await workflow.respond("SetupWorkflow"); if(context.ReceiptAmount < 1) return await popup.error(captions.recAmountError); CustomerLotteryCode = await popup.input({ title: captions.title, caption: captions.lotteryCodePrompt }); if (CustomerLotteryCode === null || CustomerLotteryCode === "") return; if (!CheckCodeFormat(CustomerLotteryCode)) return await popup.error(captions.codeFormatError); if (!CheckCodeLength(CustomerLotteryCode)) return await popup.error(captions.codeLengthError); return await workflow.respond("InsertCustomerLotteryCode", { CustomerLotteryCode: CustomerLotteryCode }); }; function CheckCodeFormat(lotteryCode) { var pattern = /^[A-Za-z0-9]+$/; return pattern.test(lotteryCode); } function CheckCodeLength(lotteryCode) { return lotteryCode.length >= 2 && lotteryCode.length <= 15; }'
        )
    end;
}