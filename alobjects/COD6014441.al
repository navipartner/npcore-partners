codeunit 6014441 "NPR Event Subscriber (Item)"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                             Added Code with tags NPR7.100.000
    // NPR5.22.01/TJ/20160516 CASE 241673 Rearranging functions and adding necessary triggers
    // NPR5.22.01/BR/20160519 CASE 241965 Prevent Error caused by Validating Item No. through RapidStart
    // NPR5.25/TJ  /20160711  CASE 245426 Adding code from Price Includes VAT - OnValidate
    // NPR5.26/MHA /20160810  CASE 248288 Create Aux Function deleted: IsEan13() and references removed to deleted Item Fields: 6014417 "NPK Created" and 6014421 ISBN
    // NPR5.27/JDH /20161027  CASE 256157 Added functionality to pop up item group on inserting a new item
    // NPR5.30/MHA /20170127  CASE 264742 Added functions for updating Vendor Item Cross Reference: OnAfterModifyEventLicenseCheck(),UpdateVendorItemCrossRef()
    // NPR5.30/MHA /20170201  CASE 264918 Np Photo Module removed
    // NPR5.30/MMV /20170202  CASE 265190 Added subscriber for "Label Barcode" validation.
    // NPR5.34/BR  /20170712  CASE 283366 Added check that item no. does not belong to barcode of another item
    // NPR5.36/AE/20170918 CASE 287536 Modify cross-ref check.
    // NPR5.38/MHA /20180105  CASE 301053 Converted Local Text Constants to Global Text Constants
    // NPR5.48/MHA /20181105  CASE 334212 Added Last Changed fields to OnBeforeInsertEventLicenseCheck() and OnBeforeModifyEventLicenseCheck()


    trigger OnRun()
    begin
    end;

    var
        RetailSetup: Record "Retail Setup";
        RetailSetupFetched: Boolean;
        InventorySetup: Record "Inventory Setup";
        InventorySetupFetched: Boolean;
        SalesSetup: Record "Sales & Receivables Setup";
        SalesSetupFetched: Boolean;
        Error_LabelBarcode: Label 'Barcode %1 cannot be selected unless it is present in %2 or %3 for this item.';
        Error_ItemCrossRef: Label 'Bar Code %1 cannot be linked to Item %2 if item %3 exits. ';
        ErrStd: Label 'Item %1 can''t be Group sale as it''s Costing Method is Standard.';
        Text000: Label 'Alternative No. %1 %2 already exists.';
        Text001: Label 'Can''t create number as no product group has been selected.';
        Text002: Label 'You can''t delete item %1 because it is part of an active sales document.';
        Text003: Label 'You can''t delete item %1 as there aren''t any posted entries for it.';
        Text004: Label 'You can''t delete %1 %2 as it''s contained in one or more period discount lines.';
        Text005: Label 'You can''t delete %1 %2 as it''s contained in one or more mixed discount lines.';

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeInsertEvent', '', true, false)]
    local procedure OnBeforeInsertEventLicenseCheck(var Rec: Record Item;RunTrigger: Boolean)
    var
        ItemGroup: Record "Item Group";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        InvtSetup: Record "Inventory Setup";
    begin
        //-NPR5.48 [334212]
        Rec."Last Changed at" := CurrentDateTime;
        Rec."Last Changed by" := CopyStr(UserId,1,MaxStrLen(Rec."Last Changed by"));
        //+NPR5.48 [334212]
        if not RunTrigger then
          exit;

        with Rec do begin
          GetRetailSetup;

        //-NPR5.25
          GetSalesSetup;
        //+NPR5.25

          //-NPR5.27 [256157]
          if RetailSetup."Item Group on Creation" and ("No." = '') and ("Item Group" = '') then begin
            if PAGE.RunModal(PAGE::"Item Group Tree", ItemGroup) = ACTION::LookupOK then begin
              "Item Group" := ItemGroup."No.";
              if ItemGroup."No. Series" <> '' then begin
                "No. Series" := ItemGroup."No. Series";
                InvtSetup.Get;
                InvtSetup.TestField("Item Nos.");
                NoSeriesMgt.InitSeries(InvtSetup."Item Nos.","No. Series",0D,"No.","No. Series");
              end;
            end;
          end;
          //+NPR5.27 [256157]

          if not "Group sale" then
            "Costing Method" := RetailSetup."Costing Method Standard";

          "Price Includes VAT" := RetailSetup."Prices Include VAT";

        //-NPR5.25
          if "Price Includes VAT" and (SalesSetup."VAT Bus. Posting Gr. (Price)" <> '') then
            "VAT Bus. Posting Gr. (Price)" := SalesSetup."VAT Bus. Posting Gr. (Price)";
        //+NPR5.25

          "Last Date Modified" := Today;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, false)]
    local procedure OnAfterInsertEventLicenseCheck(var Rec: Record Item;RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "Variety Clone Data";
    begin
        if not RunTrigger then
          exit;

        with Rec do begin
          "Primary Key Length" := StrLen("No.");
          //-#
          if "Item Group" <> '' then
            Validate("Item Group");
          //+#
          Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeModifyEvent', '', true, false)]
    local procedure OnBeforeModifyEventLicenseCheck(var Rec: Record Item;var xRec: Record Item;RunTrigger: Boolean)
    begin
        //-NPR5.48 [334212]
        Rec."Last Changed at" := CurrentDateTime;
        Rec."Last Changed by" := CopyStr(UserId,1,MaxStrLen(Rec."Last Changed by"));
        //+NPR5.48 [334212]
        if not RunTrigger then
          exit;

        with Rec do begin
          "Last Date Modified" := Today;
          "Primary Key Length" := StrLen(Rec."No."); //this line shouldn't be needed as primary key length can't be changed in modify trigger
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyEventLicenseCheck(var Rec: Record Item;var xRec: Record Item)
    begin
        //-NPR5.30 [264742]
        UpdateVendorItemCrossRef(Rec,xRec);
        //+NPR5.30 [264742]
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnBeforeDeleteEventLicenseCheck(var Rec: Record Item;RunTrigger: Boolean)
    var
        AuditRoll: Record "Audit Roll";
        SalesLinePOS: Record "Sale Line POS";
        PeriodDiscountLine: Record "Period Discount Line";
        MixedDiscountLine: Record "Mixed Discount Line";
    begin
        if not RunTrigger then
          exit;

        with Rec do begin
          AuditRoll.SetCurrentKey("Sale Type",Type,"No.",Posted);
          AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Sale);
          AuditRoll.SetRange(Type,AuditRoll.Type::Item);
          AuditRoll.SetRange("No.","No.");
          AuditRoll.SetRange(Posted,false);
          if AuditRoll.FindFirst then
            //-NPR5.38 [301053]
            //ERROR(Text001,"No.");
            Error(Text003,"No.");
            //+NPR5.38 [301053]

          SalesLinePOS.SetRange("Sale Type",SalesLinePOS."Sale Type"::Sale);
          SalesLinePOS.SetRange(Type,SalesLinePOS.Type::Item);
          SalesLinePOS.SetRange("No.","No.");
          if SalesLinePOS.FindFirst then
            Error(Text002,"No.");

          //-NPR5.30 [264918]
          // PhotoWorkLine.SETCURRENTKEY("Item No.");
          // PhotoWorkLine.SETRANGE("Item No.","No.");
          // IF PhotoWorkLine.FINDFIRST THEN
          //  ERROR(Text003,TABLECAPTION,"No.");
          //+NPR5.30 [264918]

          PeriodDiscountLine.SetCurrentKey("Item No.");
          PeriodDiscountLine.SetRange("Item No.","No.");
          if PeriodDiscountLine.FindFirst then
            Error(Text004,TableCaption,"No.");

          MixedDiscountLine.SetCurrentKey("No.");
          MixedDiscountLine.SetRange("No.","No.");
          if MixedDiscountLine.FindFirst then
            Error(Text005,TableCaption,"No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteEventLicenseCheck(var Rec: Record Item;RunTrigger: Boolean)
    var
        AlternativeNo: Record "Alternative No.";
        QtyDiscountLine: Record "Quantity Discount Line";
    begin
        if not RunTrigger then
          exit;

        with Rec do begin
          AlternativeNo.SetRange(Code,"No.");
          AlternativeNo.DeleteAll(true);

          QtyDiscountLine.SetRange("Item No.","No.");
          QtyDiscountLine.DeleteAll(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterRenameEvent', '', true, false)]
    local procedure OnAfterRenameEvent(var Rec: Record Item;var xRec: Record Item;RunTrigger: Boolean)
    begin
        if not RunTrigger then
          exit;

        with Rec do begin
          "Primary Key Length" := StrLen("No.");
          Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeValidateEvent', 'No.', true, false)]
    local procedure OnBeforeValidateEventNo(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        Utility: Codeunit Utility;
        AlternativeNo: Record "Alternative No.";
        Item: Record Item;
    begin
        with Rec do begin
          GetRetailSetup;

          if "No." = '' then
            exit;

          if not Item.Get("No.") and RetailSetup."EAN-No. at Item Create" then
            if (StrLen("No.") <= 10) and (StrLen("No.") >= 5) then
              "No." := Utility.CreateEAN("No.",'');

          AlternativeNo.SetRange("Alt. No.","No.");
          //-NPR5.22.01
          AlternativeNo.SetFilter(Code,'<>%1',"No.");
          //+NPR5.22.01
          //-NPR5.38 [301053]
          //IF AlternativeNo.FIND('-') THEN
          //  ERROR(Text001 + Text002 + Text003,"No.",AlternativeNo.Code);
          if AlternativeNo.FindFirst then
            Error(Text000,AlternativeNo."Alt. No.",AlternativeNo.Code);
          //+NPR5.38 [301053]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure OnAfterValidateEventNo(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        NFCode: Codeunit "NF Retail Code";
    begin
        ValidateNo(Rec,xRec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeValidateEvent', 'Costing Method', true, false)]
    local procedure OnBeforeValidateEventCostingMethod(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        RetailCodeunitCode: Codeunit "Std. Codeunit Code";
    begin
        CheckGroupSale(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Unit Cost', true, false)]
    local procedure OnAfterValidateEventUnitCost(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        RetailTableCode: Codeunit "Std. Table Code";
    begin
        UnitCostValidation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Last Direct Cost', true, false)]
    local procedure OnAfterValidateEventLastDirectCost(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        RetailTableCode: Codeunit "Std. Table Code";
    begin
        UnitCostValidation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Item Group', true, false)]
    local procedure OnAfterValidateEventItemGroupLicenseCheck(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        RetailTableCode: Codeunit "Std. Table Code";
        ItemGroup: Record "Item Group";
    begin
        //haven't moved code RetailTableCode.VareTVGOVAfter as it is being used from several places
        with Rec do begin
          if ItemGroup.Get("Item Group") then
            RetailTableCode.VareTVGOVAfter(Rec,ItemGroup);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Item Group', false, false)]
    local procedure OnAfterValidateEventItemGroup(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        ShoeShelves: Record "Shoe Shelves";
    begin
        if GetRetailSetup() then
          if RetailSetup."Shelve module" then
            Rec.Validate("Shelf No.",ShoeShelves.NewPlacement(Rec));
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Group sale', true, false)]
    local procedure OnAfterValidateEventGroupSaleLicenseCheck(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        RetailCodeunitCode: Codeunit "Std. Codeunit Code";
    begin
        CheckGroupSale(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Group sale', false, false)]
    local procedure OnAfterValidateEventGroupSale(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        ItemCostMgt: Codeunit ItemCostManagement;
    begin
        ItemCostMgt.UpdateUnitCost(Rec,'','',0,0,false,false,true,Rec.FieldNo("Group sale"));
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Label Barcode', false, false)]
    local procedure OnAfterValidateLabelBarcode(var Rec: Record Item;var xRec: Record Item;CurrFieldNo: Integer)
    var
        BarcodeLibrary: Codeunit "Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        AltNo: Record "Alternative No.";
        ItemCrossRef: Record "Item Cross Reference";
    begin
        //-NPR5.30 [265190]
        with Rec do
          if StrLen("Label Barcode") > 0 then begin
            if BarcodeLibrary.TranslateBarcodeToItemVariant("Label Barcode", ItemNo, VariantCode, ResolvingTable, false) then
              if (ItemNo = "No.") and (ResolvingTable in [DATABASE::"Alternative No.", DATABASE::"Item Cross Reference"]) then
                exit;
            Error(Error_LabelBarcode, "Label Barcode", AltNo.TableCaption, ItemCrossRef.TableCaption);
          end;
        //+NPR5.30 [265190]
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterRenameEvent', '', true, true)]
    local procedure OnAfterRenameItemCheckCrossRef(var Rec: Record Item;var xRec: Record Item;RunTrigger: Boolean)
    begin
        //-NPR5.34 [283366]
        CheckCrossRefFromItem(Rec."No.");
        //+NPR5.34 [283366]
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertItemCheckCrossRef(var Rec: Record Item;RunTrigger: Boolean)
    begin
        //-NPR5.34 [283366]
        CheckCrossRefFromItem(Rec."No.");
        //+NPR5.34 [283366]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertCrossRefCheckCrossRef(var Rec: Record "Item Cross Reference";RunTrigger: Boolean)
    begin
        //-NPR5.34 [283366]
        CheckCrossRef(Rec);
        //+NPR5.34 [283366]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyCrossRefCheckCrossRef(var Rec: Record "Item Cross Reference";var xRec: Record "Item Cross Reference";RunTrigger: Boolean)
    begin
        //-NPR5.34 [283366]
        CheckCrossRef(Rec);
        //+NPR5.34 [283366]
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameCrossRefCheckCrossRef(var Rec: Record "Item Cross Reference";var xRec: Record "Item Cross Reference";RunTrigger: Boolean)
    begin
        //-NPR5.34 [283366]
        CheckCrossRef(Rec);
        //+NPR5.34 [283366]
    end;

    local procedure CheckCrossRefFromItem(ItemNumber: Code[20])
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        //-NPR5.36 [287536]
        exit;
        //+NPR5.36 [287536]

        //-NPR5.34 [283366]
        ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SetRange("Cross-Reference No.",ItemNumber);
        ItemCrossReference.SetRange("Discontinue Bar Code",false);
        ItemCrossReference.SetFilter("Item No.",'<>%1',ItemNumber);
        if ItemCrossReference.FindFirst then
          Error(Error_ItemCrossRef,ItemCrossReference."Cross-Reference No.",ItemCrossReference."Item No.",ItemNumber);
        //+NPR5.34 [283366]
    end;

    local procedure CheckCrossRef(ItemCrossReference: Record "Item Cross Reference")
    var
        Item: Record Item;
    begin
        //-NPR5.36 [287536]
        exit;
        //+NPR5.36 [287536]

        //-NPR5.34 [283366]
        if StrLen(ItemCrossReference."Cross-Reference No.") > MaxStrLen(Item."No.") then
          exit;
        if ItemCrossReference."Item No." = ItemCrossReference."Cross-Reference No." then
          exit;
        if ItemCrossReference."Discontinue Bar Code" then
          exit;

        Item.SetRange("No.",ItemCrossReference."Cross-Reference No.");
        if not Item.FindFirst then
          exit;
        Error(Error_ItemCrossRef,ItemCrossReference."Cross-Reference No.",ItemCrossReference."Item No.",Item."No.");
        //+NPR5.34 [283366]
    end;

    local procedure GetRetailSetup(): Boolean
    begin
        if RetailSetupFetched then
          exit(true);

        if not RetailSetup.Get then
          exit(false);
        RetailSetupFetched := true;
        exit(true);
    end;

    local procedure GetInventorySetup(): Boolean
    begin
        if InventorySetupFetched then
          exit(true);

        if not InventorySetup.Get then
          exit(false);
        InventorySetupFetched := true;
        exit(true);
    end;

    local procedure GetSalesSetup(): Boolean
    begin
        if SalesSetupFetched then
          exit(true);

        if not SalesSetup.Get then
          exit(false);
        SalesSetupFetched := true;
        exit(true);
    end;

    local procedure CheckGroupSale(var Item: Record Item)
    begin
        if Item."Group sale" then
          if Item."Costing Method" = Item."Costing Method"::Standard then
            Error(ErrStd,Item."No.");
    end;

    local procedure UnitCostValidation(var Item: Record Item)
    begin
        GetRetailSetup();
        if RetailSetup."Staff SalesPrice Calc Codeunit" > 0 then
          CODEUNIT.Run(RetailSetup."Staff SalesPrice Calc Codeunit",Item);
    end;

    procedure ValidateNo(var Rec: Record Item;var xRec: Record Item)
    var
        ItemGroup: Record "Item Group";
        Vendor: Record Vendor;
        VendorList: Page "Vendor List";
        InternNo: Code[20];
        Utility: Codeunit Utility;
        ISBNBooklandEAN: Code[20];
        i: Integer;
        n: Integer;
        Check: Integer;
        Weight: Integer;
        Ciffer: Integer;
        Remainder: Integer;
        EndNo: Code[20];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        with Rec do begin
        //made a new function so this EXIT doesn't exit from event subscriber completelly
          if (xRec."No." <> '') and (xRec."No." <> "No.") then
            exit;

          //Salgsmængderabatkode := "No.";
          if (CopyStr("No.",1,1) = '*') and ("No." <> '**') then begin
            if StrLen("No.") > 1 then
              EndNo := CopyStr("No.",2,StrLen("No.") - 1);
            "No." := '*';
            GetRetailSetup();
            ItemGroup.SetRange(Blocked,false);
            if ("Item Group" = '') and RetailSetup."Item Group on Creation" then
              if PAGE.RunModal(PAGE::"Item Group Tree",ItemGroup,ItemGroup."No.") = ACTION::LookupOK then begin
                "Item Group" := ItemGroup."No.";
                Clear("No.");
              end else
                Error(Text001);
            if ("Vendor No." = '') and RetailSetup."Vendor When Creation" then begin
              VendorList.LookupMode := true;
              if VendorList.RunModal = ACTION::LookupOK then begin
                VendorList.GetRecord(Vendor);
                "Vendor No." := Vendor."No.";
                Clear("No.");
              end else
                Error(Text001);
            end;

            RetailSetup.TestField("Internal EAN No. Management");

            if RetailSetup."Itemgroup Pre No. Serie" <> '' then begin
              if EndNo = '' then begin
                ItemGroup.TestField("No. Series");
                NoSeriesManagement.InitSeries(ItemGroup."No. Series",xRec."No. Series",0D,InternNo,"No. Series")
              end else
                InternNo := EndNo;
              if RetailSetup."EAN No. at 1 star" then
                "No." := Utility.CreateEAN("Item Group" + InternNo,'')
              else
                "No." := "Item Group" + InternNo;
            end else begin
              if RetailSetup."EAN No. at 1 star" then begin
                if EndNo = '' then begin
                  RetailSetup.TestField("Internal EAN No. Management");
                  NoSeriesManagement.InitSeries(RetailSetup."Internal EAN No. Management",xRec."No. Series",0D,InternNo,"No. Series")
                end else
                  InternNo := EndNo;
                "No." := Utility.CreateEAN(InternNo,'');
              end else begin
                GetInventorySetup();
                InventorySetup.TestField("Item Nos.");
                NoSeriesManagement.InitSeries(InventorySetup."Item Nos.",xRec."No. Series",0D,"No.","No. Series");
                if RetailSetup."Item group in Item no." then
                  "No." := "Item Group" + "No.";
              end;
            end;

            //-NPR5.26 [248288]
            //"NPK Created" := TRUE;
            //VALIDATE("Item Group");
            //"NPK Created" := FALSE;
            Validate("Item Group");
            //+NPR5.26 [248288]

            if RetailSetup."Item Description at 1 star" then
              if ItemGroup.Get("Item Group") then
                Description := ItemGroup.Description;
          end;

          if "No." = '**' then begin
            GetRetailSetup();
            if RetailSetup."Use VariaX module" then begin
              Clear("No.");
              GetInventorySetup();
              InventorySetup.TestField("Item Nos.");
              if RetailSetup."Itemgroup Pre No. Serie" <> '' then begin
                NoSeriesManagement.InitSeries(ItemGroup."No. Series",xRec."No. Series",0D,"No.","No. Series");
                ItemGroup.TestField("No. Series");
              end else
                NoSeriesManagement.InitSeries(InventorySetup."Item Nos.",xRec."No. Series",0D,"No.","No. Series");

            end else begin
              ItemGroup.SetRange(Blocked,false);
              if ("Item Group" = '') and RetailSetup."Item Group on Creation" then
                if PAGE.RunModal(PAGE::"Item Group Tree",ItemGroup,ItemGroup."No.") = ACTION::LookupOK then begin
                  "Item Group" := ItemGroup."No.";
                  Validate("Item Group");
                  Commit;
                  Clear("No.");
                end else
                  Error(Text001);
              if ("Vendor No." = '') and RetailSetup."Vendor When Creation" then begin
                Vendor.SetCurrentKey("Search Name");
                if PAGE.RunModal(PAGE::"Vendor List",Vendor,Vendor."No.") = ACTION::LookupOK then begin
                  "Vendor No." := Vendor."No.";
                  Clear("No.");
                end else
                  Error(Text001);
              end;
              //-NPR4.04
              //IF ("Size Group"='') AND (Opsætning."Size Code on Creation") THEN BEGIN
              //  IF PAGE.RUNMODAL(PAGE::"Variation Size Groups",Str,Str."Size Code") = ACTION::LookupOK THEN BEGIN
              //    "Size Group":=Str."Size Code";
              //  END;
              //END;
              //+NPR4.04

              GetInventorySetup();
              InventorySetup.TestField("Item Nos.");
              if RetailSetup."Itemgroup Pre No. Serie" <> '' then begin
                NoSeriesManagement.InitSeries(ItemGroup."No. Series",xRec."No. Series",0D,"No.","No. Series");
                ItemGroup.TestField("No. Series");
              end else
                NoSeriesManagement.InitSeries(InventorySetup."Item Nos.",xRec."No. Series",0D,"No.","No. Series");
              "No." := "Item Group" + "No.";

              if RetailSetup."Item Description at 2 star" then
                if ItemGroup.Get("Item Group") then
                  Description := ItemGroup.Description;
              Validate(Description);
              //Salgsmængderabatkode := "No.";
            end;
          end;

        //  Salgsmængderabatkode := "No.";
          //+NPR5.26 [248288]
          ////Checker ISBN-nummer
          //GetRetailSetup();
          //ISBN := FALSE;
          //IF RetailSetup."ISBN Bookland EAN" THEN BEGIN
          // ISBNBooklandEAN := DELCHR("No.",'=','-');
          // IF STRLEN(ISBNBooklandEAN) = 10 THEN
          //   IF DELCHR(COPYSTR(ISBNBooklandEAN,1,9),'=','0123456789') = '' THEN BEGIN
          //     Weight := 10; // Weightstring = {10,9,8,7,6,5,4,3,2}
          //     Check := 0;
          //     n := 11; //Modulus 11
          //     FOR i := 1 TO 9 DO BEGIN
          //       EVALUATE(Ciffer,COPYSTR(ISBNBooklandEAN,i,1));
          //       Check := Check + ((Weight * Ciffer) MOD n);
          //       Weight := Weight - 1;
          //     END;
          //     Remainder := Check MOD n;
          //     IF (Remainder = 1) AND (COPYSTR(ISBNBooklandEAN,10,1) = 'X') THEN
          //       ISBN := TRUE
          //     ELSE IF FORMAT((n - Remainder) MOD n) = COPYSTR(ISBNBooklandEAN,10,1) THEN
          //       ISBN := TRUE;
          //   END;
          //END;
          //IF ISBN THEN BEGIN
          // "Label Barcode" := '978' + COPYSTR(ISBNBooklandEAN,1,9);
          // "Label Barcode" := "Label Barcode" + FORMAT(STRCHECKSUM("Label Barcode",'131313131313'));
          //END ELSE BEGIN
          // //"Label Barcode" := '';
          // IF DELCHR("No.",'=','0123456789') = '' THEN
          //   IF (STRLEN("No.") = 13) THEN
          //     IF (STRCHECKSUM("No.",'1313131313131') = 0) THEN
          //       "Label Barcode" := "No.";
          //END;
          if IsEan13("No.") then
            "Label Barcode" := "No.";
          //+NPR5.26 [248288]
          Validate("Item Group");
        end;
    end;

    local procedure IsEan13(Input: Text): Boolean
    begin
        //-NPR5.26 [248288]
        if StrLen(Input) <> 13 then
          exit(false);

        if DelChr(Input,'=','0123456789') <> '' then
          exit(false);

        exit(StrCheckSum(Input,'1313131313131') = 0);
        //+NPR5.26 [248288]
    end;

    local procedure UpdateVendorItemCrossRef(Item: Record Item;xItem: Record Item)
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        //-NPR5.30 [264742]
        if Item.IsTemporary then
          exit;
        if (Item."Vendor No." = xItem."Vendor No.") and (Item."Vendor Item No." = xItem."Vendor Item No.") then
          exit;

        ItemCrossReference.SetRange("Item No.",Item."No.");
        ItemCrossReference.SetRange("Variant Code",'');
        ItemCrossReference.SetRange("Unit of Measure",xItem."Base Unit of Measure");
        ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::Vendor);
        ItemCrossReference.SetRange("Cross-Reference Type No.",xItem."Vendor No.");
        ItemCrossReference.SetRange("Cross-Reference No.",xItem."Vendor Item No.");
        ItemCrossReference.DeleteAll(true);

        if (Item."Vendor No." = '') or (Item."Vendor Item No." = '') then
          exit;

        if not ItemCrossReference.Get(Item."No.",'',Item."Base Unit of Measure",ItemCrossReference."Cross-Reference Type"::Vendor,Item."Vendor No.",Item."Vendor Item No.") then begin
          ItemCrossReference.Init;
          ItemCrossReference."Item No." := Item."No.";
          ItemCrossReference."Variant Code" := '';
          ItemCrossReference."Unit of Measure" := Item."Base Unit of Measure";
          ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::Vendor;
          ItemCrossReference."Cross-Reference Type No." := Item."Vendor No.";
          ItemCrossReference."Cross-Reference No." := Item."Vendor Item No.";
          ItemCrossReference.Description := '';
          ItemCrossReference.Insert(true);
        end;
        //+NPR5.30 [264742]
    end;
}

