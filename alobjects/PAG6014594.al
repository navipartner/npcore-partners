page 6014594 "Sales Statistics Subform"
{
    // NPR5.52/ZESO/20191010  Object created
    // NPR5.53/ZESO/20191205  CASE 371446 New Function GetGlobals
    // NPR5.53/ZESO/20191210  CASE 371446 Populate Description
    // NPR5.53/ZESO/20191211  CASE 371446 New Function SetTempRec
    // NPR5.55/BHR /20200724 CASE 361515 Comment Key not used in AL

    Caption = 'Sales Statistics Subform';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Sales Statistics Time Period";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Sales (Qty)"; "Sales (Qty)")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                        ItemLedgerEntryForm: Page "Item Ledger Entries";
                    begin
                        SetItemLedgerEntryFilter(ItemLedgerEntry, "No.");
                        ItemLedgerEntryForm.SetTableView(ItemLedgerEntry);
                        ItemLedgerEntryForm.Editable(false);
                        ItemLedgerEntryForm.RunModal;
                    end;
                }
                field("Sales (LCY)"; "Sales (LCY)")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        ValueEntry: Record "Value Entry";
                        ValueEntryForm: Page "Value Entries";
                    begin
                        SetValueEntryFilter(ValueEntry, "No.");
                        ValueEntryForm.SetTableView(ValueEntry);
                        ValueEntryForm.Editable(false);
                        ValueEntryForm.RunModal;
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
        TempRec: Record "Sales Statistics Time Period" temporary;
        StartDateTime: DateTime;
        EndDateTime: DateTime;
        ItemGroupFilter: Text;
        Dim1Filter: Text;
        Dim2Filter: Text;
        ItemNoFilter: Text;
        ItemCategoryCodeFilter: Text;
        Statistics: Option ,Item,"Item Group","Item Category";

    procedure PopulateTemp(StartDate: Date; EndDate: Date; StartTime: Time; EndTime: Time; VarStatisticsBy: Option ,Item,"Item Group","Item Category"; VarItemFilter: Text; VarItemCatFilter: Text; VarItemGroupFilter: Text; VarDim1Filter: Text; VarDim2Filter: Text)
    var
        ItemQtyQuery: Query "Sales Statistics - Item Qty";
        ItemGroupQtyQuery: Query "Sales Statistics - Item Gr Qty";
        ItemCatQtyQuery: Query "Sales Statistics -Item Cat Qty";
        ItemAmtQuery: Query "Sales Stats - Item Sales";
        ItemGroupAmtQuery: Query "Sales Stats - Item Grp Sales";
        ItemCatAmtQuery: Query "Sales Stats - Item Cat Sales";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ItemGroup: Record "Item Group";
    begin
        TempRec.DeleteAll;
        StartDateTime := CreateDateTime(StartDate, StartTime);
        EndDateTime := CreateDateTime(EndDate, EndTime);
        ItemNoFilter := VarItemFilter;
        ItemGroupFilter := VarItemGroupFilter;
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
                    ItemQtyQuery.Open;
                    while ItemQtyQuery.Read do begin
                        TempRec.Init;
                        TempRec."No." := ItemQtyQuery.Item_No;
                        //-NPR5.53 [371446]
                        if Item.Get(ItemQtyQuery.Item_No) then
                            TempRec.Description := Item.Description;
                        //+NPR5.53 [371446]
                        TempRec."Sales (Qty)" := -ItemQtyQuery.Sum_Quantity;
                        TempRec.Insert;
                    end;

                    ItemAmtQuery.SetRange(ItemAmtQuery.Filter_Entry_Type, ItemAmtQuery.Filter_Entry_Type::Sale);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Item_No, ItemNoFilter);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Item_Group_No, ItemGroupFilter);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemAmtQuery.SetFilter(ItemAmtQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemAmtQuery.Open;
                    while ItemAmtQuery.Read do begin
                        if TempRec.Get(ItemAmtQuery.Item_No) then begin
                            TempRec."Sales (LCY)" := ItemAmtQuery.Sum_Sales_Amount_Actual;
                            TempRec.Modify;
                        end;
                    end;




                end;

            VarStatisticsBy::"Item Group":
                begin
                    ItemGroupQtyQuery.SetRange(ItemGroupQtyQuery.Filter_Entry_Type, ItemGroupQtyQuery.Filter_Entry_Type::Sale);
                    ItemGroupQtyQuery.SetFilter(ItemGroupQtyQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
                    ItemGroupQtyQuery.SetFilter(ItemGroupQtyQuery.Filter_Item_No, ItemNoFilter);
                    ItemGroupQtyQuery.SetFilter(ItemGroupQtyQuery.Filter_Item_Group_No, ItemGroupFilter);
                    ItemGroupQtyQuery.SetFilter(ItemGroupQtyQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemGroupQtyQuery.SetFilter(ItemGroupQtyQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemGroupQtyQuery.SetFilter(ItemGroupQtyQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemGroupQtyQuery.Open;
                    while ItemGroupQtyQuery.Read do begin
                        TempRec.Init;
                        TempRec."No." := ItemGroupQtyQuery.Item_Group_No;
                        //-NPR5.53 [371446]
                        if ItemGroup.Get(ItemGroupQtyQuery.Item_Group_No) then
                            TempRec.Description := ItemGroup.Description;
                        //+NPR5.53 [371446]
                        TempRec."Sales (Qty)" := -ItemGroupQtyQuery.Sum_Quantity;
                        TempRec.Insert;
                    end;

                    ItemGroupAmtQuery.SetRange(ItemGroupAmtQuery.Filter_Entry_Type, ItemGroupAmtQuery.Filter_Entry_Type::Sale);
                    ItemGroupAmtQuery.SetFilter(ItemGroupAmtQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
                    ItemGroupAmtQuery.SetFilter(ItemGroupAmtQuery.Filter_Item_No, ItemNoFilter);
                    ItemGroupAmtQuery.SetFilter(ItemGroupAmtQuery.Filter_Item_Group_No, ItemGroupFilter);
                    ItemGroupAmtQuery.SetFilter(ItemGroupAmtQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemGroupAmtQuery.SetFilter(ItemGroupAmtQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemGroupAmtQuery.SetFilter(ItemGroupAmtQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemGroupAmtQuery.Open;
                    while ItemGroupAmtQuery.Read do begin
                        if TempRec.Get(ItemGroupAmtQuery.Item_Group_No) then begin
                            TempRec."Sales (LCY)" := ItemGroupAmtQuery.Sum_Sales_Amount_Actual;
                            TempRec.Modify;
                        end;
                    end;
                end;

            VarStatisticsBy::"Item Category":
                begin
                    ItemCatQtyQuery.SetRange(ItemCatQtyQuery.Filter_Entry_Type, ItemCatQtyQuery.Filter_Entry_Type::Sale);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Item_No, ItemNoFilter);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Item_Group_No, ItemGroupFilter);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemCatQtyQuery.SetFilter(ItemCatQtyQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemCatQtyQuery.Open;
                    while ItemCatQtyQuery.Read do begin
                        TempRec.Init;
                        TempRec."No." := ItemCatQtyQuery.Item_Category_Code;
                        //-NPR5.53 [371446]
                        if ItemCategory.Get(ItemCatQtyQuery.Item_Category_Code) then
                            TempRec.Description := ItemCategory.Description;
                        //+NPR5.53 [371446]
                        TempRec."Sales (Qty)" := -ItemCatQtyQuery.Sum_Quantity;
                        TempRec.Insert;
                    end;

                    ItemCatAmtQuery.SetRange(ItemCatAmtQuery.Filter_Entry_Type, ItemCatAmtQuery.Filter_Entry_Type::Sale);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_DateTime, '%1..%2', StartDateTime, EndDateTime);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Item_No, ItemNoFilter);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Item_Group_No, ItemGroupFilter);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Item_Category_Code, ItemCategoryCodeFilter);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Dim_1_Code, Dim1Filter);
                    ItemCatAmtQuery.SetFilter(ItemCatAmtQuery.Filter_Dim_2_Code, Dim2Filter);
                    ItemCatAmtQuery.Open;
                    while ItemCatAmtQuery.Read do begin
                        if TempRec.Get(ItemCatAmtQuery.Item_Category_Code) then begin
                            TempRec."Sales (LCY)" := ItemCatAmtQuery.Sum_Sales_Amount_Actual;
                            TempRec.Modify;
                        end
                    end;
                end;
        end;
        CurrPage.Update;
    end;

    procedure SetItemLedgerEntryFilter(var ItemLedgerEntry: Record "Item Ledger Entry"; varNo: Code[20])
    begin
        //SetItemLedgerEntryFilter
        ItemLedgerEntry.SetCurrentKey("Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetFilter("Document Date and Time", '%1..%2', StartDateTime, EndDateTime);
        case Statistics of
            Statistics::Item:
                ItemLedgerEntry.SetRange("Item No.", varNo);
            Statistics::"Item Category":
                ItemLedgerEntry.SetRange("Item Category Code", varNo);
            Statistics::"Item Group":
                ItemLedgerEntry.SetRange("Item Group No.", varNo);
        end;

        //IF ItemGroupFilter <> '' THEN
        //ItemLedgerEntry.SETRANGE( "Item Group No.", ItemGroupFilter )
        //ELSE
        //ItemLedgerEntry.SETRANGE( "Item Group No.",varNo);

        if Dim1Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ItemLedgerEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ItemLedgerEntry.SetRange("Global Dimension 2 Code");

        //IF ItemNoFilter <> ''  THEN
        //ItemLedgerEntry.SETFILTER("Item No.",ItemNoFilter)
        //ELSE
        //ItemLedgerEntry.SETRANGE("Item No.",varNo);

        //IF ItemCategoryCodeFilter <> ''  THEN
        //ItemLedgerEntry.SETFILTER("Item Category Code",ItemCategoryCodeFilter)
        //ELSE
        //ItemLedgerEntry.SETRANGE("Item Category Code",varNo);
    end;

    procedure SetValueEntryFilter(var ValueEntry: Record "Value Entry"; varNo: Code[20])
    begin
        //SetValueEntryFilter
        //-NPR5.55 [361515]
        //ValueEntry.SETCURRENTKEY( "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code" );
        //+NPR5.55 [361515]
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetFilter("Document Date and Time", '%1..%2', StartDateTime, EndDateTime);
        case Statistics of
            Statistics::Item:
                ValueEntry.SetRange("Item No.", varNo);
            Statistics::"Item Category":
                ValueEntry.SetRange("Item Category Code", varNo);
            Statistics::"Item Group":
                ValueEntry.SetRange("Item Group No.", varNo);
        end;

        //IF ItemGroupFilter <> '' THEN
        //ValueEntry.SETRANGE( "Item Group No.", ItemGroupFilter )
        //ELSE
        //ValueEntry.SETRANGE( "Item Group No.",varNo);

        if Dim1Filter <> '' then
            ValueEntry.SetRange("Global Dimension 1 Code", Dim1Filter)
        else
            ValueEntry.SetRange("Global Dimension 1 Code");

        if Dim2Filter <> '' then
            ValueEntry.SetRange("Global Dimension 2 Code", Dim2Filter)
        else
            ValueEntry.SetRange("Global Dimension 2 Code");


        //IF ItemCategoryCodeFilter <> ''  THEN
        //ValueEntry.SETFILTER("Item Category Code",ItemCategoryCodeFilter)
        //ELSE
        //ValueEntry.SETRANGE("Item Category Code",varNo);


        //IF ItemNoFilter <> ''  THEN
        //ValueEntry.SETFILTER("Item No.",ItemNoFilter)
        //ELSE
        //ValueEntry.SETRANGE("Item No.",varNo);
    end;

    procedure GetGlobals(var InStartDate: Date; var InEndDate: Date; var InStartTime: Time; var InEndTime: Time; var InVarStatisticsBy: Option; var InVarItemFilter: Text; var InVarItemCatFilter: Text; var InVarItemGroupFilter: Text; var InVarDim1Filter: Text; var InVarDim2Filter: Text)
    begin
        //-NPR5.53 [371446]
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
        //+NPR5.53 [371446]
    end;

    procedure SetTempRec(var NewTempRec: Record "Sales Statistics Time Period")
    begin
        //-NPR5.53 [371446]
        TempRec.Copy(NewTempRec, true);
        //+NPR5.53 [371446]
    end;
}

