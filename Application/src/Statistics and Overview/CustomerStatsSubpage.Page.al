page 6014589 "NPR Customer Stats Subpage"
{
    // NPR4.21/TS/20160225  CASE 226010 HideEmty always set as True so as not to display Emty Lines
    // NPR5.31/BR/20172021  CASE 272890 Changed from ListPart to List (for export to Excel) and made non-editable
    // NPR5.55/BHR /20200724 CASE 361515 Comment Key not used in AL

    Caption = 'Customer Statistics Subform';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            repeater(Control6150623)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
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
        [InDataSet]
        LSQty: Boolean;
        [InDataSet]
        LSAmount: Boolean;
        [InDataSet]
        LPA: Boolean;
        [InDataSet]
        "LP%": Boolean;
        "Sale Quantity": Decimal;
        "LastYear Sale Quantity": Decimal;
        "Sale Amount": Decimal;
        "LastYear Sale Amount": Decimal;
        "Profit Amount": Decimal;
        "LastYear Profit Amount": Decimal;
        "Profit %": Decimal;
        "LastYear Profit %": Decimal;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        ItemGroupFilter: Code[20];
        HideEmpty: Boolean;
        Periodestart: Date;
        Periodeslut: Date;
        LastYear: Boolean;
        ShowSameWeekday: Boolean;
        DateFilterLastYear: Text[50];
        CalcLastYear: Text[50];

    procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemGroup: Code[20]; LastYearCalc: Text[50])
    begin
        //SetFilter()
        if (Dim1Filter <> GlobalDim1) or (Dim2Filter <> GlobalDim2) or (Periodestart <> DatoStart) or
           (Periodeslut <> DatoEnd) or (ItemGroupFilter <> ItemGroup) then
            ReleaseLock;
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        CalcLastYear := LastYearCalc;

        if (ItemGroup = '') and (ItemGroupFilter <> '') and HideEmpty then begin
            ItemGroupFilter := ItemGroup;
            HideEmpty := false;
            ChangeEmptyFilter;
        end else begin
            ItemGroupFilter := ItemGroup;
        end;

        CurrPage.Update;
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
        ItemLedgerEntry.SetRange("Source No.", "No.");
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemGroupFilter <> '' then
            ItemLedgerEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
        else
            ItemLedgerEntry.SetRange("NPR Item Group No.");

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        //SetValueEntryFilter
        //-NPR5.55 [361515]
        //ValueEntry.SETCURRENTKEY( "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code" );
        //-NPR5.55 [361515]
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Source No.", "No.");
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemGroupFilter <> '' then
            ValueEntry.SetRange("NPR Item Group No.", ItemGroupFilter)
        else
            ValueEntry.SetRange("NPR Item Group No.");

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ValueEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure ChangeEmptyFilter(): Boolean
    var
        Customer: Record Customer;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Current: Record Customer;
        "Count": Integer;
        txtDlg: Label 'Processing Customer #1######## @2@@@@@@@@';
        Dlg: Dialog;
    begin
        //ChangeEmptyFilter()
        //-NPR4.21
        //HideEmpty := NOT HideEmpty;
        HideEmpty := true;
        //+NPR4.21
        ClearMarks;
        if HideEmpty then begin
            Current := Rec;

            Dlg.Open(txtDlg);
            if Customer.Find('-') then
                repeat
                    Count += 1;
                    Dlg.Update(1, Customer."No.");
                    Dlg.Update(2, Round(Count / Customer.Count * 10000, 1, '='));
                    SetItemLedgerEntryFilter(ItemLedgerEntry);
                    ItemLedgerEntry.SetRange("Source No.", Customer."No.");

                    ItemLedgerEntry.CalcSums(Quantity);
                    if ItemLedgerEntry.Quantity <> 0 then begin
                        Get(Customer."No.");
                        Mark(true);
                    end;
                until Customer.Next = 0;
            Dlg.Close;

            MarkedOnly(true);
            Rec := Current;
        end else begin
            MarkedOnly(false);
        end;

        CurrPage.Update;

        exit(HideEmpty);
    end;

    procedure InitForm()
    begin
        //InitForm()
        Reset;
        Dim1Filter := '';
        Dim2Filter := '';
        Periodestart := Today;
        Periodeslut := Today;
        ItemGroupFilter := '';
        HideEmpty := true;
    end;

    procedure UpdateHidden()
    begin
        //UpdateHidden()
        if HideEmpty then begin
            HideEmpty := false;
            ChangeEmptyFilter;
            CurrPage.Update;
        end;
    end;

    procedure ReleaseLock()
    begin
        //ReleaseLock()
        if Count = 0 then begin
            MarkedOnly(false);
            ClearMarks;
        end;
    end;

    procedure ShowLastYear(Show: Boolean)
    begin
        //CurrPage."LastYear Sale Quantity".VISIBLE( Show );
        //CurrPage."LastYear Sale Amount".VISIBLE( Show );
        //CurrPage."LastYear Profit Amount".VISIBLE( Show );
        //CurrPage."LastYear Profit %".VISIBLE( Show );
        LSQty := Show;
        LSAmount := Show;
        LPA := Show;
        "LP%" := Show;
    end;
}

