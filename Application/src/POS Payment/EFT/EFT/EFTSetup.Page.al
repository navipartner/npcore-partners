﻿page 6184481 "NPR EFT Setup"
{
    Extensible = False;
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Setup';
    ContextSensitiveHelpPage = 'retail/eft/explanation/EFT_setup.html';
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

                    ToolTip = 'Specifies the value of the Payment Type POS field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("EFT Integration Type"; Rec."EFT Integration Type")
                {

                    ToolTip = 'Specifies the value of the EFT Integration Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Integration; Rec.Integration)
                {
                    ToolTip = 'Specifies the value of the Integration field.';
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

                ToolTip = 'Executes the POS Unit Parameters action';
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

                ToolTip = 'Executes the Payment Type Parameters action';
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

