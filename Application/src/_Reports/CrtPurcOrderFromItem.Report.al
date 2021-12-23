report 6014411 "NPR Crt. Purc. Order From Item"
{
    Caption = 'Add to Purchase Order';
    ProcessingOnly = true;
    UseRequestPage = true;
    UsageCategory = None;
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group("Set Values")
                {
                    Caption = 'Set Values';
                    field("Purc. Order No."; PurchaseOrderNoG)
                    {
                        Caption = 'Purchase Order No.';
                        ToolTip = 'Choose Existing Purchase Order or leave it empty if You want to create a new one.';
                        TableRelation = "Purchase Header"."No." where("Document Type" = filter(Order), Status = const(Open));
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            UpdateOnPurcOrderSet();
                        end;
                    }

                    field("Vendor No."; VendorNoG)
                    {
                        Caption = 'Vendor No.';
                        ToolTip = 'In case You want to create new Purchase Order, please set Vendor.';
                        TableRelation = Vendor."No.";
                        ApplicationArea = All;
                        Editable = not NotEditableFieldsG;
                    }

                    field("Location Code"; LocationCodeG)
                    {
                        Caption = 'Location Code';
                        ToolTip = 'In case You want to define specific location, choose one. Otherwise, system will use location from Document Header';
                        TableRelation = Location.Code;
                        ApplicationArea = All;
                    }

                    field("Processing Item No"; ItemToProcessG."No.")
                    {
                        Caption = 'Processing Item No.';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Processing Item No. field.';
                    }

                    field("Processing Item Description"; ItemToProcessG.Description)
                    {
                        Caption = 'Processing Item Description.';
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Processing Item Description. field.';
                    }

                    field("Open Purchase Order"; OpenPurchDocumentG)
                    {
                        Caption = 'Open Purchase Order';
                        ToolTip = 'If You want to open Purchase Order Card after adding the item, You need to check this option';
                        ApplicationArea = All;
                    }
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }

    trigger OnPreReport()
    begin
        CheckEnteredValues();
        ProcessItem();
    end;

    local procedure UpdateOnPurcOrderSet()
    begin
        if PurchaseOrderNoG = '' then begin
            NotEditableFieldsG := false;
            VendorNoG := ItemToProcessG."Vendor No.";
            LocationCodeG := '';
        end
        else begin
            NotEditableFieldsG := true;
            VendorNoG := '';
            LocationCodeG := '';
        end;
    end;

    procedure SetValues(Item: Record Item)
    begin
        ItemToProcessG := Item;
        ItemToProcessG.TestField("No.");

        VendorNoG := ItemToProcessG."Vendor No.";
    end;

    local procedure CheckEnteredValues()
    var
        PurcOrderHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        MissingVendorErr: Label 'You need to enter Vendor No.';
        BlockedVendorErr: Label 'Vendor %1 is Blocked and can not be used.', Comment = '%1=Vendor No.';
    begin
        ItemToProcessG.TestField("No.");

        if (PurchaseOrderNoG = '') then begin
            if (VendorNoG = '') then
                Error(MissingVendorErr);

            Vendor.Get(VendorNoG);
            if Vendor.Blocked <> Vendor.Blocked::" " then
                Error(BlockedVendorErr, Vendor."No.");
        end;

        if PurchaseOrderNoG <> '' then begin
            PurcOrderHeader.Get(PurcOrderHeader."Document Type"::Order, PurchaseOrderNoG);
            PurcOrderHeader.TestStatusOpen();
        end;
    end;

    local procedure ProcessItem()
    var
        ItemVariant: Record "Item Variant";
        PurchaseLine: Record "Purchase Line";
        PurcOrderHeader: Record "Purchase Header";
        NextLineNo: Integer;
    begin
        NextLineNo := 10000;

        if PurchaseOrderNoG = '' then
            createPurchaseHeader(VendorNoG, LocationCodeG, PurcOrderHeader)
        else begin
            PurcOrderHeader.Get(PurcOrderHeader."Document Type"::Order, PurchaseOrderNoG);
            PurchaseLine.SetRange("Document Type", PurcOrderHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurcOrderHeader."No.");
            if PurchaseLine.FindLast() then
                NextLineNo := PurchaseLine."Line No." + 10000;
        end;

        ItemVariant.SetRange("Item No.", ItemToProcessG."No.");
        if ItemVariant.FindSet() then
            repeat
                CreatePurcOrderLine(PurcOrderHeader, NextLineNo, ItemToProcessG."No.", ItemVariant.Code, LocationCodeG);
                NextLineNo += 10000;
            until ItemVariant.Next() = 0
        else
            CreatePurcOrderLine(PurcOrderHeader, NextLineNo, ItemToProcessG."No.", '', LocationCodeG);

        if OpenPurchDocumentG then
            Page.Run(Page::"Purchase Order", PurcOrderHeader);
    end;

    local procedure createPurchaseHeader(VendorNo: Code[20]; LocationCode: Code[20]; var PurchaseHeader: Record "Purchase Header")
    begin
        Clear(PurchaseHeader);

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        if LocationCode <> '' then
            PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Modify();

    end;

    local procedure CreatePurcOrderLine(PurcOrderHeader: Record "Purchase Header"; NextLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurcOrderHeader."Document Type";
        PurchaseLine."Document No." := PurcOrderHeader."No.";
        PurchaseLine."Line No." := NextLineNo;
        PurchaseLine.Insert(true);

        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", ItemNo);
        if VariantCode <> '' then
            PurchaseLine.Validate("Variant Code", VariantCode);

        if (LocationCode <> '') and (LocationCode <> PurchaseLine."Location Code") then
            PurchaseLine.Validate("Location Code", LocationCode);

        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Modify();
    end;

    var
        ItemToProcessG: Record Item;
        OpenPurchDocumentG: Boolean;
        [InDataSet]
        NotEditableFieldsG: Boolean;
        LocationCodeG: Code[20];
        PurchaseOrderNoG: Code[20];
        VendorNoG: Code[20];
}
