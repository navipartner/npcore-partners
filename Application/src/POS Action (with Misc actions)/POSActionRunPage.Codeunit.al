codeunit 6150802 "NPR POS Action: Run Page"
{
    // NPR5.32/NPKNAV/20170526  CASE 270854 Transport NPR5.32 - 26 May 2017
    // NPR5.39/BR  /20180126  CASE 303616 Added TableID and TableView
    // NPR5.43/THRO/20180607  CASE 318038 Added Lookup and Validation for parameter TableView
    // NPR5.44/MMV /20180724 CASE 323068 Removed object table check. Was incompatible with extensions.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running a page';
        PageMissingError: Label 'That page was not found.';
        POSSetup: Codeunit "NPR POS Setup";

    local procedure ActionCode(): Text
    begin
        exit('RUNPAGE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterWorkflow(false);
                RegisterIntegerParameter('PageId', 0);
                RegisterBooleanParameter('RunModal', false);
                //-NPR5.39 [303616]
                RegisterIntegerParameter('TableID', 0);
                RegisterTextParameter('TableView', '');
                //+NPR5.39 [303616]
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        PageId: Integer;
        RunModal: Boolean;
        TableID: Integer;
        TableView: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);

        PageId := JSON.GetInteger('PageId', true);
        RunModal := JSON.GetBoolean('RunModal', true);
        //-NPR5.39 [303616]
        //RunPage(PageId,RunModal);
        TableID := JSON.GetInteger('TableID', false);
        TableView := JSON.GetString('TableView', false);
        RunPage(PageId, RunModal, TableID, TableView);
        //+NPR5.39 [303616]
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupTableView(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        POSParameterTableIDValue: Record "NPR POS Parameter Value";
        TableID: Integer;
    begin
        //-NPR5.43 [318038]
        if (POSParameterValue."Action Code" <> ActionCode) or (POSParameterValue.Name <> 'TableView') or (POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text) then
            exit;
        POSParameterTableIDValue.SetRange("Table No.", POSParameterValue."Table No.");
        POSParameterTableIDValue.SetRange(Code, POSParameterValue.Code);
        POSParameterTableIDValue.SetRange(ID, POSParameterValue.ID);
        POSParameterTableIDValue.SetRange("Record ID", POSParameterValue."Record ID");
        POSParameterTableIDValue.SetRange(Name, 'TableID');
        if POSParameterTableIDValue.FindFirst then
            if Evaluate(TableID, POSParameterTableIDValue.Value) then
                if TableID <> 0 then begin
                    POSParameterValue.Value := POSParameterValue.GetTableViewString(TableID, POSParameterValue.Value);
                    Handled := true;
                end;
        //+NPR5.43 [318038]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateTableView(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        POSParameterTableIDValue: Record "NPR POS Parameter Value";
        RecRef: RecordRef;
        TableID: Integer;
    begin
        //-NPR5.43 [318038]
        if (POSParameterValue."Action Code" <> ActionCode) or (POSParameterValue.Name <> 'TableView') or (POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text) then
            exit;
        if POSParameterValue.Value <> '' then begin
            POSParameterTableIDValue.SetRange("Table No.", POSParameterValue."Table No.");
            POSParameterTableIDValue.SetRange(Code, POSParameterValue.Code);
            POSParameterTableIDValue.SetRange(ID, POSParameterValue.ID);
            POSParameterTableIDValue.SetRange("Record ID", POSParameterValue."Record ID");
            POSParameterTableIDValue.SetRange(Name, 'TableID');
            if POSParameterTableIDValue.FindFirst then
                if Evaluate(TableID, POSParameterTableIDValue.Value) then
                    if TableID <> 0 then begin
                        RecRef.Open(TableID);
                        RecRef.SetView(POSParameterValue.Value);
                        POSParameterValue.Value := RecRef.GetView(false);
                    end;
        end;
        //+NPR5.43 [318038]
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure RunPage(PageId: Integer; RunModal: Boolean; TableID: Integer; TableView: Text)
    var
        "Object": Record "Object";
        RecRef: RecordRef;
        RecRefVar: Variant;
    begin
        if PageId = 0 then
            exit;

        //-NPR5.44 [323068]
        // Object.SETRANGE(Type,Object.Type::Page);
        // Object.SETRANGE(ID,PageId);
        // IF NOT Object.FINDSET THEN
        //    ERROR(PageMissingError);
        //+NPR5.44 [323068]

        //-NPR5.39 [303616]
        if (TableID = 0) or (TableView = '') then begin
            //+NPR5.39 [303616]
            if RunModal then
                PAGE.RunModal(PageId)
            else
                PAGE.Run(PageId);
            //-NPR5.39 [303616]
        end else begin
            RecRef.Open(TableID);
            RecRef.SetView(TableView);
            RecRefVar := RecRef;
            if RunModal then
                PAGE.RunModal(PageId, RecRefVar)
            else
                PAGE.Run(PageId, RecRefVar);
        end;
        //+NPR5.39 [303616]
    end;
}

