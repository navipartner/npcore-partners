report 6060110 "NPR Add EAN barcode to items"
{
    Caption = 'Add EAN barcode to all items';
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem(Item; Item)
        {

            trigger OnAfterGetRecord()
            var
                AltNo: Record "NPR Alternative No.";
                RetailFormCode: Codeunit "NPR Retail Form Code";
                FoundValid: Boolean;
                Itt: Integer;
            begin
                //Does item already have a valid 'Label Barcode'
                if not (CheckBarcodeValid(Item."NPR Label Barcode")) then begin
                    //Check alt no for valid EAN
                    AltNo.SetRange(Type, AltNo.Type::Item);
                    AltNo.SetRange(AltNo.Code, Item."No.");
                    AltNo.SetRange(AltNo."Variant Code", '');
                    FoundValid := false;
                    if AltNo.FindSet then
                        repeat
                            if CheckBarcodeValid(AltNo."Alt. No.") then begin
                                Item."NPR Label Barcode" := AltNo."Alt. No.";
                                Item.Modify();
                                FoundValid := true;
                            end;
                        until ((AltNo.Next() = 0) or (FoundValid = true));

                    //Generate new EAN
                    if not FoundValid then
                        if not CreateNewBarcode(Item, '*', '') then
                            Error(CreateBarcodeErr);

                end;
                Itt += 1;

                if Itt mod (Total / 100) = 0 then
                    ProgressDialog.Update(1, Round(Itt / Total * 10000, 1, '>'));
            end;

            trigger OnPostDataItem()
            begin
                ProgressDialog.Close();
                Message(UpdatedItemsMsg);
            end;

            trigger OnPreDataItem()
            var
                ProgressLbl: Label 'Progress : @@1@@@@@@@@@@';
            begin
                Total := Item.Count;
                ProgressDialog.Open(ProgressLbl);
            end;
        }
    }

    trigger OnPreReport()
    begin
        if not Confirm(CheckItemsQst) then
            CurrReport.Quit();

        if Confirm(ExportItemsQst) then
            ExportAllBarcodes();
    end;

    var
        ProgressDialog: Dialog;
        Itt: Integer;
        Total: Integer;
        UpdatedItemsMsg: Label 'All items are now updated with EAN barcodes';
        CheckItemsQst: Label 'Do you want to check all items for valid EAN barcodes and generate new ones where needed?';
        ExportItemsQst: Label 'Do you want to export all item barcodes and associated alternative numbers first?';
        CreateBarcodeErr: Label 'Error when creating new barcode';

    local procedure CheckBarcodeValid(barcode: Code[20]): Boolean
    var
        Vare: Record Item;
        "alt.varenummer": Record "NPR Alternative No.";
        NrSerieStyring: Codeunit NoSeriesManagement;
        InputDialog: Page "NPR Input Dialog";
        Intereankode: Code[10];
        Internnr: Code[10];
    begin
        //EAN13 check
        if StrLen(barcode) <> 13 then
            exit(false)
        else
            exit(not (StrCheckSum(barcode, '1313131313131') <> 0))
    end;

    local procedure CreateNewBarcode(var Rec: Record Item; AltNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        Item2: Record Item;
        AlternativeNo: Record "NPR Alternative No.";
        RetailSetup: Record "NPR Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        InputDialog: Page "NPR Input Dialog";
        InterEANCode: Code[10];
        InternNo: Code[10];
        IncorrectDigitsErr: Label 'Chack digits are incorrect on EAN no.';
        ItemExistErr: Label 'Item %1 exists already!', Comment = '%1 = Item No.';
        AlternativeNoExistErr: Label 'No. %1 exists already on item %2!', Comment = '%1 = Alternative No., %2 = Item No.';
    begin
        //Copied from Retail Form Code (CU 6014435) CreateNewAltItem() but removed xrec

        if AltNo = '*' then begin
            RetailSetup.Get();
            RetailSetup.TestField("Internal EAN No. Management");
            NoSeriesMgt.InitSeries(RetailSetup."Internal EAN No. Management", '', 0D, InternNo, Rec."No. Series");

            InterEANCode := Format(RetailSetup."EAN-Internal");
            AltNo := InterEANCode + PadStr('', 10 - StrLen(Format(InternNo)), '0') + Format(InternNo);
            AltNo := AltNo + Format(StrCheckSum(AltNo, '131313131313'));
            if StrCheckSum(AltNo, '1313131313131') <> 0 then
                Error(IncorrectDigitsErr);
        end;

        if Item2.Get(AltNo) then
            Error(ItemExistErr, Item2."No.");

        AlternativeNo.SetCurrentKey("Alt. No.");
        AlternativeNo.SetRange("Alt. No.", AltNo);
        if AlternativeNo.Find('-') then
            Error(AlternativeNoExistErr, AltNo, AlternativeNo.Code);

        AlternativeNo.Reset();
        AlternativeNo.Type := AlternativeNo.Type::Item;
        AlternativeNo.Code := Rec."No.";
        AlternativeNo."Alt. No." := AltNo;
        AlternativeNo."Variant Code" := VariantCode;
        AlternativeNo.Insert(true);
        Rec."NPR Label Barcode" := AlternativeNo."Alt. No.";
        Rec.Modify();

        exit(true);
    end;

    local procedure ExportAllBarcodes()
    var
        AltNo: Record "NPR Alternative No.";
        TableExportLibrary: Codeunit "NPR Table Export Library";
    begin
        TableExportLibrary.SetFileModeDotNetStream();
        TableExportLibrary.SetShowStatus(true);
        TableExportLibrary.SetWriteTableInformation(true);

        TableExportLibrary.AddTableForExport(DATABASE::Item);
        TableExportLibrary.AddFieldForExport(DATABASE::Item, 1);
        TableExportLibrary.AddFieldForExport(DATABASE::Item, 6014410);
        TableExportLibrary.AddTableForExport(DATABASE::"NPR Alternative No.");
        AltNo.SetRange(Type, AltNo.Type::Item);
        TableExportLibrary.SetTableView(DATABASE::"NPR Alternative No.", AltNo.GetView(false));
        TableExportLibrary.ExportTableBatch();
    end;
}

