page 6059872 "NPR POSEntryMediaImageFactBox"
{
    Caption = 'Image Preview FactBox';
    PageType = CardPart;
    SourceTable = "NPR POS Entry Media Info";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    UsageCategory = None;
    Extensible = false;

    layout
    {
        area(content)
        {
            field(Image; Rec.Image)
            {
                ToolTip = 'Specifies the value of the Image field.';
                ApplicationArea = NPRRetail;
                ShowCaption = false;
            }
        }
    }
}