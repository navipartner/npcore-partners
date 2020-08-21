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
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                }
                field("Discount Authorised by"; "Discount Authorised by")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                    ApplicationArea = All;
                }
                field("EFT Approved"; "EFT Approved")
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

