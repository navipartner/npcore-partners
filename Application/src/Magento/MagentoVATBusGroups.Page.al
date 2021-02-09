page 6151409 "NPR Magento VAT Bus. Groups"
{
    Caption = 'VAT Business Posting Groups';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento VAT Bus. Group";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("VAT Business Posting Group"; Rec."VAT Business Posting Group")
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
            action("Setup VAT Business Posting Groups")
            {
                Caption = 'Setup VAT Business Posting Groups';
                Image = Setup;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup VAT Business Posting Groups action';

                trigger OnAction()
                begin
                    MagentoSetupMgt.SetupVATBusinessPostingGroups();
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}