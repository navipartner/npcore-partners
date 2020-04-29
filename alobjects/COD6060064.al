codeunit 6060064 "Nonstock Purchase Mgt."
{
    // NPR5.39/BR  /20180219  CASE 295322 Object Created
    // NPR5.42/RA  /20180523  CASE 295322
    // NPR5.48/TJ  /20190102  CASE 340615 Commented out usage of field Item."Product Group Code"
    //                                    Page 5726 was renamed to Catalog Item List


    trigger OnRun()
    begin
    end;

    var
        Text002: Label 'You cannot enter a nonstock item on %1.';
        Text003: Label 'Creating item card for nonstock item\';
        Text004: Label 'Manufacturer Code    #1####\';
        Text005: Label 'Vendor               #2##################\';
        Text006: Label 'Vendor Item          #3##################\';
        Text007: Label 'Item No.             #4##################';
        NewItem: Record Item;
        NonStock: Record "Nonstock Item";
        ProgWindow: Dialog;
        MfrLength: Integer;
        VenLength: Integer;
        NonstockItemSetup: Record "Nonstock Item Setup";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        UnitofMeasure: Record "Unit of Measure";
        ItemCategory: Record "Item Category";
        ItemVend: Record "Item Vendor";

    procedure ShowNonstock(var PurchaseLine: Record "Purchase Line";ItemCrossRef: Code[20])
    var
        NonstockItem: Record "Nonstock Item";
        Execute: Boolean;
    begin
        //This function is based on the ShowNonstock function in Table 37 Sales Line
        with PurchaseLine do begin
          TestField(Type,Type::Item);
          TestField("No.",'');
          //-NPR5.42
          /*
          IF PAGE.RUNMODAL(PAGE::"Nonstock Item List",NonstockItem) = ACTION::LookupOK THEN BEGIN
            NonstockItem.TESTFIELD("Item Template Code");
            //ItemCategory.GET(NonstockItem."Item Category Code");
            //ItemCategory.TESTFIELD("Def. Gen. Prod. Posting Group");
            //ItemCategory.TESTFIELD("Def. Inventory Posting Group");
        
            "No." := NonstockItem."Entry No.";
            NonStockPurchase(PurchaseLine);
            VALIDATE("No.","No.");
            IF NonstockItem."Negotiated Cost" <> 0 THEN
              VALIDATE("Direct Unit Cost",NonstockItem."Negotiated Cost")
            ELSE
              IF NonstockItem."Published Cost" <> 0 THEN
                VALIDATE("Direct Unit Cost",NonstockItem."Published Cost");
          END;
          */
          if ItemCrossRef = '' then begin
            //-NPR5.48 [340615]
            //IF PAGE.RUNMODAL(PAGE::"Nonstock Item List",NonstockItem) = ACTION::LookupOK THEN
            if PAGE.RunModal(PAGE::"Catalog Item List",NonstockItem) = ACTION::LookupOK then
            //+NPR5.48 [340615]
              Execute := true;
          end else begin
            NonstockItem.SetRange("Vendor Item No.", ItemCrossRef);
            if not NonstockItem.FindFirst then begin
              NonstockItem.SetRange("Vendor Item No.");
              NonstockItem.SetRange("Bar Code", ItemCrossRef);
              if not NonstockItem.FindFirst then
                exit;
            end;
            Execute := true;
          end;
          if Execute then begin
            NonstockItem.TestField("Item Template Code");
            "No." := NonstockItem."Entry No.";
            NonStockPurchase(PurchaseLine);
            Validate("No.","No.");
            "Cross-Reference Type" := "Cross-Reference Type"::"Bar Code";
            "Cross-Reference No." := NonstockItem."Bar Code";
          end;
          //+NPR5.42
        end;

    end;

    procedure NonStockPurchase(var PurchaseLine2: Record "Purchase Line")
    var
        InvtSetup: Record "Inventory Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        //This function is based on the NonStockSales function in Codeunit 5703 Nonstock Item Management
        if (PurchaseLine2."Document Type" in
            [PurchaseLine2."Document Type"::"Return Order",PurchaseLine2."Document Type"::"Credit Memo"])
        then
          Error(Text002,PurchaseLine2."Document Type");
        
        NonStock.Get(PurchaseLine2."No.");
        if NonStock."Item No." <> '' then begin
          PurchaseLine2."No." := NonStock."Item No.";
          exit;
        end;
        //-NPR5.42
        /*
        MfrLength := STRLEN(NonStock."Manufacturer Code");
        VenLength := STRLEN(NonStock."Vendor Item No.");
        
        NonstockItemSetup.GET;
        CASE NonstockItemSetup."No. Format" OF
          NonstockItemSetup."No. Format"::"Vendor Item No.":
            PurchaseLine2."No." := NonStock."Vendor Item No.";
          NonstockItemSetup."No. Format"::"Mfr. + Vendor Item No.":
            IF NonstockItemSetup."No. Format Separator" = '' THEN BEGIN
              IF MfrLength + VenLength <= 20 THEN
                PurchaseLine2."No." := NonStock."Manufacturer Code" + NonStock."Vendor Item No."
              ELSE
                PurchaseLine2."No." := NonStock."Manufacturer Code" + NonStock."Entry No.";
            END ELSE BEGIN
              IF MfrLength + VenLength < 20 THEN
                PurchaseLine2."No." :=
                  NonStock."Manufacturer Code" + NonstockItemSetup."No. Format Separator" +
                  NonStock."Vendor Item No."
              ELSE
                PurchaseLine2."No." :=
                  NonStock."Manufacturer Code" + NonstockItemSetup."No. Format Separator" +
                  NonStock."Entry No.";
            END;
          NonstockItemSetup."No. Format"::"Vendor Item No. + Mfr.":
            IF NonstockItemSetup."No. Format Separator" = '' THEN BEGIN
              IF MfrLength + VenLength <= 20 THEN
                PurchaseLine2."No." := NonStock."Vendor Item No." + NonStock."Manufacturer Code"
              ELSE
                PurchaseLine2."No." := NonStock."Entry No." + NonStock."Manufacturer Code";
            END ELSE BEGIN
              IF MfrLength + VenLength < 20 THEN
                PurchaseLine2."No." :=
                  NonStock."Vendor Item No." + NonstockItemSetup."No. Format Separator" +
                  NonStock."Manufacturer Code"
              ELSE
                PurchaseLine2."No." :=
                  NonStock."Entry No." + NonstockItemSetup."No. Format Separator" +
                  NonStock."Manufacturer Code";
            END;
          NonstockItemSetup."No. Format"::"Entry No.":
            PurchaseLine2."No." := NonStock."Entry No.";
        END;
        
        NonStock."Item No." := PurchaseLine2."No.";
        NonStock.MODIFY;
        */
        //+NPR5.42
        if not UnitofMeasure.Get(NonStock."Unit of Measure") then begin
          UnitofMeasure.Code := NonStock."Unit of Measure";
          UnitofMeasure.Insert;
        end;
        //-NPR5.42
        /*
        IF NOT ItemUnitofMeasure.GET(PurchaseLine2."No.",NonStock."Unit of Measure") THEN BEGIN
          ItemUnitofMeasure."Item No." := PurchaseLine2."No.";
          ItemUnitofMeasure.Code := NonStock."Unit of Measure";
          ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
          ItemUnitofMeasure.INSERT;
        END;
        
        NewItem.SETRANGE("No.",PurchaseLine2."No.");
        IF NewItem.FINDFIRST THEN
          EXIT;
        */
        NewItem.SetRange("Vendor Item No.", NonStock."Vendor Item No.");
        if NewItem.FindFirst then begin
          NonStock."Item No." := NewItem."No.";
          NonStock.Modify;
          PurchaseLine2."No." := NewItem."No.";
          exit;
        end;
        //+NPR5.42
        ProgWindow.Open(Text003 +
          Text004 +
          Text005 +
          Text006 +
          Text007);
        ProgWindow.Update(1,NonStock."Manufacturer Code");
        ProgWindow.Update(2,NonStock."Vendor No.");
        ProgWindow.Update(3,NonStock."Vendor Item No.");
        ProgWindow.Update(4,PurchaseLine2."No.");
        
        //-NPR2017
        //ItemCategory.GET(NonStock."Item Template Code");
        //+NPR2017
        
        //-NPR5.42
        InvtSetup.Get;
        InvtSetup.TestField("Item Nos.");
        NoSeriesMgt.InitSeries(InvtSetup."Item Nos.",NewItem."No. Series",0D,NewItem."No.",NewItem."No. Series");
        //+NPR5.42
        
        //-NPR2017
        //NewItem."Inventory Posting Group" := ItemCategory."Def. Inventory Posting Group";
        //NewItem."Costing Method" := ItemCategory."Def. Costing Method";
        //NewItem."Gen. Prod. Posting Group" := ItemCategory."Def. Gen. Prod. Posting Group";
        //NewItem."Tax Group Code" := ItemCategory."Def. Tax Group Code";
        //NewItem."VAT Prod. Posting Group" := ItemCategory."Def. VAT Prod. Posting Group";
        //+NPR2017
        
        //-NPR5.42
        //NewItem."No." := PurchaseLine2."No.";
        //+NPR5.42
        
        NewItem.Description := NonStock.Description;
        NewItem.Validate(Description,NewItem.Description);
        //-NPR5.42
        if not ItemUnitofMeasure.Get(NewItem."No.", NonStock."Unit of Measure") then begin
          ItemUnitofMeasure."Item No." := NewItem."No.";
          ItemUnitofMeasure.Code := NonStock."Unit of Measure";
          ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
          ItemUnitofMeasure.Insert;
        end;
        //+NPR5.42
        NewItem.Validate("Base Unit of Measure",NonStock."Unit of Measure");
        NewItem."Unit Price" := NonStock."Unit Price";
        //-NPR5.42
        //NewItem."Unit Cost" := NonStock."Negotiated Cost";
        //NewItem."Last Direct Cost" := NonStock."Negotiated Cost";
        if NonStock."Negotiated Cost" <> 0 then
          NewItem."Last Direct Cost" := NonStock."Negotiated Cost"
        else
          NewItem."Last Direct Cost" := NonStock."Published Cost";
        //+NPR5.42
        NewItem."Automatic Ext. Texts" := false;
        if NewItem."Costing Method" = NewItem."Costing Method"::Standard then
          NewItem."Standard Cost" := NonStock."Negotiated Cost";
        NewItem."Vendor No." := NonStock."Vendor No.";
        NewItem."Vendor Item No." := NonStock."Vendor Item No.";
        NewItem."Net Weight" := NonStock."Net Weight";
        NewItem."Gross Weight" := NonStock."Gross Weight";
        NewItem."Manufacturer Code" := NonStock."Manufacturer Code";
        NewItem."Item Category Code" := NonStock."Item Template Code";
        //-NPR5.48 [340615]
        //NewItem."Product Group Code" := NonStock."Product Group Code";
        //+NPR5.48 [340615]
        NewItem."Created From Nonstock Item" := true;
        //-NPR5.42
        NewItem."Label Barcode" := NonStock."Bar Code";
        NewItem."Unit Price" := NonStock."Unit Price";
        //+NPR5.42
        NewItem.Insert;
        
        //-NPR5.42
        PurchaseLine2."No." := NewItem."No.";
        
        NonStock."Item No." := NewItem."No.";
        NonStock.Modify;
        //+NPR5.42
        
        if CheckLicensePermission(DATABASE::"Item Vendor") then
          NonstockItemVend(NonStock);
        if CheckLicensePermission(DATABASE::"Item Cross Reference") then
          NonstockItemCrossRef(NonStock);
        
        ProgWindow.Close;

    end;

    local procedure CheckLicensePermission(TableID: Integer): Boolean
    var
        LicensePermission: Record "License Permission";
    begin
        LicensePermission.SetRange("Object Type",LicensePermission."Object Type"::TableData);
        LicensePermission.SetRange("Object Number",TableID);
        LicensePermission.SetFilter("Insert Permission",'<>%1',LicensePermission."Insert Permission"::" ");
        exit(LicensePermission.FindFirst);
    end;

    local procedure NonstockItemVend(NonStock2: Record "Nonstock Item")
    begin
        ItemVend.SetRange("Item No.",NonStock2."Item No.");
        ItemVend.SetRange("Vendor No.",NonStock2."Vendor No.");
        if ItemVend.FindFirst then
          exit;

        ItemVend."Item No." := NonStock2."Item No.";
        ItemVend."Vendor No." := NonStock2."Vendor No.";
        ItemVend."Vendor Item No." := NonStock2."Vendor Item No.";
        ItemVend.Insert(true);
    end;

    local procedure NonstockItemCrossRef(var NonStock2: Record "Nonstock Item")
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        ItemCrossReference.SetRange("Item No.",NonStock2."Item No.");
        ItemCrossReference.SetRange("Unit of Measure",NonStock2."Unit of Measure");
        ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::Vendor);
        ItemCrossReference.SetRange("Cross-Reference Type No.",NonStock2."Vendor No.");
        ItemCrossReference.SetRange("Cross-Reference No.",NonStock2."Vendor Item No.");
        if not ItemCrossReference.FindFirst then begin
          ItemCrossReference.Init;
          ItemCrossReference.Validate("Item No.",NonStock2."Item No.");
          ItemCrossReference.Validate("Unit of Measure",NonStock2."Unit of Measure");
          ItemCrossReference.Validate("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::Vendor);
          ItemCrossReference.Validate("Cross-Reference Type No.",NonStock2."Vendor No.");
          ItemCrossReference.Validate("Cross-Reference No.",NonStock2."Vendor Item No.");
          ItemCrossReference.Insert;
        end;
        if NonStock2."Bar Code" <> '' then begin
          ItemCrossReference.Reset;
          ItemCrossReference.SetRange("Item No.",NonStock2."Item No.");
          ItemCrossReference.SetRange("Unit of Measure",NonStock2."Unit of Measure");
          ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
          ItemCrossReference.SetRange("Cross-Reference No.",NonStock2."Bar Code");
          if not ItemCrossReference.FindFirst then begin
            ItemCrossReference.Init;
            ItemCrossReference.Validate("Item No.",NonStock2."Item No.");
            ItemCrossReference.Validate("Unit of Measure",NonStock2."Unit of Measure");
            ItemCrossReference.Validate("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
            ItemCrossReference.Validate("Cross-Reference No.",NonStock2."Bar Code");
            ItemCrossReference.Insert;
          end;
        end;
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 54, 'OnAfterActionEvent', 'Nonstockitems', true, true)]
    local procedure OnAfterNonstockitems(var Rec: Record "Purchase Line")
    begin
        //-NPR5.42
        //ShowNonstock(Rec);
        ShowNonstock(Rec, '');
        //+NPR5.42
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure OnBeforeValidateCrossReferenceNo(var Rec: Record "Purchase Line";var xRec: Record "Purchase Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        //-NPR5.42
        if (Rec."Cross-Reference No." <> '') and (Rec."Cross-Reference No." <> xRec."Cross-Reference No.") then begin
          Item.SetRange("Vendor Item No.", Rec."Cross-Reference No.");
          if not Item.FindFirst then begin
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::Vendor);
            ItemCrossReference.SetRange("Cross-Reference No.", Rec."Cross-Reference No.");
            if not ItemCrossReference.FindFirst then begin
              Item.SetRange("Vendor Item No.");
              Item.SetRange("Label Barcode", Rec."Cross-Reference No.");
              if not Item.FindFirst then begin
                ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
                if not ItemCrossReference.FindFirst then
                  ShowNonstock(Rec, Rec."Cross-Reference No.");
              end;
            end;
          end;
        end;
        //+NPR5.42
    end;
}

