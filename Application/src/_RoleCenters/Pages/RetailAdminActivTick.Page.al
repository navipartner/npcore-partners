page 6014692 "NPR Retail Admin Activ. - Tick"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - Tick';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Ticket Types"; "Ticket Types")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Types field';
                }
                field("Ticket Admission BOMs"; "Ticket Admission BOMs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Admission BOMs field';
                }
                field("Ticket Schedules"; "Ticket Schedules")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Schedules field';
                }
                field("Ticket Admissions"; "Ticket Admissions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Admissions field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

