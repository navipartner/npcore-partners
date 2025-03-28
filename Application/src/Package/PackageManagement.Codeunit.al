codeunit 6059947 "NPR Package Management"
{
    Access = Internal;

    var
        PackageProviderSetup: Record "NPR Shipping Provider Setup";

    procedure TestFieldPakkelabels(RecRef: RecordRef);
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        ShiptoAddress: Record "Ship-to Address";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        PakkeShippingAgent: Record "NPR Package Shipping Agent";
        PackageDimension: Record "NPR Package Dimension";
    begin
        case RecRef.Number of
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    if SalesHeader.Find() then begin
                        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) or (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then begin

                            SalesHeader.CalcFields("NPR Package Quantity");
                            if SalesHeader."NPR Package Quantity" = 0 then
                                exit;

                            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                            SalesLine.SetRange("Document No.", SalesHeader."No.");
                            SalesLine.SetRange(Type, SalesLine.Type::Item);
                            SalesLine.SetFilter("Net Weight", '<>0');
                            if SalesLine.IsEmpty() then
                                exit;


                            if not PakkeShippingAgent.Get(SalesHeader."Shipping Agent Code") then
                                exit
                            else
                                SalesHeader.TestField(SalesHeader."Shipping Agent Service Code");

                            if SalesHeader."Ship-to Code" <> '' then begin
                                ShiptoAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code");
                                if PakkeShippingAgent."Phone Mandatory" then
                                    ShiptoAddress.TestField("Phone No.");

                                if PakkeShippingAgent."Email Mandatory" then
                                    ShiptoAddress.TestField("E-Mail");

                            end else begin

                                Customer.Get(SalesHeader."Sell-to Customer No.");
                                if PakkeShippingAgent."Phone Mandatory" then
                                    Customer.TestField("Phone No.");

                                if PakkeShippingAgent."Email Mandatory" then
                                    Customer.TestField("E-Mail");
                            end;

                            SalesHeader.TestField("Ship-to Name");
                            SalesHeader.TestField("Ship-to Address");
                            SalesHeader.TestField("Ship-to Post Code");
                            SalesHeader.TestField("Ship-to City");

                            if PakkeShippingAgent."Ship to Contact Mandatory" then
                                SalesHeader.TestField("Ship-to Contact");

                            PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Order);
                            PackageDimension.SetRange("Document No.", SalesHeader."No.");
                            PackageDimension.SetFilter(Quantity, '<>0');
                            if PackageDimension.FindSet() then
                                repeat
                                    if PakkeShippingAgent."LxWxH Dimensions Required" then begin
                                        PackageDimension.TestField(Length);
                                        PackageDimension.TestField(Width);
                                        PackageDimension.TestField(Height);
                                    end;
                                    if PakkeShippingAgent."Volume Required" then
                                        PackageDimension.TestField(Volume);
                                    if PakkeShippingAgent."running_metre required" then
                                        PackageDimension.TestField(running_metre);
                                    if PakkeShippingAgent."Package Type Required" then
                                        PackageDimension.TestField("Package Code");
                                until PackageDimension.Next() = 0;
                        end;
                    end;
                end;
            Database::"Sales Shipment Header":
                begin
                    RecRef.SetTable(SalesShipmentHeader);
                    if SalesShipmentHeader.Find() then begin

                        SalesShipmentHeader.TestField("Shipping Agent Code");
                        PakkeShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");

                        SalesShipmentHeader.TestField("Shipping Agent Service Code");

                        PakkeShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
                        if SalesShipmentHeader."Ship-to Code" <> '' then begin
                            ShiptoAddress.Get(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Ship-to Code");
                            if PakkeShippingAgent."Phone Mandatory" then
                                ShiptoAddress.TestField("Phone No.");

                            if PakkeShippingAgent."Email Mandatory" then
                                ShiptoAddress.TestField("E-Mail");

                        end else begin

                            Customer.Get(SalesShipmentHeader."Sell-to Customer No.");
                            if PakkeShippingAgent."Phone Mandatory" then
                                Customer.TestField("Phone No.");

                            if PakkeShippingAgent."Email Mandatory" then
                                Customer.TestField("E-Mail");
                        end;

                        SalesShipmentHeader.TestField("Ship-to Name");
                        SalesShipmentHeader.TestField("Ship-to Address");
                        SalesShipmentHeader.TestField("Ship-to Post Code");
                        SalesShipmentHeader.TestField("Ship-to City");

                        if PakkeShippingAgent."Ship to Contact Mandatory" then
                            SalesShipmentHeader.TestField("Ship-to Contact");
                    end;
                end;
        end;
    end;

    local procedure CheckNetWeight(SalesShipmentHeader: Record "Sales Shipment Header"): Boolean;
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetFilter("Net Weight", '<>%1', 0);
        exit(not SalesShipmentLine.IsEmpty());
    end;

    procedure AddEntry(RecRef: RecordRef; ShowWindow: Boolean; Silent: Boolean; var ShipmentDocument: Record "NPR Shipping Provider Document"): Boolean
    var
        CompanyInfo: Record "Company Information";
        Customer: Record Customer;
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShipToAddress: Record "Ship-to Address";
        SalesShipmentLine: Record "Sales Shipment Line";
        ShipmondoEvents: Codeunit "NPR Shipmondo Events";
        DocFound: Boolean;
    begin
        if not InitPackageProvider() then
            exit;

        ShipmentDocument.SetRange("Table No.", RecRef.Number);
        ShipmentDocument.SetRange(RecordID, RecRef.RecordId);
        if ShipmentDocument.FindLast() then
            DocFound := true
        else begin
            Clear(ShipmentDocument);
            ShipmentDocument.Init();
            ShipmentDocument.Validate("Entry No.", 0);
            ShipmentDocument.Validate("Table No.", RecRef.Number);
            ShipmentDocument.Validate(RecordID, RecRef.RecordId);
            ShipmentDocument.Validate("Creation Time", CurrentDateTime);
        end;
        case RecRef.Number of

            Database::"Sales Shipment Header":
                begin
                    RecRef.SetTable(SalesShipmentHeader);
                    if SalesShipmentHeader.Find() then begin
                        SalesShipmentHeader.CalcFields("NPR Package Quantity");
                        if SalesShipmentHeader."Shipment Method Code" = '' then exit;
                        if CheckNetWeight(SalesShipmentHeader) = false then exit;
                        if SalesShipmentHeader."NPR Package Quantity" = 0 then exit;

                        if not DocFound then
                            ShipmentDocument.Insert(true);
                        Customer.Get(SalesShipmentHeader."Sell-to Customer No.");
                        Clear(ShipToAddress);
                        ShipmentDocument."Document No." := SalesShipmentHeader."No.";
                        ShipmentDocument."Document Type" := ShipmentDocument."Document Type"::"Posted Shipment";
                        ShipmentDocument."Location Code" := SalesShipmentHeader."Location Code";
                        if ShipToAddress.Get(SalesShipmentHeader."Sell-to Customer No.", SalesShipmentHeader."Ship-to Code") then begin
                            ShipmentDocument."Ship-to Code" := SalesShipmentHeader."Ship-to Code";
                            ShipmentDocument."E-Mail" := ShipToAddress."E-Mail";
                            ShipmentDocument."SMS No." := ShipToAddress."Phone No.";
                            ShipmentDocument."Phone No." := ShipToAddress."Phone No.";
                            ShipmentDocument."Fax No." := ShipToAddress."Fax No.";
                        end else begin
                            ShipmentDocument."E-Mail" := Customer."E-Mail";
                            ShipmentDocument."SMS No." := Customer."Phone No.";
                            ShipmentDocument."Phone No." := Customer."Phone No.";
                            ShipmentDocument."Fax No." := Customer."Fax No.";
                        end;

                        ShipmentDocument."Receiver ID" := SalesShipmentHeader."Sell-to Customer No.";
                        ShipmentDocument.Name := SalesShipmentHeader."Ship-to Name";
                        ShipmentDocument.Address := SalesShipmentHeader."Ship-to Address";
                        ShipmentDocument."Address 2" := SalesShipmentHeader."Ship-to Address 2";
                        ShipmentDocument."Post Code" := SalesShipmentHeader."Ship-to Post Code";
                        ShipmentDocument.City := SalesShipmentHeader."Ship-to City";
                        ShipmentDocument.County := SalesShipmentHeader."Ship-to County";
                        ShipmentDocument."Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code";
                        ShipmentDocument.Contact := SalesShipmentHeader."Ship-to Contact";
                        ShipmentDocument.Reference := SalesShipmentHeader."Your Reference";
                        ShipmentDocument."Shipment Date" := SalesShipmentHeader."Shipment Date";
                        ShipmentDocument."VAT Registration No." := Customer."VAT Registration No.";
                        ShipmentDocument."Currency Code" := SalesShipmentHeader."Currency Code";

                        ShipmentDocument."Shipping Method Code" := SalesShipmentHeader."Shipment Method Code";
                        ShipmentDocument."Shipping Agent Code" := SalesShipmentHeader."Shipping Agent Code";
                        ShipmentDocument."Shipping Agent Service Code" := SalesShipmentHeader."Shipping Agent Service Code";
                        ShipmentDocument."Parcel Qty." := SalesShipmentHeader."NPR Package Quantity";
                        ShipmentDocument."Order No." := SalesShipmentHeader."Order No.";

                        ShipmentDocument."Package Code" := SalesShipmentHeader."NPR Package Code";

                        ShipmentDocument."Total Weight" := 0;
                        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
                        SalesShipmentLine.SetFilter("Net Weight", '<>0');
                        if SalesShipmentLine.FindSet() then
                            repeat
                                ShipmentDocument."Total Weight" += SalesShipmentLine."Net Weight" * SalesShipmentLine.Quantity;
                            until SalesShipmentLine.Next() = 0;
                        ShipmentDocument."Total Weight" := Round(ShipmentDocument."Total Weight", 1, '>') * 1000;
                        if SalesShipmentHeader."NPR Delivery Location" <> '' then begin
                            ShipmentDocument.Name := SalesShipmentHeader."Bill-to Name";
                            ShipmentDocument.Address := SalesShipmentHeader."Bill-to Address";
                            ShipmentDocument."Address 2" := SalesShipmentHeader."Bill-to Address 2";
                            ShipmentDocument."Post Code" := SalesShipmentHeader."Bill-to Post Code";
                            ShipmentDocument.City := SalesShipmentHeader."Bill-to City";
                            ShipmentDocument.County := SalesShipmentHeader."Bill-to County";
                            ShipmentDocument."Country/Region Code" := SalesShipmentHeader."Bill-to Country/Region Code";

                            ShipmentDocument."Delivery Location" := SalesShipmentHeader."NPR Delivery Location";
                            ShipmentDocument."Ship-to Name" := SalesShipmentHeader."Ship-to Name";
                            ShipmentDocument."Ship-to Address" := SalesShipmentHeader."Ship-to Address";
                            ShipmentDocument."Ship-to Address 2" := SalesShipmentHeader."Ship-to Address 2";
                            ShipmentDocument."Ship-to Post Code" := SalesShipmentHeader."Ship-to Post Code";
                            ShipmentDocument."Ship-to City" := SalesShipmentHeader."Ship-to City";
                            ShipmentDocument."Ship-to County" := SalesShipmentHeader."Ship-to County";
                            ShipmentDocument."Ship-to Country/Region Code" := SalesShipmentHeader."Ship-to Country/Region Code";
                            ShipmentDocument.Contact := SalesShipmentHeader."Ship-to Contact";
                        end;

                        if PackageProviderSetup."Order No. to Reference" then
                            if SalesShipmentHeader."Order No." <> '' then
                                ShipmentDocument.Reference := CopyStr(SalesShipmentHeader."Order No.", 1,
                                                                      MaxStrLen(ShipmentDocument.Reference));

                        if (PackageProviderSetup."Order No. or Ext Doc No to ref") then begin
                            if SalesShipmentHeader."External Document No." <> '' then
                                ShipmentDocument.Reference := SalesShipmentHeader."External Document No."
                            else
                                ShipmentDocument.Reference := SalesShipmentHeader."Order No.";
                        end;
                        ShipmentDocument."External Document No." := SalesShipmentHeader."External Document No.";
                        ShipmentDocument."Delivery Instructions" := SalesShipmentHeader."NPR Delivery Instructions";
                        ShipmentDocument."Your Reference" := SalesShipmentHeader."Your Reference";

                    end;
                end;
        end;

        CompanyInfo.Get();
        ShipmentDocument."Sender VAT Reg. No" := CompanyInfo."VAT Registration No.";
        if ShipmentDocument."Country/Region Code" = '' then
            ShipmentDocument."Country/Region Code" := CompanyInfo."Country/Region Code";
        if ShipmentDocument."Shipment Date" < Today then
            ShipmentDocument."Shipment Date" := Today;

        ShipmondoEvents.AddEntryOnBeforeShipmentDocumentModify(ShipmentDocument, RecRef);
        ShipmentDocument.Modify(true);

        Commit();
        exit(true);
    end;

    procedure PostDimension(RecRef: RecordRef)
    var
        PackageDimension: Record "NPR Package Dimension";
        PackageDimension1: Record "NPR Package Dimension";
        PackageDimensionDetails: Record "NPR Package Dimension Details";
        PostPackageDimensionDetails: Record "NPR Package Dimension Details";
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        RecRef.SetTable(SalesShipmentHeader);
        PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Shipment);
        PackageDimension.SetRange("Document No.", SalesShipmentHeader."No.");
        if not PackageDimension.IsEmpty() then exit;

        PackageDimension.Reset();
        PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Order);
        PackageDimension.SetRange("Document No.", SalesShipmentHeader."Order No.");
        PackageDimension.SetFilter(Quantity, '<>0');
        if PackageDimension.FindSet() then
            repeat
                PackageDimension1.Init();
                PackageDimension1.TransferFields(PackageDimension);
                PackageDimension1."Document Type" := PackageDimension1."Document Type"::Shipment;
                PackageDimension1."Document No." := SalesShipmentHeader."No.";
                PackageDimension1.Insert();

                PackageDimensionDetails.Reset();
                PackageDimensionDetails.SetRange("Document Type", PackageDimension."Document Type"::Order);
                PackageDimensionDetails.SetRange("Document No.", SalesShipmentHeader."Order No.");
                PackageDimensionDetails.SetRange("Package Dimension Line No.", PackageDimension."Line No.");
                if PackageDimensionDetails.FindSet() then
                    repeat
                        PostPackageDimensionDetails.Init();
                        PostPackageDimensionDetails.TransferFields(PackageDimensionDetails);
                        PostPackageDimensionDetails."Document Type" := PostPackageDimensionDetails."Document Type"::Shipment;
                        PostPackageDimensionDetails."Document No." := SalesShipmentHeader."No.";
                        PostPackageDimensionDetails.Insert();
                    until PackageDimensionDetails.Next() = 0;

                PackageDimension.Delete();
            until PackageDimension.Next() = 0;
        Commit();
    end;


    local procedure ValidateShipmentMethodCode(Rec: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        PakkeShippingAgent: Record "NPR Package Shipping Agent";
        PackageDimension: Record "NPR Package Dimension";
    begin
        if Rec."Shipment Method Code" = '' then exit;

        if not PakkeShippingAgent.Get(Rec."Shipping Agent Code") then
            exit;

        if PackageProviderSetup."Default Weight" > 0 then begin
            SalesLine.SetRange(SalesLine."Document Type", Rec."Document Type");
            SalesLine.SetRange("Document No.", Rec."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetRange("Net Weight", 0);
            SalesLine.ModifyAll("Net Weight", PackageProviderSetup."Default Weight");
        end;

        PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Order);
        PackageDimension.SetRange("Document No.", Rec."No.");
        if not PackageDimension.IsEmpty() then
            exit;
        PackageDimension.Init();
        PackageDimension."Document Type" := PackageDimension."Document Type"::Order;
        PackageDimension."Document No." := Rec."No.";
        PackageDimension."Line No." := 10000;
        PackageDimension.Quantity := Rec."NPR Kolli";

        if PakkeShippingAgent."Declared Value Required" then
            PopulatePackageAmountFields(Rec, PackageDimension);

        if PakkeShippingAgent."LxWxH Dimensions Required" then
            PopulateDefaultPackageDimensions(PackageDimension, PackageProviderSetup);

        PackageDimension.Insert(true);
    end;

    local procedure UpdatePackageCode(Rec: Record "Sales Header");
    var
        PackageDimension: Record "NPR Package Dimension";
    begin
        if Rec."NPR Package Code" <> '' then begin
            PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Order);
            PackageDimension.SetRange("Document No.", Rec."No.");
            PackageDimension.SetFilter("Package Code", '%1', '');
            PackageDimension.ModifyAll("Package Code", Rec."NPR Package Code");
        end;
    end;

    local procedure UpdatePackageQuantity(Rec: Record "Sales Header");
    var
        PackageDimension: Record "NPR Package Dimension";
    begin
        PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Order);
        PackageDimension.SetRange("Document No.", Rec."No.");
        if PackageDimension.Count = 1 then begin
            PackageDimension.FindFirst();
            PackageDimension.Quantity := Rec."NPR Kolli";
            PackageDimension.Modify();
        end;
    end;

    local procedure GetPackageDimensions(Rec: Record "Sales Header"; var PackageDimension: Record "NPR Package Dimension") Found: Boolean;
    begin
        PackageDimension.Reset();
        PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Order);
        PackageDimension.SetRange("Document No.", Rec."No.");
        Found := (PackageDimension.Find('-') and (PackageDimension.Next() = 0));
    end;

    local procedure GetUseDefaultPackageDimensions(SalesHeader: Record "Sales Header") UseDefaultPackageDimensions: Boolean;
    var
        PackageShippingAgent: Record "NPR Package Shipping Agent";
    begin
        if not PackageShippingAgent.Get(SalesHeader."Shipping Agent Code") then
            exit;

        UseDefaultPackageDimensions := PackageShippingAgent."LxWxH Dimensions Required";
    end;

    local procedure UpdatePackageAmountFields(SalesHeader: Record "Sales Header");
    var
        PackageDimension: Record "NPR Package Dimension";
        ShipmondoEvents: Codeunit "NPR Shipmondo Events";
        FieldsPopulated: Boolean;
    begin
        if not GetPackageAmountRequired(SalesHeader) then
            exit;

        if not GetPackageDimensions(SalesHeader, PackageDimension) then
            exit;

        FieldsPopulated := PopulatePackageAmountFields(SalesHeader, PackageDimension);
        ShipmondoEvents.OnAfterPopulatePackageAmountFields(SalesHeader, PackageDimension, FieldsPopulated);
        if not FieldsPopulated then
            exit;

        PackageDimension.Modify();
    end;

    local procedure PopulatePackageAmountFields(SalesHeader: Record "Sales Header"; var PackageDimension: Record "NPR Package Dimension") Populated: Boolean;
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PackageAmount: Decimal;
        CurrnecyCode: Code[10];
    begin
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        PackageAmount := CalcPakcageAmount(SalesHeader);
        if PackageDimension."Package Amount Incl. VAT" <> PackageAmount then begin
            PackageDimension."Package Amount Incl. VAT" := PackageAmount;
            Populated := true;
        end;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        CurrnecyCode := SalesHeader."Currency Code";
        if CurrnecyCode = '' then
            CurrnecyCode := GeneralLedgerSetup."LCY Code";

        if PackageDimension."Package Amount Currency Code" <> CurrnecyCode then begin
            PackageDimension."Package Amount Currency Code" := CurrnecyCode;
            Populated := true;
        end;
    end;

    local procedure CalcPakcageAmount(SalesHeader: Record "Sales Header") PakcageAmountInclVAT: Decimal;
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("Net Weight", '<>0');
        if SalesLine.IsEmpty then
            exit;

        SalesLine.CalcSums("Amount Including VAT");
        PakcageAmountInclVAT := SalesLine."Amount Including VAT";
    end;

    local procedure GetPackageAmountRequired(SalesHeader: Record "Sales Header") PackageAmountRequired: Boolean;
    var
        PackageShippingAgent: Record "NPR Package Shipping Agent";
    begin
        if not PackageShippingAgent.Get(SalesHeader."Shipping Agent Code") then
            exit;

        PackageAmountRequired := PackageShippingAgent."Declared Value Required";
    end;

    local procedure UpdateDefaultPackageDimensions(SalesHeader: Record "Sales Header"; ShippingProviderSetup: Record "NPR Shipping Provider Setup")
    var
        PackageDimension: Record "NPR Package Dimension";
        Modi: Boolean;
    begin
        if not GetUseDefaultPackageDimensions(SalesHeader) then
            exit;

        if not GetPackageDimensions(SalesHeader, PackageDimension) then
            exit;

        Modi := PopulateDefaultPackageDimensions(PackageDimension, ShippingProviderSetup);

        if Modi then
            PackageDimension.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ICInboxOutboxMgt, 'OnCreateSalesDocumentOnBeforeSalesHeaderModify', '', false, false)]
    local procedure OnCreateSalesDocumentOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader.IsTemporary then
            exit;

        if not InitPackageProvider() then
            exit;

        ValidateShipmentMethodCode(SalesHeader);
        UpdatePackageCode(SalesHeader);
    end;

    local procedure PopulateDefaultPackageDimensions(var PackageDimension: Record "NPR Package Dimension"; ShippingProviderSetup: Record "NPR Shipping Provider Setup") Populated: Boolean;
    begin
        if (ShippingProviderSetup."Default Height" <> 0) and (PackageDimension.Height = 0) then begin
            PackageDimension.Height := ShippingProviderSetup."Default Height";
            Populated := true;
        end;

        if (ShippingProviderSetup."Default Width" <> 0) and (PackageDimension.Width = 0) then begin
            PackageDimension.Width := ShippingProviderSetup."Default Width";
            Populated := true;
        end;

        if (ShippingProviderSetup."Default Length" <> 0) and (PackageDimension.Length = 0) then begin
            PackageDimension.Length := ShippingProviderSetup."Default Length";
            Populated := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header");
    begin
        if SalesHeader.IsTemporary then
            exit;

        if not InitPackageProvider() then
            exit;

        UpdatePackageAmountFields(SalesHeader);
        UpdateDefaultPackageDimensions(SalesHeader, PackageProviderSetup);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure OnAfterModifyQtyEventSalesLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer);
    var
        SalesHeader: Record "Sales Header";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec.Quantity = 0 then
            exit;
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        if SalesHeader."Shipment Method Code" = '' then
            exit;
        if not InitPackageProvider() then
            exit;

        if PackageProviderSetup."Default Weight" <= 0 then exit;

        if Rec."Net Weight" = 0 then
            Rec."Net Weight" := PackageProviderSetup."Default Weight";

        UpdatePackageAmountFields(SalesHeader);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'NPR Package Code', false, false)]
    local procedure OnAfterModifyPackageCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        if Rec.IsTemporary then
            exit;
        if not InitPackageProvider() then
            exit;
        UpdatePackageCode(Rec);
        UpdatePackageAmountFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'NPR Kolli', false, false)]
    local procedure OnAfterModifyNPRKolli(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        if Rec.IsTemporary then
            exit;
        if not InitPackageProvider() then
            exit;
        UpdatePackageQuantity(Rec);
        UpdatePackageAmountFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Shipping Agent Service Code', false, false)]
    local procedure OnAfterModifyShippingAgentSerEventSalesHeader(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer);
    begin
        if Rec.IsTemporary then
            exit;

        if not InitPackageProvider() then
            exit;
        ValidateShipmentMethodCode(Rec);
    end;

    local procedure InitPackageProvider(): Boolean;
    begin
        if not PackageProviderSetup.Get() then
            exit(false);

        if not PackageProviderSetup."Enable Shipping" then
            exit(false);

        if PackageProviderSetup."Shipping Provider" = PackageProviderSetup."Shipping Provider"::Pacsoft then
            exit(false);

        exit(true);
    end;

}