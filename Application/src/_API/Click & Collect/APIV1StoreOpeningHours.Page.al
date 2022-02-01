page 6059807 "NPR APIV1 Store Opening Hours"
{
    APIGroup = 'clickAndCollect';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Store Opening Hours';
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    Editable = false;
    EntityName = 'storeOpeningHour';
    EntitySetName = 'storeOpeningHours';
    Extensible = false;
    PageType = API;
    SourceTable = "NPR APIV1 Store Opening Buffer";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(store; Rec.Store)
                {
                    Caption = 'Store Code', Locked = true;
                }
                field(calendarDate; Rec."Calendar Date")
                {
                    Caption = 'Date', Locked = true;
                }
                field(startTime; Rec."Start Time")
                {
                    Caption = 'Start Time', Locked = true;
                }
                field(endTime; Rec."End Time")
                {
                    Caption = 'End Time', Locked = true;
                }
                field(weekday; Rec.Weekday)
                {
                    Caption = 'Weekday', Locked = true;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not Loaded then begin
            LoadOpeningHours(Rec.GetFilter(Store), Rec.GetFilter("Calendar Date"));
            if not Rec.FindFirst() then
                exit(false);

            Loaded := true;
        end;

        exit(true);
    end;

    local procedure LoadOpeningHours(StoreFilter: Text; DateFilter: Text)
    var
        NpCsStore: Record "NPR NpCs Store";
        TempNpCsOpenHourCalendarEntry: Record "NPR NpCs Open. Hour Cal. Entry" temporary;
        StoreOpeningMgmt: Codeunit "NPR NpCs Store Open.Hours Mgt.";
        StartDate: Date;
        EndDate: Date;
    begin
        GetStartEndDate(DateFilter, StartDate, EndDate);
        if StoreFilter <> '' then
            NpCsStore.SetFilter(Code, StoreFilter);
        NpCsStore.SetFilter("Opening Hour Set", '<>%1', '');
        if NpCsStore.FindSet() then
            repeat
                Clear(StoreOpeningMgmt);
                StoreOpeningMgmt.Initialize(NpCsStore."Opening Hour Set", StartDate, EndDate);
                StoreOpeningMgmt.GetTempNpCsOpenHourCalendarEntry(TempNpCsOpenHourCalendarEntry);
                if TempNpCsOpenHourCalendarEntry.FindSet() then
                    repeat
                        InsertRecFromTempNpCsOpenHourCalendarEntry(NpCsStore, TempNpCsOpenHourCalendarEntry);
                    until TempNpCsOpenHourCalendarEntry.Next() = 0;
            until NpCsStore.Next() = 0;
    end;

    local procedure InsertRecFromTempNpCsOpenHourCalendarEntry(NpCsStore: Record "NPR NpCs Store"; var TempNpCsOpenHourCalendarEntry: Record "NPR NpCs Open. Hour Cal. Entry" temporary)
    begin
        Rec.Store := NpCsStore.Code;
        Rec."Calendar Date" := TempNpCsOpenHourCalendarEntry."Calendar Date";
        Rec."Start Time" := TempNpCsOpenHourCalendarEntry."Start Time";
        Rec."End Time" := TempNpCsOpenHourCalendarEntry."End Time";
        Rec.Insert();
    end;

    local procedure GetStartEndDate(DateFilter: Text; var StartDate: Date; var EndDate: Date)
    var
        DateRec: Record Date;
    begin
        if DateFilter = '' then
            exit;

        DateRec.SetRange("Period Type", DateRec."Period Type"::Date);
        DateRec.SetFilter("Period Start", DateFilter);
        DateRec.FindFirst();
        StartDate := DateRec."Period Start";
        DateRec.FindLast();
        EndDate := DateRec."Period Start";
    end;

    var
        Loaded: Boolean;
}
