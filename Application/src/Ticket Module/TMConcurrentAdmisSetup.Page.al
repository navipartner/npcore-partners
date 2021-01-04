page 6151136 "NPR TM Concurrent Admis. Setup"
{
    // TM1.45/TSA/20200122  CASE 385922 Transport TM1.45 - 22 January 2020

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
                field("Code"; Code)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Total Capacity"; "Total Capacity")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Total Capacity field';
                }
                field("Capacity Control"; "Capacity Control")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Capacity Control field';
                }
                field("Concurrency Type"; "Concurrency Type")
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

