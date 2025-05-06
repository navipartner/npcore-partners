page 6060002 "NPR APIV1 PBIPOSEntrySalesLine"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'posEntrySalesLine';
    EntitySetName = 'posEntrySalesLines';
    Caption = 'PowerBI POS Entry Sales Line';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR POS Entry Sales Line";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(posEntryNo; Rec."POS Entry No.")
                {
                    Caption = 'POS Entry No.', Locked = true;
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.', Locked = true;
                }
                field(posStoreCode; Rec."POS Store Code")
                {
                    Caption = 'POS Store Code', Locked = true;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.', Locked = true;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }

                field(postingGroup; Rec."Posting Group")
                {
                    Caption = 'Posting Group', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price', Locked = true;
                }
                field(unitCostLcy; Rec."Unit Cost (LCY)")
                {
                    Caption = 'Unit Cost (LCY)', Locked = true;
                }
                field(vat; Rec."VAT %")
                {
                    Caption = 'VAT %', Locked = true;
                }
                field(amountExclVatLcy; Rec."Amount Excl. VAT (LCY)")
                {
                    Caption = 'Amount Excl. VAT (LCY)', Locked = true;
                }
                field(amountInclVatLcy; Rec."Amount Incl. VAT (LCY)")
                {
                    Caption = 'Amount Incl. VAT (LCY)', Locked = true;
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }
                field(itemEntryNo; Rec."Item Entry No.")
                {
                    Caption = 'Item Entry No.', Locked = true;
                }
                field(dimensionSetId; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID', Locked = true;
                }
                field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    Caption = 'Shortcut Dimension 1 Code', Locked = true;
                }
                field(shortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    Caption = 'Shortcut Dimension 2 Code', Locked = true;
                }
                field(genBusPostingGroup; Rec."Gen. Bus. Posting Group")
                {
                    Caption = 'Gen. Bus. Posting Group', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(lineDscAmtExclVATLCY; Rec."Line Dsc. Amt. Excl. VAT (LCY)")
                {
                    Caption = 'Line Dsc. Amt. Excl. VAT (LCY)';
                }
                field(lineDscAmtInclVATLCY; Rec."Line Dsc. Amt. Incl. VAT (LCY)")
                {
                    Caption = 'Line Dsc. Amt. Incl. VAT (LCY)';
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code';
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }

    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}