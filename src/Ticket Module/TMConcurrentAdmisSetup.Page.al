page 6151136 "NPR TM Concurrent Admis. Setup"
{
    // TM1.45/TSA/20200122  CASE 385922 Transport TM1.45 - 22 January 2020

    Caption = 'Concurrent Admission Setup';
    PageType = List;
    SourceTable = "NPR TM Concurrent Admis. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Total Capacity"; "Total Capacity")
                {
                    ApplicationArea = All;
                }
                field("Capacity Control"; "Capacity Control")
                {
                    ApplicationArea = All;
                }
                field("Concurrency Type"; "Concurrency Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

