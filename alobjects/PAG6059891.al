page 6059891 "Npm Nav Field List"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager
    // NPR5.51/MHA /20190816  CASE 365332 Np Page Manager is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Nav Field List';
    DataCaptionExpression = Format("No.") + ' ' + "Field Caption";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    SourceTable = "Field";

    layout
    {
    }

    actions
    {
    }
}

