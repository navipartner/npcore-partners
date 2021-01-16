page 6151422 "NPR Magento Setup Event Subs."
{
    // MAG2.05/MHA /20170714  CASE 283777 Object created

    Caption = 'Magento Setup Event Subscriptions';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Codeunit ID"; "Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit ID field';
                }
                field("Function Name"; "Function Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Function Name field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Codeunit Name"; "Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit Name field';
                }
            }
        }
    }

    actions
    {
    }
}

