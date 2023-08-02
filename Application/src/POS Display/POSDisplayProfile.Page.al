page 6059995 "NPR POS Display Profile"
{
    Extensible = False;
    Caption = 'POS Display Profile';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/customer_display/customer_display/';
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

                    ToolTip = 'Specifies the unique code of the profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the short description of a profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Activate; Rec.Activate)
                {

                    ToolTip = 'Activate the POS Display Profile on the customer display.';
                    ApplicationArea = NPRRetail;
                }
                field("Prices ex. VAT"; Rec."Prices ex. VAT")
                {

                    ToolTip = 'Specifies whether the prices are visible without the VAT on the POS.';
                    ApplicationArea = NPRRetail;
                }
                group(Media)
                {
                    Caption = 'Media';
                    field("Image Rotation Interval"; Rec."Image Rotation Interval")
                    {

                        ToolTip = 'Specifies the time-delay between the images (the number of milliseconds during which an image is displayed).';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Display)
                {
                    Caption = 'Display';
                    field("Custom Display Codeunit"; Rec."Custom Display Codeunit")
                    {

                        ToolTip = 'Specifies the customized codeunit used for out-of-the-box functionality. Adding a Codeunit ID here will expand on the base funcitonality and/or set usage or limitations that could override existing fields. If using a Custom Display Codeunit, read the documentation on that Codeunit.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Display Content Code"; Rec."Display Content Code")
                    {

                        ToolTip = 'Specifies the Display Content Code group that will be used for this POS Display Profile. Display Content Codes are groupings of either images, videos, or URLs. This is where the media displayed on the Customer Display is uploaded or linked to.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Receipt)
            {
                Caption = 'Receipt';
                field("Hide receipt"; Rec."Hide receipt")
                {

                    ToolTip = 'Remove the receipt from the Customer Display.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Duration"; Rec."Receipt Duration")
                {

                    ToolTip = 'Specifies the duration (in milliseconds) that the receipt will stay on-screen.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Width Pct."; Rec."Receipt Width Pct.")
                {

                    ToolTip = 'Specifies the width of the whole receipt on the Customer Display.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Placement"; Rec."Receipt Placement")
                {

                    ToolTip = 'Specifies the alignment of the receipt on the screen.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Description Padding"; Rec."Receipt Description Padding")
                {

                    ToolTip = 'Specifies the size of the field containing the Sales Line Description.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Discount Padding"; Rec."Receipt Discount Padding")
                {

                    ToolTip = 'Specifies the size of the field that contains the discount percentage.';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt Total Padding"; Rec."Receipt Total Padding")
                {

                    ToolTip = 'Specifies the size of the fields that contain the Sales Line Totals (i.e. Quantity x Unit Price).';
                    ApplicationArea = NPRRetail;
                }
                field("Receipt GrandTotal Padding"; Rec."Receipt GrandTotal Padding")
                {

                    ToolTip = 'Specifies the size of the field that contains the Total for the entire sale.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("POS Device Display")
            {
                Caption = 'POS Unit Display';
                Image = Administration;
                RunObject = Page "NPR POS Unit Display";
                ToolTip = 'Set Unit specific info for POS Display Profile';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitDisplayContent();
    end;
}

