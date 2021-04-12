page 6150722 "NPR POS Tax Line Subpage"
{
    Caption = 'POS Tax Line Subpage';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Entry Tax Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tax Base Amount"; Rec."Tax Base Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                }
                field("Tax %"; Rec."Tax %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax % field';
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
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Use Tax"; Rec."Use Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Tax field';
                }
            }
        }
    }

    actions
    {
    }
}

