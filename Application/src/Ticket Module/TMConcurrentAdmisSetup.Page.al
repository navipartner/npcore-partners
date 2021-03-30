page 6151136 "NPR TM Concurrent Admis. Setup"
{

    Caption = 'Concurrent Admission Setup';
    PageType = List;
    SourceTable = "NPR TM Concurrent Admis. Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Total Capacity"; Rec."Total Capacity")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Total Capacity field';
                }
                field("Capacity Control"; Rec."Capacity Control")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Capacity Control field';
                }
                field("Concurrency Type"; Rec."Concurrency Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Concurrency Type field';
                }
            }
        }
    }

    actions
    {
    }
}

