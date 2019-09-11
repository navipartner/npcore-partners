page 6060011 "GIM - Fields List"
{
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Fields List';
    Editable = false;
    PageType = List;
    SourceTable = "Field";
    SourceTableView = WHERE(Class=CONST(Normal),
                            Type=FILTER(<>BLOB));

    layout
    {
    }

    actions
    {
    }
}

