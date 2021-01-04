page 6060135 "NPR MM Members. Admis. Setup"
{

    Caption = 'Membership Admission Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Members. Admis. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership  Code"; "Membership  Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership  Code field';
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Ticket No. Type"; "Ticket No. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket No. Type field';
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Cardinality Type"; "Cardinality Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cardinality Type field';
                }
                field("Max Cardinality"; "Max Cardinality")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Cardinality field';
                }
                field(Description; Description)
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

