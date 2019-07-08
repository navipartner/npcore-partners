page 6151407 "Magento Tax Classes"
{
    // MAG1.05/20150223  CASE 206395 Object created
    // MAG1.17/MH/20150622  CASE 216851 Magento Setup functions moved to new codeunit
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.03/MHA /20170324  CASE 266871 Added field 517 "Customer Config. Template Code"
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup Actions to support Setup Event Subscription

    Caption = 'Tax Classes';
    PageType = List;
    SourceTable = "Magento Tax Class";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field(Type;Type)
                {
                }
                field("Customer Config. Template Code";"Customer Config. Template Code")
                {
                    Enabled = "Type"=1;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Magento Tax Classes")
            {
                Caption = 'Setup Tax Classes';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //-MAG2.07 [286943]
                    //MagentoSetupMgt.SetupMagentoTaxClasses();
                    MagentoSetupMgt.TriggerSetupMagentoTaxClasses();
                    //+MAG2.07 [286943]
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
}

