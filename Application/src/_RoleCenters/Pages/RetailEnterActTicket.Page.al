page 6151250 "NPR Retail Enter. Act - Ticket"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";

    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Issued Tickets"; "Issued Tickets")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issued Tickets field';
                }
                field("Ticket Requests"; "Ticket Requests")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Request";
                    ToolTip = 'Specifies the value of the Ticket Requests field';
                }
                field("Ticket Schedules"; "Ticket Schedules")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Schedules";
                    ToolTip = 'Specifies the value of the Ticket Schedules field';
                }
                field("Ticket Admissions"; "Ticket Admissions")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Admissions";
                    ToolTip = 'Specifies the value of the Ticket Admissions field';
                }
            }
            cuegroup(Members)
            {
                Caption = 'Members';
                field(Control6; Members)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Members field';
                }
                field(Memberships; Memberships)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Memberships field';
                }
                field(Membercards; Membercards)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membercards field';
                }
            }

            cuegroup(Master)
            {
                Caption = 'Master';
                field(Items; Items)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Items field';
                }
                field(Contacts; Contacts)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contacts field';
                }
                field(Customers; Customers)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customers field';
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

