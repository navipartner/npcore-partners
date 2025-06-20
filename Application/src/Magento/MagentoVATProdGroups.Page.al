﻿page 6151410 "NPR Magento VAT Prod. Groups"
{
    Extensible = False;
    Caption = 'Magento VAT Product Posting Groups';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento VAT Prod. Group";
    UsageCategory = Administration;
    ApplicationArea = NPRMagento;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("VAT Product Posting Group"; Rec."VAT Product Posting Group")
                {

                    ToolTip = 'Specifies the value of the VAT Product Posting Group field';
                    ApplicationArea = NPRMagento;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMagento;
                }
                field("Magento Tax Class"; Rec."Magento Tax Class")
                {

                    ToolTip = 'Specifies the value of the Magento Tax Class field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup VAT Product Posting Groups")
            {
                Caption = 'Setup VAT Product Posting Groups';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Setup VAT Product Posting Groups action';
                ApplicationArea = NPRMagento;

                trigger OnAction()
                begin
                    MagentoSetupMgt.SetupVATProductPostingGroups();
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}
