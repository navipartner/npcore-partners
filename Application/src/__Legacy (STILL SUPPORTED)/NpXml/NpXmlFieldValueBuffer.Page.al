page 6151561 "NPR NpXml Field Value Buffer"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
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

