page 6151566 "NpXml Api Headers"
{
    // NC2.06 /MHA /20170809  CASE 265779 Object created

    Caption = 'NpXml Api Headers';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpXml Api Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field(Value;Value)
                {
                }
            }
        }
    }

    actions
    {
    }
}

