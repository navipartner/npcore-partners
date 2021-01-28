report 6014441 "NPR POS Item Sales with Dim."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/POS Item Sales with Dimensions.rdlc';
    Caption = 'POS Item Sales with Dimensions';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("POS Entry"; "NPR POS Entry")
        {
            DataItemTableView = SORTING("Entry No.");
            RequestFilterFields = "POS Unit No.", "Posting Date";
            dataitem("POS Sales Line"; "NPR POS Sales Line")
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

            trigger OnAfterGetRecord()
            var
                TempDimBuf: Record "Dimension Buffer" temporary;
                DimSetEntry: Record "Dimension Set Entry";
                POSSalesLine2: Record "NPR POS Sales Line";
                POSEntryQry: Query "NPR POS Entry with Sales Lines";
                DimensionBufferID: Integer;
            begin
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
                POSEntryQry.Open;
                while POSEntryQry.Read do begin
                    POSSalesLine2.Get(POSEntryQry.POS_Entry_No, POSEntryQry.Line_No);
                    TempDimBuf.DeleteAll;
                    if TempSelectedDim.FindSet() then
                        repeat
                            TempDimBuf.Init();
                            TempDimBuf."Table ID" := DATABASE::"NPR POS Sales Line";
                            TempDimBuf."Dimension Code" := TempSelectedDim."Dimension Code";
                            if DimSetEntry.Get(POSSalesLine2."Dimension Set ID", TempSelectedDim."Dimension Code") then
                                TempDimBuf."Dimension Value Code" := DimSetEntry."Dimension Value Code";
                            TempDimBuf.Insert();
                        until TempSelectedDim.Next() = 0;
                    DimensionBufferID := DimBufMgt.GetDimensionId(TempDimBuf);

                    POSSalesLineCons.SetRange("Planned Delivery Date", POSEntryQry.Posting_Date);
                    POSSalesLineCons.SetRange(Type, POSSalesLine2.Type);
                    POSSalesLineCons.SetRange("No.", POSSalesLine2."No.");
                    POSSalesLineCons.SetRange("Variant Code", POSSalesLine2."Variant Code");
                    POSSalesLineCons.SetRange("Location Code", POSSalesLine2."Location Code");
                    POSSalesLineCons.SetRange("POS Unit No.", POSSalesLine2."POS Unit No.");
                    POSSalesLineCons.SetRange("Dimension Set ID", DimensionBufferID);
                    if not POSSalesLineCons.FindFirst() then begin
                        POSSalesLineCons := POSSalesLine2;
                        POSSalesLineCons."Unit Cost (LCY)" := Round(POSSalesLine2."Unit Cost (LCY)" * POSSalesLine2.Quantity, Currency."Amount Rounding Precision");
                        POSSalesLineCons."Planned Delivery Date" := POSEntryQry.Posting_Date;
                        POSSalesLineCons."Dimension Set ID" := DimensionBufferID;
                        POSSalesLineCons.Insert();
                    end else begin
                        POSSalesLineCons."Quantity (Base)" := POSSalesLineCons."Quantity (Base)" + POSSalesLine2."Quantity (Base)";
                        POSSalesLineCons."Amount Excl. VAT (LCY)" := POSSalesLineCons."Amount Excl. VAT (LCY)" + POSSalesLine2."Amount Excl. VAT (LCY)";
                        POSSalesLineCons."Amount Incl. VAT (LCY)" := POSSalesLineCons."Amount Incl. VAT (LCY)" + POSSalesLine2."Amount Incl. VAT (LCY)";
                        POSSalesLineCons."Line Dsc. Amt. Excl. VAT (LCY)" := POSSalesLineCons."Line Dsc. Amt. Excl. VAT (LCY)" + POSSalesLine2."Line Dsc. Amt. Excl. VAT (LCY)";
                        POSSalesLineCons."Unit Cost (LCY)" := POSSalesLineCons."Unit Cost (LCY)" + Round(POSSalesLine2."Unit Cost (LCY)" * POSSalesLine2.Quantity, Currency."Amount Rounding Precision");
                        POSSalesLineCons.Modify();
                    end;
                end;
            end;
        }
        dataitem(AppliedFilterLoop; "Integer")
        {
            DataItemTableView = SORTING(Number);
            column(FilterFieldName; AppliedFilterBuffer.Name)
            {
            }
            column(FilterValue; AppliedFilterBuffer.Value)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    AppliedFilterBuffer.FindSet()
                else
                    AppliedFilterBuffer.Next();
            end;

            trigger OnPreDataItem()
            begin
                SetRange(Number, 1, AppliedFilterBuffer.Count);
            end;
        }
        dataitem(POSSalesLineCons; "NPR POS Sales Line")
        {
            DataItemTableView = SORTING("POS Entry No.", "Line No.");
            UseTemporary = true;
            column(LineNo; LineNo)
            {
            }
            column(ItemNo; "No.")
            {
            }
            column(VariantCode; "Variant Code")
            {
                IncludeCaption = true;
            }
            column(LocationCode; "Location Code")
            {
                IncludeCaption = true;
            }
            column(POSUnitNo; "POS Unit No.")
            {
                IncludeCaption = true;
            }
            column(Description; Description)
            {
                IncludeCaption = true;
            }
            column(QtyBase; "Quantity (Base)")
            {
                DecimalPlaces = 0 : 5;
            }
            column(SalesAmtLCY; "Amount Excl. VAT (LCY)")
            {
                DecimalPlaces = 2 : 2;
            }
            column(SalesAmtLCYInclVAT; "Amount Incl. VAT (LCY)")
            {
                DecimalPlaces = 2 : 2;
            }
            column(CostAmtLCY; "Unit Cost (LCY)")
            {
                DecimalPlaces = 2 : 2;
            }
            column(DiscountAmtLCY; "Line Dsc. Amt. Excl. VAT (LCY)")
            {
                DecimalPlaces = 2 : 2;
            }
            column(PostingDate; "Planned Delivery Date")
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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Dimensions field';

                        trigger OnAssistEdit()
                        begin
                            SetDimSelectionMultiple(3, REPORT::"NPR POS Item Sales with Dim.", ColumnDim);
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ColumnDim := DimSelectionBuf.GetDimSelectionText(3, REPORT::"NPR POS Item Sales with Dim.", '');
        end;
    }

    labels
    {
        AppliedFiltersLbl = 'Filters:';
        ContribMarginLbl = 'Contribution Margin';
        CostAmtLbl = 'Cost Amt.';
        CoverMarginLbl = 'Coverage Margin';
        DiscountAmtLbl = 'Discount Amt.';
        ItemNoLbl = 'Item No.';
        DateLbl = 'Date';
        SalesAmtLbl = 'Sales Amt. excl. VAT';
        SalesAmtInclVATLbl = 'Sales Amt. incl. VAT';
        SoldQtyLbl = 'Sold Qty.';
        UnitCostLbl = 'Unit Cost';
    }

    trigger OnPreReport()
    begin
        Currency.InitRoundingPrecision();
        SelectedDim.GetSelectedDim(UserId, 3, REPORT::"NPR POS Item Sales with Dim.", '', TempSelectedDim);
        GenerateDimSetIDFilter();
        GenerateAppliedFilterBuffer();
    end;

    var
        Currency: Record Currency;
        Dim: Record Dimension;
        DimSelectionBuf: Record "Dimension Selection Buffer";
        TempDimSetEntryBuffer: Record "Dimension Set Entry" temporary;
        DimValue: Record "Dimension Value";
        AppliedFilterBuffer: Record "Name/Value Buffer" temporary;
        SelectedDim: Record "Selected Dimension";
        TempSelectedDim: Record "Selected Dimension" temporary;
        DimBufMgt: Codeunit "Dimension Buffer Management";
        DimMgt: Codeunit DimensionManagement;
        LineNo: Integer;
        DimFilterLbl: Label 'Dimension: %1';
        NoEntriesWithinFilterErr: Label 'There are no entries within applied dimension filters.';
        FilterIsNotSupportedErr: Label 'You cannot set filter for field "%1" of table "%2" in this report.\Please contact system vendor if you want the report to support such filter.';
        ColumnDim: Text;
        DimSetFilter: Text;

    local procedure GenerateDimSetIDFilter()
    var
        DimSetEntry: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        FilterForBlankIncluded: Boolean;
    begin
        TempSelectedDim.SetFilter("Dimension Value Filter", '<>%1', '');
        if TempSelectedDim.FindSet() then begin
            DimMgt.GetDimSetIDsForFilter(TempSelectedDim."Dimension Code", TempSelectedDim."Dimension Value Filter");
            DimMgt.GetTempDimSetEntry(TempDimSetEntryBuffer);
            while not TempDimSetEntryBuffer.IsEmpty and (TempSelectedDim.Next <> 0) do begin
                FilterForBlankIncluded := FilterIncludesBlank(TempSelectedDim."Dimension Code", TempSelectedDim."Dimension Value Filter");
                DimSetEntry.SetRange("Dimension Code", TempSelectedDim."Dimension Code");
                DimSetEntry.SetFilter("Dimension Value Code", TempSelectedDim."Dimension Value Filter");
                DimSetEntry."Dimension Code" := TempSelectedDim."Dimension Code";
                DimSetEntry2.SetRange("Dimension Code", TempSelectedDim."Dimension Code");
                TempDimSetEntryBuffer.FindSet();
                repeat
                    DimSetEntry."Dimension Set ID" := TempDimSetEntryBuffer."Dimension Set ID";
                    if not DimSetEntry.Find() then begin
                        DimSetEntry2 := DimSetEntry;
                        if not FilterForBlankIncluded or (FilterForBlankIncluded and DimSetEntry2.Find) then
                            TempDimSetEntryBuffer.Delete();
                    end;
                until TempDimSetEntryBuffer.Next() = 0;
            end;

            if TempDimSetEntryBuffer.IsEmpty() then
                Error(NoEntriesWithinFilterErr);
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
        AppliedFilterBuffer.DeleteAll();
        FilterNo := 100;
        RecRef.GetTable("POS Entry");
        CheckAndAddRecFiltersToBuffer(RecRef, FilterNo);
        RecRef.GetTable("POS Sales Line");
        CheckAndAddRecFiltersToBuffer(RecRef, FilterNo);

        TempSelectedDim.SetFilter("Dimension Value Filter", '<>%1', '');
        if TempSelectedDim.FindSet() then
            repeat
                AddFilterToBuffer(StrSubstNo(DimFilterLbl, TempSelectedDim."Dimension Code"), TempSelectedDim."Dimension Value Filter", FilterNo);
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
                  ((RecRef.Number = DATABASE::"NPR POS Sales Line") and
                   (FldRef.Number in ["POS Sales Line".FieldNo("No."), "POS Sales Line".FieldNo("Location Code")])))
                then
                    Error(FilterIsNotSupportedErr, FldRef.Caption, RecRef.Caption);
                AddFilterToBuffer(FldRef.Caption, AppliedFilter, FilterNo);
            end;
        end;
    end;

    local procedure AddFilterToBuffer(FieldName: Text; AppliedFilter: Text; var FilterNo: Integer)
    begin
        if AppliedFilter = '' then
            exit;
        AppliedFilterBuffer.Init();
        AppliedFilterBuffer.ID := FilterNo;
        AppliedFilterBuffer.Name := CopyStr(FieldName, 1, MaxStrLen(AppliedFilterBuffer.Name));
        AppliedFilterBuffer.Value := CopyStr(AppliedFilter, 1, MaxStrLen(AppliedFilterBuffer.Value));
        AppliedFilterBuffer.Insert();
        FilterNo += 1;
    end;

    local procedure SetDimSelectionMultiple(ObjectType: Integer; ObjectID: Integer; var SelectedDimText: Text[250])
    var
        Dim: Record Dimension;
        TempDimSelectionBuf: Record "Dimension Selection Buffer" temporary;
        SelectedDim: Record "Selected Dimension";
        DimSelectionMultiple: Page "NPR Dim. Select.Mul.w.Filter";
        Selected: Boolean;
    begin
        Clear(DimSelectionMultiple);
        if Dim.FindSet() then
            repeat
                Selected := SelectedDim.Get(UserId, ObjectType, ObjectID, '', Dim.Code);
                if not Selected then
                    SelectedDim.Init();
                DimSelectionMultiple.InsertDimSelBuf(
                  Selected, Dim.Code, Dim.GetMLName(GlobalLanguage), SelectedDim."Dimension Value Filter");
            until Dim.Next = 0;

        if DimSelectionMultiple.RunModal = ACTION::OK then begin
            DimSelectionMultiple.GetDimSelBuf(TempDimSelectionBuf);
            DimSelectionBuf.SetDimSelection(ObjectType, ObjectID, '', SelectedDimText, TempDimSelectionBuf);
        end;
    end;
}

