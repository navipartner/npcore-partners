page 6150630 "NPR POS Tax Checkpoint"
{
    Caption = 'POS Tax Checkpoint';
    Editable = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR POS Worksh. Tax Checkp.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("Tax Jurisdiction Code"; "Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                }
                field("VAT Identifier"; "VAT Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Identifier field';
                }
                field("Tax Calculation Type"; "Tax Calculation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Calculation Type field';
                }
                field("Tax Type"; "Tax Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Type field';
                }
                field("Tax %"; "Tax %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax % field';
                }
                field("Tax Base Amount"; "Tax Base Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                }
                field("Tax Amount"; "Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Amount field';
                }
                field("Amount Including Tax"; "Amount Including Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including Tax field';
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Amount field';
                }
                field("Workshift Checkpoint Entry No."; "Workshift Checkpoint Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Workshift Checkpoint Entry No. field';
                }
            }
        }
    }

    actions
    {
    }
}

