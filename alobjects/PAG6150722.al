page 6150722 "POS Tax Line Subpage"
{
    // NPR5.36/BR  /20170818  CASE  277096 Object created

    Caption = 'POS Tax Line Subpage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "POS Tax Amount Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Tax Base Amount";"Tax Base Amount")
                {
                }
                field("Tax %";"Tax %")
                {
                }
                field("Tax Amount";"Tax Amount")
                {
                }
                field("Amount Including Tax";"Amount Including Tax")
                {
                }
                field("VAT Identifier";"VAT Identifier")
                {
                }
                field("Tax Calculation Type";"Tax Calculation Type")
                {
                }
                field("Tax Jurisdiction Code";"Tax Jurisdiction Code")
                {
                }
                field("Tax Area Code";"Tax Area Code")
                {
                }
                field("Tax Group Code";"Tax Group Code")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Use Tax";"Use Tax")
                {
                }
            }
        }
    }

    actions
    {
    }
}

