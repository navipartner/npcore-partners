page 6060026 "GIM - Import Buffer by Columns"
{
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Import Buffer by Columns';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Integer";
    SourceTableView = SORTING(Number)
                      WHERE(Number=CONST(1));

    layout
    {
    }

    actions
    {
    }
}

