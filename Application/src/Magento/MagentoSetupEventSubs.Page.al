page 6151422 "NPR Magento Setup Event Subs."
{
    Caption = 'Magento Setup Event Subscriptions';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Setup Event Sub.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Function Name"; Rec."Function Name")
                {

                    ToolTip = 'Specifies the value of the Function Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}