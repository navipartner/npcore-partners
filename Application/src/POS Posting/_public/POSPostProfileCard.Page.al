page 6150639 "NPR POS Post. Profile Card"
{
    Caption = 'POS Posting Profile Card';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/posting_profile/posting_profile/';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Posting Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Default POS Posting Setup"; Rec."Default POS Posting Setup")
                {
                    ToolTip = 'Specifies the value of the Default POS Posting Setup field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the value of the Source Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ToolTip = 'Specifies the value of the Tax Liable field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Period Register No. Series"; Rec."POS Period Register No. Series")
                {
                    ToolTip = 'Specifies the value of the POS Period Register No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Customer No."; Rec."VAT Customer No.")
                {
                    ToolTip = 'Specifies the value of the VAT Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Compression"; Rec."Posting Compression")
                {
                    ToolTip = 'Specifies whether the system should compress G/L entries created from POS entries. Options: "Uncompressed" - no compression is used; "Per POS Entry" - each POS entry is posted separately to the General Ledger, and the resulting G/L entries are consolidated per G/L account; "Per POS period" - all the POS entries created in the same period are posted together to the General Ledger, and the resulting G/L entries are consolidated per G/L account.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Ledger Document No."; Rec."Item Ledger Document No.")
                {
                    ToolTip = 'Specifies which document number to use when creating Item Ledger entries from POS entries.';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Process Ext. POS Sales"; Rec."Auto Process Ext. POS Sales")
                {
                    ToolTip = 'Specifies the value of the Auto Process Ext. POS Sales field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ToolTip = 'Specifies the value of the Journal Template Name which will be assigned to General Journal Lines in the POS Posting activity.';
                    ApplicationArea = NPRRetail;
                    Description = 'Initially created for BE localization';
                }
                field("Sales Channel"; Rec."Sales Channel")
                {
                    ToolTip = 'Specifies the value of the Sales Channel field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                group("Posting Difference")
                {
                    Caption = 'Posting Difference';
                    field("Max. POS Posting Diff. (LCY)"; Rec."Max. POS Posting Diff. (LCY)")
                    {
                        ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                    field("POS Posting Diff. Account"; Rec."POS Posting Diff. Account")
                    {
                        ToolTip = 'Specifies the value of the Differences Account field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Rounding)
                {
                    Caption = 'Rounding';
                    field("POS Sales Rounding Account"; Rec."POS Sales Rounding Account")
                    {
                        ToolTip = 'Specifies the value of the POS Sales Rounding Account field';
                        ApplicationArea = NPRRetail;
                    }
                    field("POS Sales Amt. Rndng Precision"; Rec."POS Sales Amt. Rndng Precision")
                    {
                        ToolTip = 'Specifies the value of the POS Sales Amt. Rndng Precision field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Rounding Type"; Rec."Rounding Type")
                    {
                        ToolTip = 'Specifies the value of the Rounding Type field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(BackgroundPosting)
                {
                    Caption = 'Background Posting';
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-10-28';
                    ObsoleteReason = 'Background posting setups moved to table 6150632 "NPR POS Sales Document Setup"';

                    field("Post POS Sale Documents With Job Queue"; Rec."Post POS Sale Doc. With JQ")
                    {
                        ToolTip = 'Specifies If the POS Sale Document will be scheduled for backgroung posting';
                        ApplicationArea = NPRRetail;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2023-10-28';
                        ObsoleteReason = 'Background posting setups moved to table 6150632 "NPR POS Sales Document Setup"';
                    }
                }
            }
            group("Customer Ledger Entry Posting Setup")
            {
                Caption = 'Customer Ledger Entry Posting Setup';
                ObsoleteState = Pending;
                ObsoleteTag = '2025-01-12';
                ObsoleteReason = 'Moved Customer Ledger Posting Setup to Fiscalization Setup Tables';
                Visible = false;
                Enabled = false;

                field("Enable POS Entry CLE Posting"; Rec."Enable POS Entry CLE Posting")
                {
                    Caption = 'Enable Posting';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable posting Customer Ledger Entries from POS Entry when customer is selected on POS.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '2024-11-03';
                    ObsoleteReason = 'Moved Customer Ledger Posting Setup to Fiscalization Setup Tables';
                }
                field("Customer Posting Group Filter"; Rec."Customer Posting Group Filter")
                {
                    ToolTip = 'Set the Customer Posting Group for which Customer Ledger Entries Filter will be posted.';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2024-11-03';
                    ObsoleteReason = 'Moved Customer Ledger Posting Setup to Fiscalization Setup Tables';
                }
                field("Enable Legal Ent. CLE Posting"; Rec."Enable Legal Ent. CLE Posting")
                {
                    Caption = 'Post for Legal Entites';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable posting Customer Ledger Entries for customers that are Legal Entities - have VAT Registration No. set on their Customer Card.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '2024-11-03';
                    ObsoleteReason = 'Moved Customer Ledger Posting Setup to Fiscalization Setup Tables';
                }
                field("General Journal Template Name"; Rec."General Journal Template Name")
                {
                    ToolTip = 'Specifies the value of the Journal Template Name which will be assigned to General Journal Lines in the Customer Ledger activity.';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2024-11-03';
                    ObsoleteReason = 'Moved Customer Ledger Posting Setup to Fiscalization Setup Tables';
                }
                field("General Journal Batch Name"; Rec."General Journal Batch Name")
                {
                    ToolTip = 'Specifies the value of the Journal Batch Name which will be assigned to General Journal Lines in the Customer Ledger activity.';
                    ApplicationArea = NPRRetail;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2024-11-03';
                    ObsoleteReason = 'Moved Customer Ledger Posting Setup to Fiscalization Setup Tables';
                }
            }
        }
    }
}