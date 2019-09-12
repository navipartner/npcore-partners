page 6059887 "Npm Mandatory Fields"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager
    // NPR5.51/MHA /20190816  CASE 365332 Np Page Manager is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Mandatory Fields';
    DataCaptionExpression = Format(Code);
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Npm Field";
    SourceTableView = WHERE(Code=CONST('0'));

    layout
    {
    }

    actions
    {
    }
}

