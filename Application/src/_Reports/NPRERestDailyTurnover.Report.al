﻿report 6150660 "NPR NPRE: Rest. Daily Turnover"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/NPRE - Rest. Daily Turnover.rdlc';
    Caption = 'Restaurant Daily Turnover';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("POS Entry"; "NPR POS Entry")
        {
            DataItemTableView = SORTING("Entry No.");
            RequestFilterFields = "POS Unit No.", "Posting Date";
            dataitem("POS Sales Line"; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = FIELD("Entry No.");
                DataItemTableView = SORTING("POS Entry No.", "Line No.") WHERE(Type = CONST(Item));
                RequestFilterFields = "No.", "Location Code";

                trigger OnPreDataItem()
                begin
                    CurrReport.Break();
                end;
            }

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(ReportDataGenerationLoop; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(ShowTableNo; ShowTableNo)
            {
            }

            trigger OnAfterGetRecord()
            var
                TempDimBuf: Record "Dimension Buffer" temporary;
                DimSetEntry: Record "Dimension Set Entry";
                POSEntry2: Record "NPR POS Entry";
                POSSalesLine2: Record "NPR POS Entry Sales Line";
                POSEntryQry: Query "NPR POS Entry with Sales Lines";
                DimensionBufferID: Integer;
            begin
                POSEntry2.Reset();
                TempTableCounterBuf.Reset();
                TempTableCounterBuf.DeleteAll();

                if "POS Entry".GetFilter("Posting Date") <> '' then
                    POSEntryQry.SetFilter(Posting_Date, "POS Entry".GetFilter("Posting Date"));
                if "POS Entry".GetFilter("POS Unit No.") <> '' then
                    POSEntryQry.SetFilter(POS_Unit_No, "POS Entry".GetFilter("POS Unit No."));
                POSEntryQry.SetRange(Type, "POS Sales Line".Type::Item);
                if "POS Sales Line".GetFilter("No.") <> '' then
                    POSEntryQry.SetFilter(No, "POS Sales Line".GetFilter("No."));
                if "POS Sales Line".GetFilter("Location Code") <> '' then
                    POSEntryQry.SetFilter(Location_Code, "POS Sales Line".GetFilter("Location Code"));
                if DimSetFilter <> '' then
                    POSEntryQry.SetFilter(Dimension_Set_ID, DimSetFilter);
                POSEntryQry.Open();
                while POSEntryQry.Read() do begin
                    POSSalesLine2.Get(POSEntryQry.POS_Entry_No, POSEntryQry.Line_No);
                    TempDimBuf.DeleteAll();
                    if TempSelectedDim.FindSet() then
                        repeat
                            TempDimBuf.Init();
                            TempDimBuf."Table ID" := DATABASE::"NPR POS Entry Sales Line";
# pragma warning disable AA0139
                            TempDimBuf."Dimension Code" := TempSelectedDim."Dimension Code";
# pragma warning restore
                            if DimSetEntry.Get(POSSalesLine2."Dimension Set ID", TempSelectedDim."Dimension Code") then
                                TempDimBuf."Dimension Value Code" := DimSetEntry."Dimension Value Code";
                            TempDimBuf.Insert();
                        until TempSelectedDim.Next() = 0;
                    DimensionBufferID := DimBufMgt.GetDimensionId(TempDimBuf);

                    POSSalesLineCons.SetRange("Planned Delivery Date", POSEntryQry.Posting_Date);
                    POSSalesLineCons.SetRange("Dimension Set ID", DimensionBufferID);
                    if ShowTableNo then
                        POSSalesLineCons.SetRange("NPRE Seating Code", POSSalesLine2."NPRE Seating Code");
                    if not POSSalesLineCons.FindFirst() then begin
                        POSSalesLineCons := POSSalesLine2;
                        if not ShowTableNo then
                            POSSalesLineCons."NPRE Seating Code" := '';
                        POSSalesLineCons."Planned Delivery Date" := POSEntryQry.Posting_Date;
                        POSSalesLineCons."Dimension Set ID" := DimensionBufferID;
                        POSSalesLineCons."POS Period Register No." := 0;  //For number of guests running total
                        POSSalesLineCons."Item Entry No." := 0;  //For number of tables running total
                        POSSalesLineCons.Insert();
                    end else begin
                        POSSalesLineCons."Quantity (Base)" := POSSalesLineCons."Quantity (Base)" + POSSalesLine2."Quantity (Base)";
                        POSSalesLineCons."Amount Excl. VAT (LCY)" := POSSalesLineCons."Amount Excl. VAT (LCY)" + POSSalesLine2."Amount Excl. VAT (LCY)";
                        POSSalesLineCons."Amount Incl. VAT (LCY)" := POSSalesLineCons."Amount Incl. VAT (LCY)" + POSSalesLine2."Amount Incl. VAT (LCY)";
                        POSSalesLineCons."Line Dsc. Amt. Excl. VAT (LCY)" := POSSalesLineCons."Line Dsc. Amt. Excl. VAT (LCY)" + POSSalesLine2."Line Dsc. Amt. Excl. VAT (LCY)";
                    end;

                    POSEntry2.Get(POSSalesLine2."POS Entry No.");
                    if not POSEntry2.Mark() then begin
                        POSEntry2.Mark := true;
                        POSSalesLineCons."POS Period Register No." := POSSalesLineCons."POS Period Register No." + POSEntry2."NPRE Number of Guests";
                    end;
                    TempTableCounterBuf.Init();
                    TempTableCounterBuf."Business Unit Code" := POSSalesLine2."NPRE Seating Code";
                    TempTableCounterBuf."Entry No." := POSSalesLine2."POS Entry No.";
                    if not TempTableCounterBuf.Find() then begin
                        TempTableCounterBuf.Insert();
                        POSSalesLineCons."Item Entry No." += 1;
                    end;
                    POSSalesLineCons.Modify();
                end;
            end;
        }
        dataitem(AppliedFilterLoop; "Integer")
        {
            DataItemTableView = SORTING(Number);
            column(FilterFieldName; TempAppliedFilterBuffer.Name)
            {
            }
            column(FilterValue; TempAppliedFilterBuffer.Value)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    TempAppliedFilterBuffer.FindSet()
                else
                    TempAppliedFilterBuffer.Next();
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, TempAppliedFilterBuffer.Count());
            end;
        }
        dataitem(POSSalesLineCons; "NPR POS Entry Sales Line")
        {
            DataItemTableView = SORTING("POS Entry No.", "Line No.");
            UseTemporary = true;
            column(LineNo; LineNo)
            {
            }
            column(SeatingCode; "NPRE Seating Code")
            {
            }
            column(QtyBase; "Quantity (Base)")
            {
                DecimalPlaces = 0 : 5;
            }
            column(TurnoverAmt; "Amount Excl. VAT (LCY)")
            {
                DecimalPlaces = 2 : 2;
            }
            column(PostingDate; "Planned Delivery Date")
            {
            }
            column(NumberOfGuests; "POS Period Register No.")
            {
            }
            column(NumberOfTables; "Item Entry No.")
            {
            }
            column(DimSetID; "Dimension Set ID")
            {
            }
            dataitem(DimBuffer; "Dimension Buffer")
            {
                DataItemTableView = SORTING("Table ID", "Entry No.", "Dimension Code");
                UseTemporary = true;
                column(DimCode; "Dimension Code")
                {
                }
                column(DimName; Dim.Name)
                {
                }
                column(DimValueCode; "Dimension Value Code")
                {
                }
                column(DimValueName; DimValue.Name)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Dim.Get(DimBuffer."Dimension Code");
                    Dim.Name := Dim.GetMLName(GlobalLanguage);
                    if Dim.Name = '' then
                        Dim.Name := Dim.Code;
                    if not DimValue.Get(DimBuffer."Dimension Code", DimBuffer."Dimension Value Code") then
                        Clear(DimValue);
                    if DimValue.Name = '' then
                        DimValue.Name := DimValue.Code;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                LineNo += 1;
                DimBufMgt.RetrieveDimensions("Dimension Set ID", DimBuffer);
            end;

            trigger OnPreDataItem()
            begin
                LineNo := 0;
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
                    field("Show Dimensions"; ColumnDim)
                    {
                        Caption = 'Show Dimensions';
                        Editable = false;

                        ToolTip = 'Specifies the value of the Show Dimensions field';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        begin
                            SetDimSelectionMultiple(3, REPORT::"NPR NPRE: Rest. Daily Turnover", ColumnDim);
                        end;
                    }
                    field("Show Table No"; ShowTableNo)
                    {
                        Caption = 'Show Seating Code';

                        ToolTip = 'Specifies the value of the Show Seating Code field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"NPR NPRE: Rest. Daily Turnover", '');
        end;
    }

    labels
    {
        AppliedFiltersLbl = 'Filters:';
        AveragePerGuestLbl = 'Average per Guest';
        AveragePerTableLbl = 'Average per Sale';
        DateLbl = 'Date';
        NoOfGuestsLbl = 'No. of Guests';
        NoOfTablesLbl = 'No. of Sales';
        TableNoLbl = 'Table No.';
        TurnoverLbl = 'Turnover';
    }

    trigger OnPreReport()
    begin
        Currency.InitRoundingPrecision();
# pragma warning disable AA0139
        SelectedDim.GetSelectedDim(UserId, 3, REPORT::"NPR NPRE: Rest. Daily Turnover", '', TempSelectedDim);
# pragma warning restore
        GenerateDimSetIDFilter();
        GenerateAppliedFilterBuffer();
    end;

    var
        Currency: Record Currency;
        Dim: Record Dimension;
        DimSelectionBuf: Record "Dimension Selection Buffer";
        TempDimSetEntryBuffer: Record "Dimension Set Entry" temporary;
        DimValue: Record "Dimension Value";
        TempTableCounterBuf: Record "Entry No. Amount Buffer" temporary;
        TempAppliedFilterBuffer: Record "Name/Value Buffer" temporary;
        SelectedDim: Record "Selected Dimension";
        TempSelectedDim: Record "Selected Dimension" temporary;
        DimBufMgt: Codeunit "Dimension Buffer Management";
        DimMgt: Codeunit DimensionManagement;
        ShowTableNo: Boolean;
        LineNo: Integer;
        DimFilterTxt: Label 'Dimension: %1';
        NoEntriesWithinFilter: Label 'There are no entries within applied dimension filters.';
        FilterIsNotSupported: Label 'You cannot set filter for field "%1" of table "%2" in this report.\Please contact system vendor if you want the report to support such filter.';
        ColumnDim: Text[250];
        DimSetFilter: Text;

    local procedure GenerateDimSetIDFilter()
    var
        DimSetEntry: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        FilterForBlankIncluded: Boolean;
    begin
        TempSelectedDim.SetFilter("Dimension Value Filter", '<>%1', '');
        if TempSelectedDim.FindSet() then begin
# pragma warning disable AA0139
            DimMgt.GetDimSetIDsForFilter(TempSelectedDim."Dimension Code", TempSelectedDim."Dimension Value Filter");
# pragma warning restore
            DimMgt.GetTempDimSetEntry(TempDimSetEntryBuffer);
            while not TempDimSetEntryBuffer.IsEmpty() and (TempSelectedDim.Next() <> 0) do begin
# pragma warning disable AA0139
                FilterForBlankIncluded := FilterIncludesBlank(TempSelectedDim."Dimension Code", TempSelectedDim."Dimension Value Filter");
# pragma warning restore
                DimSetEntry.SetRange("Dimension Code", TempSelectedDim."Dimension Code");
                DimSetEntry.SetFilter("Dimension Value Code", TempSelectedDim."Dimension Value Filter");
# pragma warning disable AA0139
                DimSetEntry."Dimension Code" := TempSelectedDim."Dimension Code";
# pragma warning restore
                DimSetEntry2.SetRange("Dimension Code", TempSelectedDim."Dimension Code");
                TempDimSetEntryBuffer.FindSet();
                repeat
                    DimSetEntry."Dimension Set ID" := TempDimSetEntryBuffer."Dimension Set ID";
                    if not DimSetEntry.Find() then begin
                        DimSetEntry2 := DimSetEntry;
                        if not FilterForBlankIncluded or (FilterForBlankIncluded and DimSetEntry2.Find()) then
                            TempDimSetEntryBuffer.Delete();
                    end;
                until TempDimSetEntryBuffer.Next() = 0;
            end;

            if TempDimSetEntryBuffer.IsEmpty() then
                Error(NoEntriesWithinFilter);
        end;
        TempSelectedDim.SetRange("Dimension Value Filter");
        GetDimSetFilter();
    end;

    local procedure FilterIncludesBlank(DimCode: Code[20]; DimValueFilter: Text[250]): Boolean
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        TempDimSetEntry."Dimension Code" := DimCode;
        TempDimSetEntry."Dimension Value Code" := '';
        TempDimSetEntry.Insert();
        TempDimSetEntry.SetFilter("Dimension Value Code", DimValueFilter);
        exit(not TempDimSetEntry.IsEmpty());
    end;

    local procedure GetDimSetFilter()
    begin
        DimSetFilter := '';
        if not TempDimSetEntryBuffer.FindSet() then
            exit;
        DimSetFilter := Format(TempDimSetEntryBuffer."Dimension Set ID");
        if TempDimSetEntryBuffer.Next() <> 0 then
            repeat
                DimSetFilter += '|' + Format(TempDimSetEntryBuffer."Dimension Set ID");
            until TempDimSetEntryBuffer.Next() = 0;
    end;

    local procedure GenerateAppliedFilterBuffer()
    var
        RecRef: RecordRef;
        FilterNo: Integer;
    begin
        TempAppliedFilterBuffer.DeleteAll();
        FilterNo := 100;
        RecRef.GetTable("POS Entry");
        CheckAndAddRecFiltersToBuffer(RecRef, FilterNo);
        RecRef.GetTable("POS Sales Line");
        CheckAndAddRecFiltersToBuffer(RecRef, FilterNo);

        TempSelectedDim.SetFilter("Dimension Value Filter", '<>%1', '');
        if TempSelectedDim.FindSet() then
            repeat
                AddFilterToBuffer(StrSubstNo(DimFilterTxt, TempSelectedDim."Dimension Code"), TempSelectedDim."Dimension Value Filter", FilterNo);
            until TempSelectedDim.Next() = 0;
        TempSelectedDim.SetRange("Dimension Value Filter");
    end;

    local procedure CheckAndAddRecFiltersToBuffer(var RecRef: RecordRef; var FilterNo: Integer)
    var
        FldRef: FieldRef;
        i: Integer;
        AppliedFilter: Text;
    begin
        if RecRef.GetFilters = '' then
            exit;
        for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            AppliedFilter := FldRef.GetFilter;
            if AppliedFilter <> '' then begin
                if not (
                  ((RecRef.Number = DATABASE::"NPR POS Entry") and
                   (FldRef.Number in ["POS Entry".FieldNo("Posting Date"), "POS Entry".FieldNo("POS Unit No.")])) or
                  ((RecRef.Number = DATABASE::"NPR POS Entry Sales Line") and
                   (FldRef.Number in ["POS Sales Line".FieldNo("No."), "POS Sales Line".FieldNo("Location Code")])))
                then
                    Error(FilterIsNotSupported, FldRef.Caption, RecRef.Caption);
                AddFilterToBuffer(FldRef.Caption, AppliedFilter, FilterNo);
            end;
        end;
    end;

    local procedure AddFilterToBuffer(FieldName: Text; AppliedFilter: Text; var FilterNo: Integer)
    begin
        if AppliedFilter = '' then
            exit;
        TempAppliedFilterBuffer.Init();
        TempAppliedFilterBuffer.ID := FilterNo;
        TempAppliedFilterBuffer.Name := CopyStr(FieldName, 1, MaxStrLen(TempAppliedFilterBuffer.Name));
        TempAppliedFilterBuffer.Value := CopyStr(AppliedFilter, 1, MaxStrLen(TempAppliedFilterBuffer.Value));
        TempAppliedFilterBuffer.Insert();
        FilterNo += 1;
    end;

    local procedure SetDimSelectionMultiple(ObjectType: Integer; ObjectID: Integer; var SelectedDimText: Text[250])
    var
        Dimension: Record Dimension;
        TempDimSelectionBuf: Record "Dimension Selection Buffer" temporary;
        SelectedDimension: Record "Selected Dimension";
        DimSelectionMultiple: Page "NPR Dim. Select.Mul.w.Filter";
        Selected: Boolean;
    begin
        Clear(DimSelectionMultiple);
        if Dimension.FindSet() then
            repeat
                Selected := SelectedDimension.Get(UserId, ObjectType, ObjectID, '', Dimension.Code);
                if not Selected then
                    SelectedDimension.Init();
                DimSelectionMultiple.InsertDimSelBuf(
                  Selected, Dimension.Code, Dimension.GetMLName(GlobalLanguage), SelectedDimension."Dimension Value Filter");
            until Dimension.Next() = 0;

        if DimSelectionMultiple.RunModal() = ACTION::OK then begin
            DimSelectionMultiple.GetDimSelBuf(TempDimSelectionBuf);
            DimSelectionBuf.SetDimSelection(ObjectType, ObjectID, '', SelectedDimText, TempDimSelectionBuf);
        end;
    end;
}

