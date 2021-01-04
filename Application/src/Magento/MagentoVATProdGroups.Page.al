page 6151410 "NPR Magento VAT Prod. Groups"
{
    // MAG1.01/MH/20150116  CASE 199932 Object created - Maps NAV VAT Product Posting Group to Magento Product Tax Class.
    // MAG1.17/MH/20150622  CASE 216851 Magento Setup functions moved to new codeunit
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup Actions to support Setup Event Subscription
    // MAG2.08/MHA /20171025  CASE 292926 Extensibility removed from Vat Setup

    Caption = 'VAT Product Posting Groups';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento VAT Prod. Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("VAT Product Posting Group"; "VAT Product Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Product Posting Group field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Magento Tax Class"; "Magento Tax Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Tax Class field';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup VAT Product Posting Groups action';

                trigger OnAction()
                begin
                    //-MAG2.08 [292926]
                    //MagentoSetupMgt.TriggerSetupVATProductPostingGroups();
                    MagentoSetupMgt.SetupVATProductPostingGroups();
                    //+MAG2.08 [292926]
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}

