﻿page 6184481 "NPR EFT Setup"
{
    Extensible = False;
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Setup';
    ContextSensitiveHelpPage = 'docs/providers/intro/';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "NPR EFT Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Payment Type POS"; Rec."Payment Type POS")
                {

                    ToolTip = 'Select the payment type for the point of sale (POS) transaction.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Enter the number or identifier of the POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field("EFT Integration Type"; Rec."EFT Integration Type")
                {

                    ToolTip = 'Choose the type of electronic funds transfer (EFT) integration for processing payments.';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Configures the parameters for the POS unit.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EFTInterface: Codeunit "NPR EFT Interface";
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

                ToolTip = 'Configures the parameters for the payment types.';
                ApplicationArea = NPRRetail;

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