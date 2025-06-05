﻿page 6151440 "NPR Magento Customer Groups"
{
    Extensible = False;
    Caption = 'Customer Groups';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Customer Group";
    ApplicationArea = NPRMagento;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Magento Tax Class"; Rec."Magento Tax Class")
                {

                    ToolTip = 'Specifies the value of the Magento Tax Class field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Magento Customer Groups")
            {
                Caption = 'Setup Customer Groups';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Setup Customer Groups action';
                ApplicationArea = NPRMagento;

                trigger OnAction()
                begin
                    MagentoSetupMgt.TriggerSetupMagentoCustomerGroups();
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}
