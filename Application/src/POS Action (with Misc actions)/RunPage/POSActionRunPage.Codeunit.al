codeunit 6150802 "NPR POS Action: Run Page" implements "NPR IPOS Workflow"
{
    Access = Internal;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::RUNPAGE));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for running a page';
        ParamPageId_CaptionLbl: Label 'Page ID';
        ParamRunModal_CaptionLbl: Label 'RunModal';
        ParamTableId_CaptionLbl: Label 'Table ID';
        ParamTableView_CaptionLbl: Label 'Table View';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddIntegerParameter(ParamPageID_Name(), 0, ParamPageId_CaptionLbl, ParamPageId_CaptionLbl);
        WorkflowConfig.AddIntegerParameter(ParamTableID_Name(), 0, ParamTableId_CaptionLbl, ParamTableId_CaptionLbl);
        WorkflowConfig.AddTextParameter(ParamTableView_Name(), '', ParamTableView_CaptionLbl, ParamTableView_CaptionLbl);
        WorkflowConfig.AddBooleanParameter(ParamRunModal_Name(), false, ParamRunModal_CaptionLbl, ParamRunModal_CaptionLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRunPage.js###
        'let main=async({})=>await workflow.respond();'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogicRun: Codeunit "NPR POS Action: Run Page-B";
        RunModal: Boolean;
        PageId: Integer;
        TableId: Integer;
        TableView: Text;
    begin
        PageId := Context.GetIntegerParameter(ParamPageID_Name());
        RunModal := Context.GetBooleanParameter(ParamRunModal_Name());
        TableId := Context.GetIntegerParameter(ParamTableID_Name());
        TableView := Context.GetStringParameter(ParamTableView_Name());
        OnBeforeRunPage(PageId, RunModal, Sale);
        BusinessLogicRun.RunPage(PageId, RunModal, TableId, TableView);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupTableView(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSParameterTableIDValue: Record "NPR POS Parameter Value";
        TableID: Integer;
    begin
        if (POSParameterValue."Action Code" <> ActionCode()) or (POSParameterValue.Name <> 'TableView') or (POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text) then
            exit;
        POSParameterTableIDValue.SetRange("Table No.", POSParameterValue."Table No.");
        POSParameterTableIDValue.SetRange(Code, POSParameterValue.Code);
        POSParameterTableIDValue.SetRange(ID, POSParameterValue.ID);
        POSParameterTableIDValue.SetRange("Record ID", POSParameterValue."Record ID");
        POSParameterTableIDValue.SetRange(Name, ParamTableID_Name());
        if POSParameterTableIDValue.FindFirst() then
            if Evaluate(TableID, POSParameterTableIDValue.Value) then
                if TableID <> 0 then begin
                    POSParameterValue.Value := CopyStr(POSParameterValue.GetTableViewString(TableID, POSParameterValue.Value), 1, MaxStrLen(POSParameterValue.Value));
                    Handled := true;
                end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateTableView(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSParameterTableIDValue: Record "NPR POS Parameter Value";
        RecRef: RecordRef;
        TableID: Integer;
    begin
        if (POSParameterValue."Action Code" <> ActionCode()) or (POSParameterValue.Name <> 'TableView') or (POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text) then
            exit;
        if POSParameterValue.Value <> '' then begin
            POSParameterTableIDValue.SetRange("Table No.", POSParameterValue."Table No.");
            POSParameterTableIDValue.SetRange(Code, POSParameterValue.Code);
            POSParameterTableIDValue.SetRange(ID, POSParameterValue.ID);
            POSParameterTableIDValue.SetRange("Record ID", POSParameterValue."Record ID");
            POSParameterTableIDValue.SetRange(Name, ParamTableID_Name());
            if POSParameterTableIDValue.FindFirst() then
                if Evaluate(TableID, POSParameterTableIDValue.Value) then
                    if TableID <> 0 then begin
                        RecRef.Open(TableID);
                        RecRef.SetView(POSParameterValue.Value);
                        POSParameterValue.Value := CopyStr(RecRef.GetView(false), 1, MaxStrLen(POSParameterValue.Value));
                    end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunPage(PageId: Integer; RunModal: Boolean; Sale: Codeunit "NPR POS Sale")
    begin
    end;

    local procedure ParamTableID_Name(): Text[20]
    begin
        exit('TableID');
    end;

    local procedure ParamPageID_Name(): Text[20]
    begin
        exit('PageId');
    end;

    local procedure ParamTableView_Name(): Text[20]
    begin
        exit('TableView');
    end;

    local procedure ParamRunModal_Name(): Text[20]
    begin
        exit('RunModal');
    end;
}