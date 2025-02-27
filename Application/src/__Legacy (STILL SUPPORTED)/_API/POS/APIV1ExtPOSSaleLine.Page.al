page 6059788 "NPR APIV1 - Ext. POS Sale Line"
{
    Extensible = False;

    APIGroup = 'pos';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'apiv1ExternalPOSSaleLine';
    DelayedInsert = true;
    EntityName = 'externalPosSaleLine';
    EntitySetName = 'externalPosSaleLines';
    ODataKeyFields = SystemId;
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
                    Caption = 'SystemId', Locked = true;
                }
                field(externalPOSSaleEntryNo; Rec."External POS Sale Entry No.")
                {
                    Caption = 'External POS Sale Entry No.', Locked = true;
                }

                field(registerNo; Rec."Register No.")
                {
                    Caption = 'POS Unit No.', Locked = true;
                }

                field(salesTicketNo; Rec."Sales Ticket No.")
                {
                    Caption = 'Sales Ticket No.', Locked = true;
                }

                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }
                field(type; Rec."Line Type")
                {
                    Caption = 'Type', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(barcodeReference; Rec."Barcode Reference")
                {
                    Caption = 'Barcode Reference', Locked = true;
                }
                field("date"; Rec."Date")
                {
                    Caption = 'Date', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price', Locked = true;
                }
                field(vatPercent; Rec."VAT %")
                {
                    Caption = 'VAT %', Locked = true;
                }
                field(discountType; Rec."Discount Type")
                {
                    Caption = 'Discount %', Locked = true;
                }
                field(discountPercent; Rec."Discount %")
                {
                    Caption = 'Discount %', Locked = true;
                }
                field(discountAmount; Rec."Discount Amount")
                {
                    Caption = 'Discount', Locked = true;
                }

                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code', Locked = true;
                }

                field(amount; Rec.Amount)
                {
                    Caption = 'Amount', Locked = true;
                }
                field(amountIncludingVAT; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code', Locked = true;
                }
                field(priceIncludesVAT; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes VAT', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2', Locked = true;
                }
                field(customDescr; Rec."Custom Descr")
                {
                    Caption = 'Customer Description', Locked = true;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }
                field(serialNo; Rec."Serial No.")
                {
                    Caption = 'Serial No.', Locked = true;
                }

                field(currencyAmount; Rec."Currency Amount")
                {
                    Caption = 'Currency Amount', Locked = true;
                }
                field(accessory; Rec.Accessory)
                {
                    Caption = 'Accessory', Locked = true;
                }
                field(mainItemNo; Rec."Main Item No.")
                {
                    Caption = 'Main Item No.', Locked = true;
                }
                field(mainLineNo; Rec."Main Line No.")
                {
                    Caption = 'Main Line No.', Locked = true;
                }
                field(combinationItem; Rec."Combination Item")
                {
                    Caption = 'Combination Item', Locked = true;
                }
                field(combinationNo; Rec."Combination No.")
                {
                    Caption = 'Combination No.', Locked = true;
                }
                field(vatBusPostingGroup; Rec."VAT Bus. Posting Group")
                {
                    Caption = 'VAT Bus. Posting Group', Locked = true;
                }
                field(vatProdPostingGroup; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'VAT Prod. Posting Group', Locked = true;
                }
                field(vatBaseAmount; Rec."VAT Base Amount")
                {
                    Caption = 'VAT Base Amount', Locked = true;
                }
                field(genPostingType; Rec."Gen. Posting Type")
                {
                    Caption = 'Gen. Posting Type', Locked = true;
                }
                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group', Locked = true;
                }
                field(genProdPostingGroup; Rec."Gen. Prod. Posting Group")
                {
                    Caption = 'Gen. Prod. Posting Group', Locked = true;
                }
                field(postingGroup; Rec."Posting Group")
                {
                    Caption = 'Posting Group', Locked = true;
                }
                field(cost; Rec.Cost)
                {
                    Caption = 'Cost', Locked = true;
                }
                field(customCost; Rec."Custom Cost")
                {
                    Caption = 'Custom Cost', Locked = true;
                }
                field(quantityBase; Rec."Quantity (Base)")
                {
                    Caption = 'Quantity (Base)', Locked = true;
                }
                field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per Unit of Measure', Locked = true;
                }
                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'Reason Code', Locked = true;
                }

                field(returnSaleSalesTicketNo; Rec."Return Sale Sales Ticket No.")
                {
                    Caption = 'Return Sale Sales Ticket No.', Locked = true;
                }

                field(returnReasonCode; Rec."Return Reason Code")
                {
                    Caption = 'Return Reason Code', Locked = true;
                }

                field(paymentType; Rec."Payment Type")
                {
                    Caption = 'Payment Type', Locked = true;
                }

                part(externalPosEftLine; "NPR APIV1 - Ext. POS EFT Line")
                {
#if BC17
                    CaptionML = ENU = 'Multiplicity=ZeroOrOne';
#else
                    Caption = 'External Pos Sale Line', Locked = true;
                    Multiplicity = ZeroOrOne;
#endif
                    EntityName = 'externalPosEftLine';
                    EntitySetName = 'externalPosEftLines';
                    SubPageLink =
                        "External POS Sale Entry No." = field("External POS Sale Entry No."),
                        "External Pos SaleLine No" = field("Line No.");
                }
            }
        }
    }

    var
        ExternalPOSSale: Record "NPR External POS Sale";

    internal procedure SetExternalPOSSale(pExternalPOSSale: Record "NPR External POS Sale")
    var
    begin
        ExternalPOSSale := pExternalPOSSale;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ExtPOSSaleProcessing: Codeunit "NPR Ext. POS Sale Processing";
    begin
        Rec.Insert(true);
        ExtPOSSaleProcessing.TryAutoFillExternalPOSSaleLine(Rec, ExternalPOSSale);
        exit(false);
    end;




}
