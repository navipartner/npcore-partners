page 6150639 "NPR POS Post. Profile Card"
{
    Extensible = False;
    Caption = 'POS Posting Profile Card';
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

                    ToolTip = 'Specifies the value of the Posting Compression field';
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
            }
        }
    }
}

