page 6060111 "TM Ticket Quick Statistics"
{
    // TM1.15/TSA/20160512  CASE 240863 POS Quick Statistics
    // TM1.19/TSA/20170202  CASE 265061 To be able to expose the page as a webservice and give the webserivce the ability to filter, GUIALLOWED was added in the OnOpenPage where default filter is set

    Caption = 'Ticket Quick Statistics';
    DataCaptionFields = "Admission Code";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    ShowFilter = false;
    SourceTable = "TM Admission Schedule Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Admission Start Date"; "Admission Start Date")
                {
                    ApplicationArea = All;
                }
                field("Admission Start Time"; "Admission Start Time")
                {
                    ApplicationArea = All;
                }
                field("Admission End Time"; "Admission End Time")
                {
                    ApplicationArea = All;
                }
                field("Open Reservations"; "Open Reservations")
                {
                    ApplicationArea = All;
                }
                field("Open Admitted"; "Open Admitted")
                {
                    ApplicationArea = All;
                }
                field(Departed; Departed)
                {
                    ApplicationArea = All;
                }
                field(AdmittedCount; AdmittedCount)
                {
                    ApplicationArea = All;
                    Caption = 'Admitted Today';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        AdmittedCount := "Open Admitted" + Departed;
    end;

    trigger OnOpenPage()
    begin

        if (not FilterIsSet) and (GuiAllowed) then
            GlobalAdmissionScheduleEntryFilter.SetFilter("Admission Start Date", '=%1', Today);

        FillRecordList();
    end;

    var
        AdmittedCount: Decimal;
        GlobalAdmissionScheduleEntryFilter: Record "TM Admission Schedule Entry";
        FilterIsSet: Boolean;

    procedure SetFilterRecord(var AdmissionScheduleEntryFilter: Record "TM Admission Schedule Entry")
    begin

        GlobalAdmissionScheduleEntryFilter.CopyFilters(AdmissionScheduleEntryFilter);
        FilterIsSet := true;
    end;

    local procedure FillRecordList()
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin

        AdmissionScheduleEntry.CopyFilters(GlobalAdmissionScheduleEntryFilter);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.SetFilter("Admission Is", '=%1', AdmissionScheduleEntry."Admission Is"::OPEN);
        if (AdmissionScheduleEntry.FindSet()) then begin
            repeat
                Rec.TransferFields(AdmissionScheduleEntry, true);
                Rec.Insert();
            until (AdmissionScheduleEntry.Next() = 0);
        end;
    end;
}

