page 6150842 "NPR POS Stores Modify Step"
{
    Extensible = False;
    Caption = 'POS Stores';
    PageType = ListPart;
    InsertAllowed = false;
    SourceTable = "NPR POS Store";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the POS store name which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        DimValueList: Page "Dimension Value List";
                    begin
                        GLSetup.Get();

                        DimValueList.LookupMode := true;

                        DimValue.SetRange("Global Dimension No.", 1);
                        DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");

                        if DimValue.FindFirst() then;
                        DimValueList.SetTableView(DimValue);

                        if Rec."Global Dimension 1 Code" <> '' then begin
                            DimValue.SetRange(Code, Rec."Global Dimension 1 Code");
                            if DimValue.FindFirst() then
                                DimValueList.SetRecord(DimValue);
                        end;

                        if DimValueList.RunModal() = Action::LookupOK then begin
                            DimValueList.GetRecord(DimValue);
                            Rec."Global Dimension 1 Code" := DimValue.Code;
                        end;
                    end;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DimValue: Record "Dimension Value";
                        DimValueList: Page "Dimension Value List";
                    begin
                        GLSetup.Get();

                        DimValueList.LookupMode := true;

                        DimValue.SetRange("Global Dimension No.", 2);
                        DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");

                        if DimValue.FindFirst() then;
                        DimValueList.SetTableView(DimValue);

                        if Rec."Global Dimension 2 Code" <> '' then begin
                            DimValue.SetRange(Code, Rec."Global Dimension 2 Code");
                            if DimValue.FindFirst() then
                                DimValueList.SetRecord(DimValue);
                        end;

                        if DimValueList.RunModal() = Action::LookupOK then begin
                            DimValueList.GetRecord(DimValue);
                            Rec."Global Dimension 2 Code" := DimValue.Code;
                        end;
                    end;
                }
                field("Name 2"; Rec."Name 2")
                {
                    ToolTip = 'Specifies a longer legal name of the store, if necessary. This name is not displayed on sales documents by default.';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the POS store address which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ToolTip = 'Specifies the optional second address.';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the POS store''s postal code which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the city in which the POS store is located.';
                    ApplicationArea = NPRRetail;
                }
                field(Contact; Rec.Contact)
                {
                    ToolTip = 'Specifies the name of the person that should be contacted regarding information about the store. This is also displayed on sales documents, receipts etc. ';
                    ApplicationArea = NPRRetail;
                }
                field(County; Rec.County)
                {
                    ToolTip = 'Specifies the country in which the POS store is located.';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the POS store''s country/region code which will be displayed on sales documents, receipts etc. If you are reporting for Intrastat, please ensure this is correct.';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the POS store''s location code, which is used for registering the store''s inventory. This field needs to be populated if your company has more than one store, if not, the location code is optional.';
                    ApplicationArea = NPRRetail;
                }
                field(Inactive; Rec.Inactive)
                {
                    ToolTip = 'Defines is POS Store inactive';
                    ApplicationArea = NPRRetail;
                }
                field("Language Code"; Rec."Language Code")
                {
                    ToolTip = 'Specifies the system language, which could be for example DK (Danish) or ENG (English) among others.';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ToolTip = 'Specifies a unique number used for identifying a registered store owner.';
                    ApplicationArea = NPRRetail;
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ToolTip = 'Specifies the registration number. Will display on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("Exchange Label EAN Code"; Rec."Exchange Label EAN Code")
                {
                    ToolTip = 'Specifies the code that creates EAN Label on this store';
                    ApplicationArea = NPRRetail;
                }

                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the POS store''s phone number, which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ToolTip = 'Specifies the POS store''s email, which will be displayed on sales documents, receipts etc.';
                    ApplicationArea = NPRRetail;
                }
                field("Home Page"; Rec."Home Page")
                {
                    ToolTip = 'Specifies the store''s home page URL.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Restaurant Profile"; Rec."POS Restaurant Profile")
                {
                    ToolTip = 'Specifies which restaurant the store is connected to.';
                    ApplicationArea = NPRRetail;
                }
                field("POS Posting Profile"; Rec."POS Posting Profile")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies which General and VAT Posting group this store is using as well as journal definitions etc.';
                    ApplicationArea = NPRRetail;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the code for the responsibility center that will administer this POS store by default.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Group Code"; Rec."Store Group Code")
                {
                    ToolTip = 'Specifies the code of store groups. This is a useful field for reporting.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Category Code"; Rec."Store Category Code")
                {
                    ToolTip = 'Specifies the code of store categories. This is a useful field for reporting.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Locality Code"; Rec."Store Locality Code")
                {
                    ToolTip = 'Specifies the locality code of stores. This is a useful field for reporting.';
                    ApplicationArea = NPRRetail;
                }
                field("Store Size"; Rec."Store Size")
                {
                    ToolTip = 'Specifies the size of the POS store in square meters. ';
                    ApplicationArea = NPRRetail;
                }
                field("Opening Date"; Rec."Opening Date")
                {
                    ToolTip = 'Specifies the first business day. This field is used for reports.';
                    ApplicationArea = NPRRetail;
                }
                field("Geolocation Latitude"; Rec."Geolocation Latitude")
                {
                    ToolTip = 'Specifies the store''s location on Google Maps or Bing. This could help the customer get driving instructions or to figure out if the store is close enough for picking up a collect order.';
                    ApplicationArea = NPRRetail;
                }
                field("Geolocation Longitude"; Rec."Geolocation Longitude")
                {
                    ToolTip = 'Specifies the store''s location on Google Maps or Bing. This could help the customer get driving instructions or to figure out if the store is close enough for picking up a collect order.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        GLSetup: Record "General Ledger Setup";

    internal procedure CopyTemp(var TempPOSStore: Record "NPR POS Store")
    begin
        if TempPOSStore.FindSet() then
            repeat
                Rec := TempPOSStore;
                if Rec.Insert() then;
            until TempPOSStore.Next() = 0;
    end;

    internal procedure CopyAllPOSStores(var TempPOSStores: Record "NPR POS Store")
    var
        RealPOSStores: Record "NPR POS Store";
    begin
        TempPOSStores.DeleteAll();

        If RealPOSStores.FindSet() then
            repeat
                TempPOSStores := RealPOSStores;
                if TempPOSStores.Insert() then;
            until RealPOSStores.Next() = 0;

        If Rec.FindSet() then
            repeat
                TempPOSStores := Rec;
                if TempPOSStores.Insert() then;
            until Rec.Next() = 0;
    end;

    internal procedure CreatePOSStoreData()
    var
        POSStore: Record "NPR POS Store";
    begin
        if Rec.FindSet() then
            repeat
                POSStore := Rec;
                if not POSStore.Insert() then
                    POSStore.Modify();
                CreatePOSPostingSetup(POSStore.Code);
                CreateDefaulDimensions(POSStore);
            until Rec.Next() = 0;
    end;

    internal procedure DimensionsToCreate(): Boolean
    var
        TempPOSStore: Record "NPR POS Store" temporary;
        GlobalDimension1Populated: Boolean;
        GlobalDimension2Populated: Boolean;
    begin
        if Rec.IsEmpty() then
            exit(false);

        TempPOSStore.Copy(Rec, true);
        TempPOSStore.SetFilter("Global Dimension 1 Code", '<>%1', '');

        GlobalDimension1Populated := not TempPOSStore.IsEmpty();

        TempPOSStore.Reset();
        TempPOSStore.SetFilter("Global Dimension 2 Code", '<>%1', '');
        GlobalDimension2Populated := not TempPOSStore.IsEmpty();

        exit(GlobalDimension1Populated or GlobalDimension2Populated);
    end;

    local procedure CreatePOSPostingSetup(POSStoreCode: Code[10])
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        POSPaymentMethod.SetRange("Include In Counting", POSPaymentMethod."Include In Counting"::YES);
        if POSPaymentMethod.FindSet() then
            repeat
                POSPaymentBin.SetFilter("No.", 'BANK|SAFE');
                if POSPaymentBin.FindSet() then
                    repeat
                        POSPostingSetup.Init();
                        POSPostingSetup."POS Store Code" := POSStoreCode;
                        POSPostingSetup."POS Payment Method Code" := POSPaymentMethod.Code;
                        POSPostingSetup."POS Payment Bin Code" := POSPaymentBin."No.";
                        if not POSPostingSetup.Insert() then
                            POSPostingSetup.Modify();
                    until POSPaymentBin.Next() = 0
            until POSPaymentMethod.Next() = 0;
    end;

    local procedure CreateDefaulDimensions(POSStore: Record "NPR POS Store")
    begin
        GLSetup.Get();

        CreateDefaultDimension(POSStore, POSStore."Global Dimension 1 Code", GLSetup."Global Dimension 1 Code");
        CreateDefaultDimension(POSStore, POSStore."Global Dimension 2 Code", GLSetup."Global Dimension 2 Code");
    end;

    local procedure CreateDefaultDimension(POSStore: Record "NPR POS Store" temporary; DimensionValueCode: Code[20]; DimensionCode: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if DimensionValueCode = '' then
            exit;

        if DimensionCode = '' then
            exit;

        if DefaultDimension.Get(Database::"NPR POS Store", POSStore."Code", DimensionCode) then
            exit;

        DefaultDimension.Init();
        DefaultDimension."Table ID" := Database::"NPR POS Store";
        DefaultDimension."No." := POSStore."Code";
        DefaultDimension."Dimension Code" := DimensionCode;
        DefaultDimension."Dimension Value Code" := DimensionValueCode;
        DefaultDimension.Insert();
    end;
}