page 6014545 "NPR API V1 - Price List Lines"
{
    Extensible = False;

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Price List Lines';
    DelayedInsert = true;
    EntityName = 'priceListLine';
    EntitySetName = 'priceListLines';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Price List Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(priceListCode; Rec."Price List Code")
                {
                    Caption = 'Price List Code', Locked = true;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }

                field(priceType; Rec."Price Type")
                {
                    Caption = 'Price Type', Locked = true;
                }

                field(status; Rec.Status)
                {
                    Caption = 'Status', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Applies-to Type', Locked = true;
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Applies-to No.', Locked = true;
                }
                field(sourceID; Rec."Source ID")
                {
                    Caption = 'Source ID', Locked = true;
                }
                field(parentSourceNo; Rec."Parent Source No.")
                {
                    Caption = 'Parent Source No.', Locked = true;
                }
                field(assetType; Rec."Asset Type")
                {
                    Caption = 'Product Type', Locked = true;
                }
                field(assetNo; Rec."Asset No.")
                {
                    Caption = 'Product No.', Locked = true;
                }
                field(assetId; Rec."Asset ID")
                {
                    Caption = 'Asset ID', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code', Locked = true;
                }
                field(workTypeCode; Rec."Work Type Code")
                {
                    Caption = 'Work Type Code', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date', Locked = true;
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date', Locked = true;
                }
                field(minimumQuantity; Rec."Minimum Quantity")
                {
                    Caption = 'Minimum Quantity', Locked = true;
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code', Locked = true;
                }
                field(amountType; Rec."Amount Type")
                {
                    Caption = 'Defines', Locked = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price', Locked = true;
                }

#IF BC17
                // field does not exist in BC17, so do nothing.
#ELSE
                field(directUnitCost; Rec."Direct Unit Cost")
                {
                    Caption = 'Direct Unit Cost', Locked = true;
                }
#ENDIF
                field(costFactor; Rec."Cost Factor")
                {
                    Caption = 'Cost Factor', Locked = true;
                }
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'Unit Cost', Locked = true;
                }
                field(lineDiscount; Rec."Line Discount %")
                {
                    Caption = 'Line Discount %', Locked = true;
                }
                field(allowLineDisc; Rec."Allow Line Disc.")
                {
                    Caption = 'Allow Line Disc.', Locked = true;
                }
                field(allowInvoiceDisc; Rec."Allow Invoice Disc.")
                {
                    Caption = 'Allow Invoice Disc.', Locked = true;
                }
                field(priceIncludesVAT; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes VAT', Locked = true;
                }
                field(vatBusPostingGrPrice; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    Caption = 'VAT Bus. Posting Gr. (Price)', Locked = true;
                }
                field(vatProdPostingGroup; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'VAT Prod. Posting Group', Locked = true;
                }
                field(lineAmount; Rec."Line Amount")
                {
                    Caption = 'Line Amount', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
