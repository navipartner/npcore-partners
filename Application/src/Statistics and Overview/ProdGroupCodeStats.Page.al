﻿page 6014597 "NPR Prod. Group Code Stats"
{
    Extensible = False;
    Caption = 'Product Group Code Statistics';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = Item;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150623)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("-Sale Quantity"; -"Sale Quantity")
                {

                    Caption = 'Sale (QTY)';
                    ToolTip = 'Specifies the value of the Sale (QTY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        ItemledgerEntry: Record "Item Ledger Entry";
                        ItemledgerEntryForm: Page "Item Ledger Entries";
                    begin

                        SetItemLedgerEntryFilter(ItemledgerEntry);
                        ItemledgerEntryForm.SetTableView(ItemledgerEntry);
                        ItemledgerEntryForm.Editable(false);
                        ItemledgerEntryForm.RunModal();
                    end;
                }
                field("-LastYear Sale Quantity"; -"LastYear Sale Quantity")
                {

                    Caption = 'Last Year Sale Quantity';
                    Visible = LSQTY;
                    ToolTip = 'Specifies the value of the Last Year Sale Quantity field';
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
                        ValueEntryForm: Page "Value Entries";
                    begin
                        SetValueEntryFilter(ValueEntry);
                        ValueEntryForm.SetTableView(ValueEntry);
                        ValueEntryForm.Editable(false);
                        ValueEntryForm.RunModal();
                    end;
                }
                field(SalesAmt; SalesAmt)
                {

                    Caption = 'Sales Amount';
                    ToolTip = 'Specifies the value of the Sales Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Sale Amount"; "LastYear Sale Amount")
                {

                    Caption = 'Last Year Sale Amount';
                    Visible = LSAmount;
                    ToolTip = 'Specifies the value of the Last Year Sale Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("-CostAmt"; -CostAmt)
                {

                    Caption = 'Cost (LCY)';
                    ToolTip = 'Specifies the value of the Cost (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("-Last Year CostAmt"; -"Last Year CostAmt")
                {

                    Caption = 'Last year Cost Amount';
                    Visible = LSAmount;
                    ToolTip = 'Specifies the value of the Last year Cost Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit Amount"; "Profit Amount")
                {

                    Caption = 'Profit (LCY)';
                    ToolTip = 'Specifies the value of the Profit (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit Amount"; "LastYear Profit Amount")
                {

                    Caption = 'Last Year Proifit Amount';
                    Visible = LPA;
                    ToolTip = 'Specifies the value of the Last Year Proifit Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Profit %"; Rec."Profit %")
                {

                    Caption = 'Profit %';
                    ToolTip = 'Specifies the value of the Profit % field';
                    ApplicationArea = NPRRetail;
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {

                    Caption = '-> Last year';
                    Visible = "LP%";
                    ToolTip = 'Specifies the value of the -> Last year field';
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
        if (Periodestart = 0D) then
            Periodestart := Today();
        if (Periodeslut = 0D) then
            Periodeslut := Today();
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
        "LastYear Profit %": Decimal;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        HideEmpty: Boolean;
        Periodestart: Date;
        Periodeslut: Date;
        LastYear: Boolean;
        CalcLastYear: Text[50];
        CostAmt: Decimal;
        "Last Year CostAmt": Decimal;
        SalesAmt: Decimal;
        ItemLedgerEntryNo: Integer;
        ItemCategoryCode: Code[20];

    internal procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; LastYearCalc: Text[50]; ItemNoFilter: Code[20]; ItemCategoryFilter: Code[20])
    begin
        //SetFilter()
        if (Dim1Filter <> GlobalDim1) or (Dim2Filter <> GlobalDim2) or (Periodestart <> DatoStart) or
           (Periodeslut <> DatoEnd) then
            ReleaseLock();
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        CalcLastYear := LastYearCalc;
        ItemCategoryCode := ItemCategoryFilter;
        CurrPage.Update();
    end;

    internal procedure Calc()
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        //Calc()

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcFields("Sales Amount (Actual)");

        ItemLedgerEntryNo := ItemLedgerEntry."Entry No.";
        SetValueEntryFilter(ValueEntry);

        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");
        "Sale Quantity" := 0;

        "Sale Quantity" := ItemLedgerEntry.Quantity;
        //"Sale Amount" := ItemLedgerEntry."Sales Amount (Actual)";
        "Sale Amount" := ValueEntry."Sales Amount (Actual)";
        "Profit Amount" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        //-NPR4.12
        CostAmt := ValueEntry."Cost Amount (Actual)";
        //+NPR4.12

        if "Sale Amount" <> 0 then
            Rec."Profit %" := "Profit Amount" / "Sale Amount" * 100
        else
            Rec."Profit %" := 0;

        // Calc last year
        LastYear := true;

        SetValueEntryFilter(ValueEntry);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Sales Amount (Actual)");

        SetItemLedgerEntryFilter(ItemLedgerEntry);
        ItemLedgerEntry.CalcSums(Quantity);

        "LastYear Sale Quantity" := ItemLedgerEntry.Quantity;
        "LastYear Sale Amount" := ValueEntry."Sales Amount (Actual)";
        "LastYear Profit Amount" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        "Last Year CostAmt" := ValueEntry."Cost Amount (Actual)";

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

        if ItemCategoryCode <> '' then
            ItemLedgerEntry.SetRange("Item Category Code", ItemCategoryCode)
        else
            ItemLedgerEntry.SetRange("Item Category Code");

        ItemLedgerEntry.SetRange("Item No.", Rec."No.");
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));
        if not ItemLedgerEntry.FindSet() then
            exit;

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
        ValueEntry.SetRange("Item No.", Rec."No.");
        if not LastYear then
            ValueEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ValueEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));

        //TODO:Temporary Aux Value Entry Reimplementation
        // if ItemCategoryCode <> '' then
        //     ValueEntry.SetRange("NPR Item Category Code", ItemCategoryCode)
        // else
        //     ValueEntry.SetRange("NPR Item Category Code");

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ValueEntry.SetRange("Global Dimension 2 Code");
        if ItemLedgerEntryNo <> 0 then
            ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
    end;

    internal procedure ChangeEmptyFilter(): Boolean
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Current: Record Item;
        "Count": Integer;
        txtDlg: Label 'Processing Item No. #1######## @2@@@@@@@@';
        Dlg: Dialog;
    begin
        HideEmpty := true;

        Rec.ClearMarks();
        if HideEmpty then begin
            Current := Rec;
            Dlg.Open(txtDlg);
            if Item.Find('-') then
                repeat
                    Count += 1;
                    Dlg.Update(1, Item."No.");
                    Dlg.Update(2, Round(Count / Item.Count() * 10000, 1, '='));
                    SetItemLedgerEntryFilter(ItemLedgerEntry);
                    ItemLedgerEntry.SetRange("Item No.", Item."No.");
                    ItemLedgerEntry.CalcSums(Quantity);
                    if ItemLedgerEntry.Quantity <> 0 then begin
                        Rec.Get(Item."No.");
                        Rec.Mark(true);
                    end;
                until Item.Next() = 0;
            Dlg.Close();

            Rec.MarkedOnly(true);
            Rec := Current;
        end else begin
            Rec.MarkedOnly(false);
        end;

        //CurrForm.Update();
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
        ItemCategoryCode := '';

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
        LSQty := Show;
        LSAmount := Show;
        LPA := Show;
        "LP%" := Show;
    end;
}

