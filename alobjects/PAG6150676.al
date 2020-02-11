page 6150676 "POS Tax Line List"
{
    // NPR5.53/SARA/20191024 CASE 373672 Object create

    Caption = 'POS Tax Line List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,POS Entry';
    SourceTable = "POS Tax Amount Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date";"Entry Date")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
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
                field("POS Entry No.";"POS Entry No.")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("POS Entry")
            {
                Caption = 'POS Entry';
                action("POS Entry Card")
                {
                    Caption = 'POS Entry Card';
                    Image = List;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "POS Entry Card";
                    RunPageLink = "Entry No."=FIELD("POS Entry No.");
                    RunPageView = SORTING("Entry No.");
                }
            }
        }
    }
}

