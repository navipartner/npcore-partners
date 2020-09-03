report 6060110 "NPR Add EAN barcode to items"
{
    // NPR4.18/MMV/20153011 CASE 228269 Created report
    // 
    // Report does not handle barcodes for any of our current variant systems at this moment!
    // NPR5.36/TJ /20170927 CASE 286283 Renamed variables into english and into proper naming terminology

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
                FoundValid: Boolean;
                Itt: Integer;
                RetailFormCode: Codeunit "NPR Retail Form Code";
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
                                Item.Modify;
                                FoundValid := true;
                            end;
                        until ((AltNo.Next = 0) or (FoundValid = true));

                    //Generate new EAN
                    if not FoundValid then
                        if not CreateNewBarcode(Item, '*', '') then
                            Error(Text1000001);

                end;
                Itt += 1;

                if Itt mod (Total / 100) = 0 then
                    ProgressDialog.Update(1, Round(Itt / Total * 10000, 1, '>'));
            end;

            trigger OnPostDataItem()
            begin
                ProgressDialog.Close;
                Message(Text1000004);
            end;

            trigger OnPreDataItem()
            begin
                Total := Item.Count;
                ProgressDialog.Open('Progress : @@1@@@@@@@@@@');
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if not Confirm(Text1000002) then
            CurrReport.Quit;

        if Confirm(Text1000003) then
            ExportAllBarcodes;
    end;

    var
        Total: Integer;
        Itt: Integer;
        ProgressDialog: Dialog;
        Text1000001: Label 'Error when creating new barcode';
        Text1000002: Label 'Do you want to check all items for valid EAN barcodes and generate new ones where needed?';
        Text1000003: Label 'Do you want to export all item barcodes and associated alternative numbers first?';
        Text1000004: Label 'All items are now updated with EAN barcodes';

    local procedure CheckBarcodeValid(barcode: Code[20]): Boolean
    var
        InputDialog: Page "NPR Input Dialog";
        NrSerieStyring: Codeunit NoSeriesManagement;
        Internnr: Code[10];
        Intereankode: Code[10];
        Vare: Record Item;
        "alt.varenummer": Record "NPR Alternative No.";
    begin
        //EAN13 check
        if StrLen(barcode) <> 13 then
            exit(false)
        else
            exit(not (StrCheckSum(barcode, '1313131313131') <> 0))
    end;

    local procedure CreateNewBarcode(var Rec: Record Item; AltNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        InputDialog: Page "NPR Input Dialog";
        RetailSetup: Record "NPR Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        InternNo: Code[10];
        InterEANCode: Code[10];
        Text10600006: Label 'Chack digits are incorrect on EAN no.';
        Text10600007: Label 'Item No. #1###';
        Item2: Record Item;
        Text10600008: Label 'Item %1 exists already!';
        Text10600009: Label 'No. %1 exists already on item %2!';
        AlternativeNo: Record "NPR Alternative No.";
    begin
        //Copied from Retail Form Code (CU 6014435) CreateNewAltItem() but removed xrec

        if AltNo = '*' then begin
            RetailSetup.Get;
            RetailSetup.TestField("Internal EAN No. Management");
            NoSeriesMgt.InitSeries(RetailSetup."Internal EAN No. Management", '', 0D, InternNo, Rec."No. Series");

            InterEANCode := Format(RetailSetup."EAN-Internal");
            AltNo := InterEANCode + PadStr('', 10 - StrLen(Format(InternNo)), '0') + Format(InternNo);
            AltNo := AltNo + Format(StrCheckSum(AltNo, '131313131313'));
            if StrCheckSum(AltNo, '1313131313131') <> 0 then
                Error(Text10600006);
        end;

        if Item2.Get(AltNo) then
            Error(Text10600008, Item2."No.");

        AlternativeNo.SetCurrentKey("Alt. No.");
        AlternativeNo.SetRange("Alt. No.", AltNo);
        if AlternativeNo.Find('-') then
            Error(Text10600009, AltNo, AlternativeNo.Code);

        AlternativeNo.Reset;
        AlternativeNo.Type := AlternativeNo.Type::Item;
        AlternativeNo.Code := Rec."No.";
        AlternativeNo."Alt. No." := AltNo;
        AlternativeNo."Variant Code" := VariantCode;
        AlternativeNo.Insert(true);
        Rec."NPR Label Barcode" := AlternativeNo."Alt. No.";
        Rec.Modify;

        exit(true);
    end;

    local procedure ExportAllBarcodes()
    var
        TableExportLibrary: Codeunit "NPR Table Export Library";
        AltNo: Record "NPR Alternative No.";
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

