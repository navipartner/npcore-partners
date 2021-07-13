report 6059905 "NPR Adjust Cost: ItemEntriesTQ"
{
    Caption = 'Adjust Cost - Item Entries';
    Permissions = TableData "Item Ledger Entry" = rimd,
                  TableData "Item Application Entry" = r,
                  TableData "Value Entry" = rimd,
                  TableData "Avg. Cost Adjmt. Entry Point" = rimd;
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;
    dataset
    {
        dataitem("Task Line"; "NPR Task Line")
        {
            DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.");

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
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

                        ToolTip = 'Specifies the value of the Item No. Filter field';
                        ApplicationArea = NPRRetail;
                    }
                    field(FilterItemCategory; ItemCategoryFilter)
                    {
                        Caption = 'Item Category Filter';
                        Editable = FilterItemCategoryEditable;
                        TableRelation = "Item Category";

                        ToolTip = 'Specifies the value of the Item Category Filter field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Post; PostToGL)
                    {
                        Caption = 'Post to G/L';
                        Enabled = PostEnable;

                        ToolTip = 'Specifies the value of the Post to G/L field';
                        ApplicationArea = NPRRetail;

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
                    field("Skip Various Items"; SkipVariousItems)
                    {
                        Caption = 'Skip Various Items';

                        ToolTip = 'Specifies the value of the Skip Various Items field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

        trigger OnInit()
        begin
            FilterItemCategoryEditable := true;
            FilterItemNoEditable := true;
            PostEnable := true;
            SkipVariousItems := true;
        end;

        trigger OnOpenPage()
        begin
            InvtSetup.Get();
            PostToGL := InvtSetup."Automatic Cost Posting";
            PostEnable := PostToGL;
        end;
    }

    trigger OnPostReport()
    begin
        DataLogMgt.DisableDataLog(false);
    end;

    trigger OnPreReport()
    var
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        Item: Record Item;
        ItemApplnEntry: Record "Item Application Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        UpdateItemAnalysisView: Codeunit "Update Item Analysis View";
        ItemNoFilterLbl: Label 'ITEMNOFILTER';
        ItemCategoryFilterLbl: Label 'ITEMCATEGORYFILTER';
        PostToGLLbl: Label 'POSTTOGL';
        SkipVariousItemsLbl: Label 'SKIPVARIOUSITEMS';
    begin
        DataLogMgt.DisableDataLog(true);
        ItemApplnEntry.LockTable();
        if not ItemApplnEntry.FindLast() then
            exit;
        ItemLedgEntry.LockTable();
        if not ItemLedgEntry.FindLast() then
            exit;
        AvgCostAdjmtEntryPoint.LockTable();
        if AvgCostAdjmtEntryPoint.FindLast() then;
        ValueEntry.LockTable();
        if not ValueEntry.FindLast() then
            exit;

        if "Task Line".GetFilters <> '' then
            if "Task Line".Find('-') then
                if not CurrReport.UseRequestPage() then begin
                    ItemNoFilter := "Task Line".GetParameterText(ItemNoFilterLbl);
                    ItemCategoryFilter := "Task Line".GetParameterText(ItemCategoryFilterLbl);
                    PostToGL := "Task Line".GetParameterBool(PostToGLLbl);
                    SkipVariousItems := "Task Line".GetParameterBool(SkipVariousItemsLbl);
                end;

        if (ItemNoFilter <> '') and (ItemCategoryFilter <> '') then
            Error(ItemNoAndCategoryErr);

        if ItemNoFilter <> '' then
            Item.SetFilter("No.", ItemNoFilter);
        if ItemCategoryFilter <> '' then
            Item.SetFilter("Item Category Code", ItemCategoryFilter);
        if SkipVariousItems then
            Item.SetRange("NPR Group sale", false);
        InvtAdjmt.SetProperties(false, PostToGL);
        InvtAdjmt.SetFilterItem(Item);
        InvtAdjmt.MakeMultiLevelAdjmt();

        UpdateItemAnalysisView.UpdateAll(0, true);
    end;

    var
        InvtSetup: Record "Inventory Setup";
        InvtAdjmt: Codeunit "Inventory Adjustment";
        DataLogMgt: Codeunit "NPR Data Log Management";
        [InDataSet]
        FilterItemCategoryEditable: Boolean;
        [InDataSet]
        FilterItemNoEditable: Boolean;
        [InDataSet]
        PostEnable: Boolean;
        PostToGL: Boolean;
        SkipVariousItems: Boolean;
        ItemNoAndCategoryErr: Label 'You must not use Item No. Filter and Item Category Filter at the same time.';
        ResynchronizeInfoMsg: Label 'Your general and item ledgers will no longer be synchronized after running the cost adjustment. You must run the %1 report to synchronize them again.', Comment = '%1 = Report';
        ItemCategoryFilter: Text[250];
        ItemNoFilter: Text[250];

    procedure InitializeRequest(NewItemNoFilter: Text[250]; NewItemCategoryFilter: Text[250])
    begin
        ItemNoFilter := NewItemNoFilter;
        ItemCategoryFilter := NewItemCategoryFilter;
    end;
}

