page 6150723 "POS Entry Comments"
{
    // NPR5.36/NPKNAV/20171003  CASE 277096 Transport NPR5.36 - 3 October 2017

    Caption = 'POS Entry Comments';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "POS Entry Comment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No.";"POS Entry No.")
                {
                    Visible = false;
                }
                field("Code";Code)
                {
                }
                field(Comment;Comment)
                {
                }
            }
        }
    }

    actions
    {
    }
}

