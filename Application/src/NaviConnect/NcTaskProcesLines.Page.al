page 6151506 "NPR Nc Task Proces. Lines"
{
    // NC1.22/MHA/20160415 CASE 231214 Object created
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    AutoSplitKey = true;
    Caption = 'Nc Task Proces. Lines';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Task Proces. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Value; Value)
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

