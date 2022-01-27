page 6151561 "NPR NpXml Field Value Buffer"
{
    Extensible = False;
    Caption = 'NpXml Field Value Buffer';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpXml Field Val. Buffer";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

