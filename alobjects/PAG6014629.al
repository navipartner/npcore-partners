page 6014629 "RP Template Media Factbox"
{
    Caption = 'Template Media Factbox';
    Editable = false;
    InsertAllowed = false;
    PageType = CardPart;
    SourceTable = "RP Template Media Info";

    layout
    {
        area(content)
        {
            field(Picture;Picture)
            {
                ShowCaption = false;
            }
            field(URL;URL)
            {
                ExtendedDatatype = URL;
            }
            field(Description;Description)
            {
            }
        }
    }

    actions
    {
    }
}

