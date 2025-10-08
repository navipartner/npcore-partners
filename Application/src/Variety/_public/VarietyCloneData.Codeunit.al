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
        BarcodeUsedOnVariantErr: Label 'The %1 %2 is already used for %3 %4. It must be deleted before it can be reused';

    procedure SetupNewLine(var MRecref: RecordRef; Item: Record Item; var TMPVRTBuffer: Record "NPR Variety Buffer"; NewValue: Text[250])
    var
        MasterSalesLine: Record "Sales Line";
        ItemVariant: Record "Item Variant";
        MasterPurchLine: Record "Purchase Line";
        MasterRetailJournalLine: Record "NPR Retail Journal Line";
        MasterItemReplenishment: Record "NPR Item Repl. by Store";
        MasterTransferLine: Record "Transfer Line";
        MasterItemJnlLine: Record "Item Journal Line";
        PriceListLine: Record "Price List Line";
        NotSupportedErr: Label 'Unsupported table: %1 %2 - codeunit 6059972 "NPR Variety Clone Data"';
    begin
        if not GetFromVariety(ItemVariant, Item."No.", TMPVRTBuffer."Variety 1 Value", TMPVRTBuffer."Variety 2 Value",
                                         TMPVRTBuffer."Variety 3 Value", TMPVRTBuffer."Variety 4 Value") then
            Clear(ItemVariant);

        //if the variant cant be found, its not created, and none of the functions below makes sence to call
        if ItemVariant.Code = '' then
            Error(ItemVariantDontExisit);
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        ItemVariant.TestField("NPR Blocked", false);
#ELSE
        ItemVariant.TestField(Blocked, false);
