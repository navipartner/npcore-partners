page 6014590 "NPR Vendor Statistics Subpage"
{
    Extensible = False;
    Caption = 'Vendor Statistics Subform';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = Vendor;
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteReason = 'Vendor Statistics part with Vendor No. with Sale is not possible anymore.';

    layout
    {
        area(content)
        {
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
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
                        ItemLedgerEntry: Record "Item Ledger Entry";
                        ItemLedgerEntries: Page "Item Ledger Entries";
                    begin

                        SetItemLedgerEntryFilter(ItemLedgerEntry);
                        ItemLedgerEntries.SetTableView(ItemLedgerEntry);
                        ItemLedgerEntries.Editable(false);
                        ItemLedgerEntries.RunModal();
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

    internal procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; ItemGroup: Code[20]; LastYearCalc: Text[50])
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

    internal procedure Calc()
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

    internal procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        //SetItemLedgerEntryFilter
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Vendor);
        ItemLedgerEntry.SetRange("Source No.", Rec."No.");
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));


        if ItemCategoryFilter <> '' then
            ItemLedgerEntry.SetRange("Item Category Code", ItemCategoryFilter)
        else
            ItemLedgerEntry.SetRange("Item Category Code");

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    internal procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        //SetValueEntryFilter
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ValueEntry.SetRange("Global Dimension 2 Code");
    end;

    internal procedure ChangeEmptyFilter(): Boolean
    var
        Vendor: Record Vendor;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Current: Record Vendor;
        "Count": Integer;
        txtDlg: Label 'Processing Vendor #1######## @2@@@@@@@@';
        Dlg: Dialog;
    begin
        //ChangeEmptyFilter()
        HideEmpty := true;
        Rec.ClearMarks();
        if HideEmpty then begin
            Current := Rec;

            Dlg.Open(txtDlg);
            if Vendor.Find('-') then
                repeat
                    Count += 1;
                    Dlg.Update(1, Vendor."No.");
                    Dlg.Update(2, Round(Count / Vendor.Count() * 10000, 1, '='));
                    SetItemLedgerEntryFilter(ItemLedgerEntry);
                    ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Vendor);
                    ItemLedgerEntry.SetRange("Source No.", Vendor."No.");

                    ItemLedgerEntry.CalcSums(Quantity);
                    if ItemLedgerEntry.Quantity <> 0 then begin
                        Rec.Get(Vendor."No.");
                        Rec.Mark(true);
                    end;
                until Vendor.Next() = 0;
            Dlg.Close();

            Rec.MarkedOnly(true);
            Rec := Current;
        end else begin
            Rec.MarkedOnly(false);
        end;

        CurrPage.Update();

        exit(HideEmpty);
    end;

    internal procedure InitForm()
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

    internal procedure UpdateHidden()
    begin
        //UpdateHidden()
        if HideEmpty then begin
            HideEmpty := false;
            ChangeEmptyFilter();
            CurrPage.Update();
        end;
    end;

    internal procedure ReleaseLock()
    begin
        //ReleaseLock()
        if Rec.Count() = 0 then begin
            Rec.MarkedOnly(false);
            Rec.ClearMarks();
        end;
    end;

    internal procedure ShowLastYear(Show: Boolean)
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

