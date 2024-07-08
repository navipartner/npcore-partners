enum 6014423 "NPR Mag. Store Item Visibility"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; Visible)
    {
        Caption = 'Visible for catalog and search';
    }
    value(1; Hidden)
    {
        Caption = 'Not visible individually';
    }
    value(2; VisibleCatalogOnly)
    {
        Caption = 'Visible for catalog only';
    }
    value(3; VisibleSearchOnly)
    {
        Caption = 'Visible for search only';
    }
}
