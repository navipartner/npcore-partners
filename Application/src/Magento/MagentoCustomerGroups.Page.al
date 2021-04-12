page 6151440 "NPR Magento Customer Groups"
{
    Caption = 'Customer Groups';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Customer Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Magento Tax Class"; Rec."Magento Tax Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Tax Class field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Customer Groups action';

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