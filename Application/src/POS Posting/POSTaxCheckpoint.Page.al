page 6150630 "NPR POS Tax Checkpoint"
{
    Caption = 'POS Tax Checkpoint';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Worksh. Tax Checkp.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Identifier field';
                }
                field("Tax Calculation Type"; Rec."Tax Calculation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Calculation Type field';
                }
                field("Tax Type"; Rec."Tax Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Type field';
                }
                field("Tax %"; Rec."Tax %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax % field';
                }
                field("Tax Base Amount"; Rec."Tax Base Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Amount field';
                }
                field("Amount Including Tax"; Rec."Amount Including Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including Tax field';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Amount field';
                }
                field("Workshift Checkpoint Entry No."; Rec."Workshift Checkpoint Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Workshift Checkpoint Entry No. field';
                }
            }
        }
    }
}

