page 6184481 "EFT Setup"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Setup';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "EFT Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Payment Type POS";"Payment Type POS")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("EFT Integration Type";"EFT Integration Type")
                {
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    EFTInterface: Codeunit "EFT Interface";
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    EFTInterface: Codeunit "EFT Interface";
                begin
                    EFTInterface.OnConfigureIntegrationPaymentSetup(Rec);
                end;
            }
        }
    }
}

