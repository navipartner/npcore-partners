codeunit 6014401 "NPR Dimension Mgt."
{
    var
        TempDimBuf1: Record "Dimension Buffer" temporary;
        TempDimBuf2: Record "Dimension Buffer" temporary;
        TempDimBuf3: Record "Dimension Buffer" temporary;
        DimMgt: Codeunit DimensionManagement;
        HasGotGLSetup: Boolean;
        GLSetupShortcutDimCode: array[8] of Code[20];
        Text002: Label 'This Shortcut Dimension is not defined in the %1.';
    #region GetGLSetup
    local procedure GetGLSetup()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not HasGotGLSetup then begin
            GLSetup.Get();
            GLSetupShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
            GLSetupShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
            GLSetupShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
            GLSetupShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
            GLSetupShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
            GLSetupShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
            GLSetupShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
            GLSetupShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";
            HasGotGLSetup := true;
        end;
    end;
    #endregion
    #region UpdateDocDefaultDim
    internal procedure UpdateNPRDefaultDim(TableID: Integer; RegisterNo: Code[10]; SalesTicketNo: Code[20]; Date2: Date; SaleType: Option; LineNo: Integer; No: Code[20]; var GlobalDim1Code: Code[20]; var GlobalDim2Code: Code[20])
    var
        NPRLineDimension: Record "NPR Line Dimension";
        RecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin
        GetGLSetup();
        NPRLineDimension.SetRange("Table ID", TableID);
        NPRLineDimension.SetRange("Register No.", RegisterNo);
        NPRLineDimension.SetRange("Sales Ticket No.", SalesTicketNo);
        NPRLineDimension.SetRange(Date, Date2);
        NPRLineDimension.SetRange("Line No.", LineNo);
        NPRLineDimension.SetRange("No.", No);
        NPRLineDimension.DeleteAll();
        GlobalDim1Code := '';
        GlobalDim2Code := '';
        if TempDimBuf2.FindSet() then begin
            repeat
                NPRLineDimension.Init();
                NPRLineDimension.Validate("Table ID", TableID);
                NPRLineDimension.Validate("Register No.", RegisterNo);
                NPRLineDimension.Validate("Sales Ticket No.", SalesTicketNo);
                NPRLineDimension.Validate(Date, Date2);
                NPRLineDimension.Validate("Line No.", LineNo);
                NPRLineDimension.Validate("No.", No);
                NPRLineDimension."Dimension Code" := TempDimBuf2."Dimension Code";
                NPRLineDimension."Dimension Value Code" := TempDimBuf2."Dimension Value Code";
                NPRLineDimension.Insert();
                RecRef.GetTable(NPRLineDimension);
                ChangeLogMgt.LogInsertion(RecRef);
                if NPRLineDimension."Dimension Code" = GLSetupShortcutDimCode[1] then
                    GlobalDim1Code := NPRLineDimension."Dimension Value Code";
                if NPRLineDimension."Dimension Code" = GLSetupShortcutDimCode[2] then
                    GlobalDim2Code := NPRLineDimension."Dimension Value Code";
            until TempDimBuf2.Next() = 0;
            TempDimBuf2.Reset();
            TempDimBuf2.DeleteAll();
        end;
    end;
    #endregion
    #region GetDefaultDim
    internal procedure GetDefaultDim(TableID: array[10] of Integer; No: array[10] of Code[20]; SourceCode: Code[20]; var GlobalDim1Code: Code[20]; var GlobalDim2Code: Code[20])
    var
        DefaultDimPriority1: Record "Default Dimension Priority";
        DefaultDimPriority2: Record "Default Dimension Priority";
        DefaultDim: Record "Default Dimension";
        i: Integer;
        j: Integer;
        NoFilter: array[2] of Code[20];
    begin
        GetGLSetup();
        TempDimBuf2.Reset();
        TempDimBuf2.DeleteAll();
        if TempDimBuf1.FindSet() then begin
            repeat
                TempDimBuf2.Init();
                TempDimBuf2 := TempDimBuf1;
                TempDimBuf2.Insert();
            until TempDimBuf1.Next() = 0;
        end;
        NoFilter[2] := '';
        for i := 1 to ArrayLen(TableID) do begin
            if (TableID[i] <> 0) and (No[i] <> '') then begin
                DefaultDim.SetRange("Table ID", TableID[i]);
                NoFilter[1] := No[i];
                for j := 1 to 2 do begin
                    DefaultDim.SetRange("No.", NoFilter[j]);
                    if DefaultDim.FindSet() then begin
                        repeat
                            if (DefaultDim."Dimension Value Code" <> '') or
                               (DefaultDim."Value Posting" = DefaultDim."Value Posting"::"Code Mandatory")
                            then begin
                                TempDimBuf2.SetRange("Dimension Code", DefaultDim."Dimension Code");
                                if not TempDimBuf2.FindSet() then begin
                                    TempDimBuf2.Init();
                                    TempDimBuf2."Table ID" := DefaultDim."Table ID";
                                    TempDimBuf2."Entry No." := 0;
                                    TempDimBuf2."Dimension Code" := DefaultDim."Dimension Code";
                                    TempDimBuf2."Dimension Value Code" := DefaultDim."Dimension Value Code";
                                    TempDimBuf2.Insert();
                                end else begin
                                    if (TempDimBuf2."Dimension Value Code" = '') and (DefaultDim."Dimension Value Code" <> '') then begin
                                        TempDimBuf2."Dimension Value Code" := DefaultDim."Dimension Value Code";
                                        TempDimBuf2.Modify();
                                    end else
                                        if DefaultDimPriority1.Get(SourceCode, DefaultDim."Table ID") then begin
                                            if DefaultDimPriority2.Get(SourceCode, TempDimBuf2."Table ID") then begin
                                                if DefaultDimPriority1.Priority < DefaultDimPriority2.Priority then begin
                                                    TempDimBuf3.Init();
                                                    TempDimBuf3 := TempDimBuf2;
                                                    TempDimBuf3."Table ID" := DefaultDim."Table ID";
                                                    TempDimBuf3."Entry No." := 0;
                                                    TempDimBuf3."Dimension Value Code" := DefaultDim."Dimension Value Code";
                                                    TempDimBuf3.Insert();
                                                    TempDimBuf2.Delete();
                                                    TempDimBuf2.Init();
                                                    TempDimBuf2 := TempDimBuf3;
                                                    TempDimBuf2.Insert();
                                                    TempDimBuf3.Delete();
                                                end;
                                            end else begin
                                                TempDimBuf3.Init();
                                                TempDimBuf3 := TempDimBuf2;
                                                TempDimBuf3."Table ID" := DefaultDim."Table ID";
                                                TempDimBuf3."Entry No." := 0;
                                                TempDimBuf3."Dimension Value Code" := DefaultDim."Dimension Value Code";
                                                TempDimBuf3.Insert();
                                                TempDimBuf2.Delete();
                                                TempDimBuf2.Init();
                                                TempDimBuf2 := TempDimBuf3;
                                                TempDimBuf2.Insert();
                                                TempDimBuf3.Delete();
                                            end;
                                        end;
                                end;
                                if GLSetupShortcutDimCode[1] = TempDimBuf2."Dimension Code" then
                                    GlobalDim1Code := TempDimBuf2."Dimension Value Code";
                                if GLSetupShortcutDimCode[2] = TempDimBuf2."Dimension Code" then
                                    GlobalDim2Code := TempDimBuf2."Dimension Value Code";
                            end;
                        until DefaultDim.Next() = 0;
                    end;
                end;
            end;
        end;
        TempDimBuf2.Reset();
    end;
    #endregion

    #region TypeToTableEksp
    internal procedure TypeToTableNPR(Type: Option "G/L",Item,"Item Group",Repair,,Payment,"Open/Close",BOM,Customer,Comment): Integer
    begin
        case Type of
            Type::"G/L":
                exit(DATABASE::"G/L Account");
            Type::Item:
                exit(DATABASE::Item);
            Type::"Item Group":
                exit(DATABASE::"Item Category");
            Type::Repair:
                Error('AL Error: Repair are not used in Core.');
            Type::Payment:
                exit(DATABASE::"NPR POS Payment Method");
            Type::"Open/Close":
                exit(DATABASE::"NPR Retail Comment");
            Type::BOM:
                exit(DATABASE::Item);
            Type::Customer:
                exit(DATABASE::Customer);
            Type::Comment:
                exit(DATABASE::"NPR Retail Comment");
        end;
    end;

    internal procedure LineTypeToTableNPR(POSSaleLineType: enum "NPR POS Sale Line Type"): Integer
    var
        TableId: Integer;
    begin
        case POSSaleLineType of
            POSSaleLineType::Item,
            POSSaleLineType::"BOM List":
                exit(Database::Item);
            POSSaleLineType::"Item Category":
                exit(Database::"Item Category");
            POSSaleLineType::"POS Payment":
                exit(Database::"NPR POS Payment Method");
            POSSaleLineType::"Customer Deposit":
                exit(Database::Customer);
            POSSaleLineType::Comment:
                exit(Database::"NPR Retail Comment");
            POSSaleLineType::Rounding,
            POSSaleLineType::"GL Payment",
            POSSaleLineType::"Issue Voucher":
                exit(Database::"G/L Account");
            else begin
                OnGetTableId(POSSaleLineType.AsInteger(), TableId);
                exit(TableId);
            end;

        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetTableId(POSSaleLineType: Integer; var TableId: Integer)
    begin
    end;
    #endregion

    #region DiscountTypeToTableNPR
    internal procedure DiscountTypeToTableNPR(Type: Option " ",Period,Mix,"Multi-Piece","Sales Card",BOM,,Rounding,Combination,Customer): Integer
    begin
        case Type of
            Type::" ":
                exit(0);
            Type::Period:
                exit(DATABASE::"NPR Period Discount");
            Type::Mix:
                exit(DATABASE::"NPR Mixed Discount");
            Type::"Multi-Piece":
                exit(DATABASE::"NPR Quantity Discount Header");
            Type::"Sales Card":
                exit(0);
            Type::BOM:
                exit(0);
            Type::Rounding:
                exit(0);
            Type::Combination:
                exit(0);
            Type::Customer:
                exit(0);
        end;
    end;
    #endregion
    #region DeleteNPRDim
    internal procedure DeleteNPRDim(TableID: Integer; RegisterNo: Code[10]; SalesTicketNo: Code[20]; Date2: Date; SaleType: Option; LineNo: Integer; No: Code[20])
    var
        NPRLineDimension: Record "NPR Line Dimension";
    begin
        //DeleteNPRDim
        NPRLineDimension.SetRange("Table ID", TableID);
        NPRLineDimension.SetRange("Register No.", RegisterNo);
        NPRLineDimension.SetRange("Sales Ticket No.", SalesTicketNo);
        NPRLineDimension.SetRange(Date, Date2);
        NPRLineDimension.SetRange("Line No.", LineNo);
        NPRLineDimension.SetRange("No.", No);
        NPRLineDimension.DeleteAll();
    end;
    #endregion
    #region LookupDimValueCode
    procedure LookupDimValueCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]): Boolean
    var
        DimVal: Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
    begin
        GetGLSetup();
        if GLSetupShortcutDimCode[FieldNumber] = '' then
            Error(Text002, GLSetup.TableCaption);
        DimVal.SetRange("Dimension Code", GLSetupShortcutDimCode[FieldNumber]);
        DimVal."Dimension Code" := GLSetupShortcutDimCode[FieldNumber];
        DimVal.Code := ShortcutDimCode;
        if PAGE.RunModal(0, DimVal) = ACTION::LookupOK then begin
            DimMgt.CheckDim(DimVal."Dimension Code");
            DimMgt.CheckDimValue(DimVal."Dimension Code", DimVal.Code);
            ShortcutDimCode := DimVal.Code;
            exit(true);
        end;
        exit(false);
    end;
    #endregion
    #region ValidateDimValueCode
    internal procedure ValidateDimValueCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
    end;
    #endregion
    #region SaveDefaultDim
    internal procedure SaveDefaultDim(TableID: Integer; No: Code[20]; FieldNumber: Integer; ShortcutDimCode: Code[20])
    begin
        DimMgt.SaveDefaultDim(TableID, No, FieldNumber, ShortcutDimCode);
    end;
    #endregion
    #region SaveEkspDim
    internal procedure SaveNPRDim(TableID: Integer; RegisterNo: Code[10]; SalesTicketNo: Code[20]; Date2: Date; SaleType: Option; LineNo: Integer; No: Code[20]; FieldNumber: Integer; ShortcutDimCode: Code[20])
    var
        NPRLineDim: Record "NPR Line Dimension";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        ChangeLogMgt: Codeunit "Change Log Management";
    begin
        GetGLSetup();
        if ShortcutDimCode <> '' then begin
            if NPRLineDim.Get(TableID, RegisterNo, SalesTicketNo, Date2, SaleType, LineNo, No, GLSetupShortcutDimCode[FieldNumber]) then begin
                xRecRef.GetTable(NPRLineDim);
                NPRLineDim.Validate("Dimension Value Code", ShortcutDimCode);
                NPRLineDim.Modify();
                /* This has been commented by NE, as it only updates
                  From Sale POS to Lines which i not applicable if you
                  want individual dimensions on lines.
                  NPRLineDim.UpdateLineDim(NPRLineDim,FALSE);
                */
                RecRef.GetTable(NPRLineDim);
                ChangeLogMgt.LogModification(RecRef);
            end else begin
                NPRLineDim.Init();
                NPRLineDim.Validate("Table ID", TableID);
                NPRLineDim.Validate("Register No.", RegisterNo);
                NPRLineDim.Validate("Sales Ticket No.", SalesTicketNo);
                NPRLineDim.Validate(Date, Date2);
                NPRLineDim.Validate("Line No.", LineNo);
                NPRLineDim.Validate("No.", No);
                NPRLineDim.Validate("Dimension Code", GLSetupShortcutDimCode[FieldNumber]);
                NPRLineDim.Validate("Dimension Value Code", ShortcutDimCode);
                NPRLineDim.Insert(true);
                NPRLineDim.UpdateLineDim(NPRLineDim, false);
                RecRef.GetTable(NPRLineDim);
                ChangeLogMgt.LogInsertion(RecRef);
            end;
        end else begin
            if NPRLineDim.Get(TableID, RegisterNo, SalesTicketNo, Date2, SaleType, LineNo, No, GLSetupShortcutDimCode[FieldNumber]) then begin
                xRecRef.GetTable(NPRLineDim);
                NPRLineDim."Dimension Value Code" := '';
                NPRLineDim.Modify();
                RecRef.GetTable(NPRLineDim);
                ChangeLogMgt.LogModification(RecRef);
                NPRLineDim.UpdateLineDim(NPRLineDim, true);
            end;
        end;

    end;
    #endregion
    #region SaveTempDim
    internal procedure SaveTempDim(FieldNumber: Integer; ShortcutDimCode: Code[20])
    begin
        GetGLSetup();
        TempDimBuf2.SetRange("Dimension Code", GLSetupShortcutDimCode[FieldNumber]);
        if ShortcutDimCode <> '' then begin
            if TempDimBuf2.FindFirst() then begin
                TempDimBuf2.Validate("Dimension Value Code", ShortcutDimCode);
                TempDimBuf2.Modify();
            end else begin
                TempDimBuf2.Init();
                TempDimBuf2.Validate("Table ID", 0);
                TempDimBuf2.Validate("Entry No.", 0);
                TempDimBuf2.Validate("Dimension Code", GLSetupShortcutDimCode[FieldNumber]);
                TempDimBuf2.Validate("Dimension Value Code", ShortcutDimCode);
                TempDimBuf2.Insert();
            end;
        end else
            if TempDimBuf2.FindFirst() then begin
                TempDimBuf2."Dimension Value Code" := '';
                TempDimBuf2.Modify();
            end;
    end;
    #endregion

    #region POS Entry Dimensions
    internal procedure CreateSeatingDimForPOSEntry(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry")
    begin
        CreatePosEntrySalesLineDim(POSEntrySalesLine,
                                    POSEntry,
                                    TypeToTableNPR(POSEntrySalesLine.Type), POSEntrySalesLine."No.",
# pragma warning disable AA0139
                                    DiscountTypeToTableNPR(POSEntrySalesLine."Discount Type"), POSEntrySalesLine."Discount Code",
# pragma warning restore
                                    DATABASE::"NPR NPRE Seating", POSEntrySalesLine."NPRE Seating Code",
                                    0, '');
    end;

    local procedure CreatePosEntrySalesLineDim(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry"; Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20]; Type3: Integer; No3: Code[20]; Type4: Integer; No4: Code[20])
    var
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        DimensionMgt: Codeunit DimensionManagement;
#IF NOT (BC17 or BC18 or BC19)
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        i: Integer;
#endif
    begin
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[3] := Type3;
        No[3] := No3;
        TableID[4] := Type4;
        No[4] := No4;

        POSEntrySalesLine."Shortcut Dimension 1 Code" := '';
        POSEntrySalesLine."Shortcut Dimension 2 Code" := '';

#IF NOT (BC17 or BC18 or BC19)
        for i := 1 to ArrayLen(TableID) do
            if (TableID[i] <> 0) and (No[i] <> '') then
                DimMgt.AddDimSource(DefaultDimSource, TableID[i], No[i]);
#endif

#IF NOT (BC17 or BC18 or BC19)
        POSEntrySalesLine."Dimension Set ID" :=
          DimensionMgt.GetDefaultDimID(
            DefaultDimSource, GetPOSSourceCode(POSEntry."POS Unit No."),
            POSEntrySalesLine."Shortcut Dimension 1 Code", POSEntrySalesLine."Shortcut Dimension 2 Code",
            POSEntry."Dimension Set ID", DATABASE::Customer);
#else
        POSEntrySalesLine."Dimension Set ID" :=
          DimensionMgt.GetDefaultDimID(
            TableID, No, GetPOSSourceCode(POSEntry."POS Unit No."),
            POSEntrySalesLine."Shortcut Dimension 1 Code", POSEntrySalesLine."Shortcut Dimension 2 Code",
            POSEntry."Dimension Set ID", DATABASE::Customer);
#endif
        DimensionMgt.UpdateGlobalDimFromDimSetID(POSEntrySalesLine."Dimension Set ID", POSEntrySalesLine."Shortcut Dimension 1 Code", POSEntrySalesLine."Shortcut Dimension 2 Code");
    end;

    local procedure GetPOSSourceCode(POSUnitNo: Code[10]) SourceCode: Code[10]
    var
        NPRPOSUnit: Record "NPR Pos Unit";
        NPRPOSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        SourceCode := '';

        if not NPRPOSUnit.Get(POSUnitNo) then
            exit;
        if not NPRPOSStore.Get(NPRPOSUnit."POS Store Code") then
            exit;
        if POSPostingProfile.Get(NPRPOSStore."POS Posting Profile") then
            SourceCode := POSPostingProfile."Source Code";
    end;
    #endregion
}

