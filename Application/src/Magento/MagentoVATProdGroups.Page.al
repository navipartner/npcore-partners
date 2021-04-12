page 6151410 "NPR Magento VAT Prod. Groups"
{
    Caption = 'VAT Product Posting Groups';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento VAT Prod. Group";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("VAT Product Posting Group"; Rec."VAT Product Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Product Posting Group field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Magento Tax Class"; Rec."Magento Tax Class")
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup VAT Product Posting Groups action';

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