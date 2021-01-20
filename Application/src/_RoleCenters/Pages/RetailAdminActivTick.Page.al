page 6014692 "NPR Retail Admin Activ. - Tick"
{
    Caption = 'Retail Admin Activities - Tick';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Ticket Types"; Rec."Ticket Types")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Types field';
                }
                field("Ticket Admission BOMs"; Rec."Ticket Admission BOMs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Admission BOMs field';
                }
                field("Ticket Schedules"; Rec."Ticket Schedules")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Schedules field';
                }
                field("Ticket Admissions"; Rec."Ticket Admissions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Admissions field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;
}

