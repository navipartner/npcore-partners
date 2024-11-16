codeunit 6185095 "NPR POS Action: SI Ins RetSale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert Reference Information for Return Sale';
        Prompt_EnterReturnReceiptNo: Label 'Enter Return Receipt No.';
        Prompt_EnterReturnBusPremiseId: Label 'Enter Return Receipt Business Premise ID';
        Prompt_EnterReturnCashRegId: Label 'Enter Return Receipt Cash Register ID';
        Prompt_EnterReturnReceiptDate: Label 'Enter Return Receipt Date';
        Prompt_EnterReturnReceiptTime: Label 'Enter Return Receipt Time';
        ReturnTimeFormatError: Label 'Invalid time format. Please enter time in HH:MM:SS format.';
        TitleLbl: Label 'Return Receipt Information';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('ReturnReceiptNoPrompt', Prompt_EnterReturnReceiptNo);
        WorkflowConfig.AddLabel('ReturnBusinessPremiseIdPrompt', Prompt_EnterReturnBusPremiseId);
        WorkflowConfig.AddLabel('ReturnCashRegisterIdPrompt', Prompt_EnterReturnCashRegId);
        WorkflowConfig.AddLabel('ReturnDatePrompt', Prompt_EnterReturnReceiptDate);
        WorkflowConfig.AddLabel('ReturnTimePrompt', Prompt_EnterReturnReceiptTime);
        WorkflowConfig.AddLabel('ReturnTimeFormatError', ReturnTimeFormatError);
        WorkflowConfig.AddLabel('title', TitleLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'AddPresetValuesToContext':
                AddPresetValuesToContext(Context);
            'InsertReturnInfo':
                InsertReturnInfo(Context, Sale);
        end;
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper")
    begin
        Context.SetContext('defaultReturnDate', Format(Today(), 0, 9));
        Context.SetContext('defaultReturnTime', Format(Time(), 8, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'));
    end;

    local procedure InsertReturnInfo(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        SIPOSSale: Record "NPR SI POS Sale";
        ReturnDateJToken: JsonToken;
        ReturnDate: Date;
        DateTimeFormatLbl: Label '%1T%2', Locked = true, Comment = '%1 = Date, %2 = Time';
    begin
        Sale.GetCurrentSale(POSSale);
        SIPOSSale."POS Sale SystemId" := POSSale.SystemId;
        SIPOSSale."SI Return Receipt No." := CopyStr(Context.GetString('ReturnReceiptNo'), 1, MaxStrLen(SIPOSSale."SI Return Receipt No."));
        SIPOSSale."SI Return Bus. Premise ID" := CopyStr(Context.GetString('ReturnBusinessPremiseId'), 1, MaxStrLen(SIPOSSale."SI Return Bus. Premise ID"));
        SIPOSSale."SI Return Cash Register ID" := CopyStr(Context.GetString('ReturnCashRegisterId'), 1, MaxStrLen(SIPOSSale."SI Return Cash Register ID"));
        ReturnDateJToken := Context.GetJToken('ReturnDate');
        ReturnDate := DT2Date(ReturnDateJToken.AsValue().AsDateTime());

        SIPOSSale."SI Return Receipt DateTime" := CopyStr(StrSubstNo(DateTimeFormatLbl, Format(ReturnDate, 10, '<Year4>-<Month,2>-<Day,2>'), Context.GetString('ReturnTime')),
                                                        1, MaxStrLen(SIPOSSale."SI Return Receipt DateTime"));
        if not SIPOSSale.Insert() then
            SIPOSSale.Modify();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSIInsRetSale.js###
        'const main = async ({workflow, context, parameters, captions}) => { await workflow.respond("AddPresetValuesToContext"); ReturnReceiptNo = await popup.input({ title: captions.title, caption: captions.ReturnReceiptNoPrompt, required: true}); if (ReturnReceiptNo === null) return; ReturnBusinessPremiseId = await popup.input({ title: captions.title, caption: captions.ReturnBusinessPremiseIdPrompt, required: true}); if (ReturnBusinessPremiseId === null) return; ReturnCashRegisterId = await popup.input({ title: captions.title, caption: captions.ReturnCashRegisterIdPrompt, required: true}); if (ReturnCashRegisterId === null) return; ReturnDate = await popup.datepad({ title: captions.title, caption: captions.ReturnDatePrompt, required: true, value: context.defaultReturnDate}); if (ReturnDate === null) return; ReturnTime = await popup.input({ title: captions.title, caption: captions.ReturnTimePrompt, required: true, value: context.defaultReturnTime}); if (ReturnTime === null) return; if(!isValidTimeFormat(ReturnTime)) return await popup.error(captions.ReturnTimeFormatError); return await workflow.respond("InsertReturnInfo", { ReturnReceiptNo: ReturnReceiptNo, ReturnBusinessPremiseId: ReturnBusinessPremiseId, ReturnCashRegisterId: ReturnCashRegisterId, ReturnDate: ReturnDate, ReturnTime: ReturnTime }); }; function isValidTimeFormat(time) { const timePattern = /^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/; return timePattern.test(time); }'
    )
    end;
}