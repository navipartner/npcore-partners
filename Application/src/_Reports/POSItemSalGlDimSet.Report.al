report 6014442 "NPR POS Item Sal. Gl. Dim. Set"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    ApplicationArea = NPRRetail;
    Caption = 'POS Item Sales per Global Dimensions Set';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/POS Item Sales per Global Dim Set.rdlc';

    dataset
    {
        dataitem(DimensionSetEntry; "Dimension Set Entry")
        {
            DataItemTableView = sorting("Dimension Set ID", "Dimension Code");
            PrintOnlyIfDetail = true;

            column(Dimension_Set_ID; "Dimension Set ID") { }
            column(Dimension_Code; "Dimension Code") { }
            column(Dimension_Values_Names; _DimensionValuesNames) { }

            column(ValueSetText; _ValueSetText) { }
            column(RequestPageFilters; _RequestPageFilters) { }
            column(Company_Name; CompanyName()) { }

            dataitem(POSEntry; "NPR POS Entry")
            {
                DataItemLink = "Dimension Set ID" = field("Dimension Set ID");
                DataItemLinkReference = DimensionSetEntry;
                DataItemTableView = sorting("Entry No.");
                PrintOnlyIfDetail = true;
                RequestFilterFields = "Posting Date", "POS Unit No.";

                column(Entry_No; "Entry No.") { }
                column(Posting_Date; Format("Posting Date", 0, 1)) { }

                dataitem(POSEntrySalesLine; "NPR POS Entry Sales Line")
                {
                    DataItemLink = "POS Entry No." = field("Entry No.");
                    DataItemLinkReference = POSEntry;
                    DataItemTableView = sorting("POS Entry No.", "Line No.");
                    RequestFilterFields = "No.", "Location Code";

                    column(POS_Entry_No; "POS Entry No.") { }
                    column(No; "No.") { }
                    column(Line_No; "Line No.") { }
                    column(POS_SEL_Dimension_Set_ID; "Dimension Set ID") { }
                    column(Variant_Code; "Variant Code") { }
                    column(Description; Description) { }
                    column(Quantity; Quantity) { }
                    column(Amount_Excl_VAT; "Amount Excl. VAT") { }
                    column(Amount_Incl_VAT; "Amount Incl. VAT") { }
                    column(Location_Code; "Location Code") { }
                    column(POS_Unit_No; "POS Unit No.") { }
                    column(Unit_Cost; "Unit Cost") { }
                    column(Cost_Amount; Quantity * "Unit Cost") { }
                    column(Line_Discount_Amount_Excl_VAT; "Line Discount Amount Excl. VAT") { }
                    column(Line_Discount_Amount_Incl_VAT; "Line Discount Amount Incl. VAT") { }

                    trigger OnAfterGetRecord()
                    begin
                        if TempPOSEntrySalesLine.Get(POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No.") then
                            CurrReport.Skip();

                        TempPOSEntrySalesLine.Init();
                        TempPOSEntrySalesLine.TransferFields(POSEntrySalesLine);
                        TempPOSEntrySalesLine.Insert();
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                if not IsEntriesExists("Dimension Set ID") then
                    CurrReport.Skip();

                _DimensionValuesNames := GetDimensionValuesNames("Dimension Set ID");
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
                    field("Selected Dimensions Filter"; _SelectedDimFilterText)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Dimensions filter';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Dimensions filter field';

                        trigger OnAssistEdit()
                        begin
                            SetDimensionSelectionMultiple(3, REPORT::"NPR POS Item Sal. Gl. Dim. Set", _SelectedDimFilterText, _NumberOfSelected);
                        end;
                    }
                }
            }
        }
    }

    labels
    {
        ReportCaptionLbl = 'POS Item Sales per Global Dimensions Set';
        ItemNoCaptionLbl = 'Item No.';
        DescCaptionLbl = 'Description';
        PageCaptionLbl = 'Page';
        NoCaptionLbl = 'No.';
        SoldQtyCaptionLbl = 'Sold (Qty.)';
        VariantCodeCaptionLbl = 'Variant Code';
        LocationCodeCaptionLbl = 'Location Code';
        SalesAmtExclVATCaptionLbl = 'Sales Amt. Excl. VAT';
        SalesAmtInccVATCaptionLbl = 'Sales Amt. Incl. VAT';
        CostAmtCaptionLbl = 'Cost Amt.';
        UnitCostCaptionLbl = 'Unit Cost';
        POSUnitNoCaptionLbl = 'POS Unit No.';
        ContributionMarginCaptionLbl = 'Contribution Margin';
        CoverageMarginCaptionLbl = 'Coverage Margin';
        DiscountAmtCaptionLbl = 'Discount Amt.';
        ProfitPctCaptionLbl = 'Profit %';
        FiltersCaptionLbl = 'Filters:';
        ValueSetCaptionLbl = 'Value Set =';
        DimensionValueCaptionLbl = 'Dimension Value:';
        TotalValueSetCaptionLbl = 'Total for Value Set:';
        TotalDimensionValueCaptionLbl = 'Total for Dimension Value:';
    }

    trigger OnPreReport()
    begin
        CreateRequestPageFiltersText(_RequestPageFilters);

        if _SelectedDimFilterText = '' then
            CreateDimensionsFilterText(_SelectedDimFilterText);

        if _SelectedDimFilterText = '' then
            Error(_EmptyTableErrorLbl);

        _ValueSetText := _SelectedDimFilterText.Replace(';', ', ');
    end;

    local procedure SetDimensionSelectionMultiple(ObjectType: Integer; ObjectID: Integer; var SelectedDimText: Text[250]; var NumberOfSelected: Integer)
    var
        Dimension: Record Dimension;
        SelectedDimension: Record "Selected Dimension";
        TempDimSelectionBuf: Record "Dimension Selection Buffer" temporary;
        DimSelectionMultiple: Page "NPR Dim. Select.Mul.w.Filter";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Selected: Boolean;
    begin
        Clear(DimSelectionMultiple);
        GeneralLedgerSetup.Get();
        if Dimension.FindSet() then
            repeat
                if (GeneralLedgerSetup."Global Dimension 1 Code" = Dimension.Code) or (GeneralLedgerSetup."Global Dimension 2 Code" = Dimension.Code) then begin
                    Selected := SelectedDimension.Get(UserId, ObjectType, ObjectID, '', Dimension.Code);
                    if not Selected then
                        SelectedDimension.Init();
                    DimSelectionMultiple.InsertDimSelBuf(
                      Selected, Dimension.Code, Dimension.GetMLName(GlobalLanguage()), SelectedDimension."Dimension Value Filter");
                end;
            until Dimension.Next() = 0;
        if DimSelectionMultiple.RunModal() = ACTION::OK then begin
            DimSelectionMultiple.GetDimSelBuf(TempDimSelectionBuf);
            _DimensionSelectionBuffer.SetDimSelection(ObjectType, ObjectID, '', SelectedDimText, TempDimSelectionBuf);
            NumberOfSelected := TempDimSelectionBuf.Count();
        end;
    end;

    local procedure IsEntriesExists(DimensionSetID: Integer): Boolean
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        NumberOfRows: Integer;
    begin
        DimensionSetEntry.SetRange("Dimension Set ID", DimensionSetID);
        DimensionSetEntry.SetFilter("Dimension Code", _SelectedDimFilterText.Replace(';', '|'));

        if not DimensionSetEntry.FindSet() then
            exit;

        NumberOfRows := DimensionSetEntry.Count();

        if NumberOfRows = _NumberOfSelected then
            exit(true);
    end;

    local procedure GetDimensionValuesNames(DimensionSetID: Integer): Text
    var
        DimensionSetEntries: Query "Dimension Set Entries";
        DimensionValueNames: Text;
    begin
        DimensionSetEntries.SetRange(Dimension_Set_ID, DimensionSetID);
        DimensionSetEntries.SetFilter(Dimension_Code, _SelectedDimFilterText.Replace(';', '|'));

        DimensionSetEntries.Open();

        while DimensionSetEntries.Read() do
            DimensionValueNames += DimensionSetEntries.Dimension_Value_Name + ' / ';

        DimensionSetEntries.Close();

        exit(CopyStr(DimensionValueNames, 1, StrLen(DimensionValueNames) - 3));
    end;

    local procedure CreateRequestPageFiltersText(var FiltersText: Text)
    begin
        Clear(FiltersText);

        if POSEntry.GetFilters() <> '' then
            FiltersText := POSEntry.GetFilters();

        if (POSEntrySalesLine.GetFilters() <> '') and (FiltersText <> '') then
            FiltersText += ', ' + POSEntrySalesLine.GetFilters()
        else
            if (POSEntrySalesLine.GetFilters() <> '') then
                FiltersText := POSEntrySalesLine.GetFilters();
    end;

    local procedure CreateDimensionsFilterText(var DimensionsFilterText: Text[250])
    var
        Dimension: Record Dimension;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        _NumberOfSelected := 0;
        if not Dimension.FindSet() then
            exit;

        GeneralLedgerSetup.Get();
        repeat
            if (GeneralLedgerSetup."Global Dimension 1 Code" = Dimension.Code) or (GeneralLedgerSetup."Global Dimension 2 Code" = Dimension.Code) then begin
                DimensionsFilterText += Dimension.GetMLName(GlobalLanguage()) + ';';
                _NumberOfSelected += 1;
            end;
        until Dimension.Next() = 0;

        DimensionsFilterText := CopyStr(UpperCase((CopyStr(DimensionsFilterText, 1, StrLen(DimensionsFilterText) - 1))), 1, MaxStrLen(DimensionsFilterText));
    end;

    var
        TempPOSEntrySalesLine: Record "NPR POS Entry Sales Line" temporary;
        _DimensionSelectionBuffer: Record "Dimension Selection Buffer";
        _NumberOfSelected: Integer;
        _DimensionValuesNames: Text;
        _RequestPageFilters: Text;
        _SelectedDimFilterText: Text[250];
        _ValueSetText: Text;
        _EmptyTableErrorLbl: Label 'The report couldn''t be generated, because their is no records in Dimension table.';
}