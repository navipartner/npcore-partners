page 6014570 "NPR Retail Admin Activities"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(POS)
            {
                Caption = 'POS';
                field("User Setups"; "User Setups")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Setups field';
                }
                field(Salespersons; Salespersons)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salespersons field';
                }
                field("POS Stores"; "POS Stores")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Stores field';
                }
                field("POS Units"; "POS Units")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Units field';
                }
                field("Cash Registers"; "Cash Registers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Registers field';
                }
                field("POS Payment Bins"; "POS Payment Bins")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bins field';
                }
                field("POS Payment Methods"; "POS Payment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Methods field';
                }
                field("POS Posting Setups"; "POS Posting Setups")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Posting Setups field';
                }
            }
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
            cuegroup(Members)
            {
                Caption = 'Members';
                field("Membership Setup"; "Membership Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Setup field';
                }
                field("Membership Sales Setup"; "Membership Sales Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Sales Setup field';
                }
                field("Member Alteration"; "Member Alteration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Alteration field';
                }
                field("Member Community"; "Member Community")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Community field';
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

