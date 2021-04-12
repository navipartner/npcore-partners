report 6059904 "NPR Adjust Item Cost/Price TQ"
{
    Caption = 'Adjust Item Costs/Prices';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

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
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Vendor No.", "Inventory Posting Group", "Costing Method";

            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "No.");

                case Selection of
                    Selection::"Unit Price":
                        OldFieldValue := "Unit Price";
                    Selection::"Profit %":
                        OldFieldValue := "Profit %";
                    Selection::"Indirect Cost %":
                        OldFieldValue := "Indirect Cost %";
                    Selection::"Last Direct Cost":
                        OldFieldValue := "Last Direct Cost";
                    Selection::"Standard Cost":
                        OldFieldValue := "Standard Cost";
                end;
                NewFieldValue := OldFieldValue * AdjFactor;

                GetGLSetup();
                PriceIsRnded := false;
                if RoundingMethod.Code <> '' then begin
                    RoundingMethod."Minimum Amount" := NewFieldValue;
                    if RoundingMethod.Find('=<') then begin
                        NewFieldValue := NewFieldValue + RoundingMethod."Amount Added Before";
                        if RoundingMethod.Precision > 0 then begin
                            NewFieldValue := Round(NewFieldValue, RoundingMethod.Precision, CopyStr('=><', RoundingMethod.Type + 1, 1));
                            PriceIsRnded := true;
                        end;
                        NewFieldValue := NewFieldValue + RoundingMethod."Amount Added After";
                    end;
                end;
                if not PriceIsRnded then
                    NewFieldValue := Round(NewFieldValue, GLSetup."Unit-Amount Rounding Precision");

                case Selection of
                    Selection::"Unit Price":
                        Validate("Unit Price", NewFieldValue);
                    Selection::"Profit %":
                        Validate("Profit %", NewFieldValue);
                    Selection::"Indirect Cost %":
                        Validate("Indirect Cost %", NewFieldValue);
                    Selection::"Last Direct Cost":
                        Validate("Last Direct Cost", NewFieldValue);
                    Selection::"Standard Cost":
                        Validate("Standard Cost", NewFieldValue);
                end;
                Modify();
            end;

            trigger OnPreDataItem()
            begin
                if AdjustCard = AdjustCard::"Stockkeeping Unit Card" then
                    CurrReport.Break();

                Window.Open(ProcessingItems1Lbl);
            end;
        }
        dataitem("Stockkeeping Unit"; "Stockkeeping Unit")
        {
            DataItemTableView = SORTING("Item No.", "Location Code", "Variant Code");

            trigger OnAfterGetRecord()
            begin
                SkipNoneExistingItem("Item No.");

                Window.Update(1, "Item No.");
                Window.Update(2, "Location Code");
                Window.Update(3, "Variant Code");

                case Selection of
                    Selection::"Last Direct Cost":
                        OldFieldValue := "Last Direct Cost";
                    Selection::"Standard Cost":
                        OldFieldValue := "Standard Cost";
                end;
                NewFieldValue := OldFieldValue * AdjFactor;

                PriceIsRnded := false;
                if RoundingMethod.Code <> '' then begin
                    RoundingMethod."Minimum Amount" := NewFieldValue;
                    if RoundingMethod.Find('=<') then begin
                        NewFieldValue := NewFieldValue + RoundingMethod."Amount Added Before";
                        if RoundingMethod.Precision > 0 then begin
                            NewFieldValue := Round(NewFieldValue, RoundingMethod.Precision, CopyStr('=><', RoundingMethod.Type + 1, 1));
                            PriceIsRnded := true;
                        end;
                        NewFieldValue := NewFieldValue + RoundingMethod."Amount Added After";
                    end;
                end;
                if not PriceIsRnded then
                    NewFieldValue := Round(NewFieldValue, 0.00001);

                case Selection of
                    Selection::"Last Direct Cost":
                        Validate("Last Direct Cost", NewFieldValue);
                    Selection::"Standard Cost":
                        Validate("Standard Cost", NewFieldValue);
                end;
                Modify();
            end;

            trigger OnPreDataItem()
            begin
                if AdjustCard = AdjustCard::"Item Card" then
                    CurrReport.Break();

                Item.CopyFilter("No.", "Item No.");
                Item.CopyFilter("Location Filter", "Location Code");
                Item.CopyFilter("Variant Filter", "Variant Code");

                Window.Open(
                  ProcessingItems2Lbl +
                  ProcessingLocationsLbl +
                  ProcessingVariantsLbl);
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
                    field(Adjust; AdjustCard)
                    {
                        Caption = 'Adjust';
                        OptionCaption = 'Item Card,Stockkeeping Unit Card';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Adjust field';

                        trigger OnValidate()
                        begin
                            UpdateEnabled();
                        end;
                    }
                    field(AdjustField; Selection)
                    {
                        Caption = 'Adjust Field';
                        OptionCaption = 'Unit Price,Profit %,Indirect Cost %,Last Direct Cost,Standard Cost';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Adjust Field field';

                        trigger OnValidate()
                        begin
                            if Selection = Selection::"Indirect Cost %" then
                                IndirectCost37SelectionOnValid();
                            if Selection = Selection::"Profit %" then
                                Profit37SelectionOnValidate();
                            if Selection = Selection::"Unit Price" then
                                UnitPriceSelectionOnValidate();
                        end;
                    }
                    field(AdjustmentFactor; AdjFactor)
                    {
                        Caption = 'Adjustment Factor';
                        DecimalPlaces = 0 : 5;
                        MinValue = 0;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Adjustment Factor field';
                    }
                    field("Rounding_Method"; RoundingMethod.Code)
                    {
                        Caption = 'Rounding Method';
                        TableRelation = "Rounding Method";
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Rounding Method field';
                    }
                }
            }
        }


        trigger OnInit()
        begin
            Selection3Enable := true;
            Selection2Enable := true;
            Selection1Enable := true;
        end;

        trigger OnOpenPage()
        begin
            if AdjFactor = 0 then
                AdjFactor := 1;
            UpdateEnabled();
        end;
    }


    trigger OnPostReport()
    begin
        DataLogMgt.DisableDataLog(false);
    end;

    trigger OnPreReport()
    var
        ItemView: Text;
    begin
        DataLogMgt.DisableDataLog(true);
        ItemView := Item.GetView;
        if "Task Line".GetFilters <> '' then
            if "Task Line".Find('-') then
                if not CurrReport.UseRequestPage() then begin
                    ItemView := "Task Line".GetTableView(DATABASE::Item, ItemView);
                    Item.SetView(ItemView);
                    AdjustCard := "Task Line".GetParameterInt('ADJUST');
                    Selection := "Task Line".GetParameterInt('ADJUSTFIELD');
                    AdjFactor := "Task Line".GetParameterInt('ADJUSTMENTFACTOR');
                    RoundingMethod.Code := "Task Line".GetParameterText('ROUNDINGMETHOD');
                end;
        RoundingMethod.SetRange(Code, RoundingMethod.Code);

        if Item.GetFilters <> '' then
            FilteredItem.CopyFilters(Item);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        FilteredItem: Record Item;
        RoundingMethod: Record "Rounding Method";
        DataLogMgt: Codeunit "NPR Data Log Management";
        GLSetupRead: Boolean;
        PriceIsRnded: Boolean;
        [InDataSet]
        Selection1Enable: Boolean;
        [InDataSet]
        Selection2Enable: Boolean;
        [InDataSet]
        Selection3Enable: Boolean;
        AdjFactor: Decimal;
        NewFieldValue: Decimal;
        OldFieldValue: Decimal;
        Window: Dialog;
        SelectionErr: Label '%1 is not a valid selection.', Comment = '%1 = Selection';
        ProcessingItems1Lbl: Label 'Processing items  #1##########';
        ProcessingItems2Lbl: Label 'Processing items     #1##########\';
        ProcessingLocationsLbl: Label 'Processing locations #2##########\';
        ProcessingVariantsLbl: Label 'Processing variants  #3##########';
        SelectionTxt: Label 'Unit Price,Profit %,Indirect Cost %,Last Direct Cost,Standard Cost';
        AdjustCard: Option "Item Card","Stockkeeping Unit Card";
        Selection: Option "Unit Price","Profit %","Indirect Cost %","Last Direct Cost","Standard Cost";

    local procedure UpdateEnabled()
    begin
        PageUpdateEnabled;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then
            GLSetup.Get();
        GLSetupRead := true;
    end;

    local procedure PageUpdateEnabled()
    begin
        if AdjustCard = AdjustCard::"Stockkeeping Unit Card" then
            if Selection < 3 then
                Selection := 3;
    end;

    local procedure UnitPriceSelectionOnValidate()
    begin
        if not Selection1Enable then
            Error(SelectionErr, SelectStr(Selection + 1, SelectionTxt));
    end;

    local procedure Profit37SelectionOnValidate()
    begin
        if not Selection2Enable then
            Error(SelectionErr, SelectStr(Selection + 1, SelectionTxt));
    end;

    local procedure IndirectCost37SelectionOnValid()
    begin
        if not Selection3Enable then
            Error(SelectionErr, SelectStr(Selection + 1, SelectionTxt));
    end;

    local procedure SkipNoneExistingItem(ItemNo: Code[20])
    begin
        if Item.GetFilters <> '' then begin
            FilteredItem.SetRange("No.", ItemNo);
            if FilteredItem.IsEmpty() then
                CurrReport.Skip();
        end;
    end;
}

