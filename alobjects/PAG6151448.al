page 6151448 "Magento Payment Mapping"
{
    // MAG1.01/MHA /20150121  CASE 199932 Refactored object from Web Integration
    // MAG1.17/MHA /20150622  CASE 216851 Magento Setup functions moved to new codeunit
    // MAG1.20/MHA /20150826  CASE 219645 Added field 105 Payment Gateway Code
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.05/MHA /20170712  CASE 283588 Added field 90 "Allow Adjust Payment Amount"
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup Actions to support Setup Event Subscription
    // MAG2.23/ALPO/20191004  CASE 367219 Auto set capture date for payments captured externally: new control "Captured Externally"

    Caption = 'Payment Method Mapping';
    PageType = List;
    SourceTable = "Magento Payment Mapping";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; "External Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("External Payment Type"; "External Payment Type")
                {
                    ApplicationArea = All;
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Allow Adjust Payment Amount"; "Allow Adjust Payment Amount")
                {
                    ApplicationArea = All;
                }
                field("Payment Gateway Code"; "Payment Gateway Code")
                {
                    ApplicationArea = All;
                }
                field("Captured Externally"; "Captured Externally")
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
            action("Setup Payment Methods")
            {
                Caption = 'Setup Payment Methods';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //-MAG2.07 [286943]
                    //MagentoSetupMgt.SetupNaviConnectPaymentMethods();
                    MagentoSetupMgt.TriggerSetupPaymentMethodMapping();
                    //+MAG2.07 [286943]
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
}

