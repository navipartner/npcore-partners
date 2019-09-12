page 6151043 "POS Payment View Log Entries"
{
    // NPR5.51/MHA /20190723  CASE 351688 Object created

    Caption = 'POS Payment View Log Entries';
    Editable = false;
    PageType = List;
    SourceTable = "POS Payment View Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Log Date";"Log Date")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("POS Store";"POS Store")
                {
                }
                field("POS Unit";"POS Unit")
                {
                }
                field("POS Sales No.";"POS Sales No.")
                {
                }
                field("Post Code Popup";"Post Code Popup")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

