page 6151579 "Event Exch. Int. Temp. Entries"
{
    // NPR5.34/TJ  /20170728 CASE 277938 New object

    Caption = 'Event Exch. Int. Temp. Entries';
    PageType = List;
    SourceTable = "Event Exch. Int. Temp. Entry";

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
                field(Active;Active)
                {
                }
            }
        }
    }

    actions
    {
    }
}

