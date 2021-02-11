codeunit 6059972 "NPR Variety Clone Data"
{
    trigger OnRun()
    begin
        Message(CreateBarcodeEAN13('571234500012'));
    end;

    var
        VRTSetup: Record "NPR Variety Setup";
        VRTSetupFetched: Boolean;
        Text001: Label 'Barcode length must be %1 characters. This is not a valid EAN barcode';
        Text002: Label 'The barcode is already created as an item, and cant be created';
        Text003: Label 'The %1 %2 is already used for Item %3. It must be deleted before it can be reused';
        Text004: Label '%1 %2 is created';
        Text005: Label 'Please enter GS1 Countrycode (2-3 Characters)';
        Text006: Label 'Please enter Company number (3-8 Characters)';
        Text007: Label 'There are no tables to create a copy of';
        Text008: Label 'You are about to create a copy of the %1 table %2, and use it on item %3.\This action is inreversable.\Do you wish to proceed?';
        InputDialog: Page "NPR Input Dialog";
        Text009: Label 'Warning: This will update the Fields Description and Description 2 on all %1.\This is not revertable, and will lock the database while its beeing executed.\Do you wish to continue?';
        Text010: Label 'Updating #1########\ @2@@@@@@@';
        ItemVariantDontExisit: Label 'This Variety Combination is not enabled.';

    procedure SetupNewLine(var MRecref: RecordRef; Item: Record Item; var TMPVRTBuffer: Record "NPR Variety Buffer"; NewValue: Text[250])
    var
        MasterSalesLine: Record "Sales Line";
        ItemVariant: Record "Item Variant";
        MasterPurchLine: Record "Purchase Line";
        MasterSalesPrice: Record "Sales Price";
        MasterRetailJournalLine: Record "NPR Retail Journal Line";
        MasterItemReplenishment: Record "NPR Item Repl. by Store";
        MasterTransferLine: Record "Transfer Line";
        MasterPurchPrice: Record "Purchase Price";
        MasterItemJnlLine: Record "Item Journal Line";
    begin
        //-NPR5.29 [263917]
        //IF NOT ItemVariant.GetFromVariety(Item."No.", TMPVRTBuffer."Variety 1 Value", TMPVRTBuffer."Variety 2 Value",
        if not GetFromVariety(ItemVariant, Item."No.", TMPVRTBuffer."Variety 1 Value", TMPVRTBuffer."Variety 2 Value",
        //+NPR5.29 [263917]
                                         TMPVRTBuffer."Variety 3 Value", TMPVRTBuffer."Variety 4 Value") then
            Clear(ItemVariant);

        //-NPR5.32 [274170]
        //if the variant cant be found, its not created, and none of the functions below makes sence to call
        if ItemVariant.Code = '' then
            Error(ItemVariantDontExisit);
        //+NPR5.32 [274170]

        case MRecref.Number of
            DATABASE::"Item Variant":
                begin
                    SetupVariant(Item, TMPVRTBuffer, NewValue);
                end;
            DATABASE::"Sales Line":
                begin
                    MRecref.SetTable(MasterSalesLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupSalesLine(MasterSalesLine, Item, ItemVariant));
                end;
            DATABASE::"Purchase Line":
                begin
                    MRecref.SetTable(MasterPurchLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupPurchLine(MasterPurchLine, Item, ItemVariant));
                end;

            DATABASE::"Sales Price":
                begin
                    MRecref.SetTable(MasterSalesPrice);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupSalesPrice(MasterSalesPrice, Item, ItemVariant));
                end;

            //-VRT1.01
            DATABASE::"NPR Retail Journal Line":
                begin
                    MRecref.SetTable(MasterRetailJournalLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupRetailJournalLine(MasterRetailJournalLine, Item, ItemVariant));
                end;
            //+VRT1.01

            //-NPR4.16
            DATABASE::"NPR Item Repl. by Store":
                begin
                    MRecref.SetTable(MasterItemReplenishment);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupItemReplenishment(MasterItemReplenishment, Item, ItemVariant));
                end;
            //+NPR4.16

            //-NPR5.29 [260516]
            DATABASE::"Transfer Line":
                begin
                    MRecref.SetTable(MasterTransferLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupTransferLine(MasterTransferLine, Item, ItemVariant));
                end;
            //+NPR5.29 [260516]

            //-NPR5.31 [271133]
            DATABASE::"Purchase Price":
                begin
                    MRecref.SetTable(MasterPurchPrice);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupPurchPrice(MasterPurchPrice, Item, ItemVariant));
                end;
            //+NPR5.31 [271133]

            //-NPR5.36 [288696]
            DATABASE::"Item Journal Line":
                begin
                    MRecref.SetTable(MasterItemJnlLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupItemJnlLine(MasterItemJnlLine, Item, ItemVariant));
                end;
        //+NPR5.36 [288696]

        end;
        //if the master record has been changed (the record ID is identical), a reload is needed
        if (Format(MRecref.RecordId) = Format(TMPVRTBuffer."Record ID (TMP)")) then
            MRecref.Get(TMPVRTBuffer."Record ID (TMP)");

        TMPVRTBuffer.Modify;
    end;

    procedure SetupSalesLine(var MasterSalesLine: Record "Sales Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewSalesLine: Record "Sales Line";
        LineNo: Integer;
        SalesLine2: Record "Sales Line";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        if MasterSalesLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterSalesLine.Validate("Variant Code", ItemVariant.Code);
            MasterSalesLine.Modify;
            RecRef.GetTable(MasterSalesLine);
            exit(Format(RecRef.RecordId));
        end;

        SalesLine2.SetRange("Document Type", MasterSalesLine."Document Type");
        SalesLine2.SetRange("Document No.", MasterSalesLine."Document No.");
        SalesLine2.FindLast;
        if SalesLine2."NPR Master Line No." = MasterSalesLine."Line No." then
            LineNo := SalesLine2."Line No." + 10000
        else begin
            SalesLine2.SetRange("NPR Master Line No.", MasterSalesLine."Line No.");
            SalesLine2.FindLast;
            LineNo := SalesLine2."Line No." + 1;
        end;

        NewSalesLine := MasterSalesLine;
        NewSalesLine."Line No." := LineNo;
        NewSalesLine.Insert;
        NewSalesLine.Validate(Quantity, 0);
        NewSalesLine.Validate("Variant Code", ItemVariant.Code);
        //dimensions
        NewSalesLine.Validate("Shortcut Dimension 1 Code", MasterSalesLine."Shortcut Dimension 1 Code");
        NewSalesLine.Validate("Shortcut Dimension 2 Code", MasterSalesLine."Shortcut Dimension 2 Code");
        NewSalesLine."NPR Is Master" := false;

        NewSalesLine.Modify;
        RecRef.GetTable(NewSalesLine);
        exit(Format(RecRef.RecordId));
    end;

    procedure SetupPurchLine(var MasterPurchLine: Record "Purchase Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewPurchLine: Record "Purchase Line";
        LineNo: Integer;
        PurchLine2: Record "Purchase Line";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        if MasterPurchLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterPurchLine.Validate("Variant Code", ItemVariant.Code);
            MasterPurchLine.Modify;
            RecRef.GetTable(MasterPurchLine);
            exit(Format(RecRef.RecordId));
        end;

        PurchLine2.SetRange("Document Type", MasterPurchLine."Document Type");
        PurchLine2.SetRange("Document No.", MasterPurchLine."Document No.");
        PurchLine2.FindLast;
        if PurchLine2."NPR Master Line No." = MasterPurchLine."Line No." then
            LineNo := PurchLine2."Line No." + 10000
        else begin
            PurchLine2.SetRange("NPR Master Line No.", MasterPurchLine."Line No.");
            PurchLine2.FindLast;
            LineNo := PurchLine2."Line No." + 1;
        end;

        NewPurchLine := MasterPurchLine;
        NewPurchLine."Line No." := LineNo;
        NewPurchLine.Insert;
        NewPurchLine.Validate(Quantity, 0);
        NewPurchLine.Validate("Variant Code", ItemVariant.Code);
        //dimensions
        NewPurchLine.Validate("Shortcut Dimension 1 Code", MasterPurchLine."Shortcut Dimension 1 Code");
        NewPurchLine.Validate("Shortcut Dimension 2 Code", MasterPurchLine."Shortcut Dimension 2 Code");
        NewPurchLine."NPR Is Master" := false;

        NewPurchLine.Modify;
        RecRef.GetTable(NewPurchLine);
        exit(Format(RecRef.RecordId));
    end;

    procedure SetupVariant(Item: Record Item; var VRTBuffer: Record "NPR Variety Buffer"; Value: Text[50]) RecordID: Text[250]
    var
        ItemVariant: Record "Item Variant";
        CreateVariant: Boolean;
        RecRef: RecordRef;
    begin
        Evaluate(CreateVariant, Value);
        if not CreateVariant then
            exit;

        //-NPR5.29 [263917]
        //IF ItemVariant.GetFromVariety(Item."No.", VRTBuffer."Variety 1 Value",
        if GetFromVariety(ItemVariant, Item."No.", VRTBuffer."Variety 1 Value",
        //+NPR5.29 [263917]
                                     VRTBuffer."Variety 2 Value", VRTBuffer."Variety 3 Value",
                                     VRTBuffer."Variety 4 Value") then
            Error('Variant already exists');

        ItemVariant.Init;
        ItemVariant."Item No." := Item."No.";
        //-NPR5.43 [317108]
        //ItemVariant.Code := GetNextVariantCode;
        ItemVariant.Code := GetNextVariantCode(Item."No.", VRTBuffer."Variety 1 Value", VRTBuffer."Variety 2 Value", VRTBuffer."Variety 3 Value", VRTBuffer."Variety 4 Value");
        //+NPR5.43 [317108]
        ItemVariant."NPR Variety 1" := Item."NPR Variety 1";
        ItemVariant."NPR Variety 1 Table" := Item."NPR Variety 1 Table";
        ItemVariant."NPR Variety 1 Value" := VRTBuffer."Variety 1 Value";
        ItemVariant."NPR Variety 2" := Item."NPR Variety 2";
        ItemVariant."NPR Variety 2 Table" := Item."NPR Variety 2 Table";
        ItemVariant."NPR Variety 2 Value" := VRTBuffer."Variety 2 Value";
        ItemVariant."NPR Variety 3" := Item."NPR Variety 3";
        ItemVariant."NPR Variety 3 Table" := Item."NPR Variety 3 Table";
        ItemVariant."NPR Variety 3 Value" := VRTBuffer."Variety 3 Value";
        ItemVariant."NPR Variety 4" := Item."NPR Variety 4";
        ItemVariant."NPR Variety 4 Table" := Item."NPR Variety 4 Table";
        ItemVariant."NPR Variety 4 Value" := VRTBuffer."Variety 4 Value";

        FillDescription(ItemVariant, Item);

        ItemVariant.Insert(true);

        RecRef.GetTable(ItemVariant);
        VRTBuffer."Record ID (TMP)" := RecRef.RecordId;
        VRTBuffer."Variant Code" := ItemVariant.Code;
    end;

    procedure SetupSalesPrice(var MasterSalesPrice: Record "Sales Price"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewSalesPrice: Record "Sales Price";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        with MasterSalesPrice do begin
            NewSalesPrice := MasterSalesPrice;
            NewSalesPrice."Variant Code" := ItemVariant.Code;
            NewSalesPrice.Insert;
            NewSalesPrice."NPR Is Master" := false;

            NewSalesPrice.Modify;
            RecRef.GetTable(NewSalesPrice);
            exit(Format(RecRef.RecordId));
        end;
    end;

    procedure SetupPurchPrice(var MasterPurchPrice: Record "Purchase Price"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewPurchPrice: Record "Purchase Price";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        //-NPR5.31 [271133]
        with MasterPurchPrice do begin
            NewPurchPrice := MasterPurchPrice;
            NewPurchPrice."Variant Code" := ItemVariant.Code;
            NewPurchPrice.Insert;
            NewPurchPrice."NPR Is Master" := false;

            NewPurchPrice.Modify;
            RecRef.GetTable(NewPurchPrice);
            exit(Format(RecRef.RecordId));
        end;
        //+NPR5.31 [271133]
    end;

    procedure SetupRetailJournalLine(var MasterRetailJournalLine: Record "NPR Retail Journal Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewRetailJournalLine: Record "NPR Retail Journal Line";
        RetailJournalLine2: Record "NPR Retail Journal Line";
        LineNo: Integer;
        RecRef: RecordRef;
    begin
        //-VRT1.01
        //check if a new line is needed (is variant code filled?)
        if MasterRetailJournalLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterRetailJournalLine.Validate("Variant Code", ItemVariant.Code);
            MasterRetailJournalLine.Modify;
            RecRef.GetTable(MasterRetailJournalLine);
            exit(Format(RecRef.RecordId));
        end;

        RetailJournalLine2.SetRange("No.", MasterRetailJournalLine."No.");
        RetailJournalLine2.FindLast;
        if RetailJournalLine2."Line No." = MasterRetailJournalLine."Line No." then
            LineNo := RetailJournalLine2."Line No." + 10000
        else begin
            RetailJournalLine2.SetRange("Master Line No.", MasterRetailJournalLine."Line No.");
            RetailJournalLine2.FindLast;
            LineNo := RetailJournalLine2."Line No." + 1;
        end;

        NewRetailJournalLine := MasterRetailJournalLine;
        NewRetailJournalLine."Line No." := LineNo;
        NewRetailJournalLine.Insert;
        NewRetailJournalLine.Validate("Quantity to Print", 0);
        NewRetailJournalLine.Validate("Variant Code", ItemVariant.Code);
        NewRetailJournalLine."Is Master" := false;

        NewRetailJournalLine.Modify;
        RecRef.GetTable(NewRetailJournalLine);
        exit(Format(RecRef.RecordId));
        //+VRT1.01
    end;

    procedure SetupItemReplenishment(var MasterItemReplenishment: Record "NPR Item Repl. by Store"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewItemReplenishment: Record "NPR Item Repl. by Store";
        RecRef: RecordRef;
    begin
        //-NPR4.16
        //check if a new line is needed (is variant code filled?)
        with MasterItemReplenishment do begin
            NewItemReplenishment := MasterItemReplenishment;
            NewItemReplenishment."Variant Code" := ItemVariant.Code;
            NewItemReplenishment.Insert;
            NewItemReplenishment."Is Master" := false;

            NewItemReplenishment.Modify;
            RecRef.GetTable(NewItemReplenishment);
            exit(Format(RecRef.RecordId));
        end;
        //+NPR4.16
    end;

    procedure SetupItemJnlLine(var MasterItemJnlLine: Record "Item Journal Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewItemJnlLine: Record "Item Journal Line";
        RecRef: RecordRef;
        ItemJnlLine2: Record "Item Journal Line";
        LineNo: Integer;
    begin
        //-NPR5.36 [288696]
        //check if a new line is needed (is variant code filled?)
        if MasterItemJnlLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterItemJnlLine.Validate("Variant Code", ItemVariant.Code);
            MasterItemJnlLine.Modify;
            RecRef.GetTable(MasterItemJnlLine);
            exit(Format(RecRef.RecordId));
        end;

        ItemJnlLine2.SetRange("Journal Template Name", MasterItemJnlLine."Journal Template Name");
        ItemJnlLine2.SetRange("Journal Batch Name", MasterItemJnlLine."Journal Batch Name");
        ItemJnlLine2.FindLast;
        if ItemJnlLine2."Line No." = MasterItemJnlLine."Line No." then
            LineNo := ItemJnlLine2."Line No." + 10000
        else begin
            ItemJnlLine2.SetRange("NPR Master Line No.", MasterItemJnlLine."Line No.");
            ItemJnlLine2.FindLast;
            LineNo := ItemJnlLine2."Line No." + 1;
        end;

        NewItemJnlLine := MasterItemJnlLine;
        NewItemJnlLine."Line No." := LineNo;
        NewItemJnlLine.Insert;
        NewItemJnlLine.Validate(Quantity, 0);
        NewItemJnlLine.Validate("Variant Code", ItemVariant.Code);
        NewItemJnlLine."NPR Is Master" := false;

        NewItemJnlLine.Modify;
        RecRef.GetTable(NewItemJnlLine);
        exit(Format(RecRef.RecordId));
        //+NPR5.36 [288696]
    end;

    procedure GetNextVariantCode(ItemNo: Code[20]; Variant1Code: Code[20]; Variant2Code: Code[20]; Variant3Code: Code[20]; Variant4Code: Code[20]) NewVariantCode: Code[20]
    var
        RetailSetup: Record "NPR Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        //-NPR5.43 [317108]
        GetNewVariantCode(ItemNo, Variant1Code, Variant2Code, Variant3Code, Variant4Code, NewVariantCode);
        if NewVariantCode <> '' then
            exit(NewVariantCode);
        //+NPR5.43 [317108]
        RetailSetup.Get;
        //-VRT1.10
        RetailSetup.TestField("Variant No. Series");
        //+VRT1.10
        exit(NoSeriesMgt.GetNextNo(RetailSetup."Variant No. Series", Today, true));
    end;

    procedure FillDescription(var ItemVariant: Record "Item Variant"; Item: Record Item)
    var
        TempDesc: Text[250];
    begin
        with ItemVariant do begin
            //-VRT1.11
            if not GetVRTSetup() then
                exit;
            //-NPR5.44 [321665]
            //IF VRTSetup."Variant Description" IN [VRTSetup."Variant Description"::VarietyTableSetupFirst50,VRTSetup."Variant Description"::VarietyTableSetupNext50]
            if ((VRTSetup."Variant Description" in [VRTSetup."Variant Description"::VarietyTableSetupFirst50, VRTSetup."Variant Description"::VarietyTableSetupNext50]) or
               (VRTSetup."Variant Description 2" in [VRTSetup."Variant Description"::VarietyTableSetupFirst50, VRTSetup."Variant Description"::VarietyTableSetupNext50]))
               //+NPR5.44 [321665]
               then begin
                //+VRT1.11
                GetVarietyDesc("NPR Variety 1", "NPR Variety 1 Table", "NPR Variety 1 Value", TempDesc);
                GetVarietyDesc("NPR Variety 2", "NPR Variety 2 Table", "NPR Variety 2 Value", TempDesc);
                GetVarietyDesc("NPR Variety 3", "NPR Variety 3 Table", "NPR Variety 3 Value", TempDesc);
                GetVarietyDesc("NPR Variety 4", "NPR Variety 4 Table", "NPR Variety 4 Value", TempDesc);
                //-VRT1.11
            end;
            //Description := COPYSTR(TempDesc, 1, MAXSTRLEN(Description));
            case VRTSetup."Variant Description" of
                VRTSetup."Variant Description"::VarietyTableSetupFirst50:
                    Description := CopyStr(TempDesc, 1, MaxStrLen(Description));
                VRTSetup."Variant Description"::VarietyTableSetupNext50:
                    Description := CopyStr(TempDesc, MaxStrLen(Description), MaxStrLen(Description));
                VRTSetup."Variant Description"::ItemDescription1:
                    Description := Item.Description;
                VRTSetup."Variant Description"::ItemDescription2:
                    Description := Item."Description 2";
            end;
            case VRTSetup."Variant Description 2" of
                VRTSetup."Variant Description 2"::VarietyTableSetupFirst50:
                    "Description 2" := CopyStr(TempDesc, 1, MaxStrLen("Description 2"));
                VRTSetup."Variant Description 2"::VarietyTableSetupNext50:
                    "Description 2" := CopyStr(TempDesc, MaxStrLen(Description), MaxStrLen("Description 2"));
                VRTSetup."Variant Description 2"::ItemDescription1:
                    "Description 2" := CopyStr(Item.Description, 1, MaxStrLen("Description 2"));
                VRTSetup."Variant Description 2"::ItemDescription2:
                    "Description 2" := Item."Description 2";
            end;
            //+VRT1.11
        end;
    end;

    procedure GetVarietyDesc(Variety: Code[20]; VarietyTable: Code[40]; VarietyValue: Code[20]; var TempDesc: Text[250])
    var
        VRTTable: Record "NPR Variety Table";
        VRTValue: Record "NPR Variety Value";
    begin
        if VarietyValue = '' then
            exit;

        VRTTable.Get(Variety, VarietyTable);
        if not VRTTable."Use in Variant Description" then
            exit;

        if VRTTable."Use Description field" then begin
            VRTValue.Get(Variety, VarietyTable, VarietyValue);
            if TempDesc <> '' then
                TempDesc += ' ' + VRTTable."Pre tag In Variant Description" + VRTValue.Description
            else
                TempDesc := VRTTable."Pre tag In Variant Description" + VRTValue.Description;
        end else begin
            if TempDesc <> '' then
                TempDesc += ' ' + VRTTable."Pre tag In Variant Description" + VarietyValue
            else
                TempDesc := VRTTable."Pre tag In Variant Description" + VarietyValue;
        end;
    end;

    procedure InsertDefaultBarcode(ItemNo: Code[20]; VariantCode: Code[20]; CalledFromInsert: Boolean)
    var
        SkipCreateDefaultBarcode: Boolean;
        Handled: Boolean;
    begin
        if not GetVRTSetup() then
            exit;

        CheckIfSkipCreateDefaultBarcode(ItemNo, VariantCode, SkipCreateDefaultBarcode, Handled);
        if SkipCreateDefaultBarcode then
            exit;

        if (VRTSetup."Create Item Cross Ref. auto.") or (not CalledFromInsert) then begin
            if (VariantCode = '') and (VRTSetup."Item Cross Ref. No. Series (I)" <> '') then
                AddItemRef(ItemNo, '');
            if (VariantCode <> '') and (VRTSetup."Item Cross Ref. No. Series (V)" <> '') then
                AddItemRef(ItemNo, VariantCode);

        end;
    end;

    procedure AddItemRef(ItemNo: Code[20]; VariantCode: Code[20])
    var
        NextCode: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        //-VRT1.11
        if not GetVRTSetup() then
            exit;

        if VariantCode = '' then begin
            VRTSetup.TestField("Item Cross Ref. No. Series (I)");
            NextCode := NoSeriesMgt.GetNextNo(VRTSetup."Item Cross Ref. No. Series (I)", Today, true);
        end else begin
            VRTSetup.TestField("Item Cross Ref. No. Series (V)");
            NextCode := NoSeriesMgt.GetNextNo(VRTSetup."Item Cross Ref. No. Series (V)", Today, true);
        end;

        case VRTSetup."Barcode Type (Item Cross Ref.)" of
            VRTSetup."Barcode Type (Item Cross Ref.)"::EAN8:
                InsertItemRef(ItemNo, VariantCode, CreateBarcodeEAN8(NextCode), 3, '');
            VRTSetup."Barcode Type (Item Cross Ref.)"::EAN13:
                InsertItemRef(ItemNo, VariantCode, CreateBarcodeEAN13(NextCode), 3, '');
        end;
        //+VRT1.11
    end;

    procedure InsertItemRef(ItemNo: Code[20]; VariantCode: Code[20]; Barcode: Code[20]; CrossRefType: Option " ",Customer,Vendor,"Bar Code"; CrossRefTypeNo: Code[20])
    var
        Item: Record Item;
        ItemRef: Record "Item Reference";
        ItemVar: Record "Item Variant";
        DescriptionControl: Codeunit "NPR Description Control";
    begin
        if Item.Get(Barcode) then
            Error(Text002);

        ItemRef.SetCurrentKey("Reference No.");
        ItemRef.SetRange("Reference No.", Barcode);
        if ItemRef.FindFirst then
            Error(Text003, ItemRef.TableCaption, Barcode, ItemRef."Item No.");

        ItemRef.Init;
        ItemRef."Item No." := ItemNo;
        ItemRef."Variant Code" := VariantCode;
        ItemRef.Validate("Reference Type", CrossRefType);
        ItemRef.Validate("Reference Type No.", CrossRefTypeNo);
        ItemRef."Reference No." := Barcode;
        ItemRef.Description := DescriptionControl.GetItemRefDescription(ItemNo, VariantCode);
        ItemRef."Unit of Measure" := GetUnitOfMeasure(ItemNo, 1);

        ItemRef.Insert;
    end;

    procedure CreateBarcodeEAN13(RefNo: Code[20]) Barcode: Code[13]
    begin
        if StrLen(RefNo) <> 12 then
            Error(Text001, 12);

        exit(RefNo + Format(StrCheckSum(RefNo, '131313131313')));
    end;

    procedure CreateBarcodeEAN8(RefNo: Code[20]) Barcode: Code[13]
    begin
        if StrLen(RefNo) <> 7 then
            Error(Text001, 7);

        exit(RefNo + Format(StrCheckSum(RefNo, '3131313')));
    end;

    procedure GetVRTSetup(): Boolean
    begin
        if VRTSetupFetched then
            exit(true);

        VRTSetupFetched := VRTSetup.Get;
        exit(VRTSetupFetched);
        //+VRT1.01
    end;

    procedure CreateEAN13BarcodeNoSeries(IsInternal: Boolean)
    var
        Prefix: Code[3];
        CompNo: Code[8];
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        LineNo: Integer;
    begin
        if IsInternal then begin
            Prefix := '28';
            CompNo := '000';
            if not NoSeries.Get('EAN13_INT') then begin
                NoSeries.Code := 'EAN13_INT';
                NoSeries.Description := 'EAN13 Code Internal';
                NoSeries."Default Nos." := true;
                NoSeries.Insert;
            end;
        end else begin
            Prefix := '57';
            CompNo := '12345';
            //-VRT1.11
            InputDialog.SetInput(1, Prefix, Text005);
            InputDialog.SetInput(2, CompNo, Text006);
            InputDialog.LookupMode(true);
            if InputDialog.RunModal = ACTION::LookupOK then;
            InputDialog.InputCode(1, Prefix);
            InputDialog.InputCode(2, CompNo);
            //+VRT1.11

            if (Prefix = '') or (CompNo = '') then
                exit;

            if not NoSeries.Get('EAN13_EXT') then begin
                NoSeries.Code := 'EAN13_EXT';
                NoSeries.Description := 'EAN13 Code External';
                NoSeries."Default Nos." := true;
                NoSeries.Insert;
            end;
        end;

        NoSeriesLine.SetRange("Series Code", NoSeries.Code);
        if NoSeriesLine.FindLast then
            LineNo := NoSeriesLine."Line No.";

        NoSeriesLine.Init;
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := LineNo + 10000;
        NoSeriesLine.Validate("Starting No.", Prefix + CompNo + PadStr('', 12 - StrLen(Prefix) - StrLen(CompNo), '0'));
        NoSeriesLine.Validate("Ending No.", Prefix + CompNo + PadStr('', 12 - StrLen(Prefix) - StrLen(CompNo), '9'));
        NoSeriesLine.Open := true;
        NoSeriesLine.Insert;

        Message(Text004, NoSeries.TableCaption, NoSeries.Code);
    end;

    procedure CreateTableCopy(var Item: Record Item; VarietyNo: Option Ask,Variety1,Variety2,Variety3,Variety4; ExcludeLockedTables: Boolean)
    var
        VRTTable: Record "NPR Variety Table";
        TMPVRTTable: Record "NPR Variety Table" temporary;
        VRTGroup: Record "NPR Variety Group";
        NewTableCode: Code[20];
        ItemVariant: Record "Item Variant";
    begin
        //-VRT1.10
        case VarietyNo of
            VarietyNo::Ask:
                begin
                    if VRTTable.Get(Item."NPR Variety 1", Item."NPR Variety 1 Table") then begin
                        TMPVRTTable := VRTTable;
                        TMPVRTTable.Insert;
                    end;
                    if VRTTable.Get(Item."NPR Variety 2", Item."NPR Variety 2 Table") then begin
                        TMPVRTTable := VRTTable;
                        TMPVRTTable.Insert;
                    end;
                    if VRTTable.Get(Item."NPR Variety 3", Item."NPR Variety 3 Table") then begin
                        TMPVRTTable := VRTTable;
                        TMPVRTTable.Insert;
                    end;
                    if VRTTable.Get(Item."NPR Variety 4", Item."NPR Variety 4 Table") then begin
                        TMPVRTTable := VRTTable;
                        TMPVRTTable.Insert;
                    end;
                end;
            VarietyNo::Variety1:
                begin
                    if VRTTable.Get(Item."NPR Variety 1", Item."NPR Variety 1 Table") then begin
                        TMPVRTTable := VRTTable;
                        TMPVRTTable.Insert;
                    end;
                end;
            VarietyNo::Variety2:
                begin
                    if VRTTable.Get(Item."NPR Variety 2", Item."NPR Variety 2 Table") then begin
                        TMPVRTTable := VRTTable;
                        TMPVRTTable.Insert;
                    end;
                end;
            VarietyNo::Variety3:
                begin
                    if VRTTable.Get(Item."NPR Variety 3", Item."NPR Variety 3 Table") then begin
                        TMPVRTTable := VRTTable;
                        TMPVRTTable.Insert;
                    end;
                end;
            VarietyNo::Variety4:
                begin
                    if VRTTable.Get(Item."NPR Variety 4", Item."NPR Variety 4 Table") then begin
                        TMPVRTTable := VRTTable;
                        TMPVRTTable.Insert;
                    end;
                end;
        end;


        if ExcludeLockedTables then
            TMPVRTTable.SetRange("Lock Table", false);

        case TMPVRTTable.Count of
            0:
                Error(Text007);
            1:
                TMPVRTTable.FindFirst;
            else
                if not (PAGE.RunModal(0, TMPVRTTable) = ACTION::LookupOK) then
                    exit;
        end;

        if GuiAllowed then
            if not Confirm(Text008, false, TMPVRTTable.Type, TMPVRTTable.Code, Item."No.") then
                exit;

        Clear(VRTTable);

        //Create the new table
        NewTableCode := TMPVRTTable.Code + '-' + Item."No.";
        VRTGroup.CopyTable2NewTable(TMPVRTTable.Type, TMPVRTTable.Code, NewTableCode);

        //Change the item
        ItemVariant.SetRange("Item No.", Item."No.");
        case true of
            Item."NPR Variety 1" = TMPVRTTable.Type:
                begin
                    Item."NPR Variety 1 Table" := NewTableCode;
                    Item.Modify(false);
                    ItemVariant.ModifyAll("NPR Variety 1 Table", NewTableCode, false);
                end;
            Item."NPR Variety 2" = TMPVRTTable.Type:
                begin
                    Item."NPR Variety 2 Table" := NewTableCode;
                    Item.Modify(false);
                    ItemVariant.ModifyAll("NPR Variety 2 Table", NewTableCode, false);
                end;
            Item."NPR Variety 3" = TMPVRTTable.Type:
                begin
                    Item."NPR Variety 3 Table" := NewTableCode;
                    Item.Modify(false);
                    ItemVariant.ModifyAll("NPR Variety 3 Table", NewTableCode, false);
                end;
            Item."NPR Variety 4" = TMPVRTTable.Type:
                begin
                    Item."NPR Variety 4 Table" := NewTableCode;
                    Item.Modify(false);
                    ItemVariant.ModifyAll("NPR Variety 4 Table", NewTableCode, false);
                end;
        end;
        //+VRT1.10
    end;

    procedure ShowEAN13BarcodeNoSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemRef1: Record "Item Reference";
        ItemRef2: Record "Item Reference";
        Filler: array[3] of Text;
        NextNo: array[3] of Text;
    begin
        //-VRT1.11
        RetailSetup.Get;
        if RetailSetup."EAN-Internal" <> 0 then begin
            ItemRef1.SetCurrentKey("Reference Type", "Reference No.");
            ItemRef1.SetRange("Reference Type", ItemRef1."Reference Type"::"Bar Code");
            ItemRef1.SetFilter("Reference No.", '%1', Format(RetailSetup."EAN-Internal") + '*');
            if ItemRef1.FindLast then;
            NextNo[1] := NoSeriesMgt.TryGetNextNo(RetailSetup."Internal EAN No. Management", Today);
            Filler[1] := PadStr('', 12 - StrLen(Format(RetailSetup."EAN-Internal")) - StrLen(NextNo[1]), '0')
        end;
        if RetailSetup."EAN-External" <> 0 then begin
            ItemRef2.SetCurrentKey("Reference Type", "Reference No.");
            ItemRef2.SetRange("Reference Type", ItemRef2."Reference Type"::"Bar Code");
            ItemRef2.SetFilter("Reference No.", '%1', Format(RetailSetup."EAN-External") + '*');
            if ItemRef2.FindLast then;
            NextNo[2] := NoSeriesMgt.TryGetNextNo(RetailSetup."External EAN-No. Management", Today);
            Filler[2] := PadStr('', 12 - StrLen(Format(RetailSetup."EAN-External")) - StrLen(NextNo[2]), '0')
        end;

        Message(RetailSetup.FieldCaption("EAN-Internal") + '\' +
                '   ' + RetailSetup.FieldCaption("Internal EAN No. Management") + ' : ' + RetailSetup."Internal EAN No. Management" + '\' +
                '   ' + RetailSetup.FieldCaption("EAN-Internal") + ' : ' + Format(RetailSetup."EAN-Internal") + '\' +
                '   ' + Format(RetailSetup."EAN-Internal") + '-' + Filler[1] + '-' + NextNo[1] + '-x\' +
                '    Last Item reference found: ' + ItemRef1."Reference No." + '\' +
                RetailSetup.FieldCaption("EAN-External") + '\' +
                '   ' + RetailSetup.FieldCaption("External EAN-No. Management") + ' : ' + RetailSetup."External EAN-No. Management" + '\' +
                '   ' + RetailSetup.FieldCaption("EAN-External") + ' : ' + Format(RetailSetup."EAN-External") + '\' +
                '   ' + Format(RetailSetup."EAN-External") + '-' + Filler[2] + '-' + NextNo[2] + '-x\' +
                '    Last Item reference found: ' + ItemRef2."Reference No." + '\' +
                'Retail Setup Enabled Fields:\' +
                '   ' + RetailSetup.FieldCaption("ISBN Bookland EAN") + ' : ' + Format(RetailSetup."ISBN Bookland EAN") + '\' +
                '   ' + RetailSetup.FieldCaption("Autocreate EAN-Number") + ' : ' + Format(RetailSetup."Autocreate EAN-Number") + '\' +
                '   ' + RetailSetup.FieldCaption("EAN No. at 1 star") + ' : ' + Format(RetailSetup."EAN No. at 1 star") + '\' +
                '   ' + RetailSetup.FieldCaption("EAN-No. at Item Create") + ' : ' + Format(RetailSetup."EAN-No. at Item Create") + '\'
        );
        //+VRT1.11
    end;

    procedure DisableOldBarcodeSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        //-VRT1.11
        RetailSetup.Get;
        RetailSetup."ISBN Bookland EAN" := false;
        RetailSetup."Autocreate EAN-Number" := false;
        RetailSetup."EAN No. at 1 star" := false;
        RetailSetup."EAN-No. at Item Create" := false;

        RetailSetup.Modify;
        //+VRT1.11
    end;

    procedure AssignBarcodes(Item: Record Item)
    var
        ItemVar: Record "Item Variant";
        ItemRef: Record "Item Reference";
    begin
        //-VRT1.11
        if not GetVRTSetup() then
            exit;

        if (VRTSetup."Item Cross Ref. No. Series (I)" <> '') then begin
            ItemRef.SetRange("Item No.", Item."No.");
            ItemRef.SetRange("Variant Code", '');
            ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
            if ItemRef.IsEmpty then
                AddItemRef(Item."No.", '');
        end;

        ItemVar.SetRange("Item No.", Item."No.");
        if ItemVar.FindSet then
            repeat
                if (VRTSetup."Item Cross Ref. No. Series (V)" <> '') then begin
                    ItemRef.SetRange("Item No.", Item."No.");
                    ItemRef.SetRange("Variant Code", ItemVar.Code);
                    ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
                    if ItemRef.IsEmpty then
                        AddItemRef(Item."No.", ItemVar.Code);
                end;
            until ItemVar.Next = 0;
        //+VRT1.11
    end;

    procedure UpdateVariantDescriptions()
    var
        ItemVariant: Record "Item Variant";
        NoOfRecords: Integer;
        LineCount: Integer;
        Item: Record Item;
        Dia: Dialog;
    begin
        //-VRT1.11
        if not Confirm(Text009, false, ItemVariant.TableCaption) then
            exit;

        NoOfRecords := ItemVariant.Count;

        if GuiAllowed then begin
            Dia.Open(Text010);
            Dia.Update(1, ItemVariant.TableCaption);
        end;

        if ItemVariant.FindSet(true, false) then
            repeat
                LineCount += 1;
                if GuiAllowed then
                    Dia.Update(2, Round(LineCount / NoOfRecords * 10000, 1));
                if Item."No." <> ItemVariant."Item No." then
                    if not Item.Get(ItemVariant."Item No.") then
                        Clear(Item);
                FillDescription(ItemVariant, Item);
                ItemVariant.Modify;
            until ItemVariant.Next = 0;

        if GuiAllowed then
            Dia.Close;
        //+VRT1.11
    end;

    procedure UpdateItemRefDescription()
    var
        ItemRef: Record "Item Reference";
        NoOfRecords: Integer;
        LineCount: Integer;
        Item: Record Item;
        ItemVar: Record "Item Variant";
        Dia: Dialog;
    begin
        //-VRT1.11
        if not Confirm(Text009, false, ItemRef.TableCaption) then
            exit;
        GetVRTSetup;

        NoOfRecords := ItemRef.Count;

        if GuiAllowed then begin
            Dia.Open(Text010);
            Dia.Update(1, ItemRef.TableCaption);
        end;

        if ItemRef.FindSet(true, false) then
            repeat
                LineCount += 1;
                if GuiAllowed then
                    Dia.Update(2, Round(LineCount / NoOfRecords * 10000, 1));
                if Item."No." <> ItemRef."Item No." then
                    if not Item.Get(ItemRef."Item No.") then
                        Clear(Item);
                if ItemRef."Variant Code" = '' then begin
                    case VRTSetup."Item Cross Ref. Description(I)" of
                        VRTSetup."Item Cross Ref. Description(I)"::ItemDescription1:
                            ItemRef.Description := Item.Description;
                        VRTSetup."Item Cross Ref. Description(I)"::ItemDescription2:
                            ItemRef.Description := Item."Description 2";
                    end;
                end else begin
                    if not ItemVar.Get(ItemRef."Item No.", ItemRef."Variant Code") then
                        Clear(ItemVar);
                    case VRTSetup."Item Cross Ref. Description(V)" of
                        VRTSetup."Item Cross Ref. Description(V)"::ItemDescription1:
                            ItemRef.Description := Item.Description;
                        VRTSetup."Item Cross Ref. Description(V)"::ItemDescription2:
                            ItemRef.Description := Item."Description 2";
                        VRTSetup."Item Cross Ref. Description(V)"::VariantDescription1:
                            ItemRef.Description := ItemVar.Description;
                        VRTSetup."Item Cross Ref. Description(V)"::VariantDescription2:
                            ItemRef.Description := ItemVar."Description 2";
                    end;
                end;
                ItemRef.Modify;
            until ItemRef.Next = 0;

        if GuiAllowed then
            Dia.Close;
        //+VRT1.11
    end;

    procedure LookupBarcodes(ItemNo: Code[20]; VariantCode: Code[10]): Code[20]
    var
        ItemRef: Record "Item Reference";
    begin
        //-VRT1.20 [261631]
        case GetPrimaryBarcodeTableNo of
            DATABASE::"Item Reference":
                begin
                    ItemRef.SetRange("Item No.", ItemNo);
                    ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
                    if VariantCode <> '' then
                        ItemRef.SetRange("Variant Code", VariantCode);
                    if PAGE.RunModal(0, ItemRef) = ACTION::LookupOK then
                        exit(ItemRef."Reference No.");
                end;
        end;
        //+VRT1.20 [261631]
    end;

    procedure AddCustomBarcode(ItemNo: Code[20]; VariantCode: Code[10]; Barcode: Code[20])
    var
        ItemVariant: Record "Item Variant";
    begin
        //-VRT1.20 [261631]
        if VariantCode = '' then begin
            ItemVariant.SetRange("Item No.", ItemNo);
            if not ItemVariant.IsEmpty then begin
                if PAGE.RunModal(0, ItemVariant) = ACTION::LookupOK then
                    VariantCode := ItemVariant.Code;
            end;
        end;

        case GetPrimaryBarcodeTableNo of
            DATABASE::"Item Reference":
                InsertItemRef(ItemNo, VariantCode, Barcode, 3, '')
        end;
        //+VRT1.20 [261631]
    end;

    local procedure GetPrimaryBarcodeTableNo(): Integer
    begin
                exit(DATABASE::"Item Reference");
    end;

    procedure SetupTransferLine(var MasterTransferLine: Record "Transfer Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewTransferLine: Record "Transfer Line";
        LineNo: Integer;
        TransferLine2: Record "Transfer Line";
        RecRef: RecordRef;
    begin
        //-NPR5.29 [260516]
        //check if a new line is needed (is variant code filled?)
        if MasterTransferLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterTransferLine.Validate("Variant Code", ItemVariant.Code);
            MasterTransferLine.Modify;
            RecRef.GetTable(MasterTransferLine);
            exit(Format(RecRef.RecordId));
        end;

        TransferLine2.SetRange("Document No.", MasterTransferLine."Document No.");
        TransferLine2.FindLast;
        if TransferLine2."NPR Master Line No." = MasterTransferLine."Line No." then
            LineNo := TransferLine2."Line No." + 10000
        else begin
            TransferLine2.SetRange("NPR Master Line No.", MasterTransferLine."Line No.");
            TransferLine2.FindLast;
            LineNo := TransferLine2."Line No." + 1;
        end;

        NewTransferLine := MasterTransferLine;
        NewTransferLine."Line No." := LineNo;
        NewTransferLine.Insert;
        NewTransferLine.Validate(Quantity, 0);
        NewTransferLine.Validate("Variant Code", ItemVariant.Code);
        //dimensions
        NewTransferLine.Validate("Shortcut Dimension 1 Code", MasterTransferLine."Shortcut Dimension 1 Code");
        NewTransferLine.Validate("Shortcut Dimension 2 Code", MasterTransferLine."Shortcut Dimension 2 Code");
        NewTransferLine."NPR Is Master" := false;

        NewTransferLine.Modify;
        RecRef.GetTable(NewTransferLine);
        exit(Format(RecRef.RecordId));
        //+NPR5.29 [260516]
    end;

    procedure GetFromVariety(var ItemVariant: Record "Item Variant"; ItemNo: Code[20]; VRT1: Code[20]; VRT2: Code[20]; VRT3: Code[20]; VRT4: Code[20]): Boolean
    var
        ItemVar: Record "Item Variant";
    begin
        //-NPR5.29 [263917]
        Clear(ItemVariant);
        //-NPR5.55 [361515]
        //ItemVar.SETCURRENTKEY("Item No.","Variety 1 Value","Variety 2 Value","Variety 3 Value","Variety 4 Value");
        ItemVar.SetCurrentKey("Item No.", Code);
        //+NPR5.55 [361515]
        ItemVar.SetRange("Item No.", ItemNo);
        ItemVar.SetRange("NPR Variety 1 Value", VRT1);
        ItemVar.SetRange("NPR Variety 2 Value", VRT2);
        ItemVar.SetRange("NPR Variety 3 Value", VRT3);
        ItemVar.SetRange("NPR Variety 4 Value", VRT4);
        if ItemVar.IsEmpty then
            exit(false);

        ItemVar.FindFirst;
        ItemVariant.Get(ItemVar."Item No.", ItemVar.Code);
        exit(true);
        //+NPR5.29 [263917]
    end;

    [IntegrationEvent(false, false)]
    local procedure CheckIfSkipCreateDefaultBarcode(ItemNo: Code[20]; VariantCode: Code[10]; var SkipCreateDefaultBarcode: Boolean; var Handled: Boolean)
    begin
        //-NPR5.42 [315499]
    end;

    [IntegrationEvent(false, false)]
    local procedure GetNewVariantCode(ItemNo: Code[20]; Variant1Code: Code[20]; Variant2Code: Code[20]; Variant3Code: Code[20]; Variant4Code: Code[20]; var NewVariantCode: Code[10])
    begin
        //-NPR5.43 [317108]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059972, 'GetNewVariantCode', '', true, true)]
    local procedure CreateVariantCodeFromNoSeries(ItemNo: Code[20]; Variant1Code: Code[20]; Variant2Code: Code[20]; Variant3Code: Code[20]; Variant4Code: Code[20]; var NewVariantCode: Code[10])
    var
        RetailSetup: Record "NPR Retail Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        VarietySetup: Record "NPR Variety Setup";
    begin
        //-NPR5.43 [317108]
        VarietySetup.Get;
        if not (VarietySetup."Create Variant Code From" in ['', 'CreateVariantCodeFromNoSeries']) then
            exit;

        RetailSetup.Get;
        RetailSetup.TestField("Variant No. Series");
        NewVariantCode := NoSeriesMgt.GetNextNo(RetailSetup."Variant No. Series", Today, true);
        //+NPR5.43 [317108]
    end;

    local procedure GetUnitOfMeasure(ItemNo: Code[20]; ReturnType: Integer): Code[10]
    var
        Item: Record Item;
    begin

        if not Item.Get(ItemNo) then
            exit('');

        case ReturnType of
            1:
                exit(Item."Base Unit of Measure");
            2:
                exit(Item."Sales Unit of Measure");
            3:
                exit(Item."Purch. Unit of Measure");
        end;
    end;
}

