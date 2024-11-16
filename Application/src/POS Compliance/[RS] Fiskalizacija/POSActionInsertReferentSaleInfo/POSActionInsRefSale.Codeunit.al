codeunit 6060159 "NPR POS Action - Ins. RefSale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert Reference Information for Return Sale';
        Prompt_EnterReferenceNo: Label 'Enter Reference No.';
        Prompt_EnterReferenceDate: Label 'Enter Reference Date';
        Prompt_EnterReferenceTime: Label 'Enter Reference Time';
        ReferenceTimeFormatErr: Label 'Invalid time format. Please enter time in HH:MM:SS format.';
        TitleLbl: Label 'Reference Information';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('ReferenceNoPrompt', Prompt_EnterReferenceNo);
        WorkflowConfig.AddLabel('ReferenceDatePrompt', Prompt_EnterReferenceDate);
        WorkflowConfig.AddLabel('ReferenceTimePrompt', Prompt_EnterReferenceTime);
        WorkflowConfig.AddLabel('ReferenceTimeFormatError', ReferenceTimeFormatErr);
        WorkflowConfig.AddLabel('title', TitleLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'AddPresetValuesToContext':
                AddPresetValuesToContext(Context);
            'InsertReferenceInfo':
                InsertReferenceInfo(Context, Sale);
        end;
    end;

    local procedure AddPresetValuesToContext(Context: Codeunit "NPR POS JSON Helper")
    begin
        Context.SetContext('defaultReferenceNo', 'XXXXXX-XXXXXX-00');
        Context.SetContext('defaultReferenceDate', Format(Today(), 0, 9));
        Context.SetContext('defaultReferenceTime', Format(Time()));
    end;

    local procedure InsertReferenceInfo(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        RSPOSSale: Record "NPR RS POS Sale";
        ReferenceDateJToken: JsonToken;
        ReferenceDate: Date;
        DateTimeFormatLbl: Label '%1T%2', Locked = true, Comment = '%1 = Date, %2 = Time';
    begin
        Sale.GetCurrentSale(POSSale);
        RSPOSSale."POS Sale SystemId" := POSSale.SystemId;
        RSPOSSale."Return Reference No." := CopyStr(Context.GetString('ReferenceNo'), 1, MaxStrLen(RSPOSSale."Return Reference No."));
        ReferenceDateJToken := Context.GetJToken('ReferenceDate');
        ReferenceDate := DT2Date(ReferenceDateJToken.AsValue().AsDateTime());
        RSPOSSale."Return Reference Date/Time" := CopyStr(StrSubstNo(DateTimeFormatLbl, Format(ReferenceDate, 10, '<Year4>-<Month,2>-<Day,2>').ToUpper(), Context.GetString('ReferenceTime')),
                                                        1, MaxStrLen(RSPOSSale."Return Reference Date/Time"));
        if not RSPOSSale.Insert() then
            RSPOSSale.Modify();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionInsRefSale.js###
        'const main = async ({workflow, context, parameters, captions}) => { await workflow.respond("AddPresetValuesToContext"); ReferenceNo = await popup.input({ title: captions.title, caption: captions.ReferenceNoPrompt, required: true, value: context.defaultReferenceNo}); if (ReferenceNo === null || ReferenceNo === context.defaultReferenceNo) return; ReferenceDate = await popup.datepad({ title: captions.title, caption: captions.ReferenceDatePrompt, required: true, value: context.defaultReferenceDate}); if (ReferenceDate === null) return; ReferenceTime = await popup.input({ title: captions.title, caption: captions.ReferenceTimePrompt, required: true, value: context.defaultReferenceTime}); if (ReferenceTime === null) return; if(!isValidTimeFormat(ReferenceTime)) return await popup.error(captions.ReferenceTimeFormatError); return await workflow.respond("InsertReferenceInfo", { ReferenceNo: ReferenceNo, ReferenceDate: ReferenceDate, ReferenceTime: ReferenceTime }); }; function isValidTimeFormat(time) { const timePattern = /^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/; return timePattern.test(time); }'
        );
    end;
}
