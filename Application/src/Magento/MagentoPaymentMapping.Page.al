page 6151448 "NPR Magento Payment Mapping"
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
    SourceTable = "NPR Magento Payment Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; "External Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Payment Method Code field';
                }
                field("External Payment Type"; "External Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Payment Type field';
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                field("Allow Adjust Payment Amount"; "Allow Adjust Payment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Adjust Payment Amount field';
                }
                field("Payment Gateway Code"; "Payment Gateway Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Gateway Code field';
                }
                field("Captured Externally"; "Captured Externally")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Captured Externally field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Payment Methods action';

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
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}

