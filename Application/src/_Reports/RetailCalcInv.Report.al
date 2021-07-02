report 6014663 "NPR Retail Calc. Inv."
{
    Caption = 'Retail Calculate Inventory';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") WHERE(Type = CONST(Inventory));
            RequestFilterFields = "No.", "Location Filter", "Bin Filter", "Date Filter";
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = FIELD("No."), "Variant Code" = FIELD("Variant Filter"), "Location Code" = FIELD("Location Filter"), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"), "Posting Date" = FIELD("Date Filter");
                DataItemTableView = SORTING("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");

                trigger OnAfterGetRecord()
                var
                    ItemVariant: Record "Item Variant";
                    ByBin: Boolean;
                    ExecuteLoop: Boolean;
                    InsertTempSKU: Boolean;
                begin
                    if not GetLocation("Location Code") then
                        CurrReport.Skip();

                    if ColumnDim <> '' then
                        TransferDim("Dimension Set ID");
                    if not "Drop Shipment" then
                        ByBin := Location."Bin Mandatory" and not Location."Directed Put-away and Pick";
                    if not SkipCycleSKU("Location Code", "Item No.", "Variant Code") then
                        if ByBin then begin
                            if not TempSKU.Get("Location Code", "Item No.", "Variant Code") then begin
                                InsertTempSKU := false;
                                if "Variant Code" = '' then
                                    InsertTempSKU := true
                                else
                                    if ItemVariant.Get("Item No.", "Variant Code") then
                                        InsertTempSKU := true;
                                if InsertTempSKU then begin
                                    TempSKU."Item No." := "Item No.";
                                    TempSKU."Variant Code" := "Variant Code";
                                    TempSKU."Location Code" := "Location Code";
                                    TempSKU.Insert();
                                    ExecuteLoop := true;
                                end;
                            end;
                            if ExecuteLoop then begin
                                WhseEntry.SetRange("Item No.", "Item No.");
                                WhseEntry.SetRange("Location Code", "Location Code");
                                WhseEntry.SetRange("Variant Code", "Variant Code");
                                if WhseEntry.Find('-') then
                                    if WhseEntry."Entry No." <> OldWhseEntry."Entry No." then begin
                                        OldWhseEntry := WhseEntry;
                                        repeat
                                            WhseEntry.SetRange("Bin Code", WhseEntry."Bin Code");
                                            if not ItemBinLocationIsCalculated(WhseEntry."Bin Code") then begin
                                                WhseEntry.CalcSums("Qty. (Base)");
                                                UpdateBuffer(WhseEntry."Bin Code", WhseEntry."Qty. (Base)");
                                            end;
                                            WhseEntry.Find('+');
                                            Item.CopyFilter("Bin Filter", WhseEntry."Bin Code");
                                        until WhseEntry.Next() = 0;
                                    end;
                            end;
                        end else
                            UpdateBuffer('', Quantity);
                end;

                trigger OnPreDataItem()
                begin
                    WhseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code");
                    Item.CopyFilter("Bin Filter", WhseEntry."Bin Code");
                    Item.CopyFilter("Date Filter", "Item Ledger Entry"."Posting Date");
                    if ColumnDim = '' then
                        TempDimBufIn.SetRange("Table ID", DATABASE::Item)
                    else
                        TempDimBufIn.SetRange("Table ID", DATABASE::"Item Ledger Entry");
                    TempDimBufIn.SetRange("Entry No.");
                    TempDimBufIn.DeleteAll();
                end;
            }
            dataitem("Warehouse Entry"; "Warehouse Entry")
            {
                DataItemLink = "Item No." = FIELD("No."), "Variant Code" = FIELD("Variant Filter"), "Location Code" = FIELD("Location Filter");

                trigger OnAfterGetRecord()
                begin
                    if not "Item Ledger Entry".IsEmpty then
                        CurrReport.Skip();   // Skip if item has any record in Item Ledger Entry.
                    Clear(TempQuantityOnHandBuffer);
                    TempQuantityOnHandBuffer."Item No." := "Item No.";
                    TempQuantityOnHandBuffer."Location Code" := "Location Code";
                    TempQuantityOnHandBuffer."Variant Code" := "Variant Code";

                    GetLocation("Location Code");
                    if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                        TempQuantityOnHandBuffer."Bin Code" := "Bin Code";
                    if not TempQuantityOnHandBuffer.Find() then
                        TempQuantityOnHandBuffer.Insert();   // Insert a zero quantity line.
                end;
            }
            dataitem(ItemWithNoTransaction; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                trigger OnAfterGetRecord()
                begin
                    if IncludeItemWithNoTransaction then
                        UpdateQuantityOnHandBuffer(Item."No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not HideValidationDialog then
                    Window.Update();
                TempSKU.DeleteAll();
            end;

            trigger OnPostDataItem()
            begin
                CalcPhysInvQtyAndInsertItemJnlLine();
            end;

            trigger OnPreDataItem()
            var
                ItemJnlBatch: Record "Item Journal Batch";
                ItemJnlTemplate: Record "Item Journal Template";
            begin
                if PostingDate = 0D then
                    Error(Text000);

                ItemJnlTemplate.Get(ItemJnlLine."Journal Template Name");
                ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
                if NextDocNo = '' then begin
                    if ItemJnlBatch."No. Series" <> '' then begin
                        ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
                        ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
                        if not ItemJnlLine.FindFirst() then
                            NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
                        ItemJnlLine.Init();
                    end;
                    if NextDocNo = '' then
                        Error(Text001);
                end;

                NextLineNo := 0;

                if not HideValidationDialog then
                    Window.Open(Text002, "No.");

                if not SkipDim then
                    SelectedDim.GetSelectedDim(UserId, 3, REPORT::"NPR Retail Calc. Inv.", '', TempSelectedDim);

                TempQuantityOnHandBuffer.Reset();
                TempQuantityOnHandBuffer.DeleteAll();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Posting Date"; PostingDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date for the posting of this batch job. By default, the working date is entered, but you can change it.';

                        trigger OnValidate()
                        begin
                            ValidatePostingDate();
                        end;
                    }
                    field(DocumentNo; NextDocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';
                    }
                    field(ItemsNotOnInventory; ZeroQty)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Items Not on Inventory.';
                        ToolTip = 'Specifies if journal lines should be created for items that are not on inventory, that is, items where the value in the Qty. (Calculated) field is 0.';

                        trigger OnValidate()
                        begin
                            if not ZeroQty then
                                IncludeItemWithNoTransaction := false;
                        end;
                    }
                    field("Include Item With No Transaction"; IncludeItemWithNoTransaction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include Item without Transactions';
                        ToolTip = 'Specifies if journal lines should be created for items that are not on inventory and are not used in any transactions.';

                        trigger OnValidate()
                        begin
                            if not IncludeItemWithNoTransaction then
                                exit;
                            if not ZeroQty then
                                Error(ItemNotOnInventoryErr);
                        end;
                    }
                    field(ByDimensions; ColumnDim)
                    {
                        ApplicationArea = Suite;
                        Caption = 'By Dimensions';
                        Editable = false;
                        ToolTip = 'Specifies the dimensions that you want the batch job to consider.';

                        trigger OnAssistEdit()
                        begin
                            DimSelectionBuf.SetDimSelectionMultiple(3, REPORT::"NPR Retail Calc. Inv.", ColumnDim);
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if PostingDate = 0D then
                PostingDate := WorkDate();
            ValidatePostingDate();
            ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"NPR Retail Calc. Inv.", '');
        end;
    }

    trigger OnPreReport()
    begin
        if SkipDim then
            ColumnDim := ''
        else
            DimSelectionBuf.CompareDimText(3, REPORT::"NPR Retail Calc. Inv.", '', ColumnDim, Text003);
        ZeroQtySave := ZeroQty;
    end;

    var
        TempDimBufIn: Record "Dimension Buffer" temporary;
        TempDimBufOut: Record "Dimension Buffer" temporary;
        DimSelectionBuf: Record "Dimension Selection Buffer";
        DimSetEntry: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        TempQuantityOnHandBuffer: Record "Inventory Buffer" temporary;
        ItemJnlBatch: Record "Item Journal Batch";
        ItemJnlLine: Record "Item Journal Line";
        Location: Record Location;
        SelectedDim: Record "Selected Dimension";
        TempSelectedDim: Record "Selected Dimension" temporary;
        SourceCodeSetup: Record "Source Code Setup";
        TempSKU: Record "Stockkeeping Unit" temporary;
        OldWhseEntry: Record "Warehouse Entry";
        WhseEntry: Record "Warehouse Entry";
        DimBufMgt: Codeunit "Dimension Buffer Management";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        AdjustPosQty: Boolean;
        HideValidationDialog: Boolean;
        IncludeItemWithNoTransaction: Boolean;
        ItemTrackingSplit: Boolean;
        SkipDim: Boolean;
        ZeroQty: Boolean;
        ZeroQtySave: Boolean;
        PhysInvtCountCode: Code[10];
        NextDocNo: Code[20];
        PostingDate: Date;
        NegQty: Decimal;
        PosQty: Decimal;
        Window: Dialog;
        NextLineNo: Integer;
        Text001: Label 'Enter the document no.';
        Text000: Label 'Enter the posting date.';
        ItemNotOnInventoryErr: Label 'Items Not on Inventory.';
        Text002: Label 'Processing items    #1##########';
        Text003: Label 'Retain Dimensions';
        Text004: Label 'You must not filter on dimensions if you calculate locations with %1 is %2.';
        CycleSourceType: Option " ",Item,SKU;
        ColumnDim: Text[250];

    procedure SetItemJnlLine(var NewItemJnlLine: Record "Item Journal Line")
    begin
        ItemJnlLine := NewItemJnlLine;
    end;

    local procedure ValidatePostingDate()
    begin
        ItemJnlBatch.Get(ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
        if ItemJnlBatch."No. Series" = '' then
            NextDocNo := ''
        else begin
            NextDocNo := NoSeriesMgt.GetNextNo(ItemJnlBatch."No. Series", PostingDate, false);
            Clear(NoSeriesMgt);
        end;
    end;

    local procedure InsertItemJnlLine(ItemNo: Code[20]; VariantCode2: Code[10]; DimEntryNo2: Integer; BinCode2: Code[20]; Quantity2: Decimal; PhysInvQuantity: Decimal)
    var
        Bin: Record Bin;
        DimValue: Record "Dimension Value";
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        WarehouseEntry: Record "Warehouse Entry";
        WarehouseEntry2: Record "Warehouse Entry";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        DimMgt: Codeunit DimensionManagement;
        NoBinExist: Boolean;
        OrderLineNo: Integer;
        EntryType: Option "Negative Adjmt.","Positive Adjmt.";
    begin
        if NextLineNo = 0 then begin
            ItemJnlLine.LockTable();
            ItemJnlLine.SetRange("Journal Template Name", ItemJnlLine."Journal Template Name");
            ItemJnlLine.SetRange("Journal Batch Name", ItemJnlLine."Journal Batch Name");
            if ItemJnlLine.FindLast() then
                NextLineNo := ItemJnlLine."Line No.";

            SourceCodeSetup.Get();
        end;
        NextLineNo := NextLineNo + 10000;

        if (Quantity2 <> 0) or ZeroQty then begin
            if (Quantity2 = 0) and Location."Bin Mandatory" and not Location."Directed Put-away and Pick"
            then
                if not Bin.Get(Location.Code, BinCode2) then
                    NoBinExist := true;

            ItemJnlLine.Init();
            ItemJnlLine."Line No." := NextLineNo;
            ItemJnlLine.Validate("Posting Date", PostingDate);
            if PhysInvQuantity >= Quantity2 then
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
            else
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
            ItemJnlLine.Validate("Document No.", NextDocNo);
            ItemJnlLine.Validate("Item No.", ItemNo);
            ItemJnlLine.Validate("Variant Code", VariantCode2);
            ItemJnlLine.Validate("Location Code", Location.Code);
            if not NoBinExist then
                ItemJnlLine.Validate("Bin Code", BinCode2)
            else
                ItemJnlLine.Validate("Bin Code", '');
            ItemJnlLine.Validate("Source Code", SourceCodeSetup."Phys. Inventory Journal");
            ItemJnlLine."Qty. (Phys. Inventory)" := PhysInvQuantity;
            ItemJnlLine."Phys. Inventory" := true;
            ItemJnlLine.Validate("Qty. (Calculated)", Quantity2);
            ItemJnlLine."Posting No. Series" := ItemJnlBatch."Posting No. Series";
            ItemJnlLine."Reason Code" := ItemJnlBatch."Reason Code";
            ItemJnlLine."Phys Invt Counting Period Code" := PhysInvtCountCode;
            ItemJnlLine."Phys Invt Counting Period Type" := CycleSourceType;

            if Location."Bin Mandatory" then
                ItemJnlLine."Dimension Set ID" := 0;
            ItemJnlLine."Shortcut Dimension 1 Code" := '';
            ItemJnlLine."Shortcut Dimension 2 Code" := '';

            ItemLedgEntry.Reset();
            ItemLedgEntry.SetCurrentKey("Item No.");
            ItemLedgEntry.SetRange("Item No.", ItemNo);
            if ItemLedgEntry.FindLast() then
                ItemJnlLine."Last Item Ledger Entry No." := ItemLedgEntry."Entry No."
            else
                ItemJnlLine."Last Item Ledger Entry No." := 0;

            ItemJnlLine.Insert(true);

            if Location.Code <> '' then
                if Location."Directed Put-away and Pick" then begin
                    WarehouseEntry.SetCurrentKey(
                      "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
                      "Lot No.", "Serial No.", "Entry Type");
                    WarehouseEntry.SetRange("Item No.", ItemJnlLine."Item No.");
                    WarehouseEntry.SetRange("Bin Code", Location."Adjustment Bin Code");
                    WarehouseEntry.SetRange("Location Code", ItemJnlLine."Location Code");
                    WarehouseEntry.SetRange("Variant Code", ItemJnlLine."Variant Code");
                    if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Positive Adjmt." then
                        EntryType := EntryType::"Negative Adjmt.";
                    if ItemJnlLine."Entry Type" = ItemJnlLine."Entry Type"::"Negative Adjmt." then
                        EntryType := EntryType::"Positive Adjmt.";
                    WarehouseEntry.SetRange("Entry Type", EntryType);
                    if WarehouseEntry.Find('-') then
                        repeat
                            WarehouseEntry.SetRange("Lot No.", WarehouseEntry."Lot No.");
                            WarehouseEntry.SetRange("Serial No.", WarehouseEntry."Serial No.");
                            WarehouseEntry.CalcSums("Qty. (Base)");

                            WarehouseEntry2.SetCurrentKey(
                              "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
                              "Lot No.", "Serial No.", "Entry Type");
                            WarehouseEntry2.CopyFilters(WarehouseEntry);
                            case EntryType of
                                EntryType::"Positive Adjmt.":
                                    WarehouseEntry2.SetRange("Entry Type", WarehouseEntry2."Entry Type"::"Negative Adjmt.");
                                EntryType::"Negative Adjmt.":
                                    WarehouseEntry2.SetRange("Entry Type", WarehouseEntry2."Entry Type"::"Positive Adjmt.");
                            end;
                            WarehouseEntry2.CalcSums("Qty. (Base)");
                            if Abs(WarehouseEntry2."Qty. (Base)") > Abs(WarehouseEntry."Qty. (Base)") then
                                WarehouseEntry."Qty. (Base)" := 0
                            else
                                WarehouseEntry."Qty. (Base)" := WarehouseEntry."Qty. (Base)" + WarehouseEntry2."Qty. (Base)";

                            if WarehouseEntry."Qty. (Base)" <> 0 then begin
                                if ItemJnlLine."Order Type" = ItemJnlLine."Order Type"::Production then
                                    OrderLineNo := ItemJnlLine."Order Line No.";
                                ReservEntry."Serial No." := WarehouseEntry."Serial No.";
                                ReservEntry."Lot No." := WarehouseEntry."Lot No.";
                                CreateReservEntry.CreateReservEntryFor(
                                  DATABASE::"Item Journal Line",
                                  ItemJnlLine."Entry Type".AsInteger(),
                                  ItemJnlLine."Journal Template Name",
                                  ItemJnlLine."Journal Batch Name",
                                  OrderLineNo,
                                  ItemJnlLine."Line No.",
                                  ItemJnlLine."Qty. per Unit of Measure",
                                  Abs(WarehouseEntry.Quantity),
                                  Abs(WarehouseEntry."Qty. (Base)"),
                                  ReservEntry);
                                if WarehouseEntry."Qty. (Base)" < 0 then             // only Date on positive adjustments
                                    CreateReservEntry.SetDates(WarehouseEntry."Warranty Date", WarehouseEntry."Expiration Date");
                                CreateReservEntry.CreateEntry(
                                  ItemJnlLine."Item No.",
                                  ItemJnlLine."Variant Code",
                                  ItemJnlLine."Location Code",
                                  ItemJnlLine.Description,
                                  0D,
                                  0D,
                                  0,
                                  ReservEntry."Reservation Status"::Prospect);
                            end;
                            WarehouseEntry.Find('+');
                            WarehouseEntry.SetRange("Lot No.");
                            WarehouseEntry.SetRange("Serial No.");
                        until WarehouseEntry.Next() = 0;
                end;

            if ColumnDim = '' then
                DimEntryNo2 := CreateDimFromItemDefault();

            if DimBufMgt.GetDimensions(DimEntryNo2, TempDimBufOut) then begin
                TempDimSetEntry.Reset();
                TempDimSetEntry.DeleteAll();
                if TempDimBufOut.Find('-') then begin
                    repeat
                        DimValue.Get(TempDimBufOut."Dimension Code", TempDimBufOut."Dimension Value Code");
                        TempDimSetEntry."Dimension Code" := TempDimBufOut."Dimension Code";
                        TempDimSetEntry."Dimension Value Code" := TempDimBufOut."Dimension Value Code";
                        TempDimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
                        if TempDimSetEntry.Insert() then;
                        ItemJnlLine."Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
                        DimMgt.UpdateGlobalDimFromDimSetID(ItemJnlLine."Dimension Set ID",
                          ItemJnlLine."Shortcut Dimension 1 Code", ItemJnlLine."Shortcut Dimension 2 Code");
                        ItemJnlLine.Modify();
                    until TempDimBufOut.Next() = 0;
                    TempDimBufOut.DeleteAll();
                end;
            end;
        end;
    end;

    local procedure InsertQuantityOnHandBuffer(ItemNo: Code[20]; LocationCode: Code[10])
    begin
        TempQuantityOnHandBuffer.Init();
        TempQuantityOnHandBuffer."Item No." := ItemNo;
        TempQuantityOnHandBuffer."Location Code" := LocationCode;
        TempQuantityOnHandBuffer.Insert(true);
    end;

    procedure InitializeRequest(NewPostingDate: Date; DocNo: Code[20]; ItemsNotOnInvt: Boolean)
    begin
        PostingDate := NewPostingDate;
        NextDocNo := DocNo;
        ZeroQty := ItemsNotOnInvt;
        if not SkipDim then
            ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"NPR Retail Calc. Inv.", '');
    end;

    local procedure TransferDim(DimSetID: Integer)
    begin
        DimSetEntry.SetRange("Dimension Set ID", DimSetID);
        if DimSetEntry.Find('-') then begin
            repeat
                if TempSelectedDim.Get(
                     UserId, 3, REPORT::"NPR Retail Calc. Inv.", '', DimSetEntry."Dimension Code")
                then
                    InsertDim(DATABASE::"Item Ledger Entry", DimSetID, DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code");
            until DimSetEntry.Next() = 0;
        end;
    end;

    local procedure CalcWhseQty(AdjmtBin: Code[20]; var PosQuantity: Decimal; var NegQuantity: Decimal)
    var
        WhseItemTrackingSetup: Record "Item Tracking Setup";
        WarehouseEntry: Record "Warehouse Entry";
        WarehouseEntry2: Record "Warehouse Entry";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        NoWhseEntry: Boolean;
        NoWhseEntry2: Boolean;
        WhseQuantity: Decimal;
    begin
        AdjustPosQty := false;
        ItemTrackingMgt.GetWhseItemTrkgSetup(TempQuantityOnHandBuffer."Item No.", WhseItemTrackingSetup);
        ItemTrackingSplit := WhseItemTrackingSetup."Serial No. Required" or WhseItemTrackingSetup."Lot No. Required";
        WarehouseEntry.SetCurrentKey(
          "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
          "Lot No.", "Serial No.", "Entry Type");

        WarehouseEntry.SetRange("Item No.", TempQuantityOnHandBuffer."Item No.");
        WarehouseEntry.SetRange("Location Code", TempQuantityOnHandBuffer."Location Code");
        WarehouseEntry.SetRange("Variant Code", TempQuantityOnHandBuffer."Variant Code");
        WarehouseEntry.CalcSums("Qty. (Base)");
        WhseQuantity := WarehouseEntry."Qty. (Base)";
        WarehouseEntry.SetRange("Bin Code", AdjmtBin);

        if WhseItemTrackingSetup."Serial No. Required" then begin
            WarehouseEntry.SetRange("Entry Type", WarehouseEntry."Entry Type"::"Positive Adjmt.");
            WarehouseEntry.CalcSums("Qty. (Base)");
            PosQuantity := WhseQuantity - WarehouseEntry."Qty. (Base)";
            WarehouseEntry.SetRange("Entry Type", WarehouseEntry."Entry Type"::"Negative Adjmt.");
            WarehouseEntry.CalcSums("Qty. (Base)");
            NegQuantity := WhseQuantity - WarehouseEntry."Qty. (Base)";
            WarehouseEntry.SetRange("Entry Type", WarehouseEntry."Entry Type"::Movement);
            WarehouseEntry.CalcSums("Qty. (Base)");
            if WarehouseEntry."Qty. (Base)" <> 0 then begin
                if WarehouseEntry."Qty. (Base)" > 0 then
                    PosQuantity := PosQuantity + WhseQuantity - WarehouseEntry."Qty. (Base)"
                else
                    NegQuantity := NegQuantity - WhseQuantity - WarehouseEntry."Qty. (Base)";
            end;

            WarehouseEntry.SetRange("Entry Type", WarehouseEntry."Entry Type"::"Positive Adjmt.");
            if WarehouseEntry.Find('-') then begin
                repeat
                    WarehouseEntry.SetRange("Serial No.", WarehouseEntry."Serial No.");
                    WarehouseEntry2.Reset();
                    WarehouseEntry2.SetCurrentKey(
                      "Item No.", "Bin Code", "Location Code", "Variant Code",
                      "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type");

                    WarehouseEntry2.CopyFilters(WarehouseEntry);
                    WarehouseEntry2.SetRange("Entry Type", WarehouseEntry2."Entry Type"::"Negative Adjmt.");
                    WarehouseEntry2.SetRange("Serial No.", WarehouseEntry."Serial No.");
                    if WarehouseEntry2.Find('-') then
                        repeat
                            PosQuantity := PosQuantity + 1;
                            NegQuantity := NegQuantity - 1;
                            NoWhseEntry := WarehouseEntry.Next() = 0;
                            NoWhseEntry2 := WarehouseEntry2.Next() = 0;
                        until NoWhseEntry2 or NoWhseEntry
                    else
                        AdjustPosQty := true;

                    if not NoWhseEntry and NoWhseEntry2 then
                        AdjustPosQty := true;

                    WarehouseEntry.Find('+');
                    WarehouseEntry.SetRange("Serial No.");
                until WarehouseEntry.Next() = 0;
            end;
        end else begin
            if WarehouseEntry.Find('-') then
                repeat
                    WarehouseEntry.SetRange("Lot No.", WarehouseEntry."Lot No.");
                    WarehouseEntry.CalcSums("Qty. (Base)");
                    if WarehouseEntry."Qty. (Base)" <> 0 then begin
                        if WarehouseEntry."Qty. (Base)" > 0 then
                            NegQuantity := NegQuantity - WarehouseEntry."Qty. (Base)"
                        else
                            PosQuantity := PosQuantity + WarehouseEntry."Qty. (Base)";
                    end;
                    WarehouseEntry.Find('+');
                    WarehouseEntry.SetRange("Lot No.");
                until WarehouseEntry.Next() = 0;
            if PosQuantity <> WhseQuantity then
                PosQuantity := WhseQuantity - PosQuantity;
            if NegQuantity <> -WhseQuantity then
                NegQuantity := WhseQuantity + NegQuantity;
        end;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure InitializePhysInvtCount(PhysInvtCountCode2: Code[10]; CountSourceType2: Option " ",Item,SKU)
    begin
        PhysInvtCountCode := PhysInvtCountCode2;
        CycleSourceType := CountSourceType2;
    end;

    local procedure SkipCycleSKU(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if CycleSourceType = CycleSourceType::Item then
            if SKU.ReadPermission then
                if SKU.Get(LocationCode, ItemNo, VariantCode) then
                    exit(true);
        exit(false);
    end;

    local procedure GetLocation(LocationCode: Code[10]): Boolean
    begin
        if LocationCode = '' then begin
            Clear(Location);
            exit(true);
        end;

        if Location.Code <> LocationCode then
            if not Location.Get(LocationCode) then
                exit(false);

        if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then begin
            if (Item.GetFilter("Global Dimension 1 Code") <> '') or
               (Item.GetFilter("Global Dimension 2 Code") <> '') or
               TempDimBufIn.FindFirst()
            then
                Error(Text004, Location.FieldCaption("Bin Mandatory"), Location."Bin Mandatory");
        end;

        exit(true);
    end;

    local procedure UpdateBuffer(BinCode: Code[20]; NewQuantity: Decimal)
    var
        DimEntryNo: Integer;
    begin
        if not HasNewQuantity(NewQuantity) then
            exit;
        if BinCode = '' then begin
            if ColumnDim <> '' then
                TempDimBufIn.SetRange("Entry No.", "Item Ledger Entry"."Dimension Set ID");
            DimEntryNo := DimBufMgt.FindDimensions(TempDimBufIn);
            if DimEntryNo = 0 then
                DimEntryNo := DimBufMgt.InsertDimensions(TempDimBufIn);
        end;
        if RetrieveBuffer(BinCode, DimEntryNo) then begin
            TempQuantityOnHandBuffer.Quantity := TempQuantityOnHandBuffer.Quantity + NewQuantity;
            TempQuantityOnHandBuffer.Modify();
        end else begin
            TempQuantityOnHandBuffer.Quantity := NewQuantity;
            TempQuantityOnHandBuffer.Insert();
        end;
    end;

    local procedure RetrieveBuffer(BinCode: Code[20]; DimEntryNo: Integer): Boolean
    begin
        TempQuantityOnHandBuffer.Reset();
        TempQuantityOnHandBuffer."Item No." := "Item Ledger Entry"."Item No.";
        TempQuantityOnHandBuffer."Variant Code" := "Item Ledger Entry"."Variant Code";
        TempQuantityOnHandBuffer."Location Code" := "Item Ledger Entry"."Location Code";
        TempQuantityOnHandBuffer."Dimension Entry No." := DimEntryNo;
        TempQuantityOnHandBuffer."Bin Code" := BinCode;
        exit(TempQuantityOnHandBuffer.Find());
    end;

    local procedure HasNewQuantity(NewQuantity: Decimal): Boolean
    begin
        exit((NewQuantity <> 0) or ZeroQty);
    end;

    local procedure ItemBinLocationIsCalculated(BinCode: Code[20]): Boolean
    begin
        TempQuantityOnHandBuffer.Reset();
        TempQuantityOnHandBuffer.SetRange("Item No.", "Item Ledger Entry"."Item No.");
        TempQuantityOnHandBuffer.SetRange("Variant Code", "Item Ledger Entry"."Variant Code");
        TempQuantityOnHandBuffer.SetRange("Location Code", "Item Ledger Entry"."Location Code");
        TempQuantityOnHandBuffer.SetRange("Bin Code", BinCode);
        exit(TempQuantityOnHandBuffer.Find('-'));
    end;

    procedure SetSkipDim(NewSkipDim: Boolean)
    begin
        SkipDim := NewSkipDim;
    end;

    local procedure UpdateQuantityOnHandBuffer(ItemNo: Code[20])
    var
        LocalLocation: Record Location;
    begin
        TempQuantityOnHandBuffer.SetRange("Item No.", ItemNo);
        if TempQuantityOnHandBuffer.IsEmpty() then begin
            Item.CopyFilter("Location Filter", LocalLocation.Code);
            LocalLocation.SetRange("Use As In-Transit", false);
            if (Item.GetFilter("Location Filter") <> '') and LocalLocation.FindSet() then
                repeat
                    InsertQuantityOnHandBuffer(ItemNo, LocalLocation.Code);
                until LocalLocation.Next() = 0
            else
                InsertQuantityOnHandBuffer(ItemNo, '');
        end;
    end;

    local procedure CalcPhysInvQtyAndInsertItemJnlLine()
    begin
        TempQuantityOnHandBuffer.Reset();
        if TempQuantityOnHandBuffer.FindSet() then begin
            repeat
                PosQty := 0;
                NegQty := 0;

                GetLocation(TempQuantityOnHandBuffer."Location Code");
                if Location."Directed Put-away and Pick" then
                    CalcWhseQty(Location."Adjustment Bin Code", PosQty, NegQty);

                if (NegQty - TempQuantityOnHandBuffer.Quantity <> TempQuantityOnHandBuffer.Quantity - PosQty) or ItemTrackingSplit then begin
                    if PosQty = TempQuantityOnHandBuffer.Quantity then
                        PosQty := 0;
                    if (PosQty <> 0) or AdjustPosQty then
                        InsertItemJnlLine(
                          TempQuantityOnHandBuffer."Item No.", TempQuantityOnHandBuffer."Variant Code", TempQuantityOnHandBuffer."Dimension Entry No.",
                          TempQuantityOnHandBuffer."Bin Code", TempQuantityOnHandBuffer.Quantity, PosQty);

                    if NegQty = TempQuantityOnHandBuffer.Quantity then
                        NegQty := 0;
                    if NegQty <> 0 then begin
                        if ((PosQty <> 0) or AdjustPosQty) and not ItemTrackingSplit then begin
                            NegQty := NegQty - TempQuantityOnHandBuffer.Quantity;
                            TempQuantityOnHandBuffer.Quantity := 0;
                            ZeroQty := true;
                        end;
                        if NegQty = -TempQuantityOnHandBuffer.Quantity then begin
                            NegQty := 0;
                            AdjustPosQty := true;
                        end;
                        InsertItemJnlLine(
                          TempQuantityOnHandBuffer."Item No.", TempQuantityOnHandBuffer."Variant Code", TempQuantityOnHandBuffer."Dimension Entry No.",
                          TempQuantityOnHandBuffer."Bin Code", TempQuantityOnHandBuffer.Quantity, NegQty);

                        ZeroQty := ZeroQtySave;
                    end;
                end else begin
                    PosQty := 0;
                    NegQty := 0;
                end;

                if (PosQty = 0) and (NegQty = 0) and not AdjustPosQty then
                    InsertItemJnlLine(
                      TempQuantityOnHandBuffer."Item No.", TempQuantityOnHandBuffer."Variant Code", TempQuantityOnHandBuffer."Dimension Entry No.",
                      TempQuantityOnHandBuffer."Bin Code", TempQuantityOnHandBuffer.Quantity, TempQuantityOnHandBuffer.Quantity);
            until TempQuantityOnHandBuffer.Next() = 0;
            TempQuantityOnHandBuffer.DeleteAll();
        end;
    end;

    procedure NPR_SetReportOptions(pZeroQty: Boolean; pPostingDate: Date; pHideValidationDialog: Boolean)
    begin
        ZeroQty := pZeroQty;
        HideValidationDialog := pHideValidationDialog;
        PostingDate := pPostingDate;
        ValidatePostingDate();
        ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"NPR Retail Calc. Inv.", '');
    end;

    local procedure CreateDimFromItemDefault() DimEntryNo: Integer
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetRange("No.", TempQuantityOnHandBuffer."Item No.");
        DefaultDimension.SetRange("Table ID", DATABASE::Item);
        if DefaultDimension.FindSet() then
            repeat
                InsertDim(DATABASE::Item, 0, DefaultDimension."Dimension Code", DefaultDimension."Dimension Value Code");
            until DefaultDimension.Next() = 0;

        DimEntryNo := DimBufMgt.InsertDimensions(TempDimBufIn);
        TempDimBufIn.SetRange("Table ID", DATABASE::Item);
        TempDimBufIn.DeleteAll();
    end;

    local procedure InsertDim(TableID: Integer; EntryNo: Integer; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        TempDimBufIn.Init();
        TempDimBufIn."Table ID" := TableID;
        TempDimBufIn."Entry No." := EntryNo;
        TempDimBufIn."Dimension Code" := DimCode;
        TempDimBufIn."Dimension Value Code" := DimValueCode;
        if TempDimBufIn.Insert() then;
    end;
}
