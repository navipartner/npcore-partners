codeunit 6059965 "NPR MPOS Webservice"
{
    trigger OnRun()
    var
        WebServiceMgt: Codeunit "Web Service Management";
    begin
        WebServiceMgt.CreateTenantWebService(5, Codeunit::"NPR MPOS Webservice", 'mpos_service', true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Web Service Aggregate", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWebServiceAggregate(var Rec: Record "Web Service Aggregate"; RunTrigger: Boolean)
    var
    begin
        if Rec."Object Type" <> Rec."Object Type"::Codeunit then
            exit;
        if Rec."Service Name" <> 'mpos_service' then
            exit;

        Rec."All Tenants" := false;
    end;

    procedure GetCompanyLogo() PictureBase64: Text
    var
        CompanyInformation: Record "Company Information";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        CompanyInformation.Get();

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue() then begin
            CompanyInformation.Picture.CreateInStream(InStr);
            PictureBase64 := Base64Convert.ToBase64(InStr);
        end;

        exit(PictureBase64);
    end;

    procedure GetCompanyInfo(): Text
    var
        CompanyInformation: Record "Company Information";
        InStr: InStream;
        JObject: JsonObject;
        Base64String: Text;
        MPOSHelperFunctions: Codeunit "NPR MPOS Helper Functions";
        Base64Convert: Codeunit "Base64 Convert";
        Result: Text;
    begin
        CompanyInformation.Get();

        CompanyInformation.CalcFields(Picture);
        if CompanyInformation.Picture.HasValue() then begin
            CompanyInformation.Picture.CreateInStream(InStr);
            Base64String := Base64Convert.ToBase64(InStr);
        end;

        JObject.Add('Base64Image', Base64String);
        JObject.Add('Username', MPOSHelperFunctions.GetUsername());
        JObject.Add('DatabaseName', MPOSHelperFunctions.GetDatabaseName());
        JObject.Add('TenantID', MPOSHelperFunctions.GetTenantID());
        JObject.Add('CompanyName', CompanyName);
        JObject.WriteTo(Result);
        exit(Result);
    end;

    procedure InitMPOSWebService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, MPOSWebServiceCodeunitId(), 'mpos_service', true);
    end;

    procedure MPOSWebServiceCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR MPOS Webservice");
    end;

    procedure GetNaviConnectViews(): Text
    var
        DataViewMgt: Codeunit "NPR MPOS Data View Mgt.";
        DataViews: JsonToken;
    begin
        DataViews := DataViewMgt.GetViews("NPR MPOS Data View Type"::NaviConnect);
        exit(DataViewMgt.FormatResultAsText(DataViews));
    end;

    procedure GetBarcodeInventoryViews(): Text
    var
        DataViewMgt: Codeunit "NPR MPOS Data View Mgt.";
        DataViews: JsonToken;
    begin
        DataViews := DataViewMgt.GetViews("NPR MPOS Data View Type"::NaviConnect, "NPR MPOS Data View Category"::"Barcode Inventory");
        exit(DataViewMgt.FormatResultAsText(DataViews));
    end;

    procedure GetBarcodeInventoryView(DataViewCode: Code[20]; Barcode: Code[50]): Text
    var
        DataViewMgt: Codeunit "NPR MPOS Data View Mgt.";
        DataView: JsonToken;
        Request: JsonValue;
    begin
        Request.ReadFrom('"' + Barcode + '"');
        DataView := DataViewMgt.GetView("NPR MPOS Data View Type"::NaviConnect, "NPR MPOS Data View Category"::"Barcode Inventory", DataViewCode, Request.AsToken());
        exit(DataViewMgt.FormatResultAsText(DataView));
    end;

    procedure GetBarcodeInventorySmallView(Barcode: Code[50]): Text
    var
        DataView: Record "NPR MPOS Data View";
    begin
        DataView.SetRange("Data View Type", DataView."Data View Type"::NaviConnect);
        DataView.SetRange("Data View Category", DataView."Data View Category"::"Barcode Inventory");
        DataView.SetRange("Response Size", DataView."Response Size"::Small);
        DataView.FindFirst();
        exit(GetBarcodeInventoryView(DataView."Data View Code", Barcode));
    end;

    procedure GetBarcodeInventoryMediumView(Barcode: Code[50]): Text
    var
        DataView: Record "NPR MPOS Data View";
    begin
        DataView.SetRange("Data View Type", DataView."Data View Type"::NaviConnect);
        DataView.SetRange("Data View Category", DataView."Data View Category"::"Barcode Inventory");
        DataView.SetRange("Response Size", DataView."Response Size"::Medium);
        DataView.FindFirst();
        exit(GetBarcodeInventoryView(DataView."Data View Code", Barcode));
    end;

    procedure GetBarcodeInventoryLargeView(Barcode: Code[50]): Text
    var
        DataView: Record "NPR MPOS Data View";
    begin
        DataView.SetRange("Data View Type", DataView."Data View Type"::NaviConnect);
        DataView.SetRange("Data View Category", DataView."Data View Category"::"Barcode Inventory");
        DataView.SetRange("Response Size", DataView."Response Size"::Large);
        DataView.FindFirst();
        exit(GetBarcodeInventoryView(DataView."Data View Code", Barcode));
    end;

    [Obsolete('Replaced by new function GetBarcodeInventoryView.', '2023-06-28')]
    procedure GetItemInfoByBarcode(Barcode: Code[20]): Text
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        PurchaseLine: Record "Purchase Line";
        BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
        VariantCode: Code[10];
        ItemNo: Code[20];
        ResolvingTable: Integer;
        Placeholder5Lbl: Label '%1\n%2\n%3', Comment = '%1 - placeholder 1, %2 - placeholder 2, %3 - placeholder 3';
        PlaceholderLbl: Label '%1#%2', Comment = '%1 - placeholder 1, %2 - placeholder 2';
        Placeholder3Lbl: Label 'Exp.: %1', Comment = '%1 - placeholder 1';
        Placeholder4Lbl: Label 'Last: %1', Comment = '%1 - placeholder 1';
        Placeholder2Lbl: Label 'Stock: %1', Comment = '%1 - placeholder 1';
        NotApplicableLbl: Label 'N/A', Locked = true;
        DetailTxt: Text;
        ItemInventoryTxt: Text;
        ItemLedgerEntryPostingDateTxt: Text;
        MasterTxt: Text;
        PurchaseLineExpectedReceiptDateTxt: Text;
    begin
        MasterTxt := NotApplicableLbl;
        DetailTxt := NotApplicableLbl;

        if Barcode = '' then
            exit(StrSubstNo(PlaceholderLbl, MasterTxt, DetailTxt));

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
            exit(StrSubstNo(PlaceholderLbl, MasterTxt, DetailTxt));

        if not Item.Get(ItemNo) then
            exit(StrSubstNo(PlaceholderLbl, MasterTxt, DetailTxt));

        if VariantCode <> '' then
            Item.SetFilter("Variant Filter", VariantCode);

        Item.CalcFields(Inventory, "Qty. on Purch. Order");

        DetailTxt := Format(Item.Inventory);
        ItemInventoryTxt := StrSubstNo(Placeholder2Lbl, Item.Inventory);

        if Item."Qty. on Purch. Order" > 0 then begin
            Clear(PurchaseLine);
            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
            PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
            PurchaseLine.SetRange("No.", Item."No.");
            if VariantCode <> '' then
                PurchaseLine.SetRange("Variant Code", VariantCode);
            if PurchaseLine.FindLast() then
                PurchaseLineExpectedReceiptDateTxt := StrSubstNo(Placeholder3Lbl, PurchaseLine."Expected Receipt Date")
            else
                PurchaseLineExpectedReceiptDateTxt := StrSubstNo(Placeholder3Lbl, NotApplicableLbl);
        end else
            PurchaseLineExpectedReceiptDateTxt := StrSubstNo(Placeholder3Lbl, NotApplicableLbl);

        Clear(ItemLedgerEntry);
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        if VariantCode <> '' then
            ItemLedgerEntry.SetRange("Variant Code", VariantCode);
        if ItemLedgerEntry.FindLast() then
            ItemLedgerEntryPostingDateTxt := StrSubstNo(Placeholder4Lbl, ItemLedgerEntry."Posting Date")
        else
            ItemLedgerEntryPostingDateTxt := StrSubstNo(Placeholder4Lbl, NotApplicableLbl);

        MasterTxt := StrSubstNo(Placeholder5Lbl, ItemInventoryTxt, PurchaseLineExpectedReceiptDateTxt, ItemLedgerEntryPostingDateTxt);

        exit(StrSubstNo(PlaceholderLbl, DetailTxt, MasterTxt));
    end;

    procedure ValidateBarcode(Barcode: Code[20]): Text;
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ItemVariant: Record "Item Variant";
        BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
        VariantCode: Code[10];
        ItemNo: Code[20];
        ResolvingTable: Integer;
        InvalidBarcodeErr: Label 'ERROR: INVALID BARCODE';
        UnknownBarcodeErr: Label 'ERROR: UNKNOWN BARCODE';
        UnknownItemErr: Label 'ERROR: UNKNOWN ITEM';
        ResultTxt: Label '%1: %2#%3: %4#%5: %6';
    begin
        if Barcode = '' then
            exit(InvalidBarcodeErr);

        if not BarcodeLibrary.TranslateBarcodeToItemVariant(Barcode, ItemNo, VariantCode, ResolvingTable, true) then
            exit(UnknownBarcodeErr);

        if not Item.Get(ItemNo) then
            exit(UnknownItemErr);

        if VariantCode <> '' then
            ItemVariant.Get(Item."No.", VariantCode);

        if Item."Item Category Code" <> '' then
            ItemCategory.Get(Item."Item Category Code");

        exit(StrSubstNo(ResultTxt, Item."No.", Item.Description, ItemVariant.Code, ItemVariant.Description, Item."Item Category Code", ItemCategory.Description));
    end;

    procedure GetAdyenTapToPayBoardingToken(BoardingRequestToken: Text): Text;
    var
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenTTPInteg: Codeunit "NPR EFT Adyen TTP Integ.";
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup";
        EFTAdyneBoardingToken: Codeunit "NPR EFT Adyen Boarding Token";
        Base64Token: Text;
        LblUserSetup: Label 'No such user in UserSetup %1';
        LblPosUnit: Label 'User not registered for a POS Unit';
        LblEftSetup: Label 'No mathcing EFT setup was found for POS unit %1';
        LblAdyenPaySetup: Label 'No matching setup was found for Adyen Payment Parameters for payment type %1';
        LblUnitSetupNotFound: Label 'No matching eft unit parameter setup for this POS';
    begin
        if (not UserSetup.Get(UserId())) then
            Error(LblUserSetup, UserId());
        if (not POSUnit.Get(UserSetup."NPR POS Unit No.")) then
            Error(LblPosUnit);
        EFTSetup.SetRange("POS Unit No.", POSUnit."No.");
        EFTSetup.SetRange("EFT Integration Type", EFTAdyenTTPInteg.IntegrationType());
        if (not EFTSetup.FindFirst()) then
            Error(LblEftSetup, POSUnit."No.");
        if (not EFTAdyenPaymTypeSetup.Get(EFTSetup."Payment Type POS")) then
            Error(LblAdyenPaySetup, EFTSetup."Payment Type POS");
        if (not EFTAdyenUnitSetup.Get(POSUnit."No.")) then
            Error(LblUnitSetupNotFound);
        EFTAdyneBoardingToken.RequestBoardingToken(EFTAdyenPaymTypeSetup, EFTAdyenUnitSetup."In Person Store Id", BoardingRequestToken, Base64Token);
        exit(Base64Token);
    end;
}

