page 6151004 "NPR POS Saved Sale Subp."
{
    Caption = 'POS Saved Sale Subpage';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Saved Sale Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount field';
                }
                field("Discount Code"; Rec."Discount Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Code field';
                }
                field("Discount Authorised by"; Rec."Discount Authorised by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Authorised by field';
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Price Group field';
                }
                field("EFT Approved"; Rec."EFT Approved")
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