#ENDIF

        case MRecref.Number of
            Database::"Item Variant":
                begin
                    SetupVariant(Item, TMPVRTBuffer, CopyStr(NewValue, 1, 50));
                end;
            Database::"Sales Line":
                begin
                    MRecref.SetTable(MasterSalesLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupSalesLine(MasterSalesLine, Item, ItemVariant));
                end;
            Database::"Purchase Line":
                begin
                    MRecref.SetTable(MasterPurchLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupPurchLine(MasterPurchLine, Item, ItemVariant));
                end;
            Database::"Price List Line":
                begin
                    MRecref.SetTable(PriceListLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupPriceListLine(PriceListLine, Item, ItemVariant));
                end;

            Database::"NPR Retail Journal Line":
                begin
                    MRecref.SetTable(MasterRetailJournalLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupRetailJournalLine(MasterRetailJournalLine, Item, ItemVariant));
                end;

            Database::"NPR Item Repl. by Store":
                begin
                    MRecref.SetTable(MasterItemReplenishment);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupItemReplenishment(MasterItemReplenishment, Item, ItemVariant));
                end;
            Database::"Transfer Line":
                begin
                    MRecref.SetTable(MasterTransferLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupTransferLine(MasterTransferLine, Item, ItemVariant));
                end;
            Database::"Item Journal Line":
                begin
                    MRecref.SetTable(MasterItemJnlLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupItemJnlLine(MasterItemJnlLine, Item, ItemVariant));
                end;
            else
                Error(NotSupportedErr, MRecref.Number, MRecref.Caption);
        end;
        //if the master record has been changed (the record ID is identical), a reload is needed
        if (Format(MRecref.RecordId) = Format(TMPVRTBuffer."Record ID (TMP)")) then
            MRecref.Get(TMPVRTBuffer."Record ID (TMP)");

        TMPVRTBuffer.Modify();
    end;

    internal procedure SetupSalesLine(var MasterSalesLine: Record "Sales Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewSalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        RecRef: RecordRef;
        SameOrderRecRef: RecordRef;
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        LineNo: Integer;
    begin
        //check if a new line is needed (is variant code filled?)
        if MasterSalesLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterSalesLine.Validate("Variant Code", ItemVariant.Code);
            MasterSalesLine.Modify();
            RecRef.GetTable(MasterSalesLine);
            exit(Format(RecRef.RecordId));
        end;

        RecRef.GetTable(MasterSalesLine);
        SalesLine2.SetRange("Document Type", MasterSalesLine."Document Type");
        SalesLine2.SetRange("Document No.", MasterSalesLine."Document No.");
        SameOrderRecRef.GetTable(SalesLine2);
        LineNo := GetNextLineNo(RecRef, SameOrderRecRef, MasterSalesLine.FieldNo("Line No."));

        NewSalesLine := MasterSalesLine;
        NewSalesLine."Line No." := LineNo;
        NewSalesLine.Insert();
        NewSalesLine.Validate(Quantity, 0);
        NewSalesLine.Validate("Variant Code", ItemVariant.Code);
        //dimensions
        NewSalesLine.Validate("Shortcut Dimension 1 Code", MasterSalesLine."Shortcut Dimension 1 Code");
        NewSalesLine.Validate("Shortcut Dimension 2 Code", MasterSalesLine."Shortcut Dimension 2 Code");
        NewSalesLine.Modify();

        MasterLineMapMgt.CreateMap(Database::"Sales Line", NewSalesLine.SystemId, MasterSalesLine.SystemId);

        RecRef.GetTable(NewSalesLine);
        exit(Format(RecRef.RecordId));
    end;

    internal procedure SetupPurchLine(var MasterPurchLine: Record "Purchase Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewPurchLine: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        RecRef: RecordRef;
        SameOrderRecRef: RecordRef;
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        LineNo: Integer;
    begin
        //check if a new line is needed (is variant code filled?)
        if MasterPurchLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterPurchLine.Validate("Variant Code", ItemVariant.Code);
            MasterPurchLine.Modify();
            RecRef.GetTable(MasterPurchLine);
            exit(Format(RecRef.RecordId));
        end;

        RecRef.GetTable(MasterPurchLine);
        PurchLine2.SetRange("Document Type", MasterPurchLine."Document Type");
        PurchLine2.SetRange("Document No.", MasterPurchLine."Document No.");
        SameOrderRecRef.GetTable(PurchLine2);
        LineNo := GetNextLineNo(RecRef, SameOrderRecRef, MasterPurchLine.FieldNo("Line No."));

        NewPurchLine := MasterPurchLine;
        NewPurchLine."Line No." := LineNo;
        NewPurchLine.Insert();
        NewPurchLine.Validate(Quantity, 0);
        NewPurchLine.Validate("Variant Code", ItemVariant.Code);
        //dimensions
        NewPurchLine.Validate("Shortcut Dimension 1 Code", MasterPurchLine."Shortcut Dimension 1 Code");
        NewPurchLine.Validate("Shortcut Dimension 2 Code", MasterPurchLine."Shortcut Dimension 2 Code");

        NewPurchLine.Modify();

        MasterLineMapMgt.CreateMap(Database::"Purchase Line", NewPurchLine.SystemId, MasterPurchLine.SystemId);

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

        if GetFromVariety(ItemVariant, Item."No.", VRTBuffer."Variety 1 Value",
                                     VRTBuffer."Variety 2 Value", VRTBuffer."Variety 3 Value",
                                     VRTBuffer."Variety 4 Value") then
            Error('Variant already exists');

        ItemVariant.Init();
        ItemVariant."Item No." := Item."No.";
        ItemVariant.Code := GetNextVariantCode(Item."No.", VRTBuffer."Variety 1 Value", VRTBuffer."Variety 2 Value", VRTBuffer."Variety 3 Value", VRTBuffer."Variety 4 Value");
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

    internal procedure SetupPriceListLine(var MasterPriceListLine: Record "Price List Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewPriceListLine: Record "Price List Line";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        NewPriceListLine := MasterPriceListLine;
        NewPriceListLine."Variant Code" := ItemVariant.Code;
        NewPriceListLine.Insert();

        MasterLineMapMgt.CreateMap(Database::"Price List Line", NewPriceListLine.SystemId, MasterPriceListLine.SystemId);

        RecRef.GetTable(NewPriceListLine);
        exit(Format(RecRef.RecordId));

    end;

    internal procedure SetupRetailJournalLine(var MasterRetailJournalLine: Record "NPR Retail Journal Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewRetailJournalLine: Record "NPR Retail Journal Line";
        RetailJournalLine2: Record "NPR Retail Journal Line";
        RecRef: RecordRef;
        SameJournalRecRef: RecordRef;
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        LineNo: Integer;
    begin
        //check if a new line is needed (is variant code filled?)
        if MasterRetailJournalLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterRetailJournalLine.Validate("Variant Code", ItemVariant.Code);
            MasterRetailJournalLine.Modify();
            RecRef.GetTable(MasterRetailJournalLine);
            exit(Format(RecRef.RecordId));
        end;

        RecRef.GetTable(MasterRetailJournalLine);
        RetailJournalLine2.SetRange("No.", MasterRetailJournalLine."No.");
        SameJournalRecRef.GetTable(RetailJournalLine2);
        LineNo := GetNextLineNo(RecRef, SameJournalRecRef, MasterRetailJournalLine.FieldNo("Line No."));

        NewRetailJournalLine := MasterRetailJournalLine;
        NewRetailJournalLine."Line No." := LineNo;
        NewRetailJournalLine.Insert();
        NewRetailJournalLine.Validate("Quantity to Print", 0);
        NewRetailJournalLine.Validate("Variant Code", ItemVariant.Code);
        NewRetailJournalLine.Modify();

        MasterLineMapMgt.CreateMap(Database::"NPR Retail Journal Line", NewRetailJournalLine.SystemId, MasterRetailJournalLine.SystemId);

        RecRef.GetTable(NewRetailJournalLine);
        exit(Format(RecRef.RecordId));
    end;

    internal procedure SetupItemReplenishment(var MasterItemReplenishment: Record "NPR Item Repl. by Store"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewItemReplenishment: Record "NPR Item Repl. by Store";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        NewItemReplenishment := MasterItemReplenishment;
        NewItemReplenishment."Variant Code" := ItemVariant.Code;
        NewItemReplenishment.Insert();

        MasterLineMapMgt.CreateMap(Database::"NPR Item Repl. by Store", NewItemReplenishment.SystemId, MasterItemReplenishment.SystemId);

        RecRef.GetTable(NewItemReplenishment);
        exit(Format(RecRef.RecordId));
    end;

    internal procedure SetupItemJnlLine(var MasterItemJnlLine: Record "Item Journal Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewItemJnlLine: Record "Item Journal Line";
        ItemJnlLine2: Record "Item Journal Line";
        RecRef: RecordRef;
        SameJournalRecRef: RecordRef;
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        LineNo: Integer;
    begin
        //check if a new line is needed (is variant code filled?)
        if MasterItemJnlLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterItemJnlLine.Validate("Variant Code", ItemVariant.Code);
            MasterItemJnlLine.Modify();
            RecRef.GetTable(MasterItemJnlLine);
            exit(Format(RecRef.RecordId));
        end;

        RecRef.GetTable(MasterItemJnlLine);
        ItemJnlLine2.SetRange("Journal Template Name", MasterItemJnlLine."Journal Template Name");
        ItemJnlLine2.SetRange("Journal Batch Name", MasterItemJnlLine."Journal Batch Name");
        SameJournalRecRef.GetTable(ItemJnlLine2);
        LineNo := GetNextLineNo(RecRef, SameJournalRecRef, MasterItemJnlLine.FieldNo("Line No."));

        ItemJnlLine2.SetRange("Journal Template Name", MasterItemJnlLine."Journal Template Name");
        ItemJnlLine2.SetRange("Journal Batch Name", MasterItemJnlLine."Journal Batch Name");
        ItemJnlLine2.FindLast();

        // if ItemJnlLine2."Line No." = MasterItemJnlLine."Line No." then
        if MasterLineMapMgt.IsMaster(Database::"Item Journal Line", ItemJnlLine2.SystemId) then
            LineNo := ItemJnlLine2."Line No." + 10000
        else begin
            LineNo := ItemJnlLine2."Line No." + 1; // fallback
            if ItemJnlLine2.GetBySystemId(MasterLineMapMgt.GetLastInLineSystemId(Database::"Item Journal Line", MasterItemJnlLine.SystemId)) then
                LineNo := ItemJnlLine2."Line No." + 1;
        end;

        NewItemJnlLine := MasterItemJnlLine;
        NewItemJnlLine."Line No." := LineNo;
        NewItemJnlLine.Insert();
        NewItemJnlLine.Validate(Quantity, 0);
        NewItemJnlLine.Validate("Variant Code", ItemVariant.Code);
        NewItemJnlLine.Modify();

        MasterLineMapMgt.CreateMap(Database::"Item Journal Line", NewItemJnlLine.SystemId, MasterItemJnlLine.SystemId);

        RecRef.GetTable(NewItemJnlLine);
        exit(Format(RecRef.RecordId));
    end;

    local procedure GetNextLineNo(var MasterRecRef: RecordRef; var DatasetRecRef: RecordRef; LineNoField: Integer): Integer
    var
        SameMasterRecRef: RecordRef;
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        LineNoFldRef: FieldRef;
        LineNo: Integer;
        LastInMasterLineNo: Integer;
        NextLineNo: Integer;
    begin
        SameMasterRecRef.Open(MasterRecRef.Number);
        MasterLineMapMgt.FilterRecRefOnMasterId(SameMasterRecRef, MasterRecRef, false);
        SameMasterRecRef.FindLast();
        LastInMasterLineNo := SameMasterRecRef.Field(LineNoField).Value;

        LineNoFldRef := DatasetRecRef.Field(LineNoField);
        LineNoFldRef.SetFilter('>%1', LastInMasterLineNo);
        if DatasetRecRef.FindFirst() then begin
            NextLineNo := DatasetRecRef.Field(LineNoField).Value;
            LineNo := LastInMasterLineNo + Round((NextLineNo - LastInMasterLineNo) / 2, 1);
            if (LineNo = LastInMasterLineNo) or (LineNo = NextLineNo) then begin
                LineNoFldRef.SetRange();
                DatasetRecRef.FindLast();
                LineNo := DatasetRecRef.Field(LineNoField).Value;
                LineNo += 10000;
            end;
        end else
            LineNo := LastInMasterLineNo + 10000;
        exit(LineNo);
    end;

    procedure GetNextVariantCode(ItemNo: Code[20]; Variant1Code: Code[50]; Variant2Code: Code[50]; Variant3Code: Code[50]; Variant4Code: Code[50]) NewVariantCode: Code[10]
    var
        VarietySetup: Record "NPR Variety Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        GetNewVariantCode(ItemNo, Variant1Code, Variant2Code, Variant3Code, Variant4Code, NewVariantCode);
        if NewVariantCode <> '' then
            exit(NewVariantCode);

        VarietySetup.Get();
        VarietySetup.TestField("Variant No. Series");

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        exit(CopyStr(NoSeriesMgt.GetNextNo(VarietySetup."Variant No. Series", Today, false), 1, MaxStrLen(NewVariantCode)));
#ELSE
        exit(CopyStr(NoSeriesMgt.GetNextNo(VarietySetup."Variant No. Series", Today, true), 1, MaxStrLen(NewVariantCode)));
#ENDIF
    end;

    procedure FillDescription(var ItemVariant: Record "Item Variant"; Item: Record Item)
    var
        TempDesc: Text[250];
    begin
        if not GetVRTSetup() then
            exit;

        if ((VRTSetup."Variant Description" in [VRTSetup."Variant Description"::VarietyTableSetupFirst50, VRTSetup."Variant Description"::VarietyTableSetupNext50]) or
           (VRTSetup."Variant Description 2" in [VRTSetup."Variant Description"::VarietyTableSetupFirst50, VRTSetup."Variant Description"::VarietyTableSetupNext50]))
           then begin
            GetVarietyDesc(ItemVariant."NPR Variety 1", ItemVariant."NPR Variety 1 Table", ItemVariant."NPR Variety 1 Value", TempDesc);
            GetVarietyDesc(ItemVariant."NPR Variety 2", ItemVariant."NPR Variety 2 Table", ItemVariant."NPR Variety 2 Value", TempDesc);
            GetVarietyDesc(ItemVariant."NPR Variety 3", ItemVariant."NPR Variety 3 Table", ItemVariant."NPR Variety 3 Value", TempDesc);
            GetVarietyDesc(ItemVariant."NPR Variety 4", ItemVariant."NPR Variety 4 Table", ItemVariant."NPR Variety 4 Value", TempDesc);
        end;

        case VRTSetup."Variant Description" of
            VRTSetup."Variant Description"::VarietyTableSetupFirst50:
                ItemVariant.Description := CopyStr(TempDesc, 1, MaxStrLen(ItemVariant.Description));
            VRTSetup."Variant Description"::VarietyTableSetupNext50:
                ItemVariant.Description := CopyStr(TempDesc, MaxStrLen(ItemVariant.Description), MaxStrLen(ItemVariant.Description));
            VRTSetup."Variant Description"::ItemDescription1:
                ItemVariant.Description := Item.Description;
            VRTSetup."Variant Description"::ItemDescription2:
                ItemVariant.Description := Item."Description 2";
        end;

        case VRTSetup."Variant Description 2" of
            VRTSetup."Variant Description 2"::VarietyTableSetupFirst50:
                ItemVariant."Description 2" := CopyStr(TempDesc, 1, MaxStrLen(ItemVariant."Description 2"));
            VRTSetup."Variant Description 2"::VarietyTableSetupNext50:
                ItemVariant."Description 2" := CopyStr(TempDesc, MaxStrLen(ItemVariant.Description), MaxStrLen(ItemVariant."Description 2"));
            VRTSetup."Variant Description 2"::ItemDescription1:
                ItemVariant."Description 2" := CopyStr(Item.Description, 1, MaxStrLen(ItemVariant."Description 2"));
            VRTSetup."Variant Description 2"::ItemDescription2:
                ItemVariant."Description 2" := Item."Description 2";
        end;

    end;

    internal procedure GetVarietyDesc(Variety: Code[20]; VarietyTable: Code[40]; VarietyValue: Code[50]; var TempDesc: Text[250])
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

    internal procedure InsertDefaultBarcode(ItemNo: Code[20]; VariantCode: Code[10]; CalledFromInsert: Boolean)
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

    internal procedure AddItemRef(ItemNo: Code[20]; VariantCode: Code[10])
    var
        NextCode: Code[20];
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        if not GetVRTSetup() then
            exit;

        if VariantCode = '' then begin
            VRTSetup.TestField("Item Cross Ref. No. Series (I)");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            NextCode := NoSeriesMgt.GetNextNo(VRTSetup."Item Cross Ref. No. Series (I)", Today, false);
#ELSE
            NextCode := NoSeriesMgt.GetNextNo(VRTSetup."Item Cross Ref. No. Series (I)", Today, true);
#ENDIF
        end else begin
            VRTSetup.TestField("Item Cross Ref. No. Series (V)");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            NextCode := NoSeriesMgt.GetNextNo(VRTSetup."Item Cross Ref. No. Series (V)", Today, false);
#ELSE
            NextCode := NoSeriesMgt.GetNextNo(VRTSetup."Item Cross Ref. No. Series (V)", Today, true);
#ENDIF
        end;

        case VRTSetup."Barcode Type (Item Cross Ref.)" of
            VRTSetup."Barcode Type (Item Cross Ref.)"::EAN8:
                InsertItemRef(ItemNo, VariantCode, CreateBarcodeEAN8(NextCode), Enum::"Item Reference Type"::"Bar Code", '');
            VRTSetup."Barcode Type (Item Cross Ref.)"::EAN13:
                InsertItemRef(ItemNo, VariantCode, CreateBarcodeEAN13(NextCode), Enum::"Item Reference Type"::"Bar Code", '');
        end;
    end;

    internal procedure InsertItemRef(ItemNo: Code[20]; VariantCode: Code[10]; Barcode: Code[20]; CrossRefType: Enum "Item Reference Type"; CrossRefTypeNo: Code[20])
    var
        Item: Record Item;
        ItemRef: Record "Item Reference";
    begin
        if Barcode = '' then
            exit;
        if Item.Get(Barcode) then
            Error(Text002);

        ItemRef.SetCurrentKey("Reference No.");
        ItemRef.SetRange("Reference No.", Barcode);
        ItemRef.SetFilter("Item No.", '<>%1', ItemNo);
        ItemRef.SetRange("Reference Type", CrossRefType);
        if ItemRef.FindFirst() then
            Error(Text003, ItemRef.TableCaption, Barcode, ItemRef."Item No.");

        ItemRef.SetCurrentKey("Reference No.");
        ItemRef.SetRange("Reference No.", Barcode);
        ItemRef.SetRange("Item No.", ItemNo);
        ItemRef.SetFilter("Variant Code", '<>%1', VariantCode);
        ItemRef.SetRange("Reference Type", CrossRefType);
        if ItemRef.FindFirst() then
            Error(BarcodeUsedOnVariantErr, ItemRef.TableCaption, Barcode, ItemRef.FieldCaption("Variant Code"), ItemRef."Variant Code");

        ItemRef.Init();
        ItemRef."Item No." := ItemNo;
        ItemRef."Variant Code" := VariantCode;
        ItemRef.Validate("Reference Type", CrossRefType);
        ItemRef.Validate("Reference Type No.", CrossRefTypeNo);
        ItemRef."Reference No." := Barcode;
        Item.Get(ItemNo);
        UpdateDescriptions(ItemRef, Item);
        ItemRef."Unit of Measure" := GetUnitOfMeasure(ItemNo, 1);
        if not ItemRef.Get(ItemRef."Item No.", ItemRef."Variant Code", ItemRef."Unit of Measure", ItemRef."Reference Type", ItemRef."Reference Type No.", ItemRef."Reference No.") then
            ItemRef.Insert(true);
    end;

    internal procedure CreateBarcodeEAN13(RefNo: Code[20]) Barcode: Code[13]
    begin
        if StrLen(RefNo) <> 12 then
            Error(Text001, 12);

        exit(CopyStr(RefNo + Format(StrCheckSum(RefNo, '131313131313')), 1, MaxStrLen(Barcode)));
    end;

    internal procedure CreateBarcodeEAN8(RefNo: Code[20]) Barcode: Code[13]
    begin
        if StrLen(RefNo) <> 7 then
            Error(Text001, 7);

        exit(CopyStr(RefNo + Format(StrCheckSum(RefNo, '3131313')), 1, MaxStrLen(Barcode)));
    end;

    internal procedure GetVRTSetup(): Boolean
    begin
        if VRTSetupFetched then
            exit(true);

        VRTSetupFetched := VRTSetup.Get();
        exit(VRTSetupFetched);
    end;

    internal procedure CreateEAN13BarcodeNoSeries(IsInternal: Boolean)
    var
        Prefix: Code[50];
        CompNo: Code[50];
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
                NoSeries.Insert();
            end;
        end else begin
            Prefix := '57';
            CompNo := '12345';

            InputDialog.SetInput(1, Prefix, Text005);
            InputDialog.SetInput(2, CompNo, Text006);
            InputDialog.LookupMode(true);
            if InputDialog.RunModal() <> Action::LookupOK then
                exit;
            InputDialog.InputCodeValue(1, Prefix);
            InputDialog.InputCodeValue(2, CompNo);

            if (Prefix = '') or (CompNo = '') then
                exit;

            if not NoSeries.Get('EAN13_EXT') then begin
                NoSeries.Code := 'EAN13_EXT';
                NoSeries.Description := 'EAN13 Code External';
                NoSeries."Default Nos." := true;
                NoSeries.Insert();
            end;
        end;

        NoSeriesLine.SetRange("Series Code", NoSeries.Code);
        if NoSeriesLine.FindLast() then
            LineNo := NoSeriesLine."Line No.";

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := LineNo + 10000;
        NoSeriesLine.Validate("Starting No.", GenerateNewNoSeriesLimitingNo(Prefix, CompNo, '0'));
        NoSeriesLine.Validate("Ending No.", GenerateNewNoSeriesLimitingNo(Prefix, CompNo, '9'));
        NoSeriesLine.Open := true;
        NoSeriesLine.Insert();

        Message(Text004, NoSeries.TableCaption, NoSeries.Code);
    end;

    local procedure GenerateNewNoSeriesLimitingNo(Prefix: Code[50]; CompNo: Code[50]; FillerCharacter: Text[1]) Result: Code[20]
    begin
        Result := CopyStr(Prefix + CompNo, 1, MaxStrLen(Result));
        if StrLen(Result) < 12 then
            Result := PadStr(Result, 12, FillerCharacter);
    end;

    procedure CreateTableCopy(var Item: Record Item; VarietyNo: Option Ask,Variety1,Variety2,Variety3,Variety4; ExcludeLockedTables: Boolean)
    var
        VRTTable: Record "NPR Variety Table";
        TempVRTTable: Record "NPR Variety Table" temporary;
        VRTGroup: Record "NPR Variety Group";
        NewTableCode: Code[20];
        ItemVariant: Record "Item Variant";
    begin
        case VarietyNo of
            VarietyNo::Ask:
                begin
                    if VRTTable.Get(Item."NPR Variety 1", Item."NPR Variety 1 Table") then begin
                        TempVRTTable := VRTTable;
                        TempVRTTable.Insert();
                    end;
                    if VRTTable.Get(Item."NPR Variety 2", Item."NPR Variety 2 Table") then begin
                        TempVRTTable := VRTTable;
                        TempVRTTable.Insert();
                    end;
                    if VRTTable.Get(Item."NPR Variety 3", Item."NPR Variety 3 Table") then begin
                        TempVRTTable := VRTTable;
                        TempVRTTable.Insert();
                    end;
                    if VRTTable.Get(Item."NPR Variety 4", Item."NPR Variety 4 Table") then begin
                        TempVRTTable := VRTTable;
                        TempVRTTable.Insert();
                    end;
                end;
            VarietyNo::Variety1:
                begin
                    if VRTTable.Get(Item."NPR Variety 1", Item."NPR Variety 1 Table") then begin
                        TempVRTTable := VRTTable;
                        TempVRTTable.Insert();
                    end;
                end;
            VarietyNo::Variety2:
                begin
                    if VRTTable.Get(Item."NPR Variety 2", Item."NPR Variety 2 Table") then begin
                        TempVRTTable := VRTTable;
                        TempVRTTable.Insert();
                    end;
                end;
            VarietyNo::Variety3:
                begin
                    if VRTTable.Get(Item."NPR Variety 3", Item."NPR Variety 3 Table") then begin
                        TempVRTTable := VRTTable;
                        TempVRTTable.Insert();
                    end;
                end;
            VarietyNo::Variety4:
                begin
                    if VRTTable.Get(Item."NPR Variety 4", Item."NPR Variety 4 Table") then begin
                        TempVRTTable := VRTTable;
                        TempVRTTable.Insert();
                    end;
                end;
        end;


        if ExcludeLockedTables then
            TempVRTTable.SetRange("Lock Table", false);

        case TempVRTTable.Count() of
            0:
                Error(Text007);
            1:
                TempVRTTable.FindFirst();
            else
                if not (Page.RunModal(0, TempVRTTable) = Action::LookupOK) then
                    exit;
        end;

        if GuiAllowed then
            if not Confirm(Text008, false, TempVRTTable.Type, TempVRTTable.Code, Item."No.") then
                exit;

        Clear(VRTTable);

        //Create the new table
        NewTableCode := CopyStr(TempVRTTable.Code + '-' + Item."No.", 1, MaxStrLen(NewTableCode));
        VRTGroup.CopyTable2NewTable(TempVRTTable.Type, TempVRTTable.Code, NewTableCode);

        //Change the item
        ItemVariant.SetRange("Item No.", Item."No.");
        case true of
            Item."NPR Variety 1" = TempVRTTable.Type:
                begin
                    Item."NPR Variety 1 Table" := NewTableCode;
                    Item.Modify(false);
                    ItemVariant.ModifyAll("NPR Variety 1 Table", NewTableCode, false);
                end;
            Item."NPR Variety 2" = TempVRTTable.Type:
                begin
                    Item."NPR Variety 2 Table" := NewTableCode;
                    Item.Modify(false);
                    ItemVariant.ModifyAll("NPR Variety 2 Table", NewTableCode, false);
                end;
            Item."NPR Variety 3" = TempVRTTable.Type:
                begin
                    Item."NPR Variety 3 Table" := NewTableCode;
                    Item.Modify(false);
                    ItemVariant.ModifyAll("NPR Variety 3 Table", NewTableCode, false);
                end;
            Item."NPR Variety 4" = TempVRTTable.Type:
                begin
                    Item."NPR Variety 4 Table" := NewTableCode;
                    Item.Modify(false);
                    ItemVariant.ModifyAll("NPR Variety 4 Table", NewTableCode, false);
                end;
        end;
    end;

    internal procedure ShowEAN13BarcodeNoSetup()
    var
        VarietySetup: Record "NPR Variety Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
        ItemRef1: Record "Item Reference";
        ItemRef2: Record "Item Reference";
        Filler: array[3] of Text;
        NextNo: array[3] of Text;
    begin
        VarietySetup.Get();
        if VarietySetup."EAN-Internal" <> 0 then begin
            ItemRef1.SetCurrentKey("Reference Type", "Reference No.");
            ItemRef1.SetRange("Reference Type", ItemRef1."Reference Type"::"Bar Code");
            ItemRef1.SetFilter("Reference No.", '%1', Format(VarietySetup."EAN-Internal") + '*');
            if ItemRef1.FindLast() then;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            NextNo[1] := NoSeriesMgt.PeekNextNo(VarietySetup."Internal EAN No. Series", Today);
#ELSE
            NextNo[1] := NoSeriesMgt.TryGetNextNo(VarietySetup."Internal EAN No. Series", Today);
#ENDIF
            Filler[1] := PadStr('', 12 - StrLen(Format(VarietySetup."EAN-Internal")) - StrLen(NextNo[1]), '0')
        end;
        if VarietySetup."EAN-External" <> 0 then begin
            ItemRef2.SetCurrentKey("Reference Type", "Reference No.");
            ItemRef2.SetRange("Reference Type", ItemRef2."Reference Type"::"Bar Code");
            ItemRef2.SetFilter("Reference No.", '%1', Format(VarietySetup."EAN-External") + '*');
            if ItemRef2.FindLast() then;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            NextNo[2] := NoSeriesMgt.PeekNextNo(VarietySetup."External EAN No. Series", Today);
#ELSE
            NextNo[2] := NoSeriesMgt.TryGetNextNo(VarietySetup."External EAN No. Series", Today);
#ENDIF
            Filler[2] := PadStr('', 12 - StrLen(Format(VarietySetup."EAN-External")) - StrLen(NextNo[2]), '0')
        end;

        Message(VarietySetup.FieldCaption("EAN-Internal") + '\' +
                '   ' + VarietySetup.FieldCaption("Internal EAN No. Series") + ' : ' + VarietySetup."Internal EAN No. Series" + '\' +
                '   ' + VarietySetup.FieldCaption("EAN-Internal") + ' : ' + Format(VarietySetup."EAN-Internal") + '\' +
                '   ' + Format(VarietySetup."EAN-Internal") + '-' + Filler[1] + '-' + NextNo[1] + '-x\' +
                '    Last Item reference found: ' + ItemRef1."Reference No." + '\' +
                VarietySetup.FieldCaption("EAN-External") + '\' +
                '   ' + VarietySetup.FieldCaption("External EAN No. Series") + ' : ' + VarietySetup."External EAN No. Series" + '\' +
                '   ' + VarietySetup.FieldCaption("EAN-External") + ' : ' + Format(VarietySetup."EAN-External") + '\' +
                '   ' + Format(VarietySetup."EAN-External") + '-' + Filler[2] + '-' + NextNo[2] + '-x\' +
                '    Last Item reference found: ' + ItemRef2."Reference No." + '\'
        );
    end;

    internal procedure AssignCustomBarcode(ItemNo: Code[20])
    var
        InputBarcode: Page "NPR Variety Input Barcode";
        ReferenceNo: Code[50];
    begin
        InputBarcode.LookupMode := true;
        if InputBarcode.RunModal() <> Action::LookupOK then
            exit;
        ReferenceNo := InputBarcode.GetBarcode();
        if ReferenceNo = '' then
            exit;
        InsertItemRef(ItemNo, '', CopyStr(ReferenceNo, 1, 20), Enum::"Item Reference Type"::"Bar Code", '');
    end;

    internal procedure AssignBarcodes(Item: Record Item)
    var
        ItemVar: Record "Item Variant";
        ItemRef: Record "Item Reference";
    begin
        if not GetVRTSetup() then
            exit;

        if (VRTSetup."Item Cross Ref. No. Series (I)" <> '') then begin
            ItemRef.SetRange("Item No.", Item."No.");
            ItemRef.SetRange("Variant Code", '');
            ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
            if ItemRef.IsEmpty() then
                AddItemRef(Item."No.", '');
        end;

        if (VRTSetup."Item Cross Ref. No. Series (V)" <> '') then begin
            ItemVar.SetRange("Item No.", Item."No.");
            if ItemVar.FindSet() then
                repeat
                    ItemRef.SetRange("Item No.", Item."No.");
                    ItemRef.SetRange("Variant Code", ItemVar.Code);
                    ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
                    if ItemRef.IsEmpty() then
                        AddItemRef(Item."No.", ItemVar.Code);
                until ItemVar.Next() = 0;
        end;
    end;

    internal procedure UpdateVariantDescriptions()
    var
        ItemVariant: Record "Item Variant";
        NoOfRecords: Integer;
        LineCount: Integer;
        Item: Record Item;
        Dia: Dialog;
    begin
        if not Confirm(Text009, false, ItemVariant.TableCaption) then
            exit;

        NoOfRecords := ItemVariant.Count();

        if GuiAllowed then begin
            Dia.Open(Text010);
            Dia.Update(1, ItemVariant.TableCaption);
        end;

        if ItemVariant.FindSet(true) then
            repeat
                LineCount += 1;
                if GuiAllowed then
                    Dia.Update(2, Round(LineCount / NoOfRecords * 10000, 1));
                if Item."No." <> ItemVariant."Item No." then
                    if not Item.Get(ItemVariant."Item No.") then
                        Clear(Item);
                FillDescription(ItemVariant, Item);
                ItemVariant.Modify();
            until ItemVariant.Next() = 0;

        if GuiAllowed then
            Dia.Close();
    end;

    internal procedure UpdateItemRefDescription()
    var
        ItemRef: Record "Item Reference";
        NoOfRecords: Integer;
        LineCount: Integer;
        Item: Record Item;
        Dia: Dialog;
    begin
        if not Confirm(Text009, false, ItemRef.TableCaption) then
            exit;

        NoOfRecords := ItemRef.Count();

        if GuiAllowed then begin
            Dia.Open(Text010);
            Dia.Update(1, ItemRef.TableCaption);
        end;

        if ItemRef.FindSet(true) then
            repeat
                LineCount += 1;
                if GuiAllowed then
                    Dia.Update(2, Round(LineCount / NoOfRecords * 10000, 1));
                if Item."No." <> ItemRef."Item No." then
                    if not Item.Get(ItemRef."Item No.") then
                        Clear(Item);
                UpdateDescriptions(ItemRef, Item);
                ItemRef.Modify();
            until ItemRef.Next() = 0;

        if GuiAllowed then
            Dia.Close();
    end;

    local procedure UpdateDescriptions(var ItemRef: Record "Item Reference"; Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
    begin
        GetVRTSetup();

        if ItemRef."Variant Code" = '' then begin
            case VRTSetup."Item Cross Ref. Description(I)" of
                VRTSetup."Item Cross Ref. Description(I)"::ItemDescription1:
                    ItemRef.Description := Item.Description;
                VRTSetup."Item Cross Ref. Description(I)"::ItemDescription2:
                    ItemRef.Description := Item."Description 2";
            end;
            case VRTSetup."Item Ref. Description 2 (I)" of
                VRTSetup."Item Ref. Description 2 (I)"::ItemDescription1:
                    ItemRef."Description 2" := CopyStr(Item.Description, 1, MaxStrLen(ItemRef."Description 2"));
                VRTSetup."Item Ref. Description 2 (I)"::ItemDescription2:
                    ItemRef."Description 2" := Item."Description 2";
            end;
            exit;
        end;

        if not ItemVariant.Get(ItemRef."Item No.", ItemRef."Variant Code") then
            Clear(ItemVariant);
        case VRTSetup."Item Cross Ref. Description(V)" of
            VRTSetup."Item Cross Ref. Description(V)"::ItemDescription1:
                ItemRef.Description := Item.Description;
            VRTSetup."Item Cross Ref. Description(V)"::ItemDescription2:
                ItemRef.Description := Item."Description 2";
            VRTSetup."Item Cross Ref. Description(V)"::VariantDescription1:
                ItemRef.Description := ItemVariant.Description;
            VRTSetup."Item Cross Ref. Description(V)"::VariantDescription2:
                ItemRef.Description := ItemVariant."Description 2";
        end;
        case VRTSetup."Item Ref. Description 2 (V)" of
            VRTSetup."Item Ref. Description 2 (V)"::ItemDescription1:
                ItemRef."Description 2" := CopyStr(Item.Description, 1, MaxStrLen(ItemRef."Description 2"));
            VRTSetup."Item Ref. Description 2 (V)"::ItemDescription2:
                ItemRef."Description 2" := Item."Description 2";
            VRTSetup."Item Ref. Description 2 (V)"::VariantDescription1:
                ItemRef."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(ItemRef."Description 2"));
            VRTSetup."Item Ref. Description 2 (V)"::VariantDescription2:
                ItemRef."Description 2" := ItemVariant."Description 2";
        end;
    end;


    internal procedure SetupTransferLine(var MasterTransferLine: Record "Transfer Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewTransferLine: Record "Transfer Line";
        TransferLine2: Record "Transfer Line";
        RecRef: RecordRef;
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        LineNo: Integer;
    begin
        //check if a new line is needed (is variant code filled?)
        if MasterTransferLine."Variant Code" = '' then begin
            //Variant Code is blank. Use this one for the current line
            MasterTransferLine.Validate("Variant Code", ItemVariant.Code);
            MasterTransferLine.Modify();
            RecRef.GetTable(MasterTransferLine);
            exit(Format(RecRef.RecordId));
        end;

        TransferLine2.SetRange("Document No.", MasterTransferLine."Document No.");
        TransferLine2.FindLast();

        if MasterLineMapMgt.IsMaster(Database::"Transfer Line", TransferLine2.SystemId) then
            LineNo := TransferLine2."Line No." + 10000
        else begin
            LineNo := TransferLine2."Line No." + 10000; // fallback
            if TransferLine2.GetBySystemId(MasterLineMapMgt.GetLastInLineSystemId(Database::"Transfer Line", MasterTransferLine.SystemId)) then
                LineNo := TransferLine2."Line No." + 10000;
        end;

        NewTransferLine := MasterTransferLine;
        NewTransferLine."Line No." := LineNo;
        NewTransferLine.Insert();
        NewTransferLine.Validate(Quantity, 0);
        NewTransferLine.Validate("Variant Code", ItemVariant.Code);
        //dimensions
        NewTransferLine.Validate("Shortcut Dimension 1 Code", MasterTransferLine."Shortcut Dimension 1 Code");
        NewTransferLine.Validate("Shortcut Dimension 2 Code", MasterTransferLine."Shortcut Dimension 2 Code");
        NewTransferLine.Modify();

        MasterLineMapMgt.CreateMap(Database::"Transfer Line", NewTransferLine.SystemId, MasterTransferLine.SystemId);

        RecRef.GetTable(NewTransferLine);
        exit(Format(RecRef.RecordId));
    end;

    procedure GetFromVariety(var ItemVariant: Record "Item Variant"; ItemNo: Code[20]; VRT1: Code[50]; VRT2: Code[50]; VRT3: Code[50]; VRT4: Code[50]): Boolean
    var
        ItemVar: Record "Item Variant";
    begin
        Clear(ItemVariant);
        ItemVar.SetCurrentKey("Item No.", Code);
        ItemVar.SetRange("Item No.", ItemNo);
        ItemVar.SetRange("NPR Variety 1 Value", VRT1);
        ItemVar.SetRange("NPR Variety 2 Value", VRT2);
        ItemVar.SetRange("NPR Variety 3 Value", VRT3);
        ItemVar.SetRange("NPR Variety 4 Value", VRT4);
        if ItemVar.IsEmpty then
            exit(false);

        ItemVar.FindFirst();
        ItemVariant.Get(ItemVar."Item No.", ItemVar.Code);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure CheckIfSkipCreateDefaultBarcode(ItemNo: Code[20]; VariantCode: Code[10]; var SkipCreateDefaultBarcode: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure GetNewVariantCode(ItemNo: Code[20]; Variant1Code: Code[50]; Variant2Code: Code[50]; Variant3Code: Code[50]; Variant4Code: Code[50]; var NewVariantCode: Code[10])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Clone Data", 'GetNewVariantCode', '', true, true)]
    local procedure CreateVariantCodeFromNoSeries(ItemNo: Code[20]; Variant1Code: Code[50]; Variant2Code: Code[50]; Variant3Code: Code[50]; Variant4Code: Code[50]; var NewVariantCode: Code[10])
    var
        VarietySetup: Record "NPR Variety Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        VarietySetup.Get();
        if not (VarietySetup."Create Variant Code From" in ['', 'CreateVariantCodeFromNoSeries']) then
            exit;

        VarietySetup.TestField("Variant No. Series");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NewVariantCode := CopyStr(NoSeriesMgt.GetNextNo(VarietySetup."Variant No. Series", Today, false), 1, MaxStrLen(NewVariantCode));
#ELSE
        NewVariantCode := CopyStr(NoSeriesMgt.GetNextNo(VarietySetup."Variant No. Series", Today, true), 1, MaxStrLen(NewVariantCode));
#ENDIF
    end;

    internal procedure GetUnitOfMeasure(ItemNo: Code[20]; ReturnType: Integer): Code[10]
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
