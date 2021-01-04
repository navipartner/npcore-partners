page 6014567 "NPR Retail Logo Factbox"
{
    // NPR4.21/MMV/20160223 CASE 223223 Created page

    Caption = 'Retail Logo Factbox';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    UsageCategory = Administration;
    SourceTable = "NPR Retail Logo";

    layout
    {
        area(content)
        {
            field(Logo; Logo)
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Logo field';
            }
            field(Width; Width)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Width field';
            }
            field(Height; Height)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Height field';
            }
        }
    }

    actions
    {
    }
}

