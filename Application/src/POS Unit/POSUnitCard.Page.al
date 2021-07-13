page 6150617 "NPR POS Unit Card"
{
    UsageCategory = None;
    Caption = 'POS Unit Card';
    RefreshOnActivate = true;
    SourceTable = "NPR POS Unit";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin"; Rec."Default POS Payment Bin")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Payment Bin field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Type"; Rec."POS Type")
                {

                    ToolTip = 'Specifies the value of the POS Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Profiles)
            {
                Caption = 'Profiles';
                field("POS Audit Profile"; Rec."POS Audit Profile")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Audit Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS View Profile"; Rec."POS View Profile")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS View Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS End of Day Profile"; Rec."POS End of Day Profile")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS End of Day Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("Ean Box Sales Setup"; Rec."Ean Box Sales Setup")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Ean Box Sales Setup field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit Receipt Text Profile"; Rec."POS Unit Receipt Text Profile")
                {

                    ToolTip = 'Specifies the value of the POS Unit Receipt Text Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {

                    ToolTip = 'Specifies the value of the POS Sales Workflow Set field';
                    ApplicationArea = NPRRetail;
                }
                field("Global POS Sales Setup"; Rec."Global POS Sales Setup")
                {

                    ToolTip = 'Specifies the value of the Global POS Sales Setup field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Named Actions Profile"; Rec."POS Named Actions Profile")
                {

                    ToolTip = 'Specifies the value of the POS Named Actions Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Restaurant Profile"; Rec."POS Restaurant Profile")
                {

                    ToolTip = 'Specifies the value of the POS Restaurant Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Pricing Profile"; Rec."POS Pricing Profile")
                {

                    ToolTip = 'Specifies the value of the POS Pricing Profile field where customer discount and price group should be set.';
                    ApplicationArea = NPRRetail;
                }
                field("MPOS Profile"; Rec."MPOS Profile")
                {

                    ToolTip = 'Specifies the value of the MPOS Profile field where ticket admission should be set.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Self Service Profile"; Rec."POS Self Service Profile")
                {

                    ToolTip = 'Specifies the value of the Self Service Profile field.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Display Profile"; Rec."POS Display Profile")
                {

                    ToolTip = 'Specifies the value of the POS Display Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Tax Free Profile"; Rec."POS Tax Free Profile")
                {

                    ToolTip = 'Specifies the value of the POS Tax Free Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Security Profile"; Rec."POS Security Profile")
                {

                    ToolTip = 'Specifies the value of the POS Security Profile field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6150615),
                              "No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+D';

                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;
            }
            action("POS Period Registers")
            {
                Caption = 'POS Period Registers';
                Image = Register;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Period Register List";
                RunPageLink = "POS Unit No." = FIELD("No.");

                ToolTip = 'Executes the POS Period Registers action';
                ApplicationArea = NPRRetail;
            }
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = LedgerEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Entry List";
                RunPageLink = "POS Unit No." = FIELD("No.");

                ToolTip = 'Executes the POS Entries action';
                ApplicationArea = NPRRetail;
            }
            action("POS Unit Bins")
            {
                Caption = 'POS Unit Bins';
                Image = List;
                RunObject = Page "NPR POS Unit to Bin Relation";
                RunPageLink = "POS Unit No." = FIELD("No.");

                ToolTip = 'Executes the POS Unit Bins action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

