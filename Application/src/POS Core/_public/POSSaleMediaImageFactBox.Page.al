page 6059901 "NPR POSSaleMediaImage FactBox"
{
    Caption = 'Image Preview FactBox';
    PageType = CardPart;
    SourceTable = "NPR POS Sale Media Info";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    UsageCategory = None;
    Extensible = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Image; Rec.Image)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Image field.';
                }
            }
        }
    }
}
