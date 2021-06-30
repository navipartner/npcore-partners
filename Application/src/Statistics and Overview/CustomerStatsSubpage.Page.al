page 6014589 "NPR Customer Stats Subpage"
{
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("-Sale Quantity"; -"Sale Quantity")
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
                        AuxItemLedgerEntries.RunModal();
                    end;
                }
                field("-LastYear Sale Quantity"; -"LastYear Sale Quantity")
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
                        AuxValueEntries.RunModal();
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
                field("-LastYear Profit Amount"; -"LastYear Profit Amount")
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

        Calc();
    end;

    trigger OnOpenPage()
    begin

        if (Periodestart = 0D) then Periodestart := Today();
        if (Periodeslut = 0D) then Periodeslut := Today();
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
        ItemCategoryFilter: Code[20];
        HideEmpty: Boolean;
        Periodestart: Date;
        Periodeslut: Date;
        LastYear: Boolean;
        CalcLastYear: Text[50];

    procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemGroup: Code[20]; LastYearCalc: Text[50])
    begin
        //SetFilter()
        if (Dim1Filter <> GlobalDim1) or (Dim2Filter <> GlobalDim2) or (Periodestart <> DatoStart) or
           (Periodeslut <> DatoEnd) or (ItemCategoryFilter <> ItemGroup) then
            ReleaseLock();
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        CalcLastYear := LastYearCalc;

        if (ItemGroup = '') and (ItemCategoryFilter <> '') and HideEmpty then begin
            ItemCategoryFilter := ItemGroup;
            HideEmpty := false;
            ChangeEmptyFilter();
        end else begin
            ItemCategoryFilter := ItemGroup;
        end;

        CurrPage.Update();
    end;

    procedure Calc()
    var
        AuxValueEntry: Record "NPR Aux. Value Entry";
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        //Calc()
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
        //SetItemLedgerEntryFilter
        AuxItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
        AuxItemLedgerEntry.SetRange("Source No.", Rec."No.");
        if not LastYear then
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            AuxItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemCategoryFilter <> '' then
            AuxItemLedgerEntry.SetRange("Item Category Code", ItemCategoryFilter)
        else
            AuxItemLedgerEntry.SetRange("Item Category Code");

        if Dim1Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure SetValueEntryFilter(var AuxValueEntry: Record "NPR Aux. Value Entry")
    begin
        //SetValueEntryFilter
        AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
        AuxValueEntry.SetRange("Source No.", Rec."No.");
        if not LastYear then
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            AuxValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if ItemCategoryFilter <> '' then
            AuxValueEntry.SetRange("Item Category Code", ItemCategoryFilter)
        else
            AuxValueEntry.SetRange("Item Category Code");

        if Dim1Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure ChangeEmptyFilter(): Boolean
    var
        Customer: Record Customer;
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        Current: Record Customer;
        "Count": Integer;
        txtDlg: Label 'Processing Customer #1######## @2@@@@@@@@';
        Dlg: Dialog;
    begin
        //ChangeEmptyFilter()
        HideEmpty := true;
        Rec.ClearMarks();
        if HideEmpty then begin
            Current := Rec;

            Dlg.Open(txtDlg);
            if Customer.Find('-') then
                repeat
                    Count += 1;
                    Dlg.Update(1, Customer."No.");
                    Dlg.Update(2, Round(Count / Customer.Count() * 10000, 1, '='));
                    SetItemLedgerEntryFilter(AuxItemLedgerEntry);
                    AuxItemLedgerEntry.SetRange("Source No.", Customer."No.");

                    AuxItemLedgerEntry.CalcSums(Quantity);
                    if AuxItemLedgerEntry.Quantity <> 0 then begin
                        Rec.Get(Customer."No.");
                        Rec.Mark(true);
                    end;
                until Customer.Next() = 0;
            Dlg.Close();

            Rec.MarkedOnly(true);
            Rec := Current;
        end else begin
            Rec.MarkedOnly(false);
        end;

        CurrPage.Update();

        exit(HideEmpty);
    end;

    procedure InitForm()
    begin
        //InitForm()
        Rec.Reset();
        Dim1Filter := '';
        Dim2Filter := '';
        Periodestart := Today();
        Periodeslut := Today();
        ItemCategoryFilter := '';
        HideEmpty := true;
    end;

    procedure UpdateHidden()
    begin
        //UpdateHidden()
        if HideEmpty then begin
            HideEmpty := false;
            ChangeEmptyFilter();
            CurrPage.Update();
        end;
    end;

    procedure ReleaseLock()
    begin
        //ReleaseLock()
        if Rec.Count() = 0 then begin
            Rec.MarkedOnly(false);
            Rec.ClearMarks();
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

