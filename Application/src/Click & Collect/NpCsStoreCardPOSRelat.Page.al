page 6151209 "NPR NpCs Store Card POSRelat."
{
    Caption = 'Collect Store POS Relations';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NpCs Store POS Relation";

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
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}

