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
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Total Capacity"; "Total Capacity")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Capacity Control"; "Capacity Control")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Concurrency Type"; "Concurrency Type")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
    }
}

