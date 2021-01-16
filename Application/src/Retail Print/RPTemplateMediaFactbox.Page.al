page 6014629 "NPR RP Template Media Factbox"
{
    Caption = 'Template Media Factbox';
    Editable = false;
    InsertAllowed = false;
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR RP Template Media Info";

    layout
    {
        area(content)
        {
            field(Picture; Picture)
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Picture field';
            }
            field(URL; URL)
            {
                ApplicationArea = All;
                ExtendedDatatype = URL;
                ToolTip = 'Specifies the value of the URL field';
            }
            field(Description; Description)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Description field';
            }
        }
    }

    actions
    {
    }
}

