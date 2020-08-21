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
            field(Picture; Picture)
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
            field(URL; URL)
            {
                ApplicationArea = All;
                ExtendedDatatype = URL;
            }
            field(Description; Description)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

