page 6151422 "NPR Magento Setup Event Subs."
{
    // MAG2.05/MHA /20170714  CASE 283777 Object created

    Caption = 'Magento Setup Event Subscriptions';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Magento Setup Event Sub.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Codeunit ID"; "Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Function Name"; "Function Name")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Codeunit Name"; "Codeunit Name")
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

