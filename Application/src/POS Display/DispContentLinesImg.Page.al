page 6059953 "NPR Disp. Content Lines Img"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Display Content Lines Image';
    LinksAllowed = false;
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR Display Content Lines";

    layout
    {
        area(content)
        {
            field(Image; Image)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Image field';
            }
        }
    }

    actions
    {
    }
}

