page 6151004 "POS Quote Subpage"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added "Customer Price Group"
    // NPR5.51/MMV /20190820  CASE 364694 Handle EFT approvals

    Caption = 'POS Quote Subpage';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "POS Quote Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Price Includes VAT";"Price Includes VAT")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
                field("Discount Type";"Discount Type")
                {
                }
                field("Discount %";"Discount %")
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
                field("Discount Code";"Discount Code")
                {
                }
                field("Discount Authorised by";"Discount Authorised by")
                {
                }
                field("Customer Price Group";"Customer Price Group")
                {
                }
                field("EFT Approved";"EFT Approved")
                {
                }
            }
        }
    }

    actions
    {
    }
}

