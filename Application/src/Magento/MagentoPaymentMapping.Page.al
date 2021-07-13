page 6151448 "NPR Magento Payment Mapping"
{
    Caption = 'Payment Method Mapping';
    PageType = List;
    SourceTable = "NPR Magento Payment Mapping";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; Rec."External Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the External Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("External Payment Type"; Rec."External Payment Type")
                {

                    ToolTip = 'Specifies the value of the External Payment Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Adjust Payment Amount"; Rec."Allow Adjust Payment Amount")
                {

                    ToolTip = 'Specifies the value of the Allow Adjust Payment Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Gateway Code"; Rec."Payment Gateway Code")
                {

                    ToolTip = 'Specifies the value of the Payment Gateway Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Captured Externally"; Rec."Captured Externally")
                {

                    ToolTip = 'Specifies the value of the Captured Externally field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Setup Payment Methods action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    MagentoSetupMgt.TriggerSetupPaymentMethodMapping();
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}