report 6059905 "NPR Adjust Cost: ItemEntriesTQ"
{
    // TQ1.28.02/JDH/20161013 CASE 242568 Possible to run in 1.28 version (and before) of TQ
    // NPR5.31/BR  /20170428  CASE 271478 Added option Skip Various Items
    // TQ1.31/MHA /20171218  CASE 271126 Data Log Disabled during Report Run

    Caption = 'Adjust Cost - Item Entries';
    Permissions = TableData "Item Ledger Entry" = rimd,
                  TableData "Item Application Entry" = r,
                  TableData "Value Entry" = rimd,
                  TableData "Avg. Cost Adjmt. Entry Point" = rimd;
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Task Line"; "NPR Task Line")
        {
            DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.");

            trigger OnPreDataItem()
            begin
                //-TQ1.28.02
                CurrReport.Break;
                //+TQ1.28.02
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FilterItemNo; ItemNoFilter)
                    {
                        Caption = 'Item No. Filter';
                        Editable = FilterItemNoEditable;
                        TableRelation = Item;
                        ApplicationArea=All;
                    }
                    field(FilterItemCategory; ItemCategoryFilter)
                    {
                        Caption = 'Item Category Filter';
                        Editable = FilterItemCategoryEditable;
                        TableRelation = "Item Category";
                        ApplicationArea=All;
                    }
                    field(Post; PostToGL)
                    {
                        Caption = 'Post to G/L';
                        Enabled = PostEnable;
                        ApplicationArea=All;

                        trigger OnValidate()
                        var
                            ObjTransl: Record "Object Translation";
                        begin
                            if not PostToGL then
                                Message(
                                  ResynchronizeInfoMsg,
                                  ObjTransl.TranslateObject(ObjTransl."Object Type"::Report, REPORT::"Post Inventory Cost to G/L"));
                        end;
                    }
                    field(SkipVariousItems; SkipVariousItems)
                    {
                        Caption = 'Skip Various Items';
                        ApplicationArea=All;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            FilterItemCategoryEditable := true;
            FilterItemNoEditable := true;
            PostEnable := true;
            //-NPR5.31 [271478]
            SkipVariousItems := true;
            //+NPR5.31 [271478]
        end;

        trigger OnOpenPage()
        begin
            InvtSetup.Get;
            PostToGL := InvtSetup."Automatic Cost Posting";
            PostEnable := PostToGL;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        //-TQ1.31 [271126]
        DataLogMgt.DisableDataLog(false);
        //+TQ1.31 [271126]
    end;

    trigger OnPreReport()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ItemApplnEntry: Record "Item Application Entry";
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        Item: Record Item;
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
    begin
        //-TQ1.31 [271126]
        DataLogMgt.DisableDataLog(true);
        //+TQ1.31 [271126]
        ItemApplnEntry.LockTable;
        if not ItemApplnEntry.FindLast then
            exit;
        ItemLedgEntry.LockTable;
        if not ItemLedgEntry.FindLast then
            exit;
        AvgCostAdjmtEntryPoint.LockTable;
        if AvgCostAdjmtEntryPoint.FindLast then;
        ValueEntry.LockTable;
        if not ValueEntry.FindLast then
            exit;

        //-TQ1.28.02
        with "Task Line" do begin
            if GetFilters <> '' then
                if Find('-') then
                    if not CurrReport.UseRequestPage then begin
                        ItemNoFilter := GetParameterText('ITEMNOFILTER');
                        ItemCategoryFilter := GetParameterText('ITEMCATEGORYFILTER');
                        PostToGL := GetParameterBool('POSTTOGL');
                        //-NPR5.31 [271478]
                        SkipVariousItems := GetParameterBool('SKIPVARIOUSITEMS');
                        //+NPR5.31 [271478]
                    end;
        end;
        //+TQ1.28.02

        if (ItemNoFilter <> '') and (ItemCategoryFilter <> '') then
            Error(Text005);

        if ItemNoFilter <> '' then
            Item.SetFilter("No.", ItemNoFilter);
        if ItemCategoryFilter <> '' then
            Item.SetFilter("Item Category Code", ItemCategoryFilter);
        //-NPR5.31 [271478]
        if SkipVariousItems then
            Item.SetRange("NPR Group sale", false);
        //+NPR5.31 [271478]
        InvtAdjmt.SetProperties(false, PostToGL);
        InvtAdjmt.SetFilterItem(Item);
        InvtAdjmt.MakeMultiLevelAdjmt;

        UpdateItemAnalysisView.UpdateAll(0, true);
    end;

    var
        ResynchronizeInfoMsg: Label 'Your general and item ledgers will no longer be synchronized after running the cost adjustment. You must run the %1 report to synchronize them again.';
        InvtSetup: Record "Inventory Setup";
        InvtAdjmt: Codeunit "Inventory Adjustment";
        ItemNoFilter: Text[250];
        ItemCategoryFilter: Text[250];
        Text005: Label 'You must not use Item No. Filter and Item Category Filter at the same time.';
        PostToGL: Boolean;
        [InDataSet]
        PostEnable: Boolean;
        [InDataSet]
        FilterItemNoEditable: Boolean;
        [InDataSet]
        FilterItemCategoryEditable: Boolean;
        SkipVariousItems: Boolean;
        DataLogMgt: Codeunit "NPR Data Log Management";

    procedure InitializeRequest(NewItemNoFilter: Text[250]; NewItemCategoryFilter: Text[250])
    begin
        ItemNoFilter := NewItemNoFilter;
        ItemCategoryFilter := NewItemCategoryFilter;
    end;
}

