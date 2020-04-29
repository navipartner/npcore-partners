page 6014588 "Item Statistics Subpage"
{
    // NPR4.12/BHR /29062015 CASE 2171113 display Cost Amount
    // NPR4.21/TS  /20160225 CASE 226010 HideEmty always set as True so as not to display Emty Lines
    // NPR5.31/BR  /20172021 CASE 272890 made non-editable
    // NPR5.51/RA  /20190628 CASE 338480 Added Function GetGlobals
    // NPR5.51/YAHA/20190822 CASE 365732 Flow Item Category Filter From Advanced Sales Statistics to Item Statistics
    // NPR5.53/YAHA/20200107 CASE 384124 Adding vendor no - to be used in filters

    Caption = 'Item Statistics Subform';
    Editable = false;
    PageType = List;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(Control6150623)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("-""Sale Quantity""";-"Sale Quantity")
                {
                    Caption = 'Sale (QTY)';

                    trigger OnAssistEdit()
                    var
                        ItemledgerEntry: Record "Item Ledger Entry";
                        ItemledgerEntryForm: Page "Item Ledger Entries";
                    begin

                        SetItemLedgerEntryFilter( ItemledgerEntry );
                        ItemledgerEntryForm.SetTableView( ItemledgerEntry );
                        ItemledgerEntryForm.Editable( false );
                        ItemledgerEntryForm.RunModal;
                    end;
                }
                field("-""LastYear Sale Quantity""";-"LastYear Sale Quantity")
                {
                    Caption = 'No.';
                    Visible = LSQTY;
                }
                field("Sale Amount";"Sale Amount")
                {
                    Caption = 'Sale (LCY)';

                    trigger OnDrillDown()
                    var
                        ValueEntry: Record "Value Entry";
                        ValueEntryForm: Page "Value Entries";
                    begin

                        SetValueEntryFilter( ValueEntry );
                        ValueEntryForm.SetTableView( ValueEntry );
                        ValueEntryForm.Editable( false );
                        ValueEntryForm.RunModal;
                    end;
                }
                field("LastYear Sale Amount";"LastYear Sale Amount")
                {
                    Caption = 'No.';
                    Visible = LSAmount;
                }
                field("-CostAmt";-CostAmt)
                {
                    Caption = 'Cost (LCY)';
                }
                field("-""Last Year CostAmt""";-"Last Year CostAmt")
                {
                    Caption = 'Last year Cost Amount';
                    Visible = LSAmount;
                }
                field("Profit Amount";"Profit Amount")
                {
                    Caption = 'Profit (LCY)';
                }
                field("LastYear Profit Amount";"LastYear Profit Amount")
                {
                    Caption = 'Last Year Proifit Amount';
                    Visible = LPA;
                }
                field("Profit %";"Profit %")
                {
                    Caption = 'Profit %';
                }
                field("LastYear Profit %";"LastYear Profit %")
                {
                    Caption = '-> Last year';
                    Visible = "LP%";
                }
                field("Vendor No.";"Vendor No.")
                {
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
        if ( Periodestart = 0D ) then Periodestart := Today;
        if ( Periodeslut = 0D ) then Periodeslut := Today;
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
        CostAmt: Decimal;
        "Last Year CostAmt": Decimal;
        ItemCatCodeFilter: Code[20];

    procedure SetFilter(GlobalDim1: Code[20];GlobalDim2: Code[20];DatoStart: Date;DatoEnd: Date;ItemGroup: Code[20];LastYearCalc: Text[50];ItemCatCode: Code[20])
    begin
        //SetFilter()
        //-NPR5.51 [365732]
        if ( Dim1Filter <> GlobalDim1 ) or ( Dim2Filter <> GlobalDim2 ) or ( Periodestart <> DatoStart ) or
        //   ( Periodeslut <> DatoEnd ) OR ( ItemGroupFilter <> ItemGroup ) THEN
             ( Periodeslut <> DatoEnd ) or ( ItemGroupFilter <> ItemGroup ) or (ItemCatCodeFilter <> ItemCatCode) then
        //-NPR5.51 [365732]
          ReleaseLock;
        Dim1Filter := GlobalDim1;
        Dim2Filter := GlobalDim2;
        Periodestart := DatoStart;
        Periodeslut := DatoEnd;
        CalcLastYear := LastYearCalc;
        //-NPR5.51 [365732]
        ItemCatCodeFilter := ItemCatCode;
        //+NPR5.51 [365732]

        if ( ItemGroup = '' ) and ( ItemGroupFilter <> '' ) and HideEmpty then begin
          ItemGroupFilter := ItemGroup;
          HideEmpty := false;
          ChangeEmptyFilter;
        end else begin
          ItemGroupFilter := ItemGroup;
        end;

        //CurrForm.UPDATE;
          CurrPage.Update;
    end;

    procedure Calc()
    var
        ValueEntry: Record "Value Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        //Calc()
        SetValueEntryFilter( ValueEntry );
        ValueEntry.CalcSums( "Cost Amount (Actual)", "Sales Amount (Actual)" );

        SetItemLedgerEntryFilter( ItemLedgerEntry );
        ItemLedgerEntry.CalcSums( Quantity );

        "Sale Quantity" := ItemLedgerEntry.Quantity;
        "Sale Amount" := ValueEntry."Sales Amount (Actual)";
        "Profit Amount" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        //-NPR4.12
        CostAmt:= ValueEntry."Cost Amount (Actual)";
        //+NPR4.12

        if "Sale Amount" <> 0 then
          "Profit %" := "Profit Amount" / "Sale Amount" * 100
        else
          "Profit %" := 0;

        // Calc last year
        LastYear := true;

        SetValueEntryFilter( ValueEntry );
        ValueEntry.CalcSums( "Cost Amount (Actual)", "Sales Amount (Actual)" );

        SetItemLedgerEntryFilter( ItemLedgerEntry );
        ItemLedgerEntry.CalcSums( Quantity );

        "LastYear Sale Quantity" := ItemLedgerEntry.Quantity;
        "LastYear Sale Amount" := ValueEntry."Sales Amount (Actual)";
        "LastYear Profit Amount" := ValueEntry."Sales Amount (Actual)" + ValueEntry."Cost Amount (Actual)";
        //-NPR4.12
        "Last Year CostAmt":= ValueEntry."Cost Amount (Actual)";
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
        ItemLedgerEntry.SetCurrentKey( "Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code" );
        ItemLedgerEntry.SetRange( "Entry Type", ItemLedgerEntry."Entry Type"::Sale );
        ItemLedgerEntry.SetRange( "Item No.", "No." );
        if not LastYear then
          ItemLedgerEntry.SetFilter( "Posting Date", '%1..%2', Periodestart, Periodeslut )
        else
          ItemLedgerEntry.SetFilter( "Posting Date", '%1..%2', CalcDate(CalcLastYear,Periodestart), CalcDate(CalcLastYear,Periodeslut) );


        //-NPR5.51 [365732]
        if ItemCatCodeFilter <>  '' then
          ItemLedgerEntry.SetRange("Item Category Code",ItemCatCodeFilter)
        else
          ItemLedgerEntry.SetRange("Item Category Code");
        //+NPR5.51 [365732]

        if ItemGroupFilter <> '' then
          ItemLedgerEntry.SetRange( "Item Group No.", ItemGroupFilter )
        else
          ItemLedgerEntry.SetRange( "Item Group No." );

        if Dim1Filter <> '' then
          ItemLedgerEntry.SetRange( "Global Dimension 1 Code", Dim1Filter )
        else
          ItemLedgerEntry.SetRange( "Global Dimension 1 Code" );

        if Dim2Filter <> '' then
          ItemLedgerEntry.SetRange( "Global Dimension 2 Code", Dim2Filter )
        else
          ItemLedgerEntry.SetRange( "Global Dimension 2 Code" );
    end;

    procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry")
    begin
        //SetValueEntryFilter
        ValueEntry.SetCurrentKey( "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code" );
        ValueEntry.SetRange( "Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale );
        ValueEntry.SetRange( "Item No.", "No." );
        if not LastYear then
          ValueEntry.SetFilter( "Posting Date", '%1..%2', Periodestart, Periodeslut )
        else
          ValueEntry.SetFilter( "Posting Date", '%1..%2',CalcDate(CalcLastYear,Periodestart), CalcDate(CalcLastYear,Periodeslut) );

        if ItemGroupFilter <> '' then
          ValueEntry.SetRange( "Item Group No.", ItemGroupFilter )
        else
          ValueEntry.SetRange( "Item Group No." );

        if Dim1Filter <> '' then
          ValueEntry.SetRange( "Global Dimension 1 Code", Dim1Filter )
        else
          ValueEntry.SetRange( "Global Dimension 1 Code" );

        if Dim2Filter <> '' then
          ValueEntry.SetRange( "Global Dimension 2 Code", Dim2Filter )
        else
          ValueEntry.SetRange( "Global Dimension 2 Code" );
    end;

    procedure ChangeEmptyFilter(): Boolean
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        Current: Record Item;
        "Count": Integer;
        txtDlg: Label 'Processing Item No. #1######## @2@@@@@@@@';
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
          Dlg.Open( txtDlg );
          if Item.Find('-') then repeat
            Count += 1;
            Dlg.Update( 1, Item."No." );
            Dlg.Update( 2, Round( Count / Item.Count * 10000, 1, '=' ));
            SetItemLedgerEntryFilter( ItemLedgerEntry );
            ItemLedgerEntry.SetRange( "Item No.", Item."No." );
            ItemLedgerEntry.CalcSums( Quantity );
            if ItemLedgerEntry.Quantity <> 0 then begin
              Get( Item."No." );
              Mark( true );
            end;
          until Item.Next = 0;
          Dlg.Close;

          MarkedOnly( true );
          Rec := Current;
        end else begin
          MarkedOnly( false );
        end;

        //CurrForm.UPDATE;
        CurrPage.Update;
        exit( HideEmpty );
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
          //CurrForm.UPDATE;
          CurrPage.Update;
        end;
    end;

    procedure ReleaseLock()
    begin
        //ReleaseLock()
        if Count = 0 then begin
          MarkedOnly( false );
          ClearMarks;
        end;
    end;

    procedure ShowLastYear(Show: Boolean)
    begin
        //CurrForm."LastYear Sale Quantity".VISIBLE( Show );
        //CurrForm."LastYear Sale Amount".VISIBLE( Show );
        //CurrForm."LastYear Profit Amount".VISIBLE( Show );
        //CurrForm."LastYear Profit %".VISIBLE( Show );
        LSQty:=Show;
        LSAmount:=Show;
        LPA:=Show;
        "LP%":=Show;
    end;

    procedure GetGlobals(var InDim1Filter: Code[20];var InDim2Filter: Code[20];var InPeriodestart: Date;var InPeriodeslut: Date)
    begin
        //-NPR5.51 [338480]
        InDim1Filter := Dim1Filter;
        InDim2Filter := Dim2Filter;
        InPeriodestart := Periodestart;
        InPeriodeslut := Periodeslut;
        //+NPR5.51 [338480]
    end;
}

