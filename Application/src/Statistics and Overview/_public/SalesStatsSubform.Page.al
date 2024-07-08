page 6014594 "NPR Sales Stats Subform"
{
    Extensible = true;
    Caption = 'Sales Statistics Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Sales Stats Time Period";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Sales (Qty)"; Rec."Sales (Qty)")
                {

                    ToolTip = 'Specifies the value of the Sales (Qty) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                        ItemLedgerEntries: Page "Item Ledger Entries";
                    begin
                        SetItemLedgerEntryFilter(ItemLedgerEntry, Rec."No.");
                        ItemLedgerEntries.SetTableView(ItemLedgerEntry);
                        ItemLedgerEntries.Editable(false);
                        ItemLedgerEntries.RunModal();
                    end;
                }
                field("Sales (LCY)"; Rec."Sales (LCY)")
                {
                    ToolTip = 'Specifies the value of the Sales (LCY) field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        ValueEntry: Record "Value Entry";
                        ValueEntries: Page "Value Entries";
                    begin
                        case Statistics of
                            Statistics::Item:
                                begin
                                    SetValueEntryFilter(ValueEntry, Rec."No.");
                                    ValueEntries.SetTableView(ValueEntry);
                                    ValueEntries.Editable(false);
                                    ValueEntries.RunModal();
                                end;
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        TempRec := Rec;
        if not TempRec.Find(Which) then
            exit(false);
        Rec := TempRec;
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        CurrentSteps: Integer;
    begin
        TempRec := Rec;
        CurrentSteps := TempRec.Next(Steps);
        if CurrentSteps <> 0 then
            Rec := TempRec;
        exit(CurrentSteps);
    end;

    var
        TempRec: Record "NPR Sales Stats Time Period" temporary;
        StartDateTime: DateTime;
        EndDateTime: DateTime;
        Dim1Filter: Text;
        Dim2Filter: Text;
        ItemNoFilter: Text;
        ItemCategoryCodeFilter: Text;
        Statistics: Option ,Item,"Item Category";

    internal procedure PopulateTemp(StartDate: Date; EndDate: Date; VarStatisticsBy: Option ,Item,"Item Category"; VarItemFilter: Text; VarItemCatFilter: Text; VarDim1Filter: Text; VarDim2Filter: Text)
    var
        ItemQtyQuery: Query "NPR Sales Stat. -Item Cat Qty";
        ItemCatQtyQuery: Query "NPR Sales Stat. -Item Cat Qty";
        ItemAmtQuery: Query "NPR Value Entry With Item Cat";
        ItemCatAmtQuery: Query "NPR Value Entry With Item Cat";
        Item: Record Item;
        ItemCategory: Record "Item Category";
    begin
        TempRec.DeleteAll();
        ItemNoFilter := VarItemFilter;
        ItemCategoryCodeFilter := VarItemCatFilter;
        Dim1Filter := VarDim1Filter;
        Dim2Filter := VarDim2Filter;
        Statistics := VarStatisticsBy;
        case VarStatisticsBy of
            VarStatisticsBy::Item:
                begin
                    ItemQtyQuery.SetRange(ItemQtyQuery.Filter_Entry_Type, ItemQtyQuery.Filter_Entry_Type::Sale);
                    ItemQtyQuery.SetFilter(ItemQtyQuery.Filter_Date, '%1..%2', StartDate, EndDate);
                    ItemQtyQuery.SetFilter(ItemQtyQuery.Filter_Item_No, ItemNoFilter);
                    ItemQtyQuery.SetFilter(ItemQtyQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemQtyQuery.SetFilter(ItemQtyQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemQtyQuery.SetFilter(ItemQtyQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemQtyQuery.Open();
                    while ItemQtyQuery.Read() do begin
                        TempRec.Init();
                        TempRec."No." := ItemQtyQuery.Item_No;
                        if Item.Get(ItemQtyQuery.Item_No) then
                            TempRec.Description := Item.Description;
                        TempRec."Sales (Qty)" := -ItemQtyQuery.Sum_Quantity;
                        TempRec.Insert();
                    end;

                    ItemAmtQuery.SetRange(ItemAmtQuery.Filter_Entry_Type, ItemAmtQuery.Filter_Entry_Type::Sale);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_DateTime, '%1..%2', DT2Date(StartDateTime), DT2Date(EndDateTime));
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Item_No, ItemNoFilter);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemAmtQuery.Open();
                    while ItemAmtQuery.Read() do begin
                        if TempRec.Get(ItemAmtQuery.Item_No) then begin
                            TempRec."Sales (LCY)" := ItemAmtQuery.Sum_Sales_Amount_Actual;
                            TempRec.Modify();
                        end;
                    end;
                end;

            VarStatisticsBy::"Item Category":
                begin
                    ItemCatQtyQuery.SetRange(ItemCatQtyQuery.Filter_Entry_Type, ItemCatQtyQuery.Filter_Entry_Type::Sale);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Date, '%1..%2', StartDate, EndDate);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Item_No, ItemNoFilter);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemCatQtyQuery.Open();
                    while ItemCatQtyQuery.Read() do begin
                        TempRec.Init();
                        TempRec."No." := ItemCatQtyQuery.Item_Category_Code;
                        if ItemCategory.Get(ItemCatQtyQuery.Item_Category_Code) then
                            TempRec.Description := ItemCategory.Description;
                        TempRec."Sales (Qty)" := -ItemCatQtyQuery.Sum_Quantity;
                        TempRec.Insert();
                    end;

                    ItemCatAmtQuery.SetRange(ItemCatAmtQuery.Filter_Entry_Type, ItemCatAmtQuery.Filter_Entry_Type::Sale);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_DateTime, '%1..%2', StartDate, EndDate);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Item_No, ItemNoFilter);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemCatAmtQuery.Open();
                    while ItemCatAmtQuery.Read() do begin
                        if TempRec.Get(ItemCatAmtQuery.Item_Category_Code) then begin
                            TempRec."Sales (LCY)" := ItemCatAmtQuery.Sum_Sales_Amount_Actual;
                            TempRec.Modify();
                        end
                    end;
                end;
        end;
        CurrPage.Update();
    end;

    internal procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry"; varNo: Code[20])
    begin
        //SetItemLedgerEntryFilter
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', DT2Date(StartDateTime), DT2Date(EndDateTime));
        case Statistics of
            Statistics::Item:
                ItemLedgerEntry.SetRange("Item No.", varNo);
            Statistics::"Item Category":
                ItemLedgerEntry.SetRange("Item Category Code", varNo);
        end;

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    internal procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry"; varNo: Code[20])
    begin
        //SetValueEntryFilter
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetFilter("Posting Date", '%1..%2', DT2Date(StartDateTime), DT2Date(EndDateTime));
        case Statistics of
            Statistics::Item:
                ValueEntry.SetRange("Item No.", varNo);
        end;

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ValueEntry.SetRange("Global Dimension 2 Code");
    end;
}

