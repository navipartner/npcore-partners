page 6059950 "NPR POS Display Profiles"
{
    Caption = 'POS Display Profiles';
    PageType = List;
    Editable = false;
    UsageCategory = Administration;

    SourceTable = "NPR Display Setup";
    CardPageId = "NPR POS Display Profile";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Display Content Code"; Rec."Display Content Code")
                {

                    ToolTip = 'Specifies the value of the Display Content Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Screen No."; Rec."Screen No.")
                {

                    ToolTip = 'Specifies the value of the Screen No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Duration"; Rec."Receipt Duration")
                {

                    ToolTip = 'Specifies the value of the Receipt Duration field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Width Pct."; Rec."Receipt Width Pct.")
                {

                    ToolTip = 'Specifies the value of the Receipt Width Pct. field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Placement"; Rec."Receipt Placement")
                {

                    ToolTip = 'Specifies the value of the Receipt Placement field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Description Padding"; Rec."Receipt Description Padding")
                {

                    ToolTip = 'Specifies the value of the Receipt Description Padding field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Discount Padding"; Rec."Receipt Discount Padding")
                {

                    ToolTip = 'Specifies the value of the Receipt Discount Padding field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Total Padding"; Rec."Receipt Total Padding")
                {

                    ToolTip = 'Specifies the value of the Receipt Total Padding field';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt GrandTotal Padding"; Rec."Receipt GrandTotal Padding")
                {

                    ToolTip = 'Specifies the value of the Receipt GrandTotal Padding field';
                    ApplicationArea = NPRRetail;
                }
                field("Image Rotation Interval"; Rec."Image Rotation Interval")
                {

                    ToolTip = 'Specifies the value of the Image Rotation Interval field';
                    ApplicationArea = NPRRetail;
                }
                field("Media Downloaded"; Rec."Media Downloaded")
                {

                    ToolTip = 'Specifies the value of the Media Downloaded field';
                    ApplicationArea = NPRRetail;
                }
                field("Prices ex. VAT"; Rec."Prices ex. VAT")
                {

                    ToolTip = 'Specifies the value of the Prices ex. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Display Codeunit"; Rec."Custom Display Codeunit")
                {

                    ToolTip = 'Specifies the value of the Custom Display Codeunit field';
                    ApplicationArea = NPRRetail;
                }
                field(Activate; Rec.Activate)
                {

                    ToolTip = 'Specifies the value of the Activate field';
                    ApplicationArea = NPRRetail;
                }
                field("Hide receipt"; Rec."Hide receipt")
                {

                    ToolTip = 'Specifies the value of the Hide receipt field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

