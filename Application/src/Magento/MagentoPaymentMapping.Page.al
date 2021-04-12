page 6151448 "NPR Magento Payment Mapping"
{
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
                field("External Payment Method Code"; Rec."External Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Payment Method Code field';
                }
                field("External Payment Type"; Rec."External Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Payment Type field';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                field("Allow Adjust Payment Amount"; Rec."Allow Adjust Payment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Adjust Payment Amount field';
                }
                field("Payment Gateway Code"; Rec."Payment Gateway Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Gateway Code field';
                }
                field("Captured Externally"; Rec."Captured Externally")
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
                    MagentoSetupMgt.TriggerSetupPaymentMethodMapping();
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}