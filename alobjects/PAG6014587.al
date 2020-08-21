page 6014587 "Item Group Statistics Subpage"
{
    // 
    // NPR3.1, NPK, DL, Tilf¢jet kode så der foldes rigtigt
    // NPR4.000.001, JC, 06-09-2010,Case no. 92938 - Item Group Stat crashing
    // 
    // 
    // NPK7.000.000,TS,25.10.12-There we re some code that were written on the Format Trigger on some control,for the time being  I  copied it here until a soution is found.
    // 
    // 
    // No. - OnFormat(VAR Text : Text[1024];)
    // IF ("Parent item group" = '') AND ("Belongs in Main Item Group" = "No.") THEN
    // BEGIN
    //   CurrForm."No.".UPDATEFORECOLOR(255);
    //   CurrForm."No.".UPDATEFONTBOLD(TRUE);
    // END;
    // IF Level = 1 THEN CurrForm."No.".UPDATEFONTBOLD(TRUE);
    // 
    // 
    // Description - OnFormat(VAR Text : Text[1024];)
    // IF ("Parent item group" = '') AND ("Belongs in Main Item Group" = "No.") THEN
    // BEGIN
    //   CurrForm.Description.UPDATEFORECOLOR(255);
    //   CurrForm.Description.UPDATEFONTBOLD(TRUE);
    // END;
    //   CurrForm.Description.UPDATEINDENT(Level*450);
    // 
    // IF Level = 1 THEN  CurrForm.Description.UPDATEFONTBOLD(TRUE);
    // /////////////////////////////////////////
    // 
    // This code was written on the control field Expanded:
    // 
    // <Control1160330025> - OnActivate()
    // moreField := TRUE;
    // 
    // <Control1160330025> - OnDeactivate()
    // moreField := FALSE;
    // 
    // <Control1160330025> - OnPush()
    // ToggleExpandCollapse();
    // CurrForm.UPDATE();
    // NPR4.12/BHR/29062015 CASE 217113 Display Cost Amount
    // NPR4.21/TS/20160225  CASE 226010 Commented code as not to display as Tree Structure
    // NPR5.31/BR/20172021  CASE 272890 Changed from ListPart to List (for export to Excel) and made non-editable
    // NPR5.51/ZESO/20190620 CASE 358271 Added Item Group Filter from Advanced Sales Statistics Page
    // NPR5.55/BHR /20200724 CASE 361515 Comment Key not used in AL

    Caption = 'Item Group Statistics Subpage';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Item Group";
    SourceTableView = SORTING("Sorting-Key");

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                IndentationColumn = Level;
                ShowAsTree = true;
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("-""Sale Quantity"""; -"Sale Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'Sale (QTY)';

                    trigger OnAssistEdit()
                    var
                        ItemledgerEntry: Record "Item Ledger Entry";
                        ItemledgerEntryForm: Page "Item Ledger Entries";
                    begin

                        SetItemLedgerEntryFilter(ItemledgerEntry);
                        ItemledgerEntryForm.SetTableView(ItemledgerEntry);
                        ItemledgerEntryForm.Editable(false);
                        ItemledgerEntryForm.RunModal;
                    end;
                }
                field("-""LastYear Sale Quantity"""; -"LastYear Sale Quantity")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    Visible = LSQTY;
                }
                field("Sale Amount"; "Sale Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Sale (LCY)';

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
                field("LastYear Sale Amount"; "LastYear Sale Amount")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    Visible = LSAmount;
                }
                field("-CostAmt"; -CostAmt)
                {
                    ApplicationArea = All;
                    Caption = 'Cost (LCY)';
                }
                field("-""Last Year CostAmt"""; -"Last Year CostAmt")
                {
                    ApplicationArea = All;
                    Caption = 'Last year Cost Amount';
                    Visible = LSAmount;
                }
                field("Profit Amount"; "Profit Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Profit (LCY)';
                }
                field("LastYear Profit Amount"; "LastYear Profit Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Last Year Proifit Amount';
                    Visible = LPA;
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                    Caption = 'Profit %';
                }
                field("LastYear Profit %"; "LastYear Profit %")
                {
                    ApplicationArea = All;
                    Caption = '-> Last year';
                    Visible = "LP%";
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin

        //-NPR3.1
        if not Rec.Get("No.") then exit;
        TempItemGroup := Rec;
        TempItemGroup.Modify;
        //+NPR3.1
    end;

    trigger OnAfterGetRecord()
    begin

        Calc;

        //-NPR3.1
        if IsExpanded(Rec) then
            Expanded := 1
        else
            if HasChildren(Rec) then
                Expanded := 0
            else
                Expanded := 2;
        //+NPR3.1
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
    begin

        //-NPR3.1
        TempItemGroup.Copy(Rec);
        Found := TempItemGroup.Find(Which);
        Rec := TempItemGroup;
        exit(Found);
        //+NPR3.1
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        ResultSteps: Integer;
    begin

        //-NPR3.1
        TempItemGroup.Copy(Rec);
        ResultSteps := TempItemGroup.Next(Steps);
        Rec := TempItemGroup;
        exit(ResultSteps);
        //+NPR3.1
    end;

    trigger OnOpenPage()
    var
        "retail config": Record "Retail Setup";
    begin

        if (Periodestart = 0D) then Periodestart := Today;
        if (Periodeslut = 0D) then Periodeslut := Today;
        //-NPR4.21
        ////-NPR3.1
        //InitTempTable;

        //IF "retail config".GET() THEN
        //  IF "retail config"."Item Structure" THEN
        //   ExpandAll;
        //+NPR3.1
        //+NPR4.21
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
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        Periodestart: Date;
        Periodeslut: Date;
        HideEmpty: Boolean;
        LastYear: Boolean;
        ShowSameWeekday: Boolean;
        DateFilterLastYear: Text[50];
        CalcLastYear: Text[50];
        Expanded: Integer;
        moreField: Boolean;
        pos: Integer;
        TempItemGroup: Record "Item Group" temporary;
        [InDataSet]
        LSQty: Boolean;
        [InDataSet]
        LSAmount: Boolean;
        [InDataSet]
        LPA: Boolean;
        [InDataSet]
        "LP%": Boolean;
        CostAmt: Decimal;
        "Last Year CostAmt": Decimal;
        ItemGroupFilter: Code[20];

    procedure SetFilter(GlobalDim1: Code[20]; GlobalDim2: Code[20]; DatoStart: Date; DatoEnd: Date; LastYearCalc: Text[50])
    begin
        //SetFilter()
        if (Dim1Filter <> GlobalDim1) or (Dim2Filter <> GlobalDim2) or (Periodestart <> DatoStart) or (Periodeslut <> DatoEnd) then
            ReleaseLock;
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        CalcLastYear := LastYearCalc;
        //CurrForm.UPDATE;
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
        //-NPR4.12
        CostAmt := ValueEntry."Cost Amount (Actual)";
        //+NPR4.12

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
        //-NPR4.12
        "Last Year CostAmt" := ValueEntry."Cost Amount (Actual)";
        //+NPR4.12

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
        ItemLedgerEntry.SetRange("Item Group No.", "No.");
        if not LastYear then
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', Periodestart, Periodeslut)
        else
            ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CalcDate(CalcLastYear, Periodestart), CalcDate(CalcLastYear, Periodeslut));


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
        //+NPR5.55 [361515]
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Item Group No.", "No.");
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

    procedure ChangeEmptyFilter(): Boolean
    var
        ItemGroup: Record "Item Group";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Current: Record "Item Group";
        txtDlg: Label 'Processing Item Group #1######## @2@@@@@@@@';
        "Count": Integer;
        Dlg: Dialog;
        ValueEntry: Record "Value Entry";
    begin
        //ChangeEmptyFilter()
        //HideEmpty :=  NOT HideEmpty;
        HideEmpty := true;
        if HideEmpty then begin
            TempItemGroup.DeleteAll;
            Current := Rec;
            Dlg.Open(txtDlg);
            ItemGroup.SetCurrentKey("Entry No.", "Primary Key Length");
            //-NPR5.51 [358271]
            ItemGroup.SetFilter("No.", ItemGroupFilter);
            //+NPR5.51 [358271]
            if ItemGroup.Find('-') then
                repeat
                    Count += 1;
                    Dlg.Update(1, ItemGroup."No.");
                    Dlg.Update(2, Round(Count / ItemGroup.Count * 10000, 1, '='));
                    Clear(ItemLedgerEntry);
                    SetItemLedgerEntryFilter(ItemLedgerEntry);
                    ItemLedgerEntry.SetRange("Item Group No.", ItemGroup."No.");
                    if ItemLedgerEntry.Count > 0 then
                        ItemLedgerEntry.CalcSums(Quantity);
                    //-NPR5.51 [358271]
                    Clear(ValueEntry);
                    SetValueEntryFilter(ValueEntry);
                    ValueEntry.SetRange("Item Group No.", ItemGroup."No.");
                    if ValueEntry.Count > 0 then
                        ValueEntry.CalcSums("Sales Amount (Actual)");


                    //IF ItemLedgerEntry.Quantity <> 0 THEN BEGIN
                    if not ((ItemLedgerEntry.Quantity = 0) and (ValueEntry."Sales Amount (Actual)" = 0)) then begin
                        //-NPR5.51 [358271]

                        Get(ItemGroup."No.");
                        TempItemGroup := ItemGroup;
                        TempItemGroup.Insert;
                    end;
                until ItemGroup.Next = 0;
            Dlg.Close;

            Rec := Current;

        end else begin
            ExpandAll;
        end;

        //CurrForm.UPDATE;
        CurrPage.Update;
        exit(HideEmpty);
    end;

    procedure InitForm()
    begin
        //InitForm()
        Reset;
        SetCurrentKey("Entry No.", "Primary Key Length");
        Dim1Filter := '';
        Dim2Filter := '';
        Periodestart := Today;
        Periodeslut := Today;
        HideEmpty := true;
    end;

    procedure GetItemGroupCode(VarItemGroupFilter: Code[20])
    begin
        //GetItemGroupCode()
        //-NPR5.51 [358271]
        //EXIT( "No." );
        ItemGroupFilter := VarItemGroupFilter;
        //+NPR5.51 [358271]
    end;

    procedure UpdateHidden()
    begin
        //UpdateHidden()
        if HideEmpty then begin
            HideEmpty := false;
            ChangeEmptyFilter;
            //CurrForm.UPDATE;
            CurrPage.Update;
        end;
    end;

    procedure ReleaseLock()
    begin
        //ReleaseLock()
        ExpandAll;
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

    local procedure ToggleExpandCollapse()
    var
        "Item Group 1": Record "Item Group";
    begin
        //ToggleExpandCollapse
        //-NPR3.1

        if Expanded = 0 then begin               // Has children, but not expanded
            "Item Group 1".SetCurrentKey("Entry No.", "Primary Key Length");
            "Item Group 1".SetRange("Parent Item Group No.", "No.");
            "Item Group 1" := Rec;
            if "Item Group 1".Next <> 0 then begin
                repeat
                    if "Item Group 1".Level > Level then begin
                        TempItemGroup := "Item Group 1";
                        if TempItemGroup.Insert then;
                    end;
                until ("Item Group 1".Next = 0) or ("Item Group 1".Level = Level);
            end;
        end else begin
            if Expanded = 1 then begin            // Has children and is already expanded
                TempItemGroup := Rec;
                while (TempItemGroup.Next <> 0) and (TempItemGroup.Level > Level) do
                    TempItemGroup.Delete;
            end;
        end;

        //CurrForm.UPDATE;
        CurrPage.Update;
        //+NPR3.1
    end;

    local procedure IsExpanded(ActualItemGroup: Record "Item Group"): Boolean
    begin
        //IsExpanded
        //-NPR3.1

        TempItemGroup := ActualItemGroup;
        if TempItemGroup.Next = 0 then
            exit(false)
        else
            exit(TempItemGroup.Level > ActualItemGroup.Level);
        //+NPR3.1
    end;

    local procedure ExpandAll()
    var
        IG: Record "Item Group";
    begin
        //-NPR3.1Tem
        TempItemGroup.DeleteAll;
        IG.SetCurrentKey("Entry No.", "Primary Key Length");
        if IG.Find('-') then
            repeat
                TempItemGroup := IG;
                TempItemGroup.Insert;
            until IG.Next = 0;
        //+NPR3.1
    end;

    local procedure HasChildren(ActualItemGroup: Record "Item Group"): Boolean
    var
        IG2: Record "Item Group";
    begin
        //HasChildren
        //-NPR3.1

        IG2 := ActualItemGroup;
        IG2.SetCurrentKey("Entry No.", "Primary Key Length");
        IG2.SetCurrentKey("Entry No.");
        IG2.SetRange("Parent Item Group No.", ActualItemGroup."No.");
        if IG2.Next = 0 then
            exit(false)
        else
            exit(IG2.Level > ActualItemGroup.Level);
        //+NPR3.1
    end;

    local procedure InitTempTable()
    var
        IG: Record "Item Group";
    begin
        //InitTempTable
        //-NPR3.1
        TempItemGroup.DeleteAll;

        TempItemGroup.SetCurrentKey("Entry No.", "Primary Key Length");
        //IG.SETRANGE("Parent item group",CurrentItemGroup);
        IG.SetRange(Level, 0, 1);
        if IG.Find('-') then
            repeat
                TempItemGroup := IG;
                TempItemGroup.Insert;
            until IG.Next = 0;
        //+NPR3.1
    end;
}

