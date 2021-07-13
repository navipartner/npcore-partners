page 6150630 "NPR POS Tax Checkpoint"
{
    Caption = 'POS Tax Checkpoint';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Worksh. Tax Checkp.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {

                    ToolTip = 'Specifies the value of the Tax Area Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {

                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {

                    ToolTip = 'Specifies the value of the Tax Group Code field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {

                    ToolTip = 'Specifies the value of the Tax Identifier field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Calculation Type"; Rec."Tax Calculation Type")
                {

                    ToolTip = 'Specifies the value of the VAT Calculation Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Type"; Rec."Tax Type")
                {

                    ToolTip = 'Specifies the value of the Tax Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax %"; Rec."Tax %")
                {

                    ToolTip = 'Specifies the value of the Tax % field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Base Amount"; Rec."Tax Base Amount")
                {

                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Amount"; Rec."Tax Amount")
                {

                    ToolTip = 'Specifies the value of the Tax Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including Tax"; Rec."Amount Including Tax")
                {

                    ToolTip = 'Specifies the value of the Amount Including Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Amount"; Rec."Line Amount")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Workshift Checkpoint Entry No."; Rec."Workshift Checkpoint Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Workshift Checkpoint Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

