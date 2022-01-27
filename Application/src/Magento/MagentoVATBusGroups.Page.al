page 6151409 "NPR Magento VAT Bus. Groups"
{
    Extensible = False;
    Caption = 'VAT Business Posting Groups';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Magento VAT Bus. Group";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("VAT Business Posting Group"; Rec."VAT Business Posting Group")
                {

                    ToolTip = 'Specifies the value of the VAT Product Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Magento Tax Class"; Rec."Magento Tax Class")
                {

                    ToolTip = 'Specifies the value of the Magento Tax Class field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Setup VAT Business Posting Groups action';
                ApplicationArea = NPRRetail;

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
