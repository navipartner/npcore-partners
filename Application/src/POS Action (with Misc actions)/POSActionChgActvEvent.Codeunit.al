codeunit 6060161 "NPR POS Action: Chg.Actv.Event"
{
    var
        ActionDescription: Label 'Set an event from Event Management module as active for current POS register and sale';
        EventNoLbl: Label 'Event No.';
        DialogType: Option TextField,List;
        IsAlreadyAssigned: Label 'The Event ''%1'' has already been set up as active event for %2=''%3''.';
        IncorrecFunctionCall: Label 'Incorrect function %1 call: must be called with a temporary record as parameter.\This indicates a programming bug, not a user error. Please contact system vendor.';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('textfield',
              'if ((!param.ClearEvent) && (param.DialogType == param.DialogType["TextField"])) ' +
              '{input({title: labels.Title, caption: context.CaptionText, value: ""}).cancel(abort);}');
            Sender.RegisterWorkflowStep('ProcessChange', ' {respond();}');
            Sender.RegisterOptionParameter('DialogType', 'TextField,List', 'List');
            Sender.RegisterBooleanParameter('ClearEvent', false);
            Sender.RegisterBooleanParameter('OnlyCurrentSale', false);
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding(ThisDataSource());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'Title', EventNoLbl);
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.3');
    end;

    local procedure ActionCode(): Text
    begin
        exit('SET_ACTIVE_EVENT');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        EventNo: Code[20];
        ClearEvent: Boolean;
        OnlyCurrentSale: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        DialogType := JSON.GetIntegerParameterOrFail('DialogType', ActionCode());
        if not (DialogType in [DialogType::TextField, DialogType::List]) then
            DialogType := DialogType::List;
        ClearEvent := JSON.GetBooleanParameter('ClearEvent');
        if ClearEvent then
            EventNo := '';
        OnlyCurrentSale := JSON.GetBooleanParameter('OnlyCurrentSale');

        if not ClearEvent then begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SalePOS.TestField("Register No.");
            POSUnit.get(SalePOS."Register No.");

            case DialogType of
                DialogType::TextField:
                    EventNo := CopyStr(GetInput(JSON, 'textfield'), 1, MaxStrLen(EventNo));
                DialogType::List:
                    begin
                        EventNo := POSUnit.FindActiveEventFromCurrPOSUnit();
                        if not SelectEventFromList(EventNo) then
                            Error('');
                    end;
            end;
        end;

        UpdateCurrentEvent(Context, POSSession, FrontEnd, EventNo, not OnlyCurrentSale);
    end;

    local procedure ThisDataSource(): Text
    begin
        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin
        exit('ACTIVE_EVENT');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    begin
        if ThisDataSource() <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        DataSource.AddColumn(DataSourceField_EventNo(), DataSourceField_EventNo(), DataType::String, false);
        DataSource.AddColumn(DataSourceField_EventDescription(), DataSourceField_EventDescription(), DataType::String, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Job: Record Job;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not Job.Get(SalePOS."Event No.") then
            Job.Init();
        DataRow.Add(DataSourceField_EventNo(), SalePOS."Event No.");
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

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        if not JSON.SetScope('$' + Path) then
            exit('');
        exit(JSON.GetString('input'));
    end;

    local procedure SelectEventFromList(var EventNo: Code[20]): Boolean
    var
        Job: Record Job;
        EventList: Page "NPR Event List";
    begin
        FilterJobs(Job);
        if EventNo <> '' then begin
            Job."No." := EventNo;
            if Job.Find() then;
        end;
        EventList.SetTableView(Job);
        EventList.SetRecord(Job);
        EventList.LookupMode := true;
        if EventList.RunModal() = ACTION::LookupOK then begin
            EventList.GetRecord(Job);
            EventNo := Job."No.";
            exit(EventNo <> '');
        end;
        exit(false);
    end;

    local procedure UpdateCurrentEvent(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; EventNo: Code[20]; UpdateRegister: Boolean)
    var
        Job: Record Job;
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        DimMgt: Codeunit DimensionManagement;
        POSSale: Codeunit "NPR POS Sale";
    begin
        if EventNo <> '' then begin
            FilterJobs(Job);
            Job."No." := EventNo;
            Job.Find();
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if UpdateRegister then begin
            SalePOS.TestField("Register No.");
            POSUnit.Get(SalePOS."Register No.");
            POSUnit.SetActiveEventForCurrPOSUnit(EventNo);
        end;

        if SalePOS."Event No." = EventNo then
            Error(IsAlreadyAssigned, EventNo, SalePOS.FieldCaption("Sales Ticket No."), SalePOS."Sales Ticket No.");
        SalePOS.Validate("Event No.", EventNo);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, true);
        POSSession.RequestRefreshData();

    end;

    local procedure FilterJobs(var Job: Record Job)
    begin
        Job.SetRange("NPR Event", true);
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
        if DefaultDim.FindSet() then
            repeat
                DimSetEntry.Init();
                DimSetEntry."Dimension Code" := DefaultDim."Dimension Code";
                DimSetEntry.Validate("Dimension Value Code", DefaultDim."Dimension Value Code");
                DimSetEntry.Insert();
            until DefaultDim.Next() = 0;
    end;
}

