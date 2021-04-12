page 6014594 "NPR Sales Stats Subform"
{
    Caption = 'Sales Statistics Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Sales Stats Time Period";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Sales (Qty)"; Rec."Sales (Qty)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales (Qty) field';

                    trigger OnDrillDown()
                    var
                        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
                        ItemLedgerEntryForm: Page "NPR Aux. Item Ledger Entries";
                    begin
                        SetItemLedgerEntryFilter(AuxItemLedgerEntry, Rec."No.");
                        ItemLedgerEntryForm.SetTableView(AuxItemLedgerEntry);
                        ItemLedgerEntryForm.Editable(false);
                        ItemLedgerEntryForm.RunModal();
                    end;
                }
                field("Sales (LCY)"; Rec."Sales (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales (LCY) field';

                    trigger OnDrillDown()
                    var
                        AuxValueEntry: Record "NPR Aux. Value Entry";
                        AuxValueEntries: Page "NPR Aux. Value Entries";
                    begin
                        SetValueEntryFilter(AuxValueEntry, Rec."No.");
                        AuxValueEntries.SetTableView(AuxValueEntry);
                        AuxValueEntries.Editable(false);
                        AuxValueEntries.RunModal();
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
        ItemGroupFilter: Text;
        Dim1Filter: Text;
        Dim2Filter: Text;
        ItemNoFilter: Text;
        ItemCategoryCodeFilter: Text;
        Statistics: Option ,Item,"Item Category";

    procedure PopulateTemp(StartDate: Date; EndDate: Date; StartTime: Time; EndTime: Time; VarStatisticsBy: Option ,Item,"Item Category"; VarItemFilter: Text; VarItemCatFilter: Text; VarDim1Filter: Text; VarDim2Filter: Text)
    var
        ItemQtyQuery: Query "NPR Sales Stat - Item Qty";
        ItemCatQtyQuery: Query "NPR Sales Stat. -Item Cat Qty";
        ItemAmtQuery: Query "NPR Sales Stats - Item Sales";
        ItemCatAmtQuery: Query "NPR Sales Stats: Item Cat.";
        Item: Record Item;
        ItemCategory: Record "Item Category";
    begin
        TempRec.DeleteAll();
        StartDateTime := CreateDateTime(StartDate, StartTime);
        EndDateTime := CreateDateTime(EndDate, EndTime);
        ItemNoFilter := VarItemFilter;
        ItemCategoryCodeFilter := VarItemCatFilter;
        Dim1Filter := VarDim1Filter;
        Dim2Filter := VarDim2Filter;
        Statistics := VarStatisticsBy;
        case VarStatisticsBy of
            VarStatisticsBy::Item:
                begin
                    ItemQtyQuery.SetRange(ItemQtyQuery.Filter_Entry_Type, ItemQtyQuery.Filter_Entry_Type::Sale);
                    ItemQtyQuery.SetFilter(ItemQtyQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
                    ItemQtyQuery.SetFilter(ItemQtyQuery.Filter_Item_No, ItemNoFilter);
                    ItemQtyQuery.SetFilter(ItemQtyQuery.Filter_Item_Group_No, ItemGroupFilter);
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
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Item_No, ItemNoFilter);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Item_Group_No, ItemGroupFilter);
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
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
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
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
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

    procedure SetItemLedgerEntryFilter(var AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry"; varNo: Code[20])
    begin
        //SetItemLedgerEntryFilter
        AuxItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
        AuxItemLedgerEntry.SetFilter("Document Date and Time", '%1..%2', StartDateTime, EndDateTime);
        case Statistics of
            Statistics::Item:
                AuxItemLedgerEntry.SetRange("Item No.", varNo);
            Statistics::"Item Category":
                AuxItemLedgerEntry.SetRange("Item Category Code", varNo);
        end;

        if Dim1Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            AuxItemLedgerEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure SetValueEntryFilter(var AuxValueEntry: Record "NPR Aux. Value Entry"; varNo: Code[20])
    begin
        //SetValueEntryFilter
        AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
        AuxValueEntry.SetFilter("Document Date and Time", '%1..%2', StartDateTime, EndDateTime);
        case Statistics of
            Statistics::Item:
                AuxValueEntry.SetRange("Item No.", varNo);
            Statistics::"Item Category":
                AuxValueEntry.SetRange("Item Category Code", varNo);
        end;

        if Dim1Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            AuxValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            AuxValueEntry.SetRange("Global Dimension 2 Code");
    end;

    procedure GetGlobals(var InStartDate: Date; var InEndDate: Date; var InStartTime: Time; var InEndTime: Time; var InVarStatisticsBy: Option; var InVarItemFilter: Text; var InVarItemCatFilter: Text; var InVarItemGroupFilter: Text; var InVarDim1Filter: Text; var InVarDim2Filter: Text)
    begin
        InStartDate := DT2Date(StartDateTime);
        InEndDate := DT2Date(EndDateTime);
        InStartTime := DT2Time(StartDateTime);
        InEndTime := DT2Time(EndDateTime);
        InVarStatisticsBy := Statistics;
        InVarItemFilter := ItemNoFilter;
        InVarItemCatFilter := ItemCategoryCodeFilter;
        InVarItemGroupFilter := ItemGroupFilter;
        InVarDim1Filter := Dim1Filter;
        InVarDim2Filter := Dim2Filter;
    end;

    procedure SetTempRec(var NewTempRec: Record "NPR Sales Stats Time Period")
    begin
        TempRec.Copy(NewTempRec, true);
    end;
}

