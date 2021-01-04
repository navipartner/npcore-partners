page 6151004 "NPR POS Quote Subpage"
{
    // NPR5.47/MHA /20181011  CASE 302636 Object created - POS Quote (Saved POS Sale)
    // NPR5.48/MHA /20181129  CASE 336498 Added "Customer Price Group"
    // NPR5.51/MMV /20190820  CASE 364694 Handle EFT approvals

    Caption = 'POS Quote Subpage';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR POS Quote Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount field';
                }
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Code field';
                }
                field("Discount Authorised by"; "Discount Authorised by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Authorised by field';
                }
                field("Customer Price Group"; "Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Price Group field';
                }
                field("EFT Approved"; "EFT Approved")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Electronic Funds Transfer Approved field';
                }
            }
        }
    }

    actions
    {
    }
}

