page 6151566 "NPR NpXml Api Headers"
{
    // NC2.06 /MHA /20170809  CASE 265779 Object created

    Caption = 'NpXml Api Headers';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NpXml Api Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
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

