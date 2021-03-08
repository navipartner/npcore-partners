page 6014586 "NPR Salesperson Stats Retail"
{
    Caption = 'Salesperson Statistics';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Salesperson/Purchaser";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("-""Sale Quantity"""; -"Sale Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Sale (QTY)';
                    ToolTip = 'Specifies the value of the Sale (QTY) field';

                    trigger OnDrillDown()
                    var
                        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
                        AuxItemLedgerEntries: Page "NPR Aux. Item Ledger Entries";
                    begin
                        SetItemLedgerEntryFilter(AuxItemLedgerEntry);
                        AuxItemLedgerEntries.SetTableView(AuxItemLedgerEntry);
                        AuxItemLedgerEntries.Editable(false);
                        AuxItemLedgerEntries.RunModal;
                    end;
                }
                field("-""LastYear Sale Quantity"""; -"LastYear Sale Quantity")
                {
                    ApplicationArea = All;
                    Caption = '-> Last year';
                    Visible = LSQTY;
                    ToolTip = 'Specifies the value of the -> Last year field';
                }
                field("Sale Amount"; "Sale Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Sale (LCY)';
                    ToolTip = 'Specifies the value of the Sale (LCY) field';

                    trigger OnDrillDown()
                    var
                        AuxValueEntry: Record "NPR Aux. Value Entry";
                        AuxValueEntries: Page "NPR Aux. Value Entries";
                    begin
                        SetValueEntryFilter(AuxValueEntry);
                        AuxValueEntries.SetTableView(AuxValueEntry);
                        AuxValueEntries.Editable(false);
                        AuxValueEntries.RunModal;
                    end;
                }
                field("<Control61506191>"; -"LastYear Sale Amount")
                {
                    ApplicationArea = All;
                    Caption = '-> Last year';
                    Visible = LSAmount;
                    ToolTip = 'Specifies the value of the -> Last year field';
                }
                field("Profit Amount"; "Profit Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Profit (LCY)';
                    ToolTip = 'Specifies the value of the Profit (LCY) field';
                }
                field("-""LastYear Profit Amount"""; -"LastYear Profit Amount")
                {
                    ApplicationArea = All;
                    Caption = '-> Last year';
                    Visible = LPA;
                    ToolTip = 'Specifies the value of the -> Last year field';
                }
                field("<Control61506221>"; "Profit %")
                {
                    ApplicationArea = All;
                    Caption = 'Profit %';
                    ToolTip = 'Specifies the value of the Profit % field';
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    Visible = "LP%";
                    ToolTip = 'Specifies the value of the Code field';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Calc;
    end;

    trigger OnOpenPage()
    begin
        if (Periodestart = 0D) then
            Periodestart := Today;
        if (Periodeslut = 0D) then
            Periodeslut := Today;
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
        "Global Dimension 1 Filter": Code[20];
        "Global Dimension 2 Filter": Code[20];
        ItemCategoryFilter: Code[20];
        Periodestart: Date;
        Periodeslut: Date;
        LastYear: Boolean;
        ShowSameWeekday: Boolean;
        DateFilterLastYear: Text[50];
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

    procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemCategory: Code[20]; LastYearCalc: Text[50]; ItemFilter: Code[20])
    begin
        Rec."NPR Global Dimension 1 Filter" := GlobalDim1;
        "Global Dimension 2 Filter" := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        ItemCategoryFilter := ItemCategory;
        CalcLastYear := LastYearCalc;
        ItemNoFilter := ItemFilter;

        CurrPage.Update;
    end;

    procedure Calc()
    var
        AuxValueEntry: Record "NPR Aux. Value Entry";
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        SetValueEntryFilter(AuxValueEntry);
        AuxValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(AuxItemLedgerEntry);
        AuxItemLedgerEntry.CalcSums(Quantity);

        "Sale Quantity" := AuxItemLedgerEntry.Quantity;
        "Sale Amount" := AuxValueEntry."Sales Amount (Actual)";
        "Profit Amount" := AuxValueEntry."Sales Amount (Actual)" + AuxValueEntry."Cost Amount (Actual)";
        if "Sale Amount" <> 0 then
            "Profit %" := "Profit Amount" / "Sale Amount" * 100
        else
            "Profit %" := 0;

        // Calc last year
        LastYear := true;

        SetValueEntryFilter(AuxValueEntry);
        AuxValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(AuxItemLedgerEntry);
        AuxItemLedgerEntry.CalcSums(Quantity);

        "LastYear Sale Quantity" := AuxItemLedgerEntry.Quantity;
        "LastYear Sale Amount" := AuxValueEntry."Sales Amount (Actual)";
        "LastYear Profit Amount" := AuxValueEntry."Sales Amount (Actual)" + AuxValueEntry."Cost Amount (Actual)";
        if "LastYear Sale Amount" <> 0 then
            "LastYear Profit %" := "LastYear Profit Amount" / "LastYear Sale Amount" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    procedure SetItemLedgerEntryFilter(var AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry")
    begin
        AuxItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
        AuxItemLedgerEntry.SetRange("Salespers./Purch. Code", Rec.Code);
        if not LastYear then
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemCategoryFilter <> '' then
            AuxItemLedgerEntry.SetRange("Item Category Code", ItemCategoryFilter)
        else
            AuxItemLedgerEntry.SetRange("Item Category Code");

        if ItemNoFilter <> '' then
            AuxItemLedgerEntry.SetRange("Item No.", ItemNoFilter)
        else
            AuxItemLedgerEntry.SetRange("Item No.");

        if Rec."NPR Global Dimension 1 Filter" <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code", "NPR Global Dimension 1 Filter")
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if "Global Dimension 2 Filter" <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code", "Global Dimension 2 Filter")
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure SetValueEntryFilter(var AuxValueEntry: Record "NPR Aux. Value Entry")
    begin
        AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
        AuxValueEntry.SetRange("Salespers./Purch. Code", Code);
        if not LastYear then
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemNoFilter <> '' then
            AuxValueEntry.SetRange("Item No.", ItemNoFilter)
        else
            AuxValueEntry.SetRange("Item No.");

        if ItemCategoryFilter <> '' then
            AuxValueEntry.SetRange("Item Category Code", ItemCategoryFilter)
        else
            AuxValueEntry.SetRange("Item Category Code");

        if "NPR Global Dimension 1 Filter" <> '' then
            AuxValueEntry.SetRange("Global Dimension 1 Code", "NPR Global Dimension 1 Filter")
        else
            AuxValueEntry.SetRange("Global Dimension 1 Code");

        if "Global Dimension 2 Filter" <> '' then
            AuxValueEntry.SetRange("Global Dimension 2 Code", "Global Dimension 2 Filter")
        else
            AuxValueEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure InitForm()
    begin
        Rec.Reset();
        Rec."NPR Global Dimension 1 Filter" := '';
        "Global Dimension 2 Filter" := '';
        Periodestart := Today;
        Periodeslut := Today;
        ItemCategoryFilter := '';
    end;

    procedure ShowLastYear(Show: Boolean)
    begin
        LSQty := Show;
        LSAmount := Show;
        LPA := Show;
        "LP%" := Show;
    end;

    procedure ChangeEmptyFilter(): Boolean
    var
        Current: Record "Salesperson/Purchaser";
        "Count": Integer;
        Dlg: Dialog;
        SalesPerson: Record "Salesperson/Purchaser";
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        txtDlg: Label 'Processing SalesPerson #1######## @2@@@@@@@@';
    begin
        HideEmpty := not HideEmpty;

        Rec.ClearMarks;
        if HideEmpty then begin
            Current := Rec;
            Dlg.Open(txtDlg);
            if SalesPerson.FindSet() then
                repeat
                    Count += 1;

                    Dlg.Update(1, SalesPerson.Name);
                    Dlg.Update(2, Round(Count / SalesPerson.Count * 10000, 1, '='));
                    SetItemLedgerEntryFilter(AuxItemLedgerEntry);
                    AuxItemLedgerEntry.SetRange("Salespers./Purch. Code", SalesPerson.Code);
                    AuxItemLedgerEntry.CalcSums(Quantity);
                    if AuxItemLedgerEntry.Quantity <> 0 then begin
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

        CurrPage.Update();

        exit(HideEmpty);
    end;
}

