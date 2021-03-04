page 6151564 "NPR NpXml Namespaces"
{
    Caption = 'Namespaces';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR NpXml Namespace";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Alias; Alias)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Alias field';
                }
                field(Namespace; Namespace)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Namespace field';
                }
            }
        }
    }
}

