page 6060018 "GIM - Import Entities"
{
    // NPR5.51/MHA /20190819  CASE 365377 Generic Import Module is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'GIM - Import Entities';
    DataCaptionFields = Field20;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GIM - Import Entity";
    SourceTableView = SORTING(Field20,Field40,Field30,Field50);

    layout
    {
    }

    actions
    {
    }
}

