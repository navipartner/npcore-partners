page 6060111 "NPR TM Ticket Quick Stats"
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
    SourceTable = "NPR TM Admis. Schedule Entry";
    SourceTableTemporary = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Admission Start Date"; Rec."Admission Start Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Start Date field';
                }
                field("Admission Start Time"; Rec."Admission Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Start Time field';
                }
                field("Admission End Time"; Rec."Admission End Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission End Time field';
                }
                field("Open Reservations"; Rec."Open Reservations")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Open Reservations field';
                }
                field("Open Admitted"; Rec."Open Admitted")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Open Admitted field';
                }
                field(Departed; Rec.Departed)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Departed field';
                }
                field(AdmittedCount; AdmittedCount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Admitted Today';
                    ToolTip = 'Specifies the value of the Admitted Today field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        AdmittedCount := Rec."Open Admitted" + Rec.Departed;
    end;

    trigger OnOpenPage()
    begin

        if (not FilterIsSet) and (GuiAllowed) then
            GlobalAdmissionScheduleEntryFilter.SetFilter("Admission Start Date", '=%1', Today);

        FillRecordList();
    end;

    var
        AdmittedCount: Decimal;
        GlobalAdmissionScheduleEntryFilter: Record "NPR TM Admis. Schedule Entry";
        FilterIsSet: Boolean;

    procedure SetFilterRecord(var AdmissionScheduleEntryFilter: Record "NPR TM Admis. Schedule Entry")
    begin

        GlobalAdmissionScheduleEntryFilter.CopyFilters(AdmissionScheduleEntryFilter);
        FilterIsSet := true;
    end;

    local procedure FillRecordList()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
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

