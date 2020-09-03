page 6150722 "NPR POS Tax Line Subpage"
{
    // NPR5.36/BR  /20170818  CASE  277096 Object created

    Caption = 'POS Tax Line Subpage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NPR POS Tax Amount Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tax Base Amount"; "Tax Base Amount")
                {
                    ApplicationArea = All;
                }
                field("Tax %"; "Tax %")
                {
                    ApplicationArea = All;
                }
                field("Tax Amount"; "Tax Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount Including Tax"; "Amount Including Tax")
                {
                    ApplicationArea = All;
                }
                field("VAT Identifier"; "VAT Identifier")
                {
                    ApplicationArea = All;
                }
                field("Tax Calculation Type"; "Tax Calculation Type")
                {
                    ApplicationArea = All;
                }
                field("Tax Jurisdiction Code"; "Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Use Tax"; "Use Tax")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

