page 6150655 "POS Sales Line List"
{
    // NPR5.36/BR  /20170808  CASE  277096 Object created
    // NPR5.39/MHA /20180221 CASE 305139 Added field 405 "Discount Authorised by"
    // NPR5.53/SARA/20191024 CASE 373672 Addde Action button POS Entry Card

    Caption = 'POS Sales Line List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,POS Entry';
    SourceTable = "POS Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date";"Entry Date")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Starting Time";"Starting Time")
                {
                }
                field("Ending Time";"Ending Time")
                {
                }
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("POS Period Register No.";"POS Period Register No.")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Line Discount %";"Line Discount %")
                {
                }
                field("Amount Excl. VAT";"Amount Excl. VAT")
                {
                }
                field("Amount Incl. VAT";"Amount Incl. VAT")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Withhold Item";"Withhold Item")
                {
                }
                field("Discount Authorised by";"Discount Authorised by")
                {
                    Visible = false;
                }
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("Line No.";"Line No.")
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

