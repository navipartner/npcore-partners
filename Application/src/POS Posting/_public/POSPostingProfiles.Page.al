page 6150638 "NPR POS Posting Profiles"
{
    Caption = 'POS Posting Profiles';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/posting_profile/posting_profile/';
    CardPageID = "NPR POS Post. Profile Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Posting Profile";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies unique code for POS posting profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Short description - name of POS posting profile.';
                    ApplicationArea = NPRRetail;
                }
                field("Max. POS Posting Diff. (LCY)"; Rec."Max. POS Posting Diff. (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the maximum allowed difference caused by the difference between currencies.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Posting Diff. Account"; Rec."POS Posting Diff. Account")
                {

                    Visible = false;
                    ToolTip = 'Defines G/L account on which Currency difference will be posted.';
                    ApplicationArea = NPRRetail;
                }
                field("Source Code"; Rec."Source Code")
                {

                    ToolTip = 'Defines Source code which will be attached to POS transactions which are created in store with this POS posting profile.';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {

                    ToolTip = 'Defines the General business posting group which will be attached to transactions in which there is no customer attached, or to all transactions if the Store option is selected in the "Default POS Posting Setup".';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {

                    ToolTip = 'Defines the VAT business posting group which will be attached to transactions in which there is no customer attached, or to all transactions if the Store option is selected in the "Default POS Posting Setup"';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ToolTip = 'Specifies the Template which will be assigned to journal in POS posting activities.';
                    ApplicationArea = NPRRetail;
                    Description = 'Initially created for BE localization';
                }
                field("Default POS Posting Setup"; Rec."Default POS Posting Setup")
                {
                    ToolTip = 'Defines where the posting groups are sourced from by default if a customer is attached to a sale.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ToolTip = 'Defines TAX area code if the posting profile is set up for the US localization';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ToolTip = 'Used in cases when profile is set up for US localization.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("POS Period Register No. Series"; Rec."POS Period Register No. Series")
                {
                    ToolTip = 'Defines No. series used if the G/L entry posting is performed with compression by period. No. series are used to create document numbers.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("VAT Customer No."; Rec."VAT Customer No.")
                {
                    ToolTip = 'Defines the customer who is assigned to the POS.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Posting Compression"; Rec."Posting Compression")
                {
                    ToolTip = 'Defines how G/L entries will be posted. Options: Uncompressed - every POS entry will be posted as a separate document; Per POS entry - the lines are compressed per an account code within the POS entry; Per POS period – All POS entries created during a specific period will be compressed per the same account.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("POS Sales Rounding Account"; Rec."POS Sales Rounding Account")
                {
                    ToolTip = 'Defines G/L account on which rounding will be posted.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("POS Sales Amt. Rndng Precision"; Rec."POS Sales Amt. Rndng Precision")
                {
                    ToolTip = 'Defines on which decimal spaces rounding will be performed.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ToolTip = 'Defines how rounding will be done. Options: Nearest, Up, Down.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

