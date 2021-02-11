codeunit 6059969 "NPR Description Control"
{
    // NPR5.29/JDH /20161213 CASE 260472 Moved all description Control to this CU
    // NPR5.29/KENU/20170106 CASE 262474 Added OnValidateEventLocationCode Event Subscriber to stop flipping values between Description and "Description 2"
    // NPR5.36/MMV /20170724 CASE 284550 Moved initialization routine from CompanyOpen to a "IF NOT SETUP.GET()" pattern.
    // NPR5.36/KENU/20170912 CASE 289660 Added EventSubscriber: T39OnAfterValidateEventCrossReferenceNo, T37OnAfterValidateEventCrossReferenceNo, T5741OnAfterValidateEventCrossReferenceNo
    // NPR5.47/MMV /20181019 CASE 332824 Fixed case 284550 approach
    // NPR5.48/JDH /20181214 CASE 338542 Created a function to get the description for Item Cross references, and 2 subscribers to update description on ICR table
    // NPR5.51/ALST/20190731 CASE 351999 POS will now try to find a description in the current user's language, when creating the sales line, and using it
    // NPR5.55/ALST/20200624 CASE 370006 modifications to description variables


    trigger OnRun()
    begin
    end;

    procedure GetDescriptionPOS(var Rec: Record "NPR Sale Line POS"; XRec: Record "NPR Sale Line POS"; Item: Record Item)
    var
        RetailSetup: Record "NPR Retail Setup";
        Language: Record Language;
    begin
        with Rec do begin
            if "Custom Descr" then
                exit;

            if Type <> Type::Item then
                exit;

            //-NPR5.47 [332824]
            InitDescriptionControl();
            //+NPR5.47 [332824]

            if RetailSetup.Get then begin
                if RetailSetup."POS Line Description Code" = '' then begin
                    //Do this the old way
                    GetDescriptionPOS_OLD(Rec, XRec, Item);
                end else begin
                    //this is the new way
                    //-NPR5.51 [351999]
                    Language.SetRange("Windows Language ID", GlobalLanguage);
                    if Language.FindFirst then;
                    GetDescription(Description, "Description 2", "No.", "Variant Code", Language.Code, RetailSetup."POS Line Description Code");
                    // GetDescription(Description, "Description 2", "No.", "Variant Code", '', RetailSetup."POS Line Description Code");
                    //+NPR5.51 [351999]
                end;
            end;
        end;
    end;

    local procedure GetDescriptionPurchase(PurchHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        with PurchaseLine do begin
            if Type <> Type::Item then
                exit;

            //-NPR5.47 [332824]
            InitDescriptionControl();
            //+NPR5.47 [332824]

            if RetailSetup.Get then begin
                if (RetailSetup."Purchase Line Description Code" = '') then begin
                    //Do this the old way
                    GetDescriptionPL_OLD(PurchaseLine, PurchHeader);
                end else begin
                    //this is the new way
                    GetDescription(Description, "Description 2", "No.", "Variant Code", PurchHeader."Language Code", RetailSetup."Purchase Line Description Code");
                end;
            end;
        end;
    end;

    local procedure GetDescriptionSale(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        with SalesLine do begin
            if Type <> Type::Item then
                exit;

            //-NPR5.47 [332824]
            InitDescriptionControl();
            //+NPR5.47 [332824]

            if RetailSetup.Get then begin
                if (RetailSetup."Sales Line Description Code" = '') then begin
                    //Do this the old way
                    GetDescriptionSL_OLD(SalesLine, SalesHeader);
                end else begin
                    //this is the new way
                    GetDescription(Description, "Description 2", "No.", "Variant Code", SalesHeader."Language Code", RetailSetup."Sales Line Description Code");
                end;
            end;
        end;
    end;

    local procedure GetDescriptionTransfer(TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line")
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        with TransferLine do begin

            //-NPR5.47 [332824]
            InitDescriptionControl();
            //+NPR5.47 [332824]

            if RetailSetup.Get then begin
                if (RetailSetup."Transfer Line Description Code" = '') then begin
                    //Do this the old way
                    GetDescriptionTL_OLD(TransferLine, TransferHeader);
                end else begin
                    //this is the new way
                    GetDescription(Description, "Description 2", "Item No.", "Variant Code", '', RetailSetup."Transfer Line Description Code");
                end;
            end;
        end;
    end;

    local procedure GetDescription(var Desc1: Text; var Desc2: Text; ItemNo: Code[20]; VariantCode: Code[10]; LanguageCode: Code[10]; DescControlCode: Code[10])
    var
        Description1: Text[100];
        Description2: Text[50];
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        DescriptionControl: Record "NPR Description Control";
    begin
        if not DescriptionControl.Get(DescControlCode) then
            //-NPR5.47 [332824]
            //  BEGIN
            //    InitDescriptionControl();
            //    IF NOT DescriptionControl.GET(DescControlCode) THEN
            //      EXIT;
            //  END;
            exit;
        //+NPR5.47 [332824]

        if not DescriptionControl."Disable Item Translations" then begin
            if GetItemTrans(ItemNo, VariantCode, LanguageCode, Description1, Description2) then begin
                Desc1 := Description1;
                Desc2 := Description2;
                exit;
            end;
        end;

        if DescriptionControl."Setup Type" = DescriptionControl."Setup Type"::Simple then begin
            if VariantCode = '' then
                GetDescriptionSimple(Desc1, Desc2, ItemNo, VariantCode, DescriptionControl."Description 1 Std (Simple)", DescriptionControl."Description 2 Std (Simple)")
            else
                GetDescriptionSimple(Desc1, Desc2, ItemNo, VariantCode, DescriptionControl."Description 1 Var (Simple)", DescriptionControl."Description 2 Var (Simple)");
        end;
    end;

    local procedure GetDescriptionSimple(var Desc1: Text; var Desc2: Text; ItemNo: Code[20]; VariantCode: Code[10]; Desc1Setup: Option " ",ItemDescription1,ItemDescription2,VariantDescription1,VariantDescription2,VendorItemNo; Desc2Setup: Option " ",ItemDescription1,ItemDescription2,VariantDescription1,VariantDescription2,VendorItemNo)
    var
        Description1: Text[100];
        Description2: Text[100];
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        "Field": Record "Field";
        FieldNo: Integer;
    begin
        if not Item.Get(ItemNo) then
            exit;

        if VariantCode <> '' then begin
            if not ItemVariant.Get(ItemNo, VariantCode) then
                exit;
        end;

        case Desc1Setup of
            Desc1Setup::ItemDescription1:
                Description1 := Item.Description;
            Desc1Setup::ItemDescription2:
                Description1 := Item."Description 2";
            Desc1Setup::VariantDescription1:
                Description1 := ItemVariant.Description;
            Desc1Setup::VariantDescription2:
                Description1 := ItemVariant."Description 2";
            Desc1Setup::VendorItemNo:
                Description1 := Item."Vendor Item No.";
        end;

        case Desc2Setup of
            Desc2Setup::ItemDescription1:
                Description2 := Item.Description;
            Desc2Setup::ItemDescription2:
                Description2 := Item."Description 2";
            Desc2Setup::VariantDescription1:
                Description2 := ItemVariant.Description;
            Desc2Setup::VariantDescription2:
                Description2 := ItemVariant."Description 2";
            Desc2Setup::VendorItemNo:
                Description2 := Item."Vendor Item No.";
        end;

        //-NPR5.55 [370006]
        // Desc1 := Description1;
        // Desc2 := Description2;
        case Desc1Setup of
            Desc1Setup::ItemDescription1,
          Desc1Setup::VariantDescription1:
                FieldNo := Item.FieldNo(Description);
            Desc1Setup::ItemDescription2,
          Desc1Setup::VariantDescription2:
                FieldNo := Item.FieldNo("Description 2");
            Desc1Setup::VendorItemNo:
                FieldNo := Item.FieldNo("Vendor Item No.");
        end;

        Field.Get(DATABASE::Item, FieldNo);
        Desc1 := CopyStr(Description1, 1, Field.Len);

        case Desc2Setup of
            Desc2Setup::ItemDescription1,
          Desc2Setup::VariantDescription1:
                FieldNo := Item.FieldNo(Description);
            Desc2Setup::ItemDescription2,
          Desc2Setup::VariantDescription2:
                FieldNo := Item.FieldNo("Description 2");
            Desc2Setup::VendorItemNo:
                FieldNo := Item.FieldNo("Vendor Item No.");
        end;

        Field.Get(DATABASE::Item, FieldNo);
        Desc2 := CopyStr(Description2, 1, Field.Len);
        //+370006# [370006]
    end;

    local procedure InitDescriptionControl()
    var
        DescriptionControl: Record "NPR Description Control";
        RetailSetup: Record "NPR Retail Setup";
    begin
        if not DescriptionControl.IsEmpty then
            exit;

        with DescriptionControl do begin
            //-NPR5.29.01
            LockTable;
            //+NPR5.29.01
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

    local procedure GetItemTrans(ItemNo: Code[20]; VariantCode: Code[10]; LanguageCode: Code[10]; var Desc1: Text[100]; var Desc2: Text[50]): Boolean
    var
        ItemTranslation: Record "Item Translation";
    begin
        if not ItemTranslation.Get(ItemNo, VariantCode, LanguageCode) then
            exit(false);

        Desc1 := ItemTranslation.Description;
        Desc2 := ItemTranslation."Description 2";
        exit(true);
    end;

    procedure GetItemCrossRefDescription(ItemNo: Code[20]; VariantCode: Code[10]): Text[100]
    var
        VRTSetup: Record "NPR Variety Setup";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        //-NPR5.48 [338542]
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
        //+NPR5.48 [338542]
    end;

    local procedure GetDescriptionPOS_OLD(var Rec: Record "NPR Sale Line POS"; XRec: Record "NPR Sale Line POS"; Item: Record Item)
    var
        RetailSetup: Record "NPR Retail Setup";
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

            if RetailSetup.Get then begin
                if ((XRec."No." <> "No.") or (Description = '')) and not "Custom Descr" then begin
                    case RetailSetup."Description control" of
                        RetailSetup."Description control"::"<Description>":
                            Description := CopyStr(Item.Description, 1, 50);
                        RetailSetup."Description control"::"<Description 2>":
                            Description := CopyStr(Item."Description 2", 1, 50);
                        RetailSetup."Description control"::"<Vendor Name><Item Group><Vendor Item No.>":
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
                        RetailSetup."Description control"::"<Description 2><Item group name>":
                            begin
                                if ItemGroup.Get(Item."NPR Item Group") and (Item."Description 2" <> '') then
                                    Description := CopyStr(Item."Description 2" + ' ' + ItemGroup.Description, 1, 30);
                            end;
                        RetailSetup."Description control"::"<Description><Variant Info>":
                            begin
                                if ItemVariant.Get(Rec."No.", Rec."Variant Code") then
                                    Description := CopyStr(Item.Description + ' ' + ItemVariant.Description, 1, MaxStrLen(Description));
                            end;
                        RetailSetup."Description control"::"<Desc Item>:<Desc2 Variant>":
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

    local procedure GetDescriptionSL_OLD(SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        Item: Record Item;
        RetailSetup: Record "NPR Retail Setup";
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

            if not RetailSetup.Get then
                exit;
            case RetailSetup."Description control" of
                RetailSetup."Description control"::"<Description>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Desc, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Description 2>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Desc2, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Vendor Name><Item Group><Vendor Item No.>":
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
                RetailSetup."Description control"::"<Description 2><Item group name>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        if ItemGroup.Get(Item."NPR Item Group") and (Desc2 <> '') then
                            Description := CopyStr(Desc2 + ' ' + ItemGroup.Description, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Description><Variant Info>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        Description := Desc;

                        GetItemTranslation_OLD("No.", "Variant Code", SalesHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Description + ' ' + Desc, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Desc Item>:<Desc2 Variant>":
                    begin
                        GetItemTranslation_OLD("No.", '', SalesHeader."Language Code", Desc, Desc2);
                        Description := Desc;
                        GetItemTranslation_OLD("No.", "Variant Code", SalesHeader."Language Code", Desc, Desc2);
                        "Description 2" := CopyStr(Desc, 1, MaxStrLen("Description 2"));
                    end;
            end;
        end;
    end;

    local procedure GetDescriptionPL_OLD(PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    var
        Item: Record Item;
        RetailSetup: Record "NPR Retail Setup";
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

            if not RetailSetup.Get then
                exit;
            case RetailSetup."Description control" of
                RetailSetup."Description control"::"<Description>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Desc, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Description 2>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Desc2, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Vendor Name><Item Group><Vendor Item No.>":
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
                RetailSetup."Description control"::"<Description 2><Item group name>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        if ItemGroup.Get(Item."NPR Item Group") and (Desc2 <> '') then
                            Description := CopyStr(Desc2 + ' ' + ItemGroup.Description, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Description><Variant Info>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        Description := Desc;

                        GetItemTranslation_OLD("No.", "Variant Code", PurchHeader."Language Code", Desc, Desc2);
                        Description := CopyStr(Description + ' ' + Desc, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Desc Item>:<Desc2 Variant>":
                    begin
                        GetItemTranslation_OLD("No.", '', PurchHeader."Language Code", Desc, Desc2);
                        Description := Desc;
                        GetItemTranslation_OLD("No.", "Variant Code", PurchHeader."Language Code", Desc, Desc2);
                        "Description 2" := CopyStr(Desc, 1, MaxStrLen("Description 2"));
                    end;
            end;
        end;
    end;

    local procedure GetDescriptionTL_OLD(TransLine: Record "Transfer Line"; TransHeader: Record "Transfer Header")
    var
        Item: Record Item;
        RetailSetup: Record "NPR Retail Setup";
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

            if not RetailSetup.Get then
                exit;
            case RetailSetup."Description control" of
                RetailSetup."Description control"::"<Description>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        Description := CopyStr(Desc, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Description 2>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        Description := CopyStr(Desc2, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Vendor Name><Item Group><Vendor Item No.>":
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
                RetailSetup."Description control"::"<Description 2><Item group name>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        if ItemGroup.Get(Item."NPR Item Group") and (Desc2 <> '') then
                            Description := CopyStr(Desc2 + ' ' + ItemGroup.Description, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Description><Variant Info>":
                    begin
                        GetItemTranslation_OLD("Item No.", '', '', Desc, Desc2);
                        Description := Desc;

                        GetItemTranslation_OLD("Item No.", "Variant Code", '', Desc, Desc2);
                        Description := CopyStr(Description + ' ' + Desc, 1, MaxStrLen(Description));
                    end;
                RetailSetup."Description control"::"<Desc Item>:<Desc2 Variant>":
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

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Cross-Reference No.', true, true)]
    local procedure T39OnAfterValidateEventCrossReferenceNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        //+NPR5.36
        if PurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionPurchase(PurchaseHeader, Rec);
        //-NPR5.36
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnAfterValidateEvent', 'Cross-Reference No.', true, true)]
    local procedure T37OnAfterValidateEventCrossReferenceNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        //+NPR5.36
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then;
        GetDescriptionSale(SalesHeader, Rec);
        //-NPR5.36
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'NPR Cross-Reference No.', true, true)]
    local procedure T5741OnAfterValidateEventCrossReferenceNo(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        TransferHeader: Record "Transfer Header";
    begin
        //+NPR5.36
        if TransferHeader.Get(Rec."Document No.") then;
        GetDescriptionTransfer(TransferHeader, Rec);
        //-NPR5.36
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterValidateEvent', 'Item No.', true, true)]
    local procedure T5717OnAfterValidateEventItemNo(var Rec: Record "Item Cross Reference"; var xRec: Record "Item Cross Reference"; CurrFieldNo: Integer)
    begin
        //-NPR5.48 [338542]
        if (Rec."Item No." <> xRec."Item No.") or (Rec.Description = '') then
            Rec.Description := GetItemCrossRefDescription(Rec."Item No.", Rec."Variant Code");
        //+NPR5.48 [338542]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterValidateEvent', 'Variant Code', true, true)]
    local procedure T5717OnAfterValidateEventVariantCode(var Rec: Record "Item Cross Reference"; var xRec: Record "Item Cross Reference"; CurrFieldNo: Integer)
    begin
        //-NPR5.48 [338542]
        if (Rec."Variant Code" <> xRec."Variant Code") or (Rec.Description = '') then
            Rec.Description := GetItemCrossRefDescription(Rec."Item No.", Rec."Variant Code");
        //+NPR5.48 [338542]
    end;
}

