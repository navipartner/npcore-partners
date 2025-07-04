﻿page 6151422 "NPR Magento Setup Event Subs."
{
    Extensible = False;
    Caption = 'Magento Setup Event Subscriptions';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Setup Event Sub.";
    ApplicationArea = NPRMagento;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Codeunit ID field';
                    ApplicationArea = NPRMagento;
                }
                field("Function Name"; Rec."Function Name")
                {

                    ToolTip = 'Specifies the value of the Function Name field';
                    ApplicationArea = NPRMagento;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Codeunit Name field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
