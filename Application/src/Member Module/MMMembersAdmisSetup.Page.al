page 6060135 "NPR MM Members. Admis. Setup"
{

    Caption = 'Membership Admission Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Members. Admis. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership  Code"; Rec."Membership  Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership  Code field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Ticket No. Type"; Rec."Ticket No. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket No. Type field';
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Cardinality Type"; Rec."Cardinality Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cardinality Type field';
                }
                field("Max Cardinality"; Rec."Max Cardinality")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Cardinality field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

