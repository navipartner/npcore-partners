page 6151134 "NPR TM Ticket Schedule Wizard"
{
    // TM90.1.46/TSA /20200320 CASE 397084 Initial Version

    Caption = 'Schedule';
    DelayedInsert = true;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "NPR TM Admis. Schedule";
    SourceTableTemporary = true;
    usagecategory = None;

    layout
    {
        area(content)
        {
            repeater(Control6014401)
            {
                ShowCaption = false;
                field("Schedule Code"; "Schedule Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Schedule Code field';
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("Stop Time"; "Stop Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Stop Time field';
                }
                field(Monday; Monday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Monday field';
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Tuesday field';
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wednesday field';
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Thursday field';
                }
                field(Friday; Friday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Friday field';
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Saturday field';
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sunday field';
                }
                field("Capacity Control"; "Capacity Control")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Capacity Control field';
                }
                field("Max Capacity Per Sch. Entry"; "Max Capacity Per Sch. Entry")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Capacity';
                    ToolTip = 'Specifies the value of the Capacity field';
                }
                field("Prebook From"; "Prebook From")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook From field';
                }
                field("Prebook Is Required"; "Prebook Is Required")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Prebook Is Required field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        ScheduleCode := '000';
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

        if ("Start Time" = 0T) or ("Stop Time" = 0T) then
            exit(false);

        ScheduleCode := IncStr(ScheduleCode);
        "Schedule Code" := ScheduleCode;
    end;

    var
        ScheduleCode: Code[10];

    procedure GetSchedules(var AdmissionSchedule: Record "NPR TM Admis. Schedule" temporary)
    begin

        Rec.Reset;
        if (Rec.FindSet()) then begin
            repeat
                AdmissionSchedule.TransferFields(Rec, true);
                AdmissionSchedule.Insert();
            until (Rec.Next() = 0);
        end;
    end;

    procedure SetSchedules(var AdmissionSchedule: Record "NPR TM Admis. Schedule" temporary)
    begin
    end;
}

