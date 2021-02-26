page 6151250 "NPR Retail Enter. Act - Ticket"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Issued Tickets"; Rec."Issued Tickets")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "NPR TM Ticket List";
                    ToolTip = 'Specifies the value of the Issued Tickets field';
                }
                field("Ticket Requests"; Rec."Ticket Requests")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Request";
                    ToolTip = 'Specifies the value of the Ticket Requests field';
                }
                field("Ticket Types"; Rec."Ticket Types")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "NPR TM Ticket Type";
                    ToolTip = 'Specifies the value of the Ticket Type field';
                }
                field("Ticket Admission BOM"; Rec."Ticket Admission BOM")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket BOM";
                    ToolTip = 'Specifies the value of the Ticket BOM field';
                }
                field("Ticket Schedules"; Rec."Ticket Schedules")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Schedules";
                    ToolTip = 'Specifies the value of the Ticket Schedules field';
                }
                field("Ticket Admissions"; Rec."Ticket Admissions")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Admissions";
                    ToolTip = 'Specifies the value of the Ticket Admissions field';
                }
            }
            cuegroup(Members)
            {
                Caption = 'Members';
                field(Control6; Rec.Members)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Members field';
                }
                field(Memberships; Rec.Memberships)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Memberships field';
                }
                field(Membercards; Rec.Membercards)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membercards field';
                }
            }

            cuegroup(Master)
            {
                Caption = 'Master';
                field(Items; Rec.Items)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Items field';
                }
                field(Contacts; Rec.Contacts)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contacts field';
                }
                field(Customers; Rec.Customers)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customers field';
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

