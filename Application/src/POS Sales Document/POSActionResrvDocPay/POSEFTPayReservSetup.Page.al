page 6184710 "NPR POS EFT Pay Reserv Setup"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'POS EFT Payment Reservation Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR POS EFT Pay Reserv Setup";
    UsageCategory = Administration;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Payment Gateway Code"; Rec."Payment Gateway Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Payment Gateway Code field.';

                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Account Type field.';

                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Account No. field.';

                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PaymentGateways)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Payment Gateways';
                Image = PaymentPeriod;
                RunObject = page "NPR Magento Payment Gateways";
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                ToolTip = 'Executes the Payment Gateways action.';
            }
            action(POSPaymentMethods)
            {
                ApplicationArea = NPRRetail;
                Caption = 'POS Payment Methods';
                Image = PaymentHistory;
                RunObject = page "NPR POS Payment Method List";
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                ToolTip = 'Executes the POS Payment Methods action.';
            }
            action(POSShipmentMethods)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Store Shipment Profiles';
                Image = ShipmentLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "NPR Store Shipment Profiles";
                ToolTip = 'Opens the Store Shipment Profiles';
                PromotedCategory = Category4;
            }
        }
    }

    trigger OnOpenPage()
    begin
        InitSetup();
    end;

    local procedure InitSetup()
    begin
        Rec.Reset();
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;
}