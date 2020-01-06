codeunit 6060161 "POS Action - Chg. Active Event"
{
    // NPR5.52/ALPO/20190926 CASE 368673 New POS action to change current event on POS register with dimension update on both POS register and current sale


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Set an event from Event Management module as active for current POS register and sale';
        EventNoLbl: Label 'Event No.';
        DialogType: Option TextField,List;
        IsAlreadyAssigned: Label 'The Event ''%1'' has already been set up as active event for %2=''%3''.';
        IncorrecFunctionCall: Label 'Incorrect function %1 call: must be called with a temporary record as parameter.\This indicates a programming bug, not a user error. Please contact system vendor.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('textfield', 'if (param.DialogType == param.DialogType["TextField"]) {input({title: labels.Title, caption: context.CaptionText, value: ""}).cancel(abort);}');
                RegisterWorkflowStep('GetEventID', ' {respond();}');
                RegisterOptionParameter('DialogType', 'TextField,List', 'List');
                RegisterWorkflow(false);
                RegisterDataSourceBinding(ThisDataSource);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'Title', EventNoLbl);
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    local procedure ActionCode(): Text
    begin
        exit('SET_ACTIVE_EVENT');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        CashRegister: Record Register;
        SalePOS: Record "Sale POS";
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        EventNo: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        DialogType := JSON.GetIntegerParameter('DialogType', true);
        if not (DialogType in [DialogType::TextField, DialogType::List]) then
            DialogType := DialogType::List;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Register No.");
        CashRegister.Get(SalePOS."Register No.");

        case DialogType of
            DialogType::TextField:
                EventNo := CopyStr(GetInput(JSON, 'textfield'), 1, MaxStrLen(EventNo));
            DialogType::List:
                begin
                    EventNo := CashRegister."Active Event No.";
                    if not SelectEventFromList(EventNo) then
                        Error('');
                end;
        end;

        UpdateCurrentEvent(Context, POSSession, FrontEnd, EventNo);
    end;

    local procedure "---DataSourceExtension"()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin
        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin
        exit('ACTIVE_EVENT');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: DotNet npNetList_Of_T)
    begin
        if ThisDataSource <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: DotNet npNetDataSource0; var Handled: Boolean; Setup: Codeunit "POS Setup")
    var
        DataType: DotNet npNetDataType;
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        DataSource.AddColumn(DataSourceField_EventNo(), DataSourceField_EventNo(), DataType.String, false);
        DataSource.AddColumn(DataSourceField_EventDescription(), DataSourceField_EventDescription(), DataType.String, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: DotNet npNetDataRow0; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        CashRegister: Record Register;
        Job: Record Job;
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not CashRegister.Get(SalePOS."Register No.") then
            CashRegister.Init;
        if not Job.Get(CashRegister."Active Event No.") then
            Job.Init;
        DataRow.Add(DataSourceField_EventNo(), CashRegister."Active Event No.");
        DataRow.Add(DataSourceField_EventDescription(), Job.Description);
    end;

    local procedure DataSourceField_EventNo(): Text
    begin
        exit('EventNo');
    end;

    local procedure DataSourceField_EventDescription(): Text
    begin
        exit('EventDescription');
    end;

    local procedure "---Auxiliary"()
    begin
    end;

    local procedure GetInput(JSON: Codeunit "POS JSON Management"; Path: Text): Text
    begin
        if not JSON.SetScopeRoot(false) then
            exit('');
        if not JSON.SetScope('$' + Path, false) then
            exit('');
        exit(JSON.GetString('input', false));
    end;

    local procedure SelectEventFromList(var EventNo: Code[20]): Boolean
    var
        Job: Record Job;
        EventList: Page "Event List";
    begin
        FilterJobs(Job);
        if EventNo <> '' then begin
            Job."No." := EventNo;
            if Job.Find then;
        end;
        EventList.SetTableView(Job);
        EventList.SetRecord(Job);
        EventList.LookupMode := true;
        if EventList.RunModal = ACTION::LookupOK then begin
            EventList.GetRecord(Job);
            EventNo := Job."No.";
            exit(EventNo <> '');
        end;
        exit(false);
    end;

    local procedure UpdateCurrentEvent(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; EventNo: Code[20])
    var
        NewDimSetEntryTmp: Record "Dimension Set Entry" temporary;
        OldDimSetEntryTmp: Record "Dimension Set Entry" temporary;
        Job: Record Job;
        CashRegister: Record Register;
        SalePOS: Record "Sale POS";
        DimMgt: Codeunit DimensionManagement;
        POSSale: Codeunit "POS Sale";
        OldDimeSetID: Integer;
    begin
        FilterJobs(Job);
        Job."No." := EventNo;
        Job.Find;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Register No.");
        CashRegister.Get(SalePOS."Register No.");
        if CashRegister."Active Event No." = EventNo then
            Error(IsAlreadyAssigned, EventNo, CashRegister.FieldCaption("Register No."), CashRegister."Register No.");

        //Set active event on cash register
        GetDimSetEntryFromDefDim(OldDimSetEntryTmp, DATABASE::Register, CashRegister."Register No.");
        CashRegister.Validate("Active Event No.", EventNo);
        CashRegister.Modify;
        GetDimSetEntryFromDefDim(NewDimSetEntryTmp, DATABASE::Register, CashRegister."Register No.");

        //Update current sale dimensions from cash register (update only those dimension values which has been actually changed on the cash register)
        OldDimeSetID := SalePOS."Dimension Set ID";
        SalePOS."Dimension Set ID" :=
          DimMgt.GetDeltaDimSetID(SalePOS."Dimension Set ID", DimMgt.GetDimensionSetID(NewDimSetEntryTmp), DimMgt.GetDimensionSetID(OldDimSetEntryTmp));
        DimMgt.UpdateGlobalDimFromDimSetID(SalePOS."Dimension Set ID", SalePOS."Shortcut Dimension 1 Code", SalePOS."Shortcut Dimension 2 Code");
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, true);
        if SalePOS.SalesLinesExist and (OldDimeSetID <> SalePOS."Dimension Set ID") then
            SalePOS.UpdateAllLineDim(SalePOS."Dimension Set ID", OldDimeSetID);

        POSSession.RequestRefreshData();
    end;

    local procedure FilterJobs(var Job: Record Job)
    begin
        Job.SetRange("Event", true);
    end;

    local procedure GetDimSetEntryFromDefDim(var DimSetEntry: Record "Dimension Set Entry"; TableID: Integer; No: Code[20])
    var
        DefaultDim: Record "Default Dimension";
    begin
        if not DimSetEntry.IsTemporary then
            Error(IncorrecFunctionCall, 'CU6060161.GetDimSEtEntryFromDefDim');

        DefaultDim.SetRange("Table ID", TableID);
        DefaultDim.SetRange("No.", No);
        DefaultDim.SetFilter("Dimension Code", '<>%1', '');
        DefaultDim.SetFilter("Dimension Value Code", '<>%1', '');
        if DefaultDim.FindSet then
            repeat
                DimSetEntry.Init;
                DimSetEntry."Dimension Code" := DefaultDim."Dimension Code";
                DimSetEntry.Validate("Dimension Value Code", DefaultDim."Dimension Value Code");
                DimSetEntry.Insert;
            until DefaultDim.Next = 0;
    end;
}

