page 6059788 "NPR APIV1 - Ext. POS Sale Line"
{

    APIGroup = 'pos';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'apiv1ExternalPOSSaleLine';
    DelayedInsert = true;
    EntityName = 'externalPosSaleLine';
    EntitySetName = 'externalPosSaleLines';
    PageType = API;
    SourceTable = "NPR External POS Sale Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(externalPOSSaleEntryNo; Rec."External POS Sale Entry No.")
                {
                    Caption = 'External POS Sale Entry No.';
                }

                field(registerNo; Rec."Register No.")
                {
                    Caption = 'POS Unit No.';
                }

                field(salesTicketNo; Rec."Sales Ticket No.")
                {
                    Caption = 'Sales Ticket No.';
                }

                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(saleType; Rec."Sale Type")
                {
                    Caption = 'Sale Type';
                }
                field(type; Rec."Type")
                {
                    Caption = 'Type';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field("date"; Rec."Date")
                {
                    Caption = 'Date';
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(vatPercent; Rec."VAT %")
                {
                    Caption = 'VAT %';
                }
                field(discountType; Rec."Discount Type")
                {
                    Caption = 'Discount %';
                }
                field(discountPercent; Rec."Discount %")
                {
                    Caption = 'Discount %';
                }
                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'Discount';
                }

                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }

                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(amountIncludingVAT; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(priceIncludesVAT; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes VAT';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2';
                }
                field(customDescr; Rec."Custom Descr")
                {
                    Caption = 'Customer Description';
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }
                field(serialNo; Rec."Serial No.")
                {
                    Caption = 'Serial No.';
                }

                field(currencyAmount; Rec."Currency Amount")
                {
                    Caption = 'Currency Amount';
                }
                field(accessory; Rec.Accessory)
                {
                    Caption = 'Accessory';
                }
                field(mainItemNo; Rec."Main Item No.")
                {
                    Caption = 'Main Item No.';
                }
                field(mainLineNo; Rec."Main Line No.")
                {
                    Caption = 'Main Line No.';
                }
                field(combinationItem; Rec."Combination Item")
                {
                    Caption = 'Combination Item';
                }
                field(combinationNo; Rec."Combination No.")
                {
                    Caption = 'Combination No.';
                }
                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group';
                }
                field(vatProdPostingGroup; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'VAT Prod. Posting Group';
                }
                field(vatBaseAmount; Rec."VAT Base Amount")
                {
                    Caption = 'VAT Base Amount';
                }
                field(genPostingType; Rec."Gen. Posting Type")
                {
                    Caption = 'Gen. Posting Type';
                }
                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group';
                }
                field(genProdPostingGroup; Rec."Gen. Prod. Posting Group")
                {
                    Caption = 'Gen. Prod. Posting Group';
                }
                field(postingGroup; Rec."Posting Group")
                {
                    Caption = 'Posting Group';
                }
                field(cost; Rec.Cost)
                {
                    Caption = 'Cost';
                }
                field(customCost; Rec."Custom Cost")
                {
                    Caption = 'Custom Cost';
                }
                field(quantityBase; Rec."Quantity (Base)")
                {
                    Caption = 'Quantity (Base)';
                }
                field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per Unit of Measure';
                }
                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'Reason Code';
                }

                field(returnSaleSalesTicketNo; Rec."Return Sale Sales Ticket No.")
                {
                    Caption = 'Return Sale Sales Ticket No.';
                }

                field(returnReasonCode; Rec."Return Reason Code")
                {
                    Caption = 'Return Reason Code';
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        LineNoInt: Integer;
        LastExtPOSSalesLine: Record "NPR External POS Sale Line";
        Currency: Record Currency;
    begin
        IF Rec."Line No." = 0 then begin
            LineNoInt += 10000;
            LastExtPOSSalesLine.SetRange("External POS Sale Entry No.", Rec."External POS Sale Entry No.");
            IF LastExtPOSSalesLine.FindLast() then
                LineNoInt := LastExtPOSSalesLine."Line No." + 10000;

            Rec."Line No." := LineNoInt;
        end;

        // try calculate discounts if not provided via api call
        IF (Rec."Discount %" <> 0) AND (Rec."Discount Amount" = 0) then begin
            Rec.GetCurrency(Currency);
            Rec."Discount Amount" := Round((Rec.Quantity * Rec."Unit Price") * (Rec."Discount %" / 100), Currency."Amount Rounding Precision");
        end;
        IF (Rec."Discount Amount" <> 0) AND (Rec."Discount %" = 0) then begin
            Rec.GetCurrency(Currency);
            Rec."Discount %" := Round(Rec."Discount Amount" / (Rec.Quantity * Rec."Unit Price") * 100, Currency."Amount Rounding Precision");
        end;
    end;
}
