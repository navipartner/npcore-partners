page 6014570 "NPR Retail Admin Activities"
{
    Caption = 'Retail Admin Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(POS)
            {
                Caption = 'POS';
                field("User Setups"; Rec."User Setups")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Setups field';
                }
                field(Salespersons; Rec.Salespersons)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salespersons field';
                }
                field("POS Stores"; Rec."POS Stores")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Stores field';
                }
                field("POS Units"; Rec."POS Units")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Units field';
                }
                field("Cash Registers"; Rec."Cash Registers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Registers field';
                }
                field("POS Payment Bins"; Rec."POS Payment Bins")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bins field';
                }
                field("POS Payment Methods"; Rec."POS Payment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Methods field';
                }
                field("POS Posting Setups"; Rec."POS Posting Setups")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Posting Setups field';
                }
            }
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
            cuegroup(Members)
            {
                Caption = 'Members';
                field("Membership Setup"; Rec."Membership Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Setup field';
                }
                field("Membership Sales Setup"; Rec."Membership Sales Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Sales Setup field';
                }
                field("Member Alteration"; Rec."Member Alteration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Alteration field';
                }
                field("Member Community"; Rec."Member Community")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Community field';
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

