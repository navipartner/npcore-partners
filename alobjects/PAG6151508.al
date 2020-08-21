page 6151508 "Nc Task Proces. List"
{
    // NC1.22/MHA/20160125 CASE 232733 Object created
    // NC1.22/MHA/20160415 CASE 231214 Added Parameter subform
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NaviConnect Task Processors';
    CardPageID = "Nc Task Proces. Card";
    Editable = false;
    PageType = List;
    SourceTable = "Nc Task Processor";
    UsageCategory = Administration;

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
            }
        }
    }

    actions
    {
    }
}

