page 6150722 "NPR POS Tax Line Subpage"
{
    Caption = 'POS Tax Line Subpage';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR POS Entry Tax Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tax Base Amount"; Rec."Tax Base Amount")
                {

                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax %"; Rec."Tax %")
                {

                    ToolTip = 'Specifies the value of the Tax % field';
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
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {

                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {

                    ToolTip = 'Specifies the value of the Tax Area Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {

                    ToolTip = 'Specifies the value of the Tax Group Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Tax"; Rec."Use Tax")
                {

                    ToolTip = 'Specifies the value of the Use Tax field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

