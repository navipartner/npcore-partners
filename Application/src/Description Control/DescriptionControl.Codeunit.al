codeunit 6059969 "NPR Description Control"
{
    local procedure InitDescriptionControl()
    var
        DescriptionControl: Record "NPR Description Control";
    begin
        if not DescriptionControl.IsEmpty then
            exit;

        with DescriptionControl do begin

            LockTable;

            Code := 'VAR_FIRST';
            "Setup Type" := "Setup Type"::Simple;
            "Description 1 Var (Simple)" := "Description 1 Var (Simple)"::VariantDescription1;
            "Description 2 Var (Simple)" := "Description 2 Var (Simple)"::ItemDescription1;
            "Description 1 Std (Simple)" := "Description 1 Std (Simple)"::ItemDescription1;
            "Description 2 Std (Simple)" := "Description 2 Std (Simple)"::ItemDescription2;
            Insert;

            Code := 'VAR_LAST';
            "Setup Type" := "Setup Type"::Simple;
            "Description 1 Var (Simple)" := "Description 1 Var (Simple)"::ItemDescription1;
            "Description 2 Var (Simple)" := "Description 2 Var (Simple)"::VariantDescription1;
            "Description 1 Std (Simple)" := "Description 1 Std (Simple)"::ItemDescription1;
            "Description 2 Std (Simple)" := "Description 2 Std (Simple)"::ItemDescription2;
            Insert;

            Code := 'NO_VARIANT';
            "Setup Type" := "Setup Type"::Simple;
            "Description 1 Var (Simple)" := "Description 1 Var (Simple)"::ItemDescription1;
            "Description 2 Var (Simple)" := "Description 2 Var (Simple)"::ItemDescription2;
            "Description 1 Std (Simple)" := "Description 1 Std (Simple)"::ItemDescription1;
            "Description 2 Std (Simple)" := "Description 2 Std (Simple)"::ItemDescription2;
            Insert;

            Code := 'VARIANT';
            "Setup Type" := "Setup Type"::Simple;
            "Description 1 Var (Simple)" := "Description 1 Var (Simple)"::VariantDescription1;
            "Description 2 Var (Simple)" := "Description 2 Var (Simple)"::VariantDescription2;
            "Description 1 Std (Simple)" := "Description 1 Std (Simple)"::ItemDescription1;
            "Description 2 Std (Simple)" := "Description 2 Std (Simple)"::ItemDescription2;
            Insert;
        end;
    end;

    procedure GetItemRefDescription(ItemNo: Code[20]; VariantCode: Code[10]): Text[50]
    var
        VRTSetup: Record "NPR Variety Setup";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        VRTSetup.Get;
        Item.Get(ItemNo);
        if VariantCode = '' then begin
            case VRTSetup."Item Cross Ref. Description(I)" of
                VRTSetup."Item Cross Ref. Description(I)"::ItemDescription1:
                    exit(Item.Description);
                VRTSetup."Item Cross Ref. Description(I)"::ItemDescription2:
                    exit(Item."Description 2");
            end;
        end else begin
            ItemVariant.Get(ItemNo, VariantCode);
            case VRTSetup."Item Cross Ref. Description(V)" of
                VRTSetup."Item Cross Ref. Description(V)"::ItemDescription1:
                    exit(Item.Description);
                VRTSetup."Item Cross Ref. Description(V)"::ItemDescription2:
                    exit(Item."Description 2");
                VRTSetup."Item Cross Ref. Description(V)"::VariantDescription1:
                    exit(ItemVariant.Description);
                VRTSetup."Item Cross Ref. Description(V)"::VariantDescription2:
                    exit(ItemVariant."Description 2");
            end;
        end;
    end;

    procedure GetDescriptionPOS(var Rec: Record "NPR Sale Line POS"; XRec: Record "NPR Sale Line POS"; Item: Record Item)
    var
        RetailItemSetup: Record "NPR Retail Item Setup";
        ItemGroup: Record "NPR Item Group";
        Vendor: Record Vendor;
        Pos: Integer;
        VendorName: Text[100];
        ItemGroupName: Text[50];
        ItemVariant: Record "Item Variant";
    begin
        with Rec do begin
            if "Custom Descr" then
                exit;

            if Type <> Type::Item then
                exit;

            InitDescriptionControl();

            if RetailItemSetup.Get then begin
                if ((XRec."No." <> "No.") or (Description = '')) and not "Custom Descr" then begin
                    case RetailItemSetup."Description control" of
                        RetailItemSetup."Description control"::"<Description>":
                            Description := CopyStr(Item.Description, 1, 50);
                        RetailItemSetup."Description control"::"<Description 2>":
                            Description := CopyStr(Item."Description 2", 1, 50);
                        RetailItemSetup."Description control"::"<Vendor Name><Item Group><Vendor Item No.>":
                            begin
                                if ItemGroup.Get(Item."NPR Item Group") then begin
                                    if Vendor.Get(Item."Vendor No.") then
                                        Pos := StrPos(Vendor.Name, ' ');
                                    if Pos > 0 then
                                        VendorName := CopyStr(Vendor.Name, 1, Pos - 1)
                                    else
                                        VendorName := Vendor.Name;

                                    Pos := StrPos(ItemGroup.Description, ' ');
                                    if Pos > 0 then
                                        ItemGroupName := CopyStr(ItemGroup.Description, 1, Pos - 1)
                                    else
                                        ItemGroupName := ItemGroup.Description;

                                    if (VendorName <> '') and (ItemGroupName <> '') then
                                        Description := CopyStr(VendorName + ' ' + ItemGroupName + ' ' + Item."Vendor Item No.", 1, 30);
                                end;
                            end;
                        RetailItemSetup."Description control"::"<Description 2><Item group name>":
                            begin
                                if ItemGroup.Get(Item."NPR Item Group") and (Item."Description 2" <> '') then
                                    Description := CopyStr(Item."Description 2" + ' ' + ItemGroup.Description, 1, 30);
                            end;
                        RetailItemSetup."Description control"::"<Description><Variant Info>":
                            begin
                                if ItemVariant.Get(Rec."No.", Rec."Variant Code") then
                                    Description := CopyStr(Item.Description + ' ' + ItemVariant.Description, 1, MaxStrLen(Description));
                            end;
                        RetailItemSetup."Description control"::"<Desc Item>:<Desc2 Variant>":
                            begin
                                Description := Item.Description;
                                if ItemVariant.Get(Rec."No.", Rec."Variant Code") then
                                    "Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen("Description 2"));
                            end;
                    end;
                end;
            end;

            if (Description = '') or (Description = ' ') then
                Description := CopyStr(Item.Description, 1, 30);

            "Description 2" := CopyStr(Item."Description 2", 1, 30);
        end;
    end;

    local procedure GetDescriptionSale(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        RetailItemSetup: Record "NPR Retail Item Setup";
        Desc: Text[100];
        Desc2: Text[50];
        ItemGroup: Record "NPR Item Group";
        Vendor: Record Vendor;
        pos1: Integer;
        VendorName: Text[100];
        ItemGroupName: Text[50];
    begin
        with SalesLine do begin
            if Type <> Type::Item then
                exit;

            if not Item.Get("No.") then
                exit;

            if not RetailItemSetup.Get then
                exit;

            InitDescriptionControl();

            case RetailItemSetup."Description control" of
                RetailItemSetup."Description control"::"<Description>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Desc, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Description 2>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Desc2, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Vendor Name><Item Group><Vendor Item No.>":
                    begin
                        if ItemGroup.Get(Item."NPR Item Group") then begin
                            if Vendor.Get(Item."Vendor No.") then
                                pos1 := StrPos(Vendor.Name, ' ');
                            if pos1 > 0 then
                                VendorName := CopyStr(Vendor.Name, 1, pos1 - 1)
                            else
                                VendorName := Vendor.Name;

                            pos1 := StrPos(ItemGroup.Description, ' ');
                            if pos1 > 0 then
                                ItemGroupName := CopyStr(ItemGroup.Description, 1, pos1 - 1)
                            else
                                ItemGroupName := ItemGroup.Description;

                            if (VendorName <> '') and (ItemGroupName <> '') then
                                Description := CopyStr(VendorName + ' ' + ItemGroupName + ' ' + Item."Vendor Item No.", 1, MaxStrLen(Description));
                        end;
                    end;
                RetailItemSetup."Description control"::"<Description 2><Item group name>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        if ItemGroup.Get(Item."NPR Item Group") and (Desc2 <> '') then
                            Description := CopyStr(Desc2 + ' ' + ItemGroup.Description, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Description><Variant Info>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        Description := Desc;

                        GetItemTranslation_OLD("No.", "Variant Code", SalesHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Description + ' ' + Desc, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Desc Item>:<Desc2 Variant>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        Description := Desc;
                        GetItemTranslation_OLD("No.", "Variant Code", SalesHeader."Language Code", Desc, Desc2);
                        "Description 2" := CopyStr(Desc, 1, MaxStrLen("Description 2"));
                    end;
            end;
        end;
    end;

    local procedure GetDescriptionPurchase(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    var
        Item: Record Item;
        RetailItemSetup: Record "NPR Retail Item Setup";
        Desc: Text[100];
        Desc2: Text[50];
        ItemGroup: Record "NPR Item Group";
        Vendor: Record Vendor;
        pos1: Integer;
        VendorName: Text[100];
        ItemGroupName: Text[50];
    begin
        with PurchLine do begin
            if Type <> Type::Item then
                exit;

            if not Item.Get("No.") then
                exit;

            if not RetailItemSetup.Get then
                exit;

            InitDescriptionControl();

            case RetailItemSetup."Description control" of
                RetailItemSetup."Description control"::"<Description>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Desc, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Description 2>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Desc2, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Vendor Name><Item Group><Vendor Item No.>":
                    begin
                        if ItemGroup.Get(Item."NPR Item Group") then begin
                            if Vendor.Get(Item."Vendor No.") then
                                pos1 := StrPos(Vendor.Name, ' ');
                            if pos1 > 0 then
                                VendorName := CopyStr(Vendor.Name, 1, pos1 - 1)
                            else
                                VendorName := Vendor.Name;

                            pos1 := StrPos(ItemGroup.Description, ' ');
                            if pos1 > 0 then
                                ItemGroupName := CopyStr(ItemGroup.Description, 1, pos1 - 1)
                            else
                                ItemGroupName := ItemGroup.Description;

                            if (VendorName <> '') and (ItemGroupName <> '') then
                                Description := CopyStr(VendorName + ' ' + ItemGroupName + ' ' + Item."Vendor Item No.", 1, MaxStrLen(Description));
                        end;
                    end;
                RetailItemSetup."Description control"::"<Description 2><Item group name>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        if ItemGroup.Get(Item."NPR Item Group") and (Desc2 <> '') then
                            Description := CopyStr(Desc2 + ' ' + ItemGroup.Description, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Description><Variant Info>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        Description := Desc;

                        GetItemTranslation_OLD("No.", "Variant Code", PurchHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Description + ' ' + Desc, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Desc Item>:<Desc2 Variant>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        Description := Desc;
                        GetItemTranslation_OLD("No.", "Variant Code", PurchHeader."Language Code", Desc, Desc2);
                        "Description 2" := CopyStr(Desc, 1, MaxStrLen("Description 2"));
                    end;
            end;
        end;
    end;

    local procedure GetDescriptionTransfer(TransHeader: Record "Transfer Header"; var TransLine: Record "Transfer Line")
    var
        Item: Record Item;
        RetailItemSetup: Record "NPR Retail Item Setup";
        Desc: Text[100];
        Desc2: Text[50];
        ItemGroup: Record "NPR Item Group";
        Vendor: Record Vendor;
        pos1: Integer;
        VendorName: Text[100];
        ItemGroupName: Text[50];
    begin
        with TransLine do begin
            if not Item.Get("Item No.") then
                exit;

            if not RetailItemSetup.Get then
                exit;
            case RetailItemSetup."Description control" of
                RetailItemSetup."Description control"::"<Description>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        Description := CopyStr(Desc, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Description 2>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        Description := CopyStr(Desc2, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Vendor Name><Item Group><Vendor Item No.>":
                    begin
                        if ItemGroup.Get(Item."NPR Item Group") then begin
                            if Vendor.Get(Item."Vendor No.") then
                                pos1 := StrPos(Vendor.Name, ' ');
                            if pos1 > 0 then
                                VendorName := CopyStr(Vendor.Name, 1, pos1 - 1)
                            else
                                VendorName := Vendor.Name;

                            pos1 := StrPos(ItemGroup.Description, ' ');
                            if pos1 > 0 then
                                ItemGroupName := CopyStr(ItemGroup.Description, 1, pos1 - 1)
                            else
                                ItemGroupName := ItemGroup.Description;

                            if (VendorName <> '') and (ItemGroupName <> '') then
                                Description := CopyStr(VendorName + ' ' + ItemGroupName + ' ' + Item."Vendor Item No.", 1, MaxStrLen(Description));
                        end;
                    end;
                RetailItemSetup."Description control"::"<Description 2><Item group name>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        if ItemGroup.Get(Item."NPR Item Group") and (Desc2 <> '') then
                            Description := CopyStr(Desc2 + ' ' + ItemGroup.Description, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Description><Variant Info>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        Description := Desc;

                        GetItemTranslation_OLD("Item No.", "Variant Code", '', Desc, Desc2);
                        Description := CopyStr(Description + ' ' + Desc, 1, MaxStrLen(Description));
                    end;
                RetailItemSetup."Description control"::"<Desc Item>:<Desc2 Variant>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        Description := Desc;
                        GetItemTranslation_OLD("Item No.", "Variant Code", '', Desc, Desc2);
                        "Description 2" := CopyStr(Desc, 1, MaxStrLen("Description 2")); //check -TinF
                    end;
            end;
        end;
    end;

    procedure GetItemTranslation_OLD(ItemNo: Code[20]; VariantCode: Code[10]; Languagecode: Code[10]; var Desc: Text[100]; var Desc2: Text[50])
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemTranslation: Record "Item Translation";
    begin
        Item.Get(ItemNo);

        Desc := Item.Description;
        Desc2 := Item."Description 2";

        if ItemTranslation.Get(Item."No.", '', Languagecode) then begin
            Desc := ItemTranslation.Description;
            Desc2 := ItemTranslation."Description 2";
        end;

        if VariantCode <> '' then begin
            if ItemVariant.Get(Item."No.", VariantCode) then begin
                Desc := ItemVariant.Description;
                Desc2 := ItemVariant."Description 2";
            end;

            if ItemTranslation.Get(Item."No.", VariantCode, Languagecode) then begin
                Desc := ItemTranslation.Description;
                Desc2 := ItemTranslation."Description 2";
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure T39OnAfterValidateEventNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionPurchase(PurchaseHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Variant Code', true, true)]
    local procedure T39OnAfterValidateEventVariantCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionPurchase(PurchaseHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Unit of Measure Code', true, true)]
    local procedure T39OnAfterValidateEventUnitofMeasureCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionPurchase(PurchaseHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Location Code', true, true)]
    local procedure T39OnAfterValidateEventLocationCode(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        //-NPR5.29
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionPurchase(PurchaseHeader, Rec);
        //+NPR5.29
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'Item No.', true, true)]
    local procedure T5741OnAfterValidateEventNo(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        TransferHeader: Record "Transfer Header";
    begin
        if TransferHeader.Get(Rec."Document No.") then;
        GetDescriptionTransfer(TransferHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'Variant Code', true, true)]
    local procedure T5741OnAfterValidateEventVariantCode(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        TransferHeader: Record "Transfer Header";
    begin
        if TransferHeader.Get(Rec."Document No.") then;
        GetDescriptionTransfer(TransferHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'Unit of Measure Code', true, true)]
    local procedure T5741OnAfterValidateEventUnitofMeasureCode(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        TransferHeader: Record "Transfer Header";
    begin
        if TransferHeader.Get(Rec."Document No.") then;
        GetDescriptionTransfer(TransferHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'No.', true, true)]
    local procedure T37OnAfterValidateEventNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionSale(SalesHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Variant Code', true, true)]
    local procedure T37OnAfterValidateEventVariantCode(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionSale(SalesHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Unit of Measure Code', true, true)]
    local procedure T37OnAfterValidateEventUnitofMeasureCode(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionSale(SalesHeader, Rec);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Item Reference No.', true, true)]
    local procedure T39OnAfterValidateEventItemReferenceNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        //+NPR5.36
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionPurchase(PurchaseHeader, Rec);
        //-NPR5.36
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Item Reference No.', true, true)]
    local procedure T37OnAfterValidateEventItemReferenceNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        //+NPR5.36
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionSale(SalesHeader, Rec);
        //-NPR5.36
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'NPR Cross-Reference No.', true, true)]
    local procedure T5741OnAfterValidateEventItemReferenceNo(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        TransferHeader: Record "Transfer Header";
    begin
        //+NPR5.36
        if TransferHeader.Get(Rec."Document No.") then;
        GetDescriptionTransfer(TransferHeader, Rec);
        //-NPR5.36
    end;

    [EventSubscriber(ObjectType::Table, 5777, 'OnAfterValidateEvent', 'Item No.', true, true)]
    local procedure T5777OnAfterValidateEventItemNo(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; CurrFieldNo: Integer)
    begin
        //-NPR5.48 [338542]
        if (Rec."Item No." <> xRec."Item No.") or (Rec.Description = '') then
            Rec.Description := GetItemRefDescription(Rec."Item No.", Rec."Variant Code");
        //+NPR5.48 [338542]
    end;

    [EventSubscriber(ObjectType::Table, 5777, 'OnAfterValidateEvent', 'Variant Code', true, true)]
    local procedure T5777OnAfterValidateEventVariantCode(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; CurrFieldNo: Integer)
    begin
        //-NPR5.48 [338542]
        if (Rec."Variant Code" <> xRec."Variant Code") or (Rec.Description = '') then
            Rec.Description := GetItemRefDescription(Rec."Item No.", Rec."Variant Code");
        //+NPR5.48 [338542]
    end;
}

