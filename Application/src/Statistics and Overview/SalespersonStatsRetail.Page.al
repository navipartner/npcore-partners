page 6014586 "NPR Salesperson Stats Retail"
{
    // NPR4.21/TS/20160225  CASE 226010 Changed from ListPart to CardPart
    // NPR5.31/BR/20172021  CASE 272890 Changed from CardPart to Card (for export to Excel) and made non-editable
    // NPR5.55/BHR /20200724 CASE 361515 Comment Key not used in AL

    Caption = 'Salesperson Statistics';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = Card;
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
                field(Name; Name)
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
                        ItemLedgerEntry: Record "Item Ledger Entry";
                        ItemLedgerEntryForm: Page "Item Ledger Entries";
                    begin

                        SetItemLedgerEntryFilter(ItemLedgerEntry);
                        ItemLedgerEntryForm.SetTableView(ItemLedgerEntry);
                        ItemLedgerEntryForm.Editable(false);
                        ItemLedgerEntryForm.RunModal;
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
                        ValueEntry: Record "Value Entry";
                        ValueEntryForm: Page "Value Entries";
                    begin

                        SetValueEntryFilter(ValueEntry);
                        ValueEntryForm.SetTableView(ValueEntry);
                        ValueEntryForm.Editable(false);
                        ValueEntryForm.RunModal;
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

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Calc;
    end;

    trigger OnOpenPage()
    begin

        if (Periodestart = 0D) then Periodestart := Today;
        if (Periodeslut = 0D) then Periodeslut := Today;
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
        ItemGroupFilter: Code[20];
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

    procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemGroup: Code[20]; LastYearCalc: Text[50]; ItemFilter: Code[20])
    begin
        //SetFilter()
        "NPR Global Dimension 1 Filter" := GlobalDim1;
        "Global Dimension 2 Filter" := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        ItemGroupFilter := ItemGroup;
        CalcLastYear := LastYearCalc;
        ItemNoFilter := ItemFilter;

        CurrPage.Update(false);
    end;

    procedure Calc()
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        //Calc()
        SetValueEntryFilter(ValueEntry);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "Sale Quantity" := ItemLedgerEntry.Quantity;
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

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);
        // ItemLedgerEntry."Item No."
        // ValueEntry."Item No."
        //

        "LastYear Sale Quantity" := ItemLedgerEntry.Quantity;
        "LastYear Sale Amount" := ValueEntry."Sales Amount (Actual)";
        "LastYear Profit Amount" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        if "LastYear Sale Amount" <> 0 then
            "LastYear Profit %" := "LastYear Profit Amount" / "LastYear Sale Amount" * 100
        else
            "LastYear Profit %" := 0;

        LastYear := false;
    end;

    procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        //SetItemLedgerEntryFilter
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("NPR Salesperson Code", Code);
        //ItemLedgerEntry.SETFILTER( "Posting Date", DateFilter );
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemGroupFilter <> '' then
            ItemLedgerEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
        else
            ItemLedgerEntry.SetRange("NPR Item Group No.");

        if ItemNoFilter <> '' then
            ItemLedgerEntry.SetRange("Item No.", ItemNoFilter)
        else
            ItemLedgerEntry.SetRange("Item No.");

        if "NPR Global Dimension 1 Filter" <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", "NPR Global Dimension 1 Filter")
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if "Global Dimension 2 Filter" <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", "Global Dimension 2 Filter")
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        //SetValueEntryFilter
        //-NPR5.55 [361515]
        //ValueEntry.SETCURRENTKEY( "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code" );
        //+NPR5.55 [361515]
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Salespers./Purch. Code", Code);
        //ValueEntry.SETFILTER( "Posting Date", DateFilter );
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemNoFilter <> '' then
            ValueEntry.SetRange("Item No.", ItemNoFilter)
        else
            ValueEntry.SetRange("Item No.");

        if ItemGroupFilter <> '' then
            ValueEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
        else
            ValueEntry.SetRange("NPR Item Group No.");

        if "NPR Global Dimension 1 Filter" <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", "NPR Global Dimension 1 Filter")
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if "Global Dimension 2 Filter" <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", "Global Dimension 2 Filter")
        else
            ValueEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure InitForm()
    begin
        //InitForm()
        Reset;
        "NPR Global Dimension 1 Filter" := '';
        "Global Dimension 2 Filter" := '';
        Periodestart := Today;
        Periodeslut := Today;
        ItemGroupFilter := '';
    end;

    procedure ShowLastYear(Show: Boolean)
    begin
        //CurrForm."LastYear Sale Quantity".VISIBLE( Show );
        //CurrForm."LastYear Sale Amount".VISIBLE( Show );
        //CurrForm."LastYear Profit Amount".VISIBLE( Show );
        //CurrForm."LastYear Profit %".VISIBLE( Show );

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
        ItemLedgerEntry: Record "Item Ledger Entry";
        txtDlg: Label 'Processing SalesPerson #1######## @2@@@@@@@@';
    begin
        //ChangeEmptyFilter()
        HideEmpty := not HideEmpty;

        ClearMarks;
        if HideEmpty then begin
            Current := Rec;
            Dlg.Open(txtDlg);
            if SalesPerson.FindSet then
                repeat
                    Count += 1;

                    Dlg.Update(1, SalesPerson.Name);
                    Dlg.Update(2, Round(Count / SalesPerson.Count * 10000, 1, '='));
                    SetItemLedgerEntryFilter(ItemLedgerEntry);
                    ItemLedgerEntry.SetRange("NPR Salesperson Code", SalesPerson.Code);
                    ItemLedgerEntry.CalcSums(Quantity);
                    if ItemLedgerEntry.Quantity <> 0 then begin
                        Get(SalesPerson.Code);
                        Mark(true);
                    end;
                until SalesPerson.Next = 0;
            Dlg.Close;

            MarkedOnly(true);
            Rec := Current;
        end else begin
            MarkedOnly(false);
        end;

        CurrPage.Update(false);

        exit(HideEmpty);
    end;
}

