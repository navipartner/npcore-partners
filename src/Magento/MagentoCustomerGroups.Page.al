page 6151440 "NPR Magento Customer Groups"
{
    // MAG1.05/20150223  CASE 206395 Object created
    // MAG1.17/MH/20150622  CASE 216851 Magento Setup functions moved to new codeunit
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup Actions to support Setup Event Subscription

    Caption = 'Customer Groups';
    PageType = List;
    SourceTable = "NPR Magento Customer Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Magento Tax Class"; "Magento Tax Class")
                {
                    ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    //-MAG2.07 [286943]
                    //MagentoSetupMgt.SetupMagentoCustomerGroups();
                    MagentoSetupMgt.TriggerSetupMagentoCustomerGroups();
                    //+MAG2.07 [286943]
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}

