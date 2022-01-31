page 6059774 "NPR External POS Sale Subform"
{
    Extensible = False;

    Caption = 'External POS Sale Subform';
    PageType = ListPart;
    SourceTable = "NPR External POS Sale Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(saleType; Rec."Sale Type")
                {
                    Caption = 'Sale Type';
                    ToolTip = 'Specifies the value of the Sale Type field';
                    ApplicationArea = NPRRetail;
                }
                field(type; Rec."Type")
                {
                    Caption = 'Type';
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No field';
                    ApplicationArea = NPRRetail;
                }
                field("date"; Rec."Date")
                {
                    Caption = 'Date';
                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field(vat; Rec."VAT %")
                {
                    Caption = 'VAT %';
                    ToolTip = 'Specifies the value of the VAT Percent field';
                    ApplicationArea = NPRRetail;
                }
                field(discount; Rec."Discount %")
                {
                    Caption = 'Discount %';
                    ToolTip = 'Specifies the value of the Discount Percent field';
                    ApplicationArea = NPRRetail;
                }
                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'Discount';
                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }

                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                    ToolTip = 'Specifies the value of the Unit Of Measure Code field';
                    ApplicationArea = NPRRetail;
                }

                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(amountIncludingVAT; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT';
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field(priceIncludesVAT; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes VAT';
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                    ApplicationArea = NPRRetail;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2';
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field(customDescr; Rec."Custom Descr")
                {
                    Caption = 'Customer Description';
                    ToolTip = 'Specifies the value of the Custom Description field';
                    ApplicationArea = NPRRetail;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code';
                    ToolTip = 'Specifies the value of the Item Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field(serialNo; Rec."Serial No.")
                {
                    Caption = 'Serial No.';
                    ToolTip = 'Specifies the value of the Serial No. field';
                    ApplicationArea = NPRRetail;
                }
                field(accessory; Rec.Accessory)
                {
                    Caption = 'Accessory';
                    ToolTip = 'Specifies the value of the Accessory field';
                    ApplicationArea = NPRRetail;
                }
                field(mainItemNo; Rec."Main Item No.")
                {
                    Caption = 'Main Item No.';
                    ToolTip = 'Specifies the value of the Main Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field(mainLineNo; Rec."Main Line No.")
                {
                    Caption = 'Main Line No.';
                    ToolTip = 'Specifies the value of the Main Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(combinationItem; Rec."Combination Item")
                {
                    Caption = 'Combination Item';
                    ToolTip = 'Specifies the value of the Combination Item field';
                    ApplicationArea = NPRRetail;
                }
                field(combinationNo; Rec."Combination No.")
                {
                    Caption = 'Combination No.';
                    ToolTip = 'Specifies the value of the Combination No. field';
                    ApplicationArea = NPRRetail;
                }
                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group';
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field(vatProdPostingGroup; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'VAT Prod. Posting Group';
                    ToolTip = 'Specifies the value of the VAT Prod. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field(vatBaseAmount; Rec."VAT Base Amount")
                {
                    Caption = 'VAT Base Amount';
                    ToolTip = 'Specifies the value of the VAT Base Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(genPostingType; Rec."Gen. Posting Type")
                {
                    Caption = 'Gen. Posting Type';
                    ToolTip = 'Specifies the value of the Gen. Posting Type field';
                    ApplicationArea = NPRRetail;
                }
                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group';
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field(genProdPostingGroup; Rec."Gen. Prod. Posting Group")
                {
                    Caption = 'Gen. Prod. Posting Group';
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field(postingGroup; Rec."Posting Group")
                {
                    Caption = 'Posting Group';
                    ToolTip = 'Specifies the value of the Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field(cost; Rec.Cost)
                {
                    Caption = 'Cost';
                    ToolTip = 'Specifies the value of the Cost field';
                    ApplicationArea = NPRRetail;
                }
                field(customCost; Rec."Custom Cost")
                {
                    Caption = 'Custom Cost';
                    ToolTip = 'Specifies the value of the Custom Cost field';
                    ApplicationArea = NPRRetail;
                }
                field(quantityBase; Rec."Quantity (Base)")
                {
                    Caption = 'Quantity (Base)';
                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per Unit of Measure';
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field';
                    ApplicationArea = NPRRetail;
                }
                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'Reason Code';
                    ToolTip = 'Specifies the value of the Reason Code field';
                    ApplicationArea = NPRRetail;
                }

                field(returnSaleSalesTicketNo; Rec."Return Sale Sales Ticket No.")
                {
                    Caption = 'Return Sale Sales Ticket No.';
                    ToolTip = 'Specifies the value of the Return Sale Sales Ticket No. field';
                    ApplicationArea = NPRRetail;
                }

                field(returnReasonCode; Rec."Return Reason Code")
                {
                    Caption = 'Return Reason Code';
                    ToolTip = 'Specifies the value of the Return Reason Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
