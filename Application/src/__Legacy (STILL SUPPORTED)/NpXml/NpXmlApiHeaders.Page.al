page 6151566 "NPR NpXml Api Headers"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'NpXml Api Headers';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NpXml Api Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

