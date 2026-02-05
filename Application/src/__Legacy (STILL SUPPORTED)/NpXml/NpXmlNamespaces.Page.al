page 6151564 "NPR NpXml Namespaces"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Namespaces';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR NpXml Namespace";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Alias; Rec.Alias)
                {

                    ToolTip = 'Specifies the value of the Alias field';
                    ApplicationArea = NPRRetail;
                }
                field(Namespace; Rec.Namespace)
                {

                    ToolTip = 'Specifies the value of the Namespace field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

