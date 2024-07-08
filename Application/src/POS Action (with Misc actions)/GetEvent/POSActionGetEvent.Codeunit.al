codeunit 6060160 "NPR POS Action: Get Event" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Get event from Event Management module';
        EnterEventTxt: Label 'Enter Event No.';
        ParamDialogType_CaptionLbl: Label 'Dialog Type';
        ParamDialogType_DescLbl: Label 'Specifies how to input event no.';
        ParamDialogTypeOptionsLbl: Label 'TextField,List', Locked = true;
        ParamDialogTypeOptions_CaptionLbl: Label 'TextField,List';
        ParamGetEventLines_CaptionLbl: Label 'Get Event Lines';
        ParamGetEventLines_DescLbl: Label 'Specifies which event lines will be loaded into POS';
        ParamGetEventLinesOptionsLbl: Label 'Invoiceable,Selection,None', Locked = true;
        ParamGetEventLinesOptions_CaptionLbl: Label 'Invoiceable,Selection,None';
        ParamAddNewLinesToTask_CaptionLbl: Label 'Add New Lines to Task';
        ParamAddNewLinesToTask_DescLbl: Label 'Specifies how will event task be chosen when new lines will be created in POS (ones that don''t exist on event)';
        ParamAddNewLinesToTaskOptionsLbl: Label 'Default,First,Selection', Locked = true;
        ParamAddNewLinesToTaskOptions_CaptionLbl: Label 'Default,First,Selection';
        ParamLookAheadPeriod_CaptionLbl: Label 'Look-ahead Period (Days)';
        ParamLookAheadPeriod_DescLbl: Label 'Number of days ahead to show the future events for. System will apply the filter to the "Starting Date" field. Set the parameter to zero, if you do not want to enforce any starting date limitations.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter(
                       'DialogType',
                       ParamDialogTypeOptionsLbl,
#pragma warning disable AA0139
                       SelectStr(1, ParamDialogTypeOptionsLbl),
#pragma warning restore 
                       ParamDialogType_CaptionLbl,
                       ParamDialogType_DescLbl,
                       ParamDialogTypeOptions_CaptionLbl);
        WorkflowConfig.AddOptionParameter(
                       'GetEventLines',
                       ParamGetEventLinesOptionsLbl,
#pragma warning disable AA0139
                       SelectStr(1, ParamGetEventLinesOptionsLbl),
#pragma warning restore 
                       ParamGetEventLines_CaptionLbl,
                       ParamGetEventLines_DescLbl,
                       ParamGetEventLinesOptions_CaptionLbl);
        WorkflowConfig.AddOptionParameter(
                       'AddNewLinesToTask',
                       ParamAddNewLinesToTaskOptionsLbl,
#pragma warning disable AA0139
                       SelectStr(1, ParamAddNewLinesToTaskOptionsLbl),
#pragma warning restore 
                       ParamAddNewLinesToTask_CaptionLbl,
                       ParamAddNewLinesToTask_DescLbl,
                       ParamAddNewLinesToTaskOptions_CaptionLbl);
        WorkflowConfig.AddIntegerParameter('LookAheadPeriod', 0, ParamLookAheadPeriod_CaptionLbl, ParamLookAheadPeriod_DescLbl);
        WorkflowConfig.AddLabel('Prompt', EnterEventTxt);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'select_event_from_list':
                FrontEnd.WorkflowResponse(SelectEvent(Context));
            'import_event':
                ImportEvent(Context, Sale, SaleLine);
        end;
    end;

    local procedure SelectEvent(Context: Codeunit "NPR POS JSON Helper"): Code[20]
    var
        LookAheadPeriodDays: Integer;
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
    begin
        LookAheadPeriodDays := Context.GetIntegerParameter('LookAheadPeriod');
        exit(POSActionGetEventB.SelectEvent(LookAheadPeriodDays));
    end;

    procedure ImportEvent(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        GetEventLinesOption: Option;
        AddNewLinesToTaskOption: Option;
        EventNo: Code[20];
        POSActionGetEventB: Codeunit "NPR POS Action: Get Event B";
    begin
        GetEventLinesOption := Context.GetIntegerParameter('GetEventLines');
        AddNewLinesToTaskOption := Context.GetIntegerParameter('AddNewLinesToTask');
        EventNo := CopyStr(Context.GetString('selected_eventno'), 1, MaxStrLen(EventNo));
        POSActionGetEventB.ImportEvent(Sale, SaleLine, EventNo, GetEventLinesOption, AddNewLinesToTaskOption);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionGetEvent.js###
'let main=async({workflow:n,captions:i,parameters:t,popup:a})=>{let e;switch(t.DialogType.toInt()){case t.DialogType.TextField:e=await a.input({caption:i.Prompt});break;case t.DialogType.List:e=await n.respond("select_event_from_list");break}return e==null?" ":await n.respond("import_event",{selected_eventno:e})};'
        );
    end;
}
