page 6184481 "NPR EFT Setup"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Setup';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "NPR EFT Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Payment Type POS"; "Payment Type POS")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Type POS field';
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("EFT Integration Type"; "EFT Integration Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EFT Integration Type field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("POS Unit Parameters")
            {
                Caption = 'POS Unit Parameters';
                Image = Setup;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the POS Unit Parameters action';

                trigger OnAction()
                var
                    EFTInterface: Codeunit "NPR EFT Interface";
                    Handled: Boolean;
                begin
                    EFTInterface.OnConfigureIntegrationUnitSetup(Rec);
                end;
            }
            action("Payment Type Parameters")
            {
                Caption = 'Payment Type Parameters';
                Image = Setup;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Payment Type Parameters action';

                trigger OnAction()
                var
                    EFTInterface: Codeunit "NPR EFT Interface";
                begin
                    EFTInterface.OnConfigureIntegrationPaymentSetup(Rec);
                end;
            }
        }
    }
}

