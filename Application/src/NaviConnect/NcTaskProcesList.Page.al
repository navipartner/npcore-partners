page 6151508 "NPR Nc Task Proces. List"
{
    // NC1.22/MHA/20160125 CASE 232733 Object created
    // NC1.22/MHA/20160415 CASE 231214 Added Parameter subform
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NaviConnect Task Processors';
    CardPageID = "NPR Nc Task Proces. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Task Processor";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
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

