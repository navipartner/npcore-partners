page 6150865 "NPR APIV1 NpGp POS Sales Entry"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'npgpPosSalesEntry';
    EntitySetName = 'npgpPosSalesEntries';
    Caption = 'PowerBI NpGp POS Sales Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR NpGp POS Sales Entry";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(id; Rec.SystemId) { }
                field(entryNo; Rec."Entry No.") { }
                field(entryTime; Rec."Entry Time") { }
                field(entryType; Rec."Entry Type") { }
                field(posStoreCode; Rec."POS Store Code") { }
                field(posUnitNo; Rec."POS Unit No.") { }
                field(documentNo; Rec."Document No.") { }
                field(postingDate; Rec."Posting Date") { }
                field(fiscalNo; Rec."Fiscal No.") { }
                field(salespersonCode; Rec."Salesperson Code") { }
                field(currencyCode; Rec."Currency Code") { }
                field(currencyFactor; Rec."Currency Factor") { }
                field(salesAmount; Rec."Sales Amount") { }
                field(discountAmount; Rec."Discount Amount") { }
                field(returnSalesQuantity; Rec."Return Sales Quantity") { }
                field(totalAmount; Rec."Total Amount") { }
                field(totalAmountInclTax; Rec."Total Amount Incl. Tax") { }
                field(totalTaxAmount; Rec."Total Tax Amount") { }
                field(originalCompany; Rec."Original Company") { }
                field(customerNo; Rec."Customer No.") { }
                field(membershipNo; Rec."Membership No.") { }
                field(salesQuantity; Rec."Sales Quantity") { }

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