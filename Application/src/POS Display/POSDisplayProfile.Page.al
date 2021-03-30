page 6059995 "NPR POS Display Profile"
{
    Caption = 'POS Display Profile';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Display Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Activate; Rec.Activate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activate field';
                }
                field("Prices ex. VAT"; Rec."Prices ex. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prices ex. VAT field';
                }
                group(Media)
                {
                    Caption = 'Media';
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
                }
                group(Display)
                {
                    Caption = 'Display';
                    field("Custom Display Codeunit"; Rec."Custom Display Codeunit")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Custom Display Codeunit field';
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
                }
            }
            group(Receipt)
            {
                Caption = 'Receipt';
                field("Hide receipt"; Rec."Hide receipt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hide receipt field';
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
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitDisplayContent();
    end;
}

