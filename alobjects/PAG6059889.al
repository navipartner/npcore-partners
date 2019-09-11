page 6059889 "Npm Views"
{
    // NPR5.33/MHA /20170126  CASE 264348 Object created - Module: Np Page Manager
    // NPR5.51/MHA /20190816  CASE 365332 Np Page Manager is deprecated [VLOBJDEL] Object marked for deletion

    Caption = 'Page Manager - Views';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Page Manager';
    SourceTable = "Npm View";
    UsageCategory = Lists;

    layout
    {
    }

    actions
    {
    }

    var
        Text000: Label 'Page Manager changes applied';
        Text001: Label 'Page Manager changes removed';
}

