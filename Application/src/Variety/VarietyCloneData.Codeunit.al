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
        if not GetFromVariety(ItemVariant, Item."No.", TMPVRTBuffer."Variety 1 Value", TMPVRTBuffer."Variety 2 Value",
                                         TMPVRTBuffer."Variety 3 Value", TMPVRTBuffer."Variety 4 Value") then
            Clear(ItemVariant);

        //if the variant cant be found, its not created, and none of the functions below makes sence to call
        if ItemVariant.Code = '' then
            Error(ItemVariantDontExisit);

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

            DATABASE::"NPR Retail Journal Line":
                begin
                    MRecref.SetTable(MasterRetailJournalLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupRetailJournalLine(MasterRetailJournalLine, Item, ItemVariant));
                end;

            DATABASE::"NPR Item Repl. by Store":
                begin
                    MRecref.SetTable(MasterItemReplenishment);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupItemReplenishment(MasterItemReplenishment, Item, ItemVariant));
                end;

            DATABASE::"Transfer Line":
                begin
                    MRecref.SetTable(MasterTransferLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupTransferLine(MasterTransferLine, Item, ItemVariant));
                end;

            DATABASE::"Purchase Price":
                begin
                    MRecref.SetTable(MasterPurchPrice);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupPurchPrice(MasterPurchPrice, Item, ItemVariant));
                end;

            DATABASE::"Item Journal Line":
                begin
                    MRecref.SetTable(MasterItemJnlLine);
                    Evaluate(TMPVRTBuffer."Record ID (TMP)", SetupItemJnlLine(MasterItemJnlLine, Item, ItemVariant));
                end;

        end;
        //if the master record has been changed (the record ID is identical), a reload is needed
        if (Format(MRecref.RecordId) = Format(TMPVRTBuffer."Record ID (TMP)")) then
            MRecref.Get(TMPVRTBuffer."Record ID (TMP)");

        TMPVRTBuffer.Modify;
    end;

    procedure SetupSalesLine(var MasterSalesLine: Record "Sales Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewSalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        RecRef: RecordRef;
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

        SalesLine2.SetRange("Document Type", MasterSalesLine."Document Type");
        SalesLine2.SetRange("Document No.", MasterSalesLine."Document No.");
        SalesLine2.FindLast();

        // if SalesLine2."NPR Master Line No." = MasterSalesLine."Line No." then
        if MasterLineMapMgt.IsMaster(Database::"Sales Line", SalesLine2.SystemId) then
            LineNo := SalesLine2."Line No." + 10000
        else begin
            LineNo := SalesLine2."Line No." + 1; // fallback
            if SalesLine2.GetBySystemId(MasterLineMapMgt.GetLastInLineSystemId(Database::"Sales Line", MasterSalesLine.SystemId)) then
                LineNo := SalesLine2."Line No." + 1;
        end;

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

    procedure SetupPurchLine(var MasterPurchLine: Record "Purchase Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewPurchLine: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        RecRef: RecordRef;
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

        PurchLine2.SetRange("Document Type", MasterPurchLine."Document Type");
        PurchLine2.SetRange("Document No.", MasterPurchLine."Document No.");
        PurchLine2.FindLast();

        if MasterLineMapMgt.IsMaster(Database::"Purchase Line", PurchLine2.SystemId) then
            LineNo := PurchLine2."Line No." + 10000
        else begin
            LineNo := PurchLine2."Line No." + 1; // fallback
            if PurchLine2.GetBySystemId(MasterLineMapMgt.GetLastInLineSystemId(Database::"Purchase Line", MasterPurchLine.SystemId)) then
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

        //IF ItemVariant.GetFromVariety(Item."No.", VRTBuffer."Variety 1 Value",
        if GetFromVariety(ItemVariant, Item."No.", VRTBuffer."Variety 1 Value",
                                     VRTBuffer."Variety 2 Value", VRTBuffer."Variety 3 Value",
                                     VRTBuffer."Variety 4 Value") then
            Error('Variant already exists');

        ItemVariant.Init;
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

    procedure SetupSalesPrice(var MasterSalesPrice: Record "Sales Price"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewSalesPrice: Record "Sales Price";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        NewSalesPrice := MasterSalesPrice;
        NewSalesPrice."Variant Code" := ItemVariant.Code;
        NewSalesPrice.Insert();

        MasterLineMapMgt.CreateMap(Database::"Sales Price", NewSalesPrice.SystemId, MasterSalesPrice.SystemId);

        RecRef.GetTable(NewSalesPrice);
        exit(Format(RecRef.RecordId));

    end;

    procedure SetupPurchPrice(var MasterPurchPrice: Record "Purchase Price"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewPurchPrice: Record "Purchase Price";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        NewPurchPrice := MasterPurchPrice;
        NewPurchPrice."Variant Code" := ItemVariant.Code;
        NewPurchPrice.Insert();

        MasterLineMapMgt.CreateMap(Database::"Purchase Price", NewPurchPrice.SystemId, MasterPurchPrice.SystemId);

        RecRef.GetTable(NewPurchPrice);
        exit(Format(RecRef.RecordId));
    end;

    procedure SetupRetailJournalLine(var MasterRetailJournalLine: Record "NPR Retail Journal Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewRetailJournalLine: Record "NPR Retail Journal Line";
        RetailJournalLine2: Record "NPR Retail Journal Line";
        RecRef: RecordRef;
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

        RetailJournalLine2.SetRange("No.", MasterRetailJournalLine."No.");
        RetailJournalLine2.FindLast();

        if MasterLineMapMgt.IsMaster(Database::"NPR Retail Journal Line", RetailJournalLine2.SystemId) then
            LineNo := RetailJournalLine2."Line No." + 10000
        else begin
            LineNo := RetailJournalLine2."Line No." + 1; // fallback
            if RetailJournalLine2.GetBySystemId(MasterLineMapMgt.GetLastInLineSystemId(Database::"NPR Retail Journal Line", MasterRetailJournalLine.SystemId)) then
                LineNo := RetailJournalLine2."Line No." + 1;
        end;

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

    procedure SetupItemReplenishment(var MasterItemReplenishment: Record "NPR Item Repl. by Store"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewItemReplenishment: Record "NPR Item Repl. by Store";
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        RecRef: RecordRef;
    begin
        //check if a new line is needed (is variant code filled?)
        NewItemReplenishment := MasterItemReplenishment;
        NewItemReplenishment."Variant Code" := ItemVariant.Code;
        NewItemReplenishment.Insert;

        MasterLineMapMgt.CreateMap(Database::"NPR Item Repl. by Store", NewItemReplenishment.SystemId, MasterItemReplenishment.SystemId);

        RecRef.GetTable(NewItemReplenishment);
        exit(Format(RecRef.RecordId));
    end;

    procedure SetupItemJnlLine(var MasterItemJnlLine: Record "Item Journal Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
    var
        NewItemJnlLine: Record "Item Journal Line";
        ItemJnlLine2: Record "Item Journal Line";
        RecRef: RecordRef;
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";
        LineNo: Integer;
    begin
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
        NewItemJnlLine.Insert;
        NewItemJnlLine.Validate(Quantity, 0);
        NewItemJnlLine.Validate("Variant Code", ItemVariant.Code);
        NewItemJnlLine.Modify();

        MasterLineMapMgt.CreateMap(Database::"Item Journal Line", NewItemJnlLine.SystemId, MasterItemJnlLine.SystemId);

        RecRef.GetTable(NewItemJnlLine);
        exit(Format(RecRef.RecordId));
    end;

    procedure GetNextVariantCode(ItemNo: Code[20]; Variant1Code: Code[50]; Variant2Code: Code[50]; Variant3Code: Code[50]; Variant4Code: Code[50]) NewVariantCode: Code[10]
    var
        VarietySetup: Record "NPR Variety Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        GetNewVariantCode(ItemNo, Variant1Code, Variant2Code, Variant3Code, Variant4Code, NewVariantCode);
        if NewVariantCode <> '' then
            exit(NewVariantCode);

        VarietySetup.Get();
        VarietySetup.TestField("Variant No. Series");

        exit(CopyStr(NoSeriesMgt.GetNextNo(VarietySetup."Variant No. Series", Today, true), 1, MaxStrLen(NewVariantCode)));
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

    procedure GetVarietyDesc(Variety: Code[20]; VarietyTable: Code[40]; VarietyValue: Code[50]; var TempDesc: Text[250])
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

    procedure InsertDefaultBarcode(ItemNo: Code[20]; VariantCode: Code[10]; CalledFromInsert: Boolean)
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

    procedure AddItemRef(ItemNo: Code[20]; VariantCode: Code[10])
    var
        NextCode: Code[20];
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
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
    end;

    procedure InsertItemRef(ItemNo: Code[20]; VariantCode: Code[10]; Barcode: Code[20]; CrossRefType: Option " ",Customer,Vendor,"Bar Code"; CrossRefTypeNo: Code[20])
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

            InputDialog.SetInput(1, Prefix, Text005);
            InputDialog.SetInput(2, CompNo, Text006);
            InputDialog.LookupMode(true);
            if InputDialog.RunModal = ACTION::LookupOK then;
            InputDialog.InputCode(1, Prefix);
            InputDialog.InputCode(2, CompNo);

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
    end;

    procedure ShowEAN13BarcodeNoSetup()
    var
        VarietySetup: Record "NPR Variety Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ItemRef1: Record "Item Reference";
        ItemRef2: Record "Item Reference";
        Filler: array[3] of Text;
        NextNo: array[3] of Text;
    begin
        VarietySetup.Get;
        if VarietySetup."EAN-Internal" <> 0 then begin
            ItemRef1.SetCurrentKey("Reference Type", "Reference No.");
            ItemRef1.SetRange("Reference Type", ItemRef1."Reference Type"::"Bar Code");
            ItemRef1.SetFilter("Reference No.", '%1', Format(VarietySetup."EAN-Internal") + '*');
            if ItemRef1.FindLast then;
            NextNo[1] := NoSeriesMgt.TryGetNextNo(VarietySetup."Internal EAN No. Series", Today);
            Filler[1] := PadStr('', 12 - StrLen(Format(VarietySetup."EAN-Internal")) - StrLen(NextNo[1]), '0')
        end;
        if VarietySetup."EAN-External" <> 0 then begin
            ItemRef2.SetCurrentKey("Reference Type", "Reference No.");
            ItemRef2.SetRange("Reference Type", ItemRef2."Reference Type"::"Bar Code");
            ItemRef2.SetFilter("Reference No.", '%1', Format(VarietySetup."EAN-External") + '*');
            if ItemRef2.FindLast then;
            NextNo[2] := NoSeriesMgt.TryGetNextNo(VarietySetup."External EAN No. Series", Today);
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

    procedure AssignBarcodes(Item: Record Item)
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
    end;

    procedure UpdateVariantDescriptions()
    var
        ItemVariant: Record "Item Variant";
        NoOfRecords: Integer;
        LineCount: Integer;
        Item: Record Item;
        Dia: Dialog;
    begin
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
    end;


    procedure SetupTransferLine(var MasterTransferLine: Record "Transfer Line"; Item: Record Item; ItemVariant: Record "Item Variant") RecordID: Text[250]
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
            LineNo := TransferLine2."Line No." + 1; // fallback
            if TransferLine2.GetBySystemId(MasterLineMapMgt.GetLastInLineSystemId(Database::"Transfer Line", MasterTransferLine.SystemId)) then
                LineNo := TransferLine2."Line No." + 1;
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

        ItemVar.FindFirst;
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

    [EventSubscriber(ObjectType::Codeunit, 6059972, 'GetNewVariantCode', '', true, true)]
    local procedure CreateVariantCodeFromNoSeries(ItemNo: Code[20]; Variant1Code: Code[20]; Variant2Code: Code[20]; Variant3Code: Code[20]; Variant4Code: Code[20]; var NewVariantCode: Code[10])
    var
        VarietySetup: Record "NPR Variety Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        VarietySetup.Get();
        if not (VarietySetup."Create Variant Code From" in ['', 'CreateVariantCodeFromNoSeries']) then
            exit;

        VarietySetup.TestField("Variant No. Series");
        NewVariantCode := CopyStr(NoSeriesMgt.GetNextNo(VarietySetup."Variant No. Series", Today, true), 1, MaxStrLen(NewVariantCode));
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