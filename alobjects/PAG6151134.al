page 6151134 "TM Ticket Schedule Wizard"
{
    // TM90.1.46/TSA /20200320 CASE 397084 Initial Version

    Caption = 'Schedule';
    DelayedInsert = true;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "TM Admission Schedule";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6014401)
            {
                ShowCaption = false;
                field("Schedule Code";"Schedule Code")
                {
                    Visible = false;
                }
                field("Start Time";"Start Time")
                {
                    ShowMandatory = true;
                }
                field("Stop Time";"Stop Time")
                {
                    ShowMandatory = true;
                }
                field(Monday;Monday)
                {
                }
                field(Tuesday;Tuesday)
                {
                }
                field(Wednesday;Wednesday)
                {
                }
                field(Thursday;Thursday)
                {
                }
                field(Friday;Friday)
                {
                }
                field(Saturday;Saturday)
                {
                }
                field(Sunday;Sunday)
                {
                }
                field("Capacity Control";"Capacity Control")
                {
                }
                field("Max Capacity Per Sch. Entry";"Max Capacity Per Sch. Entry")
                {
                    Caption = 'Capacity';
                }
                field("Prebook From";"Prebook From")
                {
                }
                field("Prebook Is Required";"Prebook Is Required")
                {
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
          exit (false);

        ScheduleCode := IncStr (ScheduleCode);
        "Schedule Code" :=ScheduleCode;
    end;

    var
        ScheduleCode: Code[10];

    procedure GetSchedules(var AdmissionSchedule: Record "TM Admission Schedule" temporary)
    begin

        Rec.Reset;
        if (Rec.FindSet ()) then begin
          repeat
            AdmissionSchedule.TransferFields (Rec, true);
            AdmissionSchedule.Insert ();
          until (Rec.Next () = 0);
        end;
    end;

    procedure SetSchedules(var AdmissionSchedule: Record "TM Admission Schedule" temporary)
    begin
    end;
}

