report 6014601 "NPR Update Barcodes"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Update Barcodes';
    ProcessingOnly = true;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            dataitem("Item Variant"; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", Code);

                trigger OnAfterGetRecord()
                begin
                    InsertBarcode("Item No.", Code);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                InsertBarcode("No.", '');
            end;
        }

    }

    requestpage
    {
        SaveValues = true;
    }

    trigger OnPostReport()
    var
        NoOfBarCodesCreatedMsg: Label '%1 new barcodes created.', Comment = '%1 - Number of new barcodes';
        NoNewBarcodes: Label 'No new bar codes created.';
    begin
        if NoOfBarCodesCreated <> 0 then
            Message(NoOfBarCodesCreatedMsg, NoOfBarCodesCreated)
        else
            Message(NoNewBarcodes);
    end;

    var
        NoOfBarCodesCreated: Integer;
        VarietyCloneData: Codeunit "NPR Variety Clone Data";
        ItemReference: Record "Item Reference";

    local procedure InsertBarcode(ItemNo: Code[20]; VariantCode: Code[10])
    begin
        ItemReference.SetRange("Item No.", ItemNo);
        ItemReference.SetRange("Variant Code", VariantCode);
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        if ItemReference.FindFirst() then
            if (CheckBarcodeValidEAN13(ItemReference."Reference No.") or CheckBarcodeValidEAN8(ItemReference."Reference No.")) then
                exit;

        VarietyCloneData.InsertDefaultBarcode(ItemNo, VariantCode, false);
        NoOfBarCodesCreated += 1;
    end;

    local procedure CheckBarcodeValidEAN13(barcode: Code[50]): Boolean
    var
        NpRegEx: Codeunit "NPR RegEx";
    begin
        if (StrLen(barcode) <> 13) or (not NpRegEx.IsMatch(barcode, '^[0-9]+$')) then
            exit(false)
        else
            exit(not (StrCheckSum(barcode, '1313131313131') <> 0))
    end;

    local procedure CheckBarcodeValidEAN8(barcode: Code[50]): Boolean
    var
        NpRegEx: Codeunit "NPR RegEx";
    begin
        if (StrLen(barcode) <> 8) or (not NpRegEx.IsMatch(barcode, '^[0-9]+$')) then
            exit(false)
        else
            exit(not (StrCheckSum(barcode, '3131313') <> 0))
    end;
}

