codeunit 6150656 "NPR POS Act:Chg.Actv.Event BL"
{
    Access = Internal;

    procedure SelectEventFromList(var EventNo: Code[20]): Boolean
    var
        Job: Record Job;
        EventList: Page "NPR Event List";
    begin
        FilterJobs(Job);
        EventList.SetTableView(Job);
        if Job.Get(EventNo) then
            EventList.SetRecord(Job);
        EventList.LookupMode := true;
        if EventList.RunModal() = ACTION::LookupOK then begin
            EventList.GetRecord(Job);
            EventNo := Job."No.";
            exit(EventNo <> '');
        end;
        exit(false);
    end;

    procedure UpdateCurrentEvent(POSSale: Codeunit "NPR POS Sale"; EventNo: Code[20]; UpdateRegister: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        SalePOS: Record "NPR POS Sale";
        IsAlreadyAssigned: Label 'The Event ''%1'' has already been set up as active event for %2=''%3''.', Comment = '%1 - event No., %2 - Sales Ticket No. field caption, %3 - Sales Ticket No.';
    begin
        POSSale.GetCurrentSale(SalePOS);
        if UpdateRegister then begin
            SalePOS.TestField("Register No.");
            POSUnit.Get(SalePOS."Register No.");
            POSUnit.SetActiveEventForCurrPOSUnit(EventNo);
        end;

        if SalePOS."Event No." = EventNo then
            Message(IsAlreadyAssigned, EventNo, SalePOS.FieldCaption("Sales Ticket No."), SalePOS."Sales Ticket No.")
        else begin
            SalePOS.Validate("Event No.", EventNo);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, true);
        end;
    end;

    local procedure FilterJobs(var Job: Record Job)
    begin
        Job.SetRange("NPR Event", true);
    end;

    local procedure ThisExtension(): Text
    begin
        exit('ACTIVE_EVENT');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtensions(DataSourceName: Text; Extensions: List of [Text])
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if POSDataMgt.POSDataSource_BuiltInSale() <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
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
        POSDataMgt: Codeunit "NPR POS Data Management";
        POSSale: Codeunit "NPR POS Sale";
    begin
        if (DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale()) or (ExtensionName <> ThisExtension()) then
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
}