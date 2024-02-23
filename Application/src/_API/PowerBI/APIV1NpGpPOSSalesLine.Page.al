page 6150866 "NPR APIV1 NpGp POS Sales Line"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'npgpPosSalesLine';
    EntitySetName = 'npgpPosSalesLines';
    Caption = 'PowerBI NpGp POS Sales Line';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR NpGp POS Sales Line";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(id; Rec.SystemId) { }
                field(posEntryNo; Rec."POS Entry No.") { }
                field(lineNo; Rec."Line No.") { }
                field(posStoreCode; Rec."POS Store Code") { }
                field(posUnitNo; Rec."POS Unit No.") { }
                field(type; Rec."Type") { }
                field(no; Rec."No.") { }
                field(variantCode; Rec."Variant Code") { }
                field(crossReferenceNo; Rec."Cross-Reference No.") { }
                field(bomItemNo; Rec."BOM Item No.") { }
                field(locationCode; Rec."Location Code") { }
                field(description; Rec.Description) { }
                field(description2; Rec."Description 2") { }
                field(quantity; Rec.Quantity) { }
                field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure") { }
                field(quantityBase; Rec."Quantity (Base)") { }
                field(unitPrice; Rec."Unit Price") { }
                field(currencyCode; Rec."Currency Code") { }
                field(vat; Rec."VAT %") { }
                field(lineDiscount; Rec."Line Discount %") { }
                field(lineDiscountAmountExclVAT; Rec."Line Discount Amount Excl. VAT") { }
                field(lineDiscountAmountInclVAT; Rec."Line Discount Amount Incl. VAT") { }
                field(lineAmount; Rec."Line Amount") { }
                field(amountExclVAT; Rec."Amount Excl. VAT") { }
                field(amountInclVAT; Rec."Amount Incl. VAT") { }
                field(amountExclVATLCY; Rec."Amount Excl. VAT (LCY)") { }
                field(amountInclVATLCY; Rec."Amount Incl. VAT (LCY)") { }
                field(lineDscAmtExclVATLCY; Rec."Line Dsc. Amt. Excl. VAT (LCY)") { }
                field(lineDscAmtInclVATLCY; Rec."Line Dsc. Amt. Incl. VAT (LCY)") { }
                field(globalReference; Rec."Global Reference") { }
                field(documentNo; Rec."Document No.") { }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { }


#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemModifiedAt; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt)) { }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt) { }
                field(systemRowVersion; Rec.SystemRowVersion) { }
#ENDIF
            }
        }
    }
#IF NOT (BC17 or BC18 or BC19 or BC20)
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
#ENDIF

}