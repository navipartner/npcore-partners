page 6151564 "NPR NpXml Namespaces"
{
    // NC1.22/MHA/20160429  CASE 237658 Object created
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'Namespaces';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
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
                }
                field(Namespace; Namespace)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

