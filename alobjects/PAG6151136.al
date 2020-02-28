page 6151136 "TM Concurrent Admission Setup"
{
    // TM1.45/TSA/20200122  CASE 385922 Transport TM1.45 - 22 January 2020

    Caption = 'Concurrent Admission Setup';
    PageType = List;
    SourceTable = "TM Concurrent Admission Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Total Capacity";"Total Capacity")
                {
                }
                field("Capacity Control";"Capacity Control")
                {
                }
                field("Concurrency Type";"Concurrency Type")
                {
                }
            }
        }
    }

    actions
    {
    }
}

