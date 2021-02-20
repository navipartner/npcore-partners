page 6150639 "NPR POS Post. Profile Card"
{
    Caption = 'POS Posting Profile Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                field("Automatic Item Posting"; Rec."Automatic Item Posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic Item Posting field';
                }
                field("Automatic POS Posting"; Rec."Automatic POS Posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic POS Posting field';
                }
                field("Automatic Posting Method"; Rec."Automatic Posting Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic Posting Method field';
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
                field("POS Period Register No. Series"; Rec."POS Period Register No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Period Register No. Series field';
                }
                field("POS Payment Bin"; Rec."POS Payment Bin")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Payment Bin field';
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
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Default POS Entry No. Series"; Rec."Default POS Entry No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Entry No. Series field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014413; Notes)
            {
                ApplicationArea = All;
            }
            systempart(Control6014414; Links)
            {
                ApplicationArea = All;
            }
        }
    }
}

