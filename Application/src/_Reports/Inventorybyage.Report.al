report 6014400 "NPR Inventory by age"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Inventory by age.rdlc';
    Caption = 'Inventory By Age';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ItemCategoryHeader; "Item Category")
        {
            DataItemTableView = SORTING("Presentation Order");
            RequestFilterFields = "Code";
            column(PageNoCaptionLbl; PageNoCaptionLbl)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(No_Caption; No_Caption_Lbl)
            {
            }
            column(Description_Caption; Description_Caption_Lbl)
            {
            }
            column(Before_Caption; Before_Caption_Lbl)
            {
            }
            column(PeriodStartDato_2; (PeriodStartDato[2]))
            {
            }
            column(PeriodStartDato_3; (PeriodStartDato[3] - 1))
            {
            }
            column(PeriodStartDato_4; (PeriodStartDato[4] - 1))
            {
            }
            column(PeriodStartDato_5; (PeriodStartDato[5] - 1))
            {
            }
            column(After_Caption; After_Caption_Lbl)
            {
            }
            column(Total_Caption; Total_Caption_Lbl)
            {
            }
            column(No_ItemGroupHeader; "Code")
            {
            }
            column(Description_ItemGroupHeader; Description)
            {
            }
            column(ShowItem; ShowItem)
            {
            }
            column(Main_Item_Group_ItemGroupHeader; "NPR Main Category Code")
            {
            }
            column(PeriodLength; PeriodLength)
            {
            }
            column(n; n)
            {
            }
            column(RequestPageFilters; RequestPageFilters)
            {
            }
            column(ItemGrpNoLvl0; StrSubstNo(TotalText, "Code"))
            {
            }
            column(ItemFound1; ItemFound[1])
            {
            }
            column(ExistItemGrpSub1; ExistItemGrpSub[1])
            {
            }
            column(PeriodRange1; PeriodRange[1])
            {
            }
            column(PeriodRange2; PeriodRange[2])
            {
            }
            column(PeriodRange3; PeriodRange[3])
            {
            }
            column(PeriodRange4; PeriodRange[4])
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "Item Category Code" = FIELD("Code");
                column(No_Item; "No.")
                {
                }
                column(Description_Item; Description)
                {
                }
                column(RemainingAmt_1_1; RemainingAmt[1] [1])
                {
                }
                column(RemainingAmt_1_2; RemainingAmt[1] [2])
                {
                }
                column(RemainingAmt_1_3; RemainingAmt[1] [3])
                {
                }
                column(RemainingAmt_1_4; RemainingAmt[1] [4])
                {
                }
                column(RemainingAmt_1_5; RemainingAmt[1] [5])
                {
                }
                column(Total_RemainingAmt_1; TotalRemaingAmt[1])
                {
                }
                column(AmountCalc_1_1; AmountCalc[1] [1])
                {
                }
                column(AmountCalc_1_2; AmountCalc[1] [2])
                {
                }
                column(AmountCalc_1_3; AmountCalc[1] [3])
                {
                }
                column(AmountCalc_1_4; AmountCalc[1] [4])
                {
                }
                column(AmountCalc_1_5; AmountCalc[1] [5])
                {
                }
                column(Total_AmountCalc_1; TotalAmtCalc[1])
                {
                }
                column(ItemSection1; ItemSection[1])
                {
                }
                column(ExistNonZeroItemRecords1; ExistNonZeroItemRecords[1])
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Calculation(n, "No.", "Last Direct Cost");

                    TotalRemaingAmt[1] := RemainingAmt[1] [1] + RemainingAmt[1] [2] + RemainingAmt[1] [3] + RemainingAmt[1] [4] + RemainingAmt[1] [5];
                    TotalAmtCalc[1] := AmountCalc[1] [1] + AmountCalc[1] [2] + AmountCalc[1] [3] + AmountCalc[1] [4] + AmountCalc[1] [5];

                    if not ShowZeroLines then
                        if ((TotalRemaingAmt[1] = 0) and (TotalAmtCalc[1] = 0)) then
                            CurrReport.Skip();

                    ExistNonZeroItemRecords[1] := true;
                end;

                trigger OnPreDataItem()
                begin
                    ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");

                    n := 1;
                    Clear(ItemSection);
                    ItemSection[1] := true;
                    Clear(ExistNonZeroItemRecords);
                end;
            }
            dataitem(ItemCategorySub1; "Item Category")
            {
                DataItemLink = "Parent Category" = FIELD("Code");
                DataItemTableView = SORTING("Code");
                column(No_ItemGroupSub1; "Code")
                {
                }
                column(Description_ItemGroupSub1; Description)
                {
                }
                column(ItemGrpNoLvl1; StrSubstNo(TotalText, "Code"))
                {
                }
                column(ItemFound2; ItemFound[2])
                {
                }
                column(ExistItemGrpSub2; ExistItemGrpSub[2])
                {
                }
                dataitem(Item1; Item)
                {
                    DataItemLink = "Item Category Code" = FIELD("Code");
                    column(No_Item1; "No.")
                    {
                    }
                    column(Description_Item1; Description)
                    {
                    }
                    column(RemainingAmt_2_1; RemainingAmt[2] [1])
                    {
                    }
                    column(RemainingAmt_2_2; RemainingAmt[2] [2])
                    {
                    }
                    column(RemainingAmt_2_3; RemainingAmt[2] [3])
                    {
                    }
                    column(RemainingAmt_2_4; RemainingAmt[2] [4])
                    {
                    }
                    column(RemainingAmt_2_5; RemainingAmt[2] [5])
                    {
                    }
                    column(Total_RemainingAmt_2; TotalRemaingAmt[2])
                    {
                    }
                    column(AmountCalc_2_1; AmountCalc[2] [1])
                    {
                    }
                    column(AmountCalc_2_2; AmountCalc[2] [2])
                    {
                    }
                    column(AmountCalc_2_3; AmountCalc[2] [3])
                    {
                    }
                    column(AmountCalc_2_4; AmountCalc[2] [4])
                    {
                    }
                    column(AmountCalc_2_5; AmountCalc[2] [5])
                    {
                    }
                    column(Total_AmountCalc_2; TotalAmtCalc[2])
                    {
                    }
                    column(ItemSection2; ItemSection[2])
                    {
                    }
                    column(ExistNonZeroItemRecords2; ExistNonZeroItemRecords[2])
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Calculation(n, "No.", "Last Direct Cost");

                        TotalRemaingAmt[2] := RemainingAmt[2] [1] + RemainingAmt[2] [2] + RemainingAmt[2] [3] + RemainingAmt[2] [4] + RemainingAmt[2] [5];
                        TotalAmtCalc[2] := AmountCalc[2] [1] + AmountCalc[2] [2] + AmountCalc[2] [3] + AmountCalc[2] [4] + AmountCalc[2] [5];

                        if not ShowZeroLines then
                            if ((TotalRemaingAmt[2] = 0) and (TotalAmtCalc[2] = 0)) then
                                CurrReport.Skip();

                        ExistNonZeroItemRecords[2] := true;
                    end;

                    trigger OnPreDataItem()
                    begin
                        ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                        ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");

                        n := 2;
                        Clear(ItemSection);
                        ItemSection[2] := true;
                        Clear(ExistNonZeroItemRecords);
                    end;
                }
                dataitem(ItemCategorySub2; "Item Category")
                {
                    DataItemLink = "Parent Category" = FIELD("Code");
                    DataItemTableView = SORTING("Presentation Order");
                    column(No_ItemGroupSub2; "Code")
                    {
                    }
                    column(Description_ItemGroupSub2; Description)
                    {
                    }
                    column(ItemGrpNoLvl2; StrSubstNo(TotalText, "Code"))
                    {
                    }
                    column(ItemFound3; ItemFound[3])
                    {
                    }
                    column(ExistItemGrpSub3; ExistItemGrpSub[3])
                    {
                    }
                    dataitem(Item2; Item)
                    {
                        CalcFields = Inventory;
                        DataItemLink = "Item Category Code" = FIELD("Code");
                        column(No_Item2; "No.")
                        {
                        }
                        column(Description_Item2; Description)
                        {
                        }
                        column(RemainingAmt_3_1; RemainingAmt[3] [1])
                        {
                        }
                        column(RemainingAmt_3_2; RemainingAmt[3] [2])
                        {
                        }
                        column(RemainingAmt_3_3; RemainingAmt[3] [3])
                        {
                        }
                        column(RemainingAmt_3_4; RemainingAmt[3] [4])
                        {
                        }
                        column(RemainingAmt_3_5; RemainingAmt[3] [5])
                        {
                        }
                        column(Total_RemainingAmt_3; TotalRemaingAmt[3])
                        {
                        }
                        column(AmountCalc_3_1; AmountCalc[3] [1])
                        {
                        }
                        column(AmountCalc_3_2; AmountCalc[3] [2])
                        {
                        }
                        column(AmountCalc_3_3; AmountCalc[3] [3])
                        {
                        }
                        column(AmountCalc_3_4; AmountCalc[3] [4])
                        {
                        }
                        column(AmountCalc_3_5; AmountCalc[3] [5])
                        {
                        }
                        column(Total_AmountCalc_3; TotalAmtCalc[3])
                        {
                        }
                        column(ItemSection3; ItemSection[3])
                        {
                        }
                        column(ExistNonZeroItemRecords3; ExistNonZeroItemRecords[3])
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            Calculation(n, "No.", "Last Direct Cost");

                            TotalRemaingAmt[3] := RemainingAmt[3] [1] + RemainingAmt[3] [2] + RemainingAmt[3] [3] + RemainingAmt[3] [4] + RemainingAmt[3] [5];
                            TotalAmtCalc[3] := AmountCalc[3] [1] + AmountCalc[3] [2] + AmountCalc[3] [3] + AmountCalc[3] [4] + AmountCalc[3] [5];

                            if not ShowZeroLines then
                                if ((TotalRemaingAmt[3] = 0) and (TotalAmtCalc[3] = 0)) then
                                    CurrReport.Skip();

                            ExistNonZeroItemRecords[3] := true;
                        end;

                        trigger OnPreDataItem()
                        begin
                            ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                            ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");

                            n := 3;
                            Clear(ItemSection);
                            ItemSection[3] := true;
                            Clear(ExistNonZeroItemRecords);
                        end;
                    }
                    dataitem(ItemCategorySub3; "Item Category")
                    {
                        DataItemLink = "Parent Category" = FIELD("Code");
                        DataItemTableView = SORTING("Parent Category");
                        column(No_ItemGroupSub3; "Code")
                        {
                        }
                        column(Description_ItemGroupSub3; Description)
                        {
                        }
                        column(ItemGrpNoLvl3; StrSubstNo(TotalText, "Code"))
                        {
                        }
                        column(ItemFound4; ItemFound[4])
                        {
                        }
                        column(ExistItemGrpSub4; ExistItemGrpSub[4])
                        {
                        }
                        dataitem(Item3; Item)
                        {
                            CalcFields = Inventory;
                            DataItemLink = "Item Category Code" = FIELD("Code");
                            column(No_Item3; "No.")
                            {
                            }
                            column(Description_Item3; Description)
                            {
                            }
                            column(RemainingAmt_4_1; RemainingAmt[4] [1])
                            {
                            }
                            column(RemainingAmt_4_2; RemainingAmt[4] [2])
                            {
                            }
                            column(RemainingAmt_4_3; RemainingAmt[4] [3])
                            {
                            }
                            column(RemainingAmt_4_4; RemainingAmt[4] [4])
                            {
                            }
                            column(RemainingAmt_4_5; RemainingAmt[4] [5])
                            {
                            }
                            column(Total_RemainingAmt_4; TotalRemaingAmt[4])
                            {
                            }
                            column(AmountCalc_4_1; AmountCalc[4] [1])
                            {
                            }
                            column(AmountCalc_4_2; AmountCalc[4] [2])
                            {
                            }
                            column(AmountCalc_4_3; AmountCalc[4] [3])
                            {
                            }
                            column(AmountCalc_4_4; AmountCalc[4] [4])
                            {
                            }
                            column(AmountCalc_4_5; AmountCalc[4] [5])
                            {
                            }
                            column(Total_AmountCalc_4; TotalAmtCalc[4])
                            {
                            }
                            column(ItemSection4; ItemSection[4])
                            {
                            }
                            column(ExistNonZeroItemRecords4; ExistNonZeroItemRecords[4])
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                Calculation(n, "No.", "Last Direct Cost");

                                TotalRemaingAmt[4] := RemainingAmt[4] [1] + RemainingAmt[4] [2] + RemainingAmt[4] [3] + RemainingAmt[4] [4] + RemainingAmt[4] [5];
                                TotalAmtCalc[4] := AmountCalc[4] [1] + AmountCalc[4] [2] + AmountCalc[4] [3] + AmountCalc[4] [4] + AmountCalc[4] [5];

                                if not ShowZeroLines then
                                    if ((TotalRemaingAmt[4] = 0) and (TotalAmtCalc[4] = 0)) then
                                        CurrReport.Skip();

                                ExistNonZeroItemRecords[4] := true;
                            end;

                            trigger OnPreDataItem()
                            begin
                                ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                                ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");

                                n := 4;
                                Clear(ItemSection);
                                ItemSection[4] := true;

                                Clear(ExistNonZeroItemRecords);
                            end;
                        }
                        dataitem(ItemCategorySub4; "Item Category")
                        {
                            DataItemLink = "Parent Category" = FIELD("Code");
                            DataItemTableView = SORTING("Parent Category");
                            column(No_ItemGroupSub4; "Code")
                            {
                            }
                            column(Description_ItemGroupSub4; Description)
                            {
                            }
                            column(ItemGrpNoLvl4; StrSubstNo(TotalText, "Code"))
                            {
                            }
                            column(ItemFound5; ItemFound[5])
                            {
                            }
                            column(ExistItemGrpSub5; ExistItemGrpSub[5])
                            {
                            }
                            dataitem(Item4; Item)
                            {
                                CalcFields = Inventory;
                                DataItemLink = "Item Category Code" = FIELD("Code");
                                column(No_Item4; "No.")
                                {
                                }
                                column(Description_Item4; Description)
                                {
                                }
                                column(RemainingAmt_5_1; RemainingAmt[5] [1])
                                {
                                }
                                column(RemainingAmt_5_2; RemainingAmt[5] [2])
                                {
                                }
                                column(RemainingAmt_5_3; RemainingAmt[5] [3])
                                {
                                }
                                column(RemainingAmt_5_4; RemainingAmt[5] [4])
                                {
                                }
                                column(RemainingAmt_5_5; RemainingAmt[5] [5])
                                {
                                }
                                column(Total_RemainingAmt_5; TotalRemaingAmt[5])
                                {
                                }
                                column(AmountCalc_5_1; AmountCalc[5] [1])
                                {
                                }
                                column(AmountCalc_5_2; AmountCalc[5] [2])
                                {
                                }
                                column(AmountCalc_5_3; AmountCalc[5] [3])
                                {
                                }
                                column(AmountCalc_5_4; AmountCalc[5] [4])
                                {
                                }
                                column(AmountCalc_5_5; AmountCalc[5] [5])
                                {
                                }
                                column(Total_AmountCalc_5; TotalAmtCalc[5])
                                {
                                }
                                column(ItemSection5; ItemSection[5])
                                {
                                }
                                column(ExistNonZeroItemRecords5; ExistNonZeroItemRecords[5])
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    Calculation(n, "No.", "Last Direct Cost");

                                    TotalRemaingAmt[5] := RemainingAmt[5] [1] + RemainingAmt[5] [2] + RemainingAmt[5] [3] + RemainingAmt[5] [4] + RemainingAmt[5] [5];
                                    TotalAmtCalc[5] := AmountCalc[5] [1] + AmountCalc[5] [2] + AmountCalc[5] [3] + AmountCalc[5] [4] + AmountCalc[5] [5];

                                    if not ShowZeroLines then
                                        if ((TotalRemaingAmt[5] = 0) and (TotalAmtCalc[5] = 0)) then
                                            CurrReport.Skip();

                                    ExistNonZeroItemRecords[5] := true;
                                end;

                                trigger OnPreDataItem()
                                begin
                                    ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");

                                    n := 5;
                                    Clear(ItemSection);
                                    ItemSection[5] := true;

                                    Clear(ExistNonZeroItemRecords);
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if (not (ItemGrpLevel >= 5)) then
                                    CurrReport.Skip();

                                Clear(ItemFound);
                                Clear(ExistItemGrpSub);

                                if "Code" <> '' then begin
                                    CheckItem.SetRange("Item Category Code", "Code");
                                    if CheckItem.FindFirst() then
                                        ItemFound[5] := true
                                    else
                                        ItemFound[5] := false;
                                    ExistItemGrpSub[5] := true
                                end;
                            end;

                            trigger OnPreDataItem()
                            begin
                                ItemCategoryHeader.CopyFilter("NPR Date Filter", "NPR Date Filter");
                                ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "NPR Global Dimension 1 Filter");
                                ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "NPR Global Dimension 2 Filter");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if (not (ItemGrpLevel >= 4)) then
                                CurrReport.Skip();

                            Clear(ItemFound);
                            Clear(ExistItemGrpSub);
                            CheckItem.Reset();

                            if "Code" <> '' then begin
                                CheckItem.SetRange("Item Category Code", "Code");
                                if CheckItem.FindFirst() then
                                    ItemFound[4] := true
                                else
                                    ItemFound[4] := false;
                                ExistItemGrpSub[4] := true
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            ItemCategoryHeader.CopyFilter("NPR Date Filter", "NPR Date Filter");
                            ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "NPR Global Dimension 1 Filter");
                            ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "NPR Global Dimension 2 Filter");
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if (not (ItemGrpLevel >= 3)) then
                            CurrReport.Skip();

                        Clear(ItemFound);
                        Clear(ExistItemGrpSub);
                        CheckItem.Reset();

                        if "Code" <> '' then begin
                            CheckItem.SetRange("Item Category Code", "Code");
                            if CheckItem.FindFirst() then
                                ItemFound[3] := true
                            else
                                ItemFound[3] := false;
                            ExistItemGrpSub[3] := true
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        ItemCategoryHeader.CopyFilter("NPR Date Filter", "NPR Date Filter");
                        ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "NPR Global Dimension 1 Filter");
                        ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "NPR Global Dimension 2 Filter");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if (not (ItemGrpLevel >= 2)) then
                        CurrReport.Skip();

                    Clear(ItemFound);
                    Clear(ExistItemGrpSub);
                    CheckItem.Reset();

                    if "Code" <> '' then begin
                        CheckItem.SetRange("Item Category Code", "Code");
                        if CheckItem.FindFirst() then
                            ItemFound[2] := true
                        else
                            ItemFound[2] := false;
                        ExistItemGrpSub[2] := true
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    ItemCategoryHeader.CopyFilter("NPR Date Filter", "NPR Date Filter");
                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "NPR Global Dimension 1 Filter");
                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "NPR Global Dimension 2 Filter");
                end;
            }

            trigger OnAfterGetRecord()
            begin

                Clear(ItemFound);
                Clear(ExistItemGrpSub);
                CheckItem.Reset();

                if "Code" <> '' then begin
                    CheckItem.SetRange("Item Category Code", "Code");
                    if CheckItem.FindFirst() then
                        ItemFound[1] := true
                    else
                        ItemFound[1] := false;
                    ExistItemGrpSub[1] := true;
                end;
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
                    field("PeriodStartDato[2]"; PeriodStartDato[2])
                    {
                        Caption = 'Start Date';

                        ToolTip = 'Specifies the value of the Start Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Period Length"; PeriodLength)
                    {
                        Caption = 'Period Length';
                        DateFormula = true;

                        ToolTip = 'Specifies the value of the Period Length field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Item"; ShowItem)
                    {
                        Caption = 'Show Items';

                        ToolTip = 'Specifies the value of the Show Items field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Zero Lines"; ShowZeroLines)
                    {
                        Caption = 'Show Zero Item Lines';
                        Editable = ShowItem;

                        ToolTip = 'Specifies the value of the Show Zero Item Lines field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Item Grp Level"; ItemGrpLevel)
                    {
                        Caption = 'Level';

                        ToolTip = 'Specifies the value of the Level field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }


        trigger OnOpenPage()
        begin
            ItemGrpLevel := 2;
            ShowZeroLines := false;
        end;
    }

    labels
    {
        TotalRemainingQty = 'Total Remaining Qty';
        TotalAmt = 'Total Amount';
        RemainingQty = 'Remaining Qty';
        Amount = 'Amount';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        if PeriodStartDato[2] = 0D then
            PeriodStartDato[2] := WorkDate();
        if PeriodLength = '' then
            PeriodLength := '1M';
    end;

    trigger OnPreReport()
    var
        Chr: Char;
    begin
        for i := 2 to 4 do
            PeriodStartDato[i + 1] := CalcDate(PeriodLength, PeriodStartDato[i]);
        PeriodStartDato[6] := DMY2Date(31, 12, 9999);

        if ShowItem then
            RequestPageFilters += TxtShowItem;

        if ItemCategoryHeader.GetFilters <> '' then
            if RequestPageFilters <> '' then
                RequestPageFilters += ', ' + ItemCategoryHeader.GetFilters
            else
                RequestPageFilters += ItemCategoryHeader.GetFilters;

        Chr := 10;
        for i := 1 to 5 do begin
            PeriodRange[i] := Format(PeriodStartDato[i], 0, '<Day,2>-<Month,2>-<Year,2>') + Format(Chr) + Format(PeriodStartDato[i + 1] - 1, 0, '<Day,2>-<Month,2>-<Year,2>');
        end;
    end;

    var
        PeriodLength: Code[20];
        i: Integer;
        CompanyInformation: Record "Company Information";
        ItemLedgerEntry: Record "Item Ledger Entry";
        PeriodStartDato: array[6] of Date;
        RemainingAmt: array[5, 5] of Decimal;
        AmountCalc: array[5, 5] of Decimal;
        [InDataSet]
        ShowItem: Boolean;
        n: Integer;
        PageNoCaptionLbl: Label 'Page';
        Report_Caption_Lbl: Label 'Inventory by age';
        No_Caption_Lbl: Label 'No.';
        Description_Caption_Lbl: Label 'Description';
        Before_Caption_Lbl: Label '...before';
        After_Caption_Lbl: Label 'after...';
        Total_Caption_Lbl: Label 'Total';
        RequestPageFilters: Text;
        TxtShowItem: Label 'Show Item';
        TotalText: Label 'Total for Item Group %1';
        ItemSection: array[5] of Boolean;
        ItemFound: array[5] of Boolean;
        CheckItem: Record Item;
        ItemGrpLevel: Integer;
        TotalRemaingAmt: array[5] of Decimal;
        TotalAmtCalc: array[5] of Decimal;
        ShowZeroLines: Boolean;
        ExistNonZeroItemRecords: array[5] of Boolean;
        ExistItemGrpSub: array[5] of Boolean;
        PeriodRange: array[6] of Text;

    procedure Calculation("Count": Integer; ItemNo: Code[21]; LastDirectCost: Decimal)
    begin
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);

        for i := 1 to 5 do begin
            Clear(RemainingAmt[n] [i]);
            Clear(AmountCalc[n] [i]);
            ItemLedgerEntry.SetRange("Posting Date", PeriodStartDato[i], PeriodStartDato[i + 1] - 1);
            ItemLedgerEntry.CalcSums("Remaining Quantity");
            RemainingAmt[n] [i] := ItemLedgerEntry."Remaining Quantity";
            AmountCalc[n] [i] := Round(ItemLedgerEntry."Remaining Quantity" * LastDirectCost);
        end;
    end;
}

