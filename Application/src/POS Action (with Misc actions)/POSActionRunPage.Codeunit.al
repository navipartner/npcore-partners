codeunit 6150802 "NPR POS Action: Run Page"
{
    var
        ActionDescription: Label 'This is a built-in action for running a page';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('RUNPAGE');
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
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('1', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterIntegerParameter('PageId', 0);
            Sender.RegisterBooleanParameter('RunModal', false);
            Sender.RegisterIntegerParameter('TableID', 0);
            Sender.RegisterTextParameter('TableView', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        PageId: Integer;
        RunModal: Boolean;
        TableID: Integer;
        TableView: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        PageId := JSON.GetIntegerOrFail('PageId', StrSubstNo(ReadingErr, ActionCode()));
        RunModal := JSON.GetBooleanOrFail('RunModal', StrSubstNo(ReadingErr, ActionCode()));
        TableID := JSON.GetInteger('TableID');
        TableView := JSON.GetString('TableView');
        RunPage(PageId, RunModal, TableID, TableView);
        Handled := true;
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
        POSParameterTableIDValue.SetRange(Name, 'TableID');
        if POSParameterTableIDValue.FindFirst() then
            if Evaluate(TableID, POSParameterTableIDValue.Value) then
                if TableID <> 0 then begin
                    POSParameterValue.Value := POSParameterValue.GetTableViewString(TableID, POSParameterValue.Value);
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
            POSParameterTableIDValue.SetRange(Name, 'TableID');
            if POSParameterTableIDValue.FindFirst() then
                if Evaluate(TableID, POSParameterTableIDValue.Value) then
                    if TableID <> 0 then begin
                        RecRef.Open(TableID);
                        RecRef.SetView(POSParameterValue.Value);
                        POSParameterValue.Value := RecRef.GetView(false);
                    end;
        end;
    end;

    local procedure RunPage(PageId: Integer; RunModal: Boolean; TableID: Integer; TableView: Text)
    var
        RecRef: RecordRef;
        RecRefVar: Variant;
    begin
        if PageId = 0 then
            exit;

        if (TableID = 0) or (TableView = '') then begin
            if RunModal then
                PAGE.RunModal(PageId)
            else
                PAGE.Run(PageId);
        end else begin
            RecRef.Open(TableID);
            RecRef.SetView(TableView);
            RecRefVar := RecRef;
            if RunModal then
                PAGE.RunModal(PageId, RecRefVar)
            else
                PAGE.Run(PageId, RecRefVar);
        end;
    end;
}
