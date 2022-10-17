page 6014586 "NPR Salesperson Stats Retail"
{
    Extensible = False;
    Caption = 'Salesperson Statistics';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Salesperson/Purchaser";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("-Sale Quantity"; -"Sale Quantity")
                {

                    Caption = 'Sale (QTY)';
                    ToolTip = 'Specifies the value of the Sale (QTY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
                        POSEntrySalesLineList: Page "NPR POS Entry Sales Line List";
                    begin
                        SetItemLedgerEntryFilter(POSEntrySalesLine);
                        POSEntrySalesLineList.SetTableView(POSEntrySalesLine);
                        POSEntrySalesLineList.Editable(false);
                        POSEntrySalesLineList.RunModal();
                    end;
                }
                field("-LastYear Sale Quantity"; -"LastYear Sale Quantity")
                {

                    Caption = '-> Last year';
                    Visible = LSQTY;
                    ToolTip = 'Specifies the value of the -> Last year field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Amount"; "Sale Amount")
                {

                    Caption = 'Sale (LCY)';
                    ToolTip = 'Specifies the value of the Sale (LCY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        ValueEntry: Record "Value Entry";
                        AuxValueEntries: Page "NPR Aux. Value Entries";
                    begin
                        SetValueEntryFilter(ValueEntry);
                        AuxValueEntries.SetTableView(ValueEntry);
                        AuxValueEntries.Editable(false);
                        AuxValueEntries.RunModal();
                    end;
                }
                field("<Control61506191>"; -"LastYear Sale Amount")
                {

                    Caption = '-> Last year';
                    Visible = LSAmount;
                    ToolTip = 'Specifies the value of the -> Last year field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit Amount"; "Profit Amount")
                {

                    Caption = 'Profit (LCY)';
                    ToolTip = 'Specifies the value of the Profit (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("-LastYear Profit Amount"; -"LastYear Profit Amount")
                {

                    Caption = '-> Last year';
                    Visible = LPA;
                    ToolTip = 'Specifies the value of the -> Last year field';
                    ApplicationArea = NPRRetail;
                }
                field("<Control61506221>"; "Profit %")
                {

                    Caption = 'Profit %';
                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {

                    Caption = 'Code';
                    Visible = "LP%";
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Calc();
    end;

    trigger OnOpenPage()
    begin
        if (Periodestart = 0D) then
            Periodestart := Today();
        if (Periodeslut = 0D) then
            Periodeslut := Today();
    end;

    var
        "Sale Quantity": Decimal;
        "LastYear Sale Quantity": Decimal;
        "Sale Amount": Decimal;
        "LastYear Sale Amount": Decimal;
        "Profit Amount": Decimal;
        "LastYear Profit Amount": Decimal;
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        "Global Dimension 2 Filter": Code[20];
        ItemCategoryFilter: Code[20];
        Periodestart: Date;
        Periodeslut: Date;
        LastYear: Boolean;
        CalcLastYear: Text[50];
        ItemNoFilter: Code[20];
        HideEmpty: Boolean;
        [InDataSet]
        LSQty: Boolean;
        [InDataSet]
        LSAmount: Boolean;
        [InDataSet]
        LPA: Boolean;
        [InDataSet]
        "LP%": Boolean;

    internal procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemCategory: Code[20]; LastYearCalc: Text[50]; ItemFilter: Code[20])
    begin
        Rec."NPR Global Dimension 1 Filter" := GlobalDim1;
        "Global Dimension 2 Filter" := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        ItemCategoryFilter := ItemCategory;
        CalcLastYear := LastYearCalc;
        ItemNoFilter := ItemFilter;

        CurrPage.Update(false);
    end;

    internal procedure Calc()
    var
        ValueEntry: Record "Value Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        SetValueEntryFilter(ValueEntry);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(POSEntrySalesLine);
        POSEntrySalesLine.CalcSums(Quantity);

        "Sale Quantity" := POSEntrySalesLine.Quantity;
        "Sale Amount" := ValueEntry."Sales Amount (Actual)";
        "Profit Amount" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        if "Sale Amount" <> 0 then
            "Profit %" := "Profit Amount" / "Sale Amount" * 100
        else
            "Profit %" := 0;

        // Calc last year
        LastYear := true;

        SetValueEntryFilter(ValueEntry);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(POSEntrySalesLine);
        POSEntrySalesLine.CalcSums(Quantity);

        "LastYear Sale Quantity" := POSEntrySalesLine.Quantity;
        "LastYear Sale Amount" := ValueEntry."Sales Amount (Actual)";
        "LastYear Profit Amount" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        if "LastYear Sale Amount" <> 0 then
            "LastYear Profit %" := "LastYear Profit Amount" / "LastYear Sale Amount" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    internal procedure SetItemLedgerEntryFilter(var POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    begin
        POSEntrySalesLine.SetRange("Salesperson Code", Rec.Code);
        if not LastYear then
            POSEntrySalesLine.SetFilter("Entry Date", '%1..%2', Periodestart, Periodeslut)
        else
            POSEntrySalesLine.SetFilter("Entry Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemCategoryFilter <> '' then
            POSEntrySalesLine.SetRange("Item Category Code", ItemCategoryFilter)
        else
            POSEntrySalesLine.SetRange("Item Category Code");

        if ItemNoFilter <> '' then begin
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
            POSEntrySalesLine.SetRange("No.", ItemNoFilter)
        end else
            POSEntrySalesLine.SetRange("No.");

        if Rec."NPR Global Dimension 1 Filter" <> '' then
            POSEntrySalesLine.SetRange("Shortcut Dimension 1 Code", Rec."NPR Global Dimension 1 Filter")
        else
            POSEntrySalesLine.SetRange("Shortcut Dimension 1 Code");

        if "Global Dimension 2 Filter" <> '' then
            POSEntrySalesLine.SetRange("Shortcut Dimension 2 Code", "Global Dimension 2 Filter")
        else
            POSEntrySalesLine.SetRange("Shortcut Dimension 2 Code");
    end;

    internal procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Salespers./Purch. Code", Rec.Code);
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemNoFilter <> '' then
            ValueEntry.SetRange("Item No.", ItemNoFilter)
        else
            ValueEntry.SetRange("Item No.");

        //TODO:Temporary Aux Value Entry Reimplementation
        // if ItemCategoryFilter <> '' then
        //     ValueEntry.SetRange("NPR Item Category Code", ItemCategoryFilter)
        // else
        //     ValueEntry.SetRange("NPR Item Category Code");

        if Rec."NPR Global Dimension 1 Filter" <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Rec."NPR Global Dimension 1 Filter")
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if "Global Dimension 2 Filter" <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", "Global Dimension 2 Filter")
        else
            ValueEntry.SetRange("Global Dimension 2 Code");
    end;

    internal procedure InitForm()
    begin
        Rec.Reset();
        Rec."NPR Global Dimension 1 Filter" := '';
        "Global Dimension 2 Filter" := '';
        Periodestart := Today();
        Periodeslut := Today();
        ItemCategoryFilter := '';
    end;

    internal procedure ShowLastYear(Show: Boolean)
    begin
        LSQty := Show;
        LSAmount := Show;
        LPA := Show;
        "LP%" := Show;
    end;

    internal procedure ChangeEmptyFilter(): Boolean
    var
        Current: Record "Salesperson/Purchaser";
        "Count": Integer;
        Dlg: Dialog;
        SalesPerson: Record "Salesperson/Purchaser";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        txtDlg: Label 'Processing SalesPerson #1######## @2@@@@@@@@';
    begin
        HideEmpty := not HideEmpty;

        Rec.ClearMarks();
        if HideEmpty then begin
            Current := Rec;
            Dlg.Open(txtDlg);
            if SalesPerson.FindSet() then
                repeat
                    Count += 1;

                    Dlg.Update(1, SalesPerson.Name);
                    Dlg.Update(2, Round(Count / SalesPerson.Count() * 10000, 1, '='));
                    SetItemLedgerEntryFilter(POSEntrySalesLine);
                    POSEntrySalesLine.SetRange("Salesperson Code", SalesPerson.Code);
                    POSEntrySalesLine.CalcSums(Quantity);
                    if POSEntrySalesLine.Quantity <> 0 then begin
                        Rec.Get(SalesPerson.Code);
                        Rec.Mark(true);
                    end;
                until SalesPerson.Next() = 0;
            Dlg.Close();

            Rec.MarkedOnly(true);
            Rec := Current;
        end else begin
            Rec.MarkedOnly(false);
        end;

        CurrPage.Update(false);

        exit(HideEmpty);
    end;
}

