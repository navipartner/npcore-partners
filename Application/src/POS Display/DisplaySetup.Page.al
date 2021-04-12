page 6059950 "NPR POS Display Profiles"
{
    Caption = 'POS Display Profiles';
    PageType = List;
    Editable = false;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Display Setup";
    CardPageId = "NPR POS Display Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Display Content Code"; Rec."Display Content Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Content Code field';
                }
                field("Screen No."; Rec."Screen No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Screen No. field';
                }
                field("Receipt Duration"; Rec."Receipt Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Duration field';
                }
                field("Receipt Width Pct."; Rec."Receipt Width Pct.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Width Pct. field';
                }
                field("Receipt Placement"; Rec."Receipt Placement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Placement field';
                }
                field("Receipt Description Padding"; Rec."Receipt Description Padding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Description Padding field';
                }
                field("Receipt Discount Padding"; Rec."Receipt Discount Padding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Discount Padding field';
                }
                field("Receipt Total Padding"; Rec."Receipt Total Padding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Total Padding field';
                }
                field("Receipt GrandTotal Padding"; Rec."Receipt GrandTotal Padding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt GrandTotal Padding field';
                }
                field("Image Rotation Interval"; Rec."Image Rotation Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image Rotation Interval field';
                }
                field("Media Downloaded"; Rec."Media Downloaded")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Media Downloaded field';
                }
                field("Prices ex. VAT"; Rec."Prices ex. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prices ex. VAT field';
                }
                field("Custom Display Codeunit"; Rec."Custom Display Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Display Codeunit field';
                }
                field(Activate; Rec.Activate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activate field';
                }
                field("Hide receipt"; Rec."Hide receipt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hide receipt field';
                }
            }
        }
    }
}

