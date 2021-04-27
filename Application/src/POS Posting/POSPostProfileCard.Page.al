page 6150639 "NPR POS Post. Profile Card"
{
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Default POS Posting Setup"; Rec."Default POS Posting Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Posting Setup field';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Code field';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Liable field';
                }
                field("POS Period Register No. Series"; Rec."POS Period Register No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Period Register No. Series field';
                }
                field("VAT Customer No."; Rec."VAT Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Customer No. field';
                }
                field("Posting Compression"; Rec."Posting Compression")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Compression field';
                }
                group("Posting Difference")
                {
                    Caption = 'Posting Difference';
                    field("Max. POS Posting Diff. (LCY)"; Rec."Max. POS Posting Diff. (LCY)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                    }
                    field("POS Posting Diff. Account"; Rec."POS Posting Diff. Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Differences Account field';
                    }
                }
                group(Rounding)
                {
                    Caption = 'Rounding';
                    field("POS Sales Rounding Account"; Rec."POS Sales Rounding Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Sales Rounding Account field';
                    }
                    field("POS Sales Amt. Rndng Precision"; Rec."POS Sales Amt. Rndng Precision")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the POS Sales Amt. Rndng Precision field';
                    }
                    field("Rounding Type"; Rec."Rounding Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rounding Type field';
                    }
                }
            }
        }
    }
}

