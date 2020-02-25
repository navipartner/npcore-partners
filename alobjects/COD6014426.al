codeunit 6014426 "Std. Table Code"
{
    // VRT1.00/JDH/20150304 CASE 201022 Variety group is transferred to Item when creating new items
    // NPR5.23/BHR/20160421 CASE 238541 Correct bug and incorporate translation to code
    // NPR5.23/THRO/20160509 CASE 240777 Added function ItemJnlLineCrossReferenceOV
    // NPR5.23/JDH /20160512 CASE 240916 Delete many unused functions (not documented) and references to VariaX and color size solution
    // NPR5.23/BR/20160519 CASE 241965  Prevent Error caused by Validating Item No. through RapidStart
    // NPR5.23/LS  /20160608 CASE 226819 Modified function DebitorOnInsert by commenting assignment of retail Setup fields
    // NPR5.26/MHA /20160810 CASE 248288 Function deleted: KLOpretVare() and reference removed to deleted Item Field: 6014417 "NPK Created"
    // NPR5.26/MHA /20160922 CASE 252881 Unused functions deleted
    // NPR5.27/BR  /20160928 CASE 253578 Fix problem with '*' function
    // NPR5.29/JDH /20170105 CASE 260472 Removed the functions to set Descriptions, and merged functionality to Description Control
    // NPR5.29/BHR /20170123 CASE 264081 Add conditions to Validate Inventory Posting Group in function VareTVGOVAfter
    // NPR5.30/JC  /20170221 CASE 265277 Item group validate Gen. Prod Posting group as it overides VAT. Prod Posting group
    // NPR5.30/TJ  /20170222 CASE 266874 Removed functions FinkldlinieValidateGavekort and FinkldlinieValidateTilgbevis
    // NPR5.31/MHA /20170110 CASE 262904 Moved function TestMiksStatus() to Table 6014411 "Mixed Discount"
    // NPR5.33/JDH /20170612 CASE 280329 Removed unused functions
    // NPR5.38/MHA /20171211 CASE 297973 Variety Group should only be validated with Value in VareTVGOVAfter()
    // NPR5.38/BR  /20180125 CASE 302803 Added Tax Group Code to Item Group support
    // NPR5.39/TJ  /20180212 CASE 302634 Removed unused variables
    // NPR5.43/JKL /20180531 CASE 317359 Added function to automatically apply item group master template if defined.
    // NPR5.48/BHR /20190108 CASE 334217 Validate "Inventory Posting Group" only wheb type <> service on Item group
    // NPR5.50/RA  /20190403 CASE 350418 NPR5.48 is giving problems for "Politikens Boghal"
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register
    // NPR5.53/ALPO/20191210 CASE 380609 Dimensions: NPRE Seating integration


    trigger OnRun()
    begin
    end;

    var
        RetailSetup: Record "Retail Setup";
        RetailSetupFetched: Boolean;

    procedure VareTVGOVAfter(var VItem: Record Item;var ItemGroup: Record "Item Group")
    var
        DefaultDimension: Record "Default Dimension";
        DefaultDimension2: Record "Default Dimension";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin
        //VareTVGOVAfter()
        
        with VItem do begin
          GetRetailSetup;
        
          ItemGroup.TestField("VAT Bus. Posting Group");
          ItemGroup.TestField("Gen. Prod. Posting Group");
          ItemGroup.TestField("VAT Prod. Posting Group");
          //-NPR5.50
          if Type <> ItemGroup.Type then begin
          //+NPR5.50
            //-NPR5.48 [334217]
            Validate(Type,ItemGroup.Type);
            //-NPR5.29 [264081]
          //-NPR5.50
          end;
          //+NPR5.50
        
        
        
          //IF VItem.Type <> VItem.Type::Service THEN
          if ItemGroup.Type <> ItemGroup.Type::Service then
          //+NPR5.29 [264081]
          //+NPR5.48 [334217]
            ItemGroup.TestField("Inventory Posting Group");
          ItemGroup.TestField(Blocked,false);
          ItemGroup.TestField("Main Item Group", false);
          //-NPR5.30 [265277]
          Validate("Gen. Prod. Posting Group", ItemGroup."Gen. Prod. Posting Group");
          //+265277
          "VAT Prod. Posting Group"      := ItemGroup."VAT Prod. Posting Group";
          "VAT Bus. Posting Gr. (Price)" := ItemGroup."VAT Bus. Posting Group";
          //-265277 [265277]
          //-NPR5.38 [302803]
          "Tax Group Code" := ItemGroup."Tax Group Code";
          //+NPR5.38 [302803]
          //VALIDATE("Gen. Prod. Posting Group",ItemGroup."Gen. Prod. Posting Group");
          //+265277
          Validate("Inventory Posting Group",ItemGroup."Inventory Posting Group");
        
          Validate("Reordering Policy",ItemGroup."Reordering Policy");
          Validate("Item Disc. Group", ItemGroup."Item Discount Group" );
          Validate("Guarantee Index", ItemGroup."Warranty File" );
          Validate("Guarantee voucher", ItemGroup.Warranty );
          Validate(VItem."Tariff No.",ItemGroup."Tarif No.");
          if (RetailSetup."Item Description at 1 star") and (Description = '') then Validate(Description,ItemGroup.Description);
          "Costing Method" := ItemGroup."Costing Method";
          "Insurrance category" := ItemGroup."Insurance Category";
        
          // Transfer Default Dimensions from Item Group
          DefaultDimension2.SetRange("Table ID",DATABASE::Item);
          DefaultDimension2.SetRange("No.","No.");
          DefaultDimension2.DeleteAll;
          DefaultDimension.SetRange("Table ID",DATABASE::"Item Group");
          DefaultDimension.SetRange("No.","Item Group");
          if DefaultDimension.FindSet then repeat
            DefaultDimension2 := DefaultDimension;
            DefaultDimension2."Table ID" := DATABASE::Item;
            DefaultDimension2."No."      := "No.";
            DefaultDimension2.Insert;
          until DefaultDimension.Next = 0;
        
          "Global Dimension 1 Code" := ItemGroup."Global Dimension 1 Code";
          "Global Dimension 2 Code" := ItemGroup."Global Dimension 2 Code";
        
          if not ItemUnitofMeasure.Get( "No.", ItemGroup."Base Unit of Measure" ) and (ItemGroup."Base Unit of Measure" <> '') then begin
            ItemUnitofMeasure."Item No." := "No.";
            ItemUnitofMeasure.Code := ItemGroup."Base Unit of Measure";
            ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
            if ItemUnitofMeasure.Insert then;
          end;
        
          if not ItemUnitofMeasure.Get( "No.", ItemGroup."Sales Unit of Measure" ) and (ItemGroup."Sales Unit of Measure" <> '') then begin
            ItemUnitofMeasure."Item No." := "No.";
            ItemUnitofMeasure.Code := ItemGroup."Sales Unit of Measure";
            ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
            if ItemUnitofMeasure.Insert then;
          end;
        
          if not ItemUnitofMeasure.Get( "No.", ItemGroup."Purch. Unit of Measure") and (ItemGroup."Purch. Unit of Measure" <> '') then begin
            ItemUnitofMeasure."Item No." := "No.";
            ItemUnitofMeasure.Code := ItemGroup."Purch. Unit of Measure";
            ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
            if ItemUnitofMeasure.Insert then;
          end;
        
          /* Validate unit from item group on new item */
          if "Base Unit of Measure"<>ItemGroup."Base Unit of Measure" then begin
            Validate("Base Unit of Measure", ItemGroup."Base Unit of Measure");
            Validate("Sales Unit of Measure", ItemGroup."Sales Unit of Measure");
            Validate("Sales Unit of Measure", ItemGroup."Purch. Unit of Measure");
          end;
        
          //-VRT1.00
          //-NPR5.38 [297973]
          //VALIDATE("Variety Group", ItemGroup."Variety Group");
          if ItemGroup."Variety Group" <> '' then
            Validate("Variety Group",ItemGroup."Variety Group");
          //+NPR5.38 [297973]
          //+VRT1.00
        
          //-NPR5.43 [317359]
          if ItemGroup."Config. Template Header" <> '' then begin
            if ConfigTemplateHeader.Get(ItemGroup."Config. Template Header") then begin
              RecRef.GetTable(VItem);
              ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader,RecRef);
              VItem.Get(VItem."No.");
            end;
          end;
          //+NPR5.43 [317359]
        
        
        end;

    end;

    procedure ItemJnlLineCrossReferenceOV(var ItemJournalLine: Record "Item Journal Line";var xItemJournalLine: Record "Item Journal Line")
    var
        ItemCrossReference: Record "Item Cross Reference";
        Text000: Label 'There are no items with cross reference: %1';
    begin
        //-NPR5.23
        ItemCrossReference.Init;
        if ItemJournalLine."Cross-Reference No." <> '' then begin
          //DistIntegration.ICRLookupSalesItem(Rec,ReturnedCrossRef);
          ItemCrossReference.Reset;
          ItemCrossReference.SetCurrentKey(
              "Cross-Reference No.","Cross-Reference Type","Cross-Reference Type No.","Discontinue Bar Code");
          ItemCrossReference.SetRange("Cross-Reference No.",ItemJournalLine."Cross-Reference No.");
          ItemCrossReference.SetRange("Discontinue Bar Code",false);
          ItemCrossReference.SetRange("Item No.",ItemJournalLine."Item No.");
          if not ItemCrossReference.Find('-') then begin
            ItemCrossReference.SetRange("Item No.");
            if not ItemCrossReference.Find('-') then
              Error(Text000,ItemJournalLine."Cross-Reference No.");
            if GuiAllowed and (ItemCrossReference.Next <> 0) then begin
              ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");  // Bar Code have highest priority
              if ItemCrossReference.Find('-') then begin
                if ItemCrossReference.Next <> 0 then begin
                  if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) <> ACTION::LookupOK
                  then
                    Error(Text000,ItemJournalLine."Cross-Reference No.");
                end;
              end else begin
                ItemCrossReference.SetRange("Cross-Reference Type");
                if ItemCrossReference.Find('-') then
                  if ItemCrossReference.Next <> 0 then begin
                    if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) <> ACTION::LookupOK
                    then
                      Error(Text000,ItemJournalLine."Cross-Reference No.");
                  end;
              end;
            end;
          end;
          if ItemJournalLine."Item No." <> ItemCrossReference."Item No." then
            ItemJournalLine.Validate("Item No.",ItemCrossReference."Item No.");
          if ItemCrossReference."Variant Code" <> '' then
            ItemJournalLine.Validate("Variant Code",ItemCrossReference."Variant Code");

          if ItemCrossReference."Unit of Measure" <> '' then
            ItemJournalLine.Validate("Unit of Measure Code",ItemCrossReference."Unit of Measure");
        end;

        ItemJournalLine."Cross-Reference No." := ItemCrossReference."Cross-Reference No.";

        if ItemCrossReference.Description <> '' then
          ItemJournalLine.Description := ItemCrossReference.Description;
        //+NPR5.23
    end;

    procedure GetRetailSetup(): Boolean
    begin
        if RetailSetupFetched then
          exit(true);

        if not RetailSetup.Get then
          exit(false);
        RetailSetupFetched := true;
        exit(true);
    end;

    procedure UpdateGlobalDimCode(GlobalDimCodeNo: Integer;"Table ID": Integer;"No.": Code[20];NewDimValue: Code[20])
    begin
        case "Table ID" of
          //+NPR7.000.000
          //-NPR5.53 [371956]-revoked
          //DATABASE::Register :
          //  UpdateRegisterGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          //+NPR5.53 [371956]-revoked
          DATABASE::"Payment Type POS" :
            UpdatePaymentTypePOSGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          DATABASE::"Item Group" :
            UpdateItemGroupGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          DATABASE::"Mixed Discount" :
            UpdateMixedDiscountGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          DATABASE::"Period Discount" :
            UpdatePeriodDiscountGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          DATABASE::"Quantity Discount Header" :
            UpdateQuantityDiscountGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          //-NPR7.000.000
          //-NPR5.53 [371956]
          DATABASE::"POS Store":
            UpdatePOSStoreGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          DATABASE::"POS Unit":
            UpdatePOSUnitGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          //+NPR5.53 [371956]
          //-NPR5.53 [380609]
          DATABASE::"NPRE Seating":
            UpdateNPRESeatingGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
          //+NPR5.53 [380609]
        end;
    end;

    procedure UpdateRegisterGlobalDimCode(GlobalDimCodeNo: Integer;RegisterNo: Code[20];NewDimValue: Code[20])
    var
        Register: Record Register;
    begin
        exit;  //NPR5.53 [371956]
        if Register.Get(RegisterNo) then begin
          case GlobalDimCodeNo of
            1:
              Register."Global Dimension 1 Code" := NewDimValue;
            2:
              Register."Global Dimension 2 Code" := NewDimValue;
          end;
          Register.Modify(true);
        end;
    end;

    procedure UpdatePaymentTypePOSGlobalDimCode(GlobalDimCodeNo: Integer;PaymentTypeNo: Code[20];NewDimValue: Code[20])
    var
        PaymentTypePOS: Record "Payment Type POS";
    begin
        if PaymentTypePOS.Get(PaymentTypeNo) then begin
          case GlobalDimCodeNo of
            1:
              PaymentTypePOS."Global Dimension 1 Code" := NewDimValue;
            2:
              PaymentTypePOS."Global Dimension 2 Code" := NewDimValue;
          end;
          PaymentTypePOS.Modify(true);
        end;
    end;

    procedure UpdateItemGroupGlobalDimCode(GlobalDimCodeNo: Integer;ItemGroupNo: Code[20];NewDimValue: Code[20])
    var
        ItemGroup: Record "Item Group";
    begin
        if ItemGroup.Get(ItemGroupNo) then begin
          case GlobalDimCodeNo of
            1:
              ItemGroup."Global Dimension 1 Code" := NewDimValue;
            2:
              ItemGroup."Global Dimension 2 Code" := NewDimValue;
          end;
          ItemGroup.Modify(true);
        end;
    end;

    procedure UpdateMixedDiscountGlobalDimCode(GlobalDimCodeNo: Integer;MixedDiscountNo: Code[20];NewDimValue: Code[20])
    var
        MixedDiscount: Record "Mixed Discount";
    begin
        if MixedDiscount.Get(MixedDiscountNo) then begin
          case GlobalDimCodeNo of
            1:
              MixedDiscount."Global Dimension 1 Code" := NewDimValue;
            2:
              MixedDiscount."Global Dimension 2 Code" := NewDimValue;
          end;
          MixedDiscount.Modify(true);
        end;
    end;

    procedure UpdatePeriodDiscountGlobalDimCode(GlobalDimCodeNo: Integer;PeriodDiscountNo: Code[20];NewDimValue: Code[20])
    var
        PeriodDiscount: Record "Period Discount";
    begin
        if PeriodDiscount.Get(PeriodDiscountNo) then begin
          case GlobalDimCodeNo of
            1:
              PeriodDiscount."Global Dimension 1 Code" := NewDimValue;
            2:
              PeriodDiscount."Global Dimension 2 Code" := NewDimValue;
          end;
          PeriodDiscount.Modify(true);
        end;
    end;

    procedure UpdateQuantityDiscountGlobalDimCode(GlobalDimCodeNo: Integer;QuantityDiscountNo: Code[20];NewDimValue: Code[20])
    var
        QuantityDiscount: Record "Quantity Discount Header";
    begin
        if QuantityDiscount.Get(QuantityDiscountNo) then begin
          case GlobalDimCodeNo of
            1:
              QuantityDiscount."Global Dimension 1 Code" := NewDimValue;
            2:
              QuantityDiscount."Global Dimension 2 Code" := NewDimValue;
          end;
          QuantityDiscount.Modify(true);
        end;
    end;

    local procedure UpdatePOSStoreGlobalDimCode(GlobalDimCodeNo: Integer;POSStoreCode: Code[20];NewDimValue: Code[20])
    var
        POSStore: Record "POS Store";
    begin
        //-NPR5.53 [371956]
        if POSStore.Get(POSStoreCode) then begin
          case GlobalDimCodeNo of
            1:
              POSStore."Global Dimension 1 Code" := NewDimValue;
            2:
              POSStore."Global Dimension 2 Code" := NewDimValue;
          end;
          POSStore.Modify(true);
        end;
        //+NPR5.53 [371956]
    end;

    local procedure UpdatePOSUnitGlobalDimCode(GlobalDimCodeNo: Integer;POSUnitNo: Code[20];NewDimValue: Code[20])
    var
        POSUnit: Record "POS Unit";
    begin
        //-NPR5.53 [371956]
        if POSUnit.Get(POSUnitNo) then begin
          case GlobalDimCodeNo of
            1:
              POSUnit."Global Dimension 1 Code" := NewDimValue;
            2:
              POSUnit."Global Dimension 2 Code" := NewDimValue;
          end;
          POSUnit.Modify(true);
        end;
        //+NPR5.53 [371956]
    end;

    [EventSubscriber(ObjectType::Table, 6150615, 'OnAfterModifyEvent', '', true, false)]
    local procedure UpdateCashRegGlobalDimsOnPOSUnitGlobalDimChange(var Rec: Record "POS Unit";var xRec: Record "POS Unit";RunTrigger: Boolean)
    var
        CashRegister: Record Register;
    begin
        //-NPR5.53 [371956]
        with Rec do
          if ("Global Dimension 1 Code" <> xRec."Global Dimension 1 Code") or
             ("Global Dimension 2 Code" <> xRec."Global Dimension 2 Code")
          then begin
            CashRegister.Get("No.");
            CashRegister."Global Dimension 1 Code" := "Global Dimension 1 Code";
            CashRegister."Global Dimension 2 Code" := "Global Dimension 2 Code";
            CashRegister.Modify;
          end;
        //+NPR5.53 [371956]
    end;

    local procedure UpdateNPRESeatingGlobalDimCode(GlobalDimCodeNo: Integer;SeatingCode: Code[20];NewDimValue: Code[20])
    var
        NPRESeating: Record "NPRE Seating";
    begin
        //-NPR5.53 [380609]
        SeatingCode := CopyStr(SeatingCode,1,MaxStrLen(NPRESeating.Code));
        if NPRESeating.Get(SeatingCode) then begin
          case GlobalDimCodeNo of
            1:
              NPRESeating."Global Dimension 1 Code" := NewDimValue;
            2:
              NPRESeating."Global Dimension 2 Code" := NewDimValue;
          end;
          NPRESeating.Modify(true);
        end;
        //+NPR5.53 [380609]
    end;
}

