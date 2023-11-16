page 6059929 "NPR APIV1 PBIItemledgerEntry"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'itemLedgerEntry';
    EntitySetName = 'itemLedgerEntries';
    Caption = 'PowerBI Item Ledger Entry';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Item Ledger Entry";
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
                field(dimensionSetID; Rec."Dimension Set ID")
                {
                    Caption = 'Dimension Set ID', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(entryType; Rec."Entry Type")
                {
                    Caption = 'Entry Type', Locked = true;
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity', Locked = true;
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Source Type', Locked = true;
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source No.', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code', Locked = true;
                }
                field(shortcutDimension3Code; ShortcutDimCode[3])
                {
                    Caption = 'Shortcut Dimension 3 Code', Locked = true;
                }
                field(shortcutDimension4Code; ShortcutDimCode[4])
                {
                    Caption = 'Shortcut Dimension 4 Code', Locked = true;
                }
                field(shortcutDimension5Code; ShortcutDimCode[5])
                {
                    Caption = 'Shortcut Dimension 5 Code', Locked = true;
                }
                field(shortcutDimension6Code; ShortcutDimCode[6])
                {
                    Caption = 'Shortcut Dimension 6 Code', Locked = true;
                }
                field(shortcutDimension7Code; ShortcutDimCode[7])
                {
                    Caption = 'Shortcut Dimension 7 Code', Locked = true;
                }
                field(shortcutDimension8Code; ShortcutDimCode[8])
                {
                    Caption = 'Shortcut Dimension 8 Code', Locked = true;
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date', Locked = true;
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item No.', Locked = true;
                }
                field(variantCode; Rec."Variant Code")
                {
                    Caption = 'Variant Code', Locked = true;
                }
                field(open; Rec.Open)
                {
                    Caption = 'Open', Locked = true;
                }
                field(remainingQuantity; Rec."Remaining Quantity")
                {
                    Caption = 'Remaining Quantity', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.', Locked = true;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type', Locked = true;
                }
                field(invoicedQuantity; Rec."Invoiced Quantity")
                {
                    Caption = 'Invoiced Quantity', Locked = true;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }
                field(prodOrderCompLineNo; Rec."Prod. Order Comp. Line No.")
                {
                    Caption = 'Prod. Order Comp. Line No.', Locked = true;
                }
                field(purchasingCode; Rec."Purchasing Code")
                {
                    Caption = 'Purchasing Code', Locked = true;
                }
                field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure")
                {
                    Caption = 'Qty. per Unit of Measure', Locked = true;
                }
                field(transactionSpecification; Rec."Transaction Specification")
                {
                    Caption = 'Transaction Specification', Locked = true;
                }
                field(transactionType; Rec."Transaction Type")
                {
                    Caption = 'Transaction Type', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt', Locked = true;
                }
                field(lastModifiedDateTime; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CurrRecordRef: RecordRef;
    begin
        CurrRecordRef.GetTable(Rec);
        PowerBIUtils.UpdateSystemModifiedAtfilter(CurrRecordRef);
    end;

    trigger OnAfterGetRecord()
    begin
        DimMgt.GetShortcutDimensions(Rec."Dimension Set ID", ShortcutDimCode);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
        ShortcutDimCode: array[8] of Code[20];
}