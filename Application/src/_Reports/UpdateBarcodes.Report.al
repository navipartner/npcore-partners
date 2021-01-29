report 6014601 "NPR Update Barcodes"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Update Barcodes.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Update Barcodes';
    PreviewMode = PrintLayout;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            column(No_Item; "No.")
            {
                IncludeCaption = true;
            }
            column(CrossReferenceNo; CrossReferenceNo)
            {
            }
            dataitem("Item Variant"; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", Code);
                column(ItemNo_ItemVariant; "Item No.")
                {
                }
                column(Code_ItemVariant; Code)
                {
                    IncludeCaption = true;
                }
                column(CrossReferenceNo2; CrossReferenceNo)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    CrossReferenceNo := InsertBarcode("Item No.", Code);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CrossReferenceNo := InsertBarcode("No.", '');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Settings)
                {
                    field(InsertMissingBarcode; InsertMissingBarcode)
                    {
                        Caption = 'Insert missing barcode';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Insert missing barcode field';
                    }
                    field(IgnoreAltNo; IgnoreAltNo)
                    {
                        Caption = 'Ignore Alt. No.';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ignore Alt. No. field';
                    }
                }
            }
        }

    }

    labels
    {
        ReportCaption = 'Update Barcodes';
        PageLbl = 'Page   ';
        CrossReferenceLbl = 'Barcode';
        ItemVariantCode = 'Item Variant Code';
    }

    var
        ItemCrossReference: Record "Item Cross Reference";
        AlternativeNo: Record "NPR Alternative No.";
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
        IgnoreAltNo: Boolean;
        InsertMissingBarcode: Boolean;
        CrossReferenceNo: Code[20];
        AddPrefix: Text;

    local procedure InsertBarcode(ItemNo: Code[20]; VariantCode: Code[20]): Text
    begin
        ItemCrossReference.SetRange("Item No.", ItemNo);
        ItemCrossReference.SetRange("Variant Code", VariantCode);
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        if ItemCrossReference.FindFirst() then
            if (CheckBarcodeValidEAN13(ItemCrossReference."Cross-Reference No.") or CheckBarcodeValidEAN8(ItemCrossReference."Cross-Reference No.")) then begin
                exit(ItemCrossReference."Cross-Reference No.");
            end;

        AlternativeNo.SetRange(Code, ItemNo);
        AlternativeNo.SetRange("Variant Code", VariantCode);
        if (AlternativeNo.FindFirst()) and (not IgnoreAltNo) then
            if (CheckBarcodeValidEAN13(AlternativeNo."Alt. No.") or CheckBarcodeValidEAN8(AlternativeNo."Alt. No.")) then begin
                exit(AlternativeNo."Alt. No.");
            end;

        if not InsertMissingBarcode then
            exit;

        VarietyCloneData.InsertDefaultBarcode(ItemNo, VariantCode, false);

        Clear(ItemCrossReference);
        ItemCrossReference.SetRange("Item No.", ItemNo);
        ItemCrossReference.SetRange("Variant Code", VariantCode);
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        if ItemCrossReference.FindFirst() then
            exit(ItemCrossReference."Cross-Reference No.");

        if AlternativeNo.FindFirst() and (not IgnoreAltNo) then
            exit(AlternativeNo."Alt. No.");
    end;

    local procedure CheckBarcodeValidEAN13(barcode: Code[20]): Boolean
    var
        RegEx: Codeunit DotNet_Regex;
    begin
        if (StrLen(barcode) <> 13) or (not RegEx.IsMatch(barcode, '^[0-9]+$')) then
            exit(false)
        else
            exit(not (StrCheckSum(barcode, '1313131313131') <> 0))
    end;

    local procedure CheckBarcodeValidEAN8(barcode: Code[20]): Boolean
    var
        RegEx: Codeunit DotNet_Regex;
    begin
        if (StrLen(barcode) <> 8) or (not RegEx.IsMatch(barcode, '^[0-9]+$')) then
            exit(false)
        else
            exit(not (StrCheckSum(barcode, '3131313') <> 0))
    end;
}

