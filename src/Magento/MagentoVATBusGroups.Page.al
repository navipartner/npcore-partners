page 6151409 "NPR Magento VAT Bus. Groups"
{
    // MAG1.01/MH/20150116  CASE 199932 Object created - Maps NAV VAT Business Posting Group to Magento Customer Tax Class.
    // MAG1.17/MH/20150622  CASE 216851 Magento Setup functions moved to new codeunit
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup Actions to support Setup Event Subscription
    // MAG2.08/MHA /20171025  CASE 292926 Extensibility removed from Vat Setup

    Caption = 'VAT Business Posting Groups';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento VAT Bus. Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("VAT Business Posting Group"; "VAT Business Posting Group")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Magento Tax Class"; "Magento Tax Class")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup VAT Business Posting Groups")
            {
                Caption = 'Setup VAT Business Posting Groups';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    //-MAG2.08 [292926]
                    //MagentoSetupMgt.TriggerSetupVATBusinessPostingGroups();
                    MagentoSetupMgt.SetupVATBusinessPostingGroups();
                    //+MAG2.08 [292926]
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}

