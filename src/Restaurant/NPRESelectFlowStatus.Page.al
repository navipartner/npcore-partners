page 6150633 "NPR NPRE Select Flow Status"
{
    // NPR5.34/NPKNAV/20170801 CASE 283328 Transport NPR5.34 - 1 August 2017
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.55/ALPO/20200422 CASE 360258 More user friendly print category selection using multi-selection mode
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Select Flow Status';
    DataCaptionExpression = GetDataCaptionExpr();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "NPR NPRE Flow Status";
    SourceTableView = SORTING("Status Object", "Flow Order");
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Selected; Selected)
                {
                    ApplicationArea = All;
                    Caption = 'Selected';
                    Editable = true;
                    Visible = IsMultiSelectionMode;

                    trigger OnValidate()
                    begin
                        Mark(Selected);  //NPR5.55 [382428]
                    end;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Status Object"; "Status Object")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Flow Order"; "Flow Order")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(AssignedPrintCategories; AssignedPrintCategoriesAsFilterString())
                {
                    ApplicationArea = All;
                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    Visible = ShowPrintCategories;

                    trigger OnDrillDown()
                    begin
                        //-NPR5.55 [360258]-revoked
                        //-NPR5.53 [360258]
                        //TESTFIELD("Status Object","Status Object"::WaiterPadLineMealFlow);
                        //TESTFIELD(Code);
                        //FlowStatusPrCategory.SETRANGE("Flow Status Object","Status Object");
                        //FlowStatusPrCategory.SETRANGE("Flow Status Code",Code);
                        //PAGE.RUN(0,FlowStatusPrCategory);
                        //+NPR5.53 [360258]
                        //+NPR5.55 [360258]-revoked
                        AssignPrintCategories;  //NPR5.55 [360258]
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ActionGroup6014407)
            {
                action(PrintCategories)
                {
                    Caption = 'Print/Prod. Categories';
                    Enabled = PrintCategoriesEnabled;
                    Image = CoupledOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ShowPrintCategories;
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        AssignPrintCategories;  //NPR5.55 [360258]
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //ShowPrintCategories := "Status Object" = "Status Object"::WaiterPadLineMealFlow;  //#391678 [391678]-revoked
        //-NPR5.55 [382428]
        ShowPrintCategories :=
          ("Status Object" = "Status Object"::WaiterPadLineMealFlow) and (ServingStepDiscoveryMethod = 0);
        //+NPR5.55 [382428]
        PrintCategoriesEnabled := ShowPrintCategories and (Code <> '');  //NPR5.55 [360258]
    end;

    trigger OnAfterGetRecord()
    begin
        Selected := Mark;  //NPR5.55 [382428]
    end;

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        CurrFilterGr: Integer;
    begin
        if CurrPage.LookupMode then begin
            StatusObjectVisible := false;
        end else begin
            StatusObjectVisible := true;
        end;
        ShowPrintCategories := GetFilter("Status Object") = Format("Status Object"::WaiterPadLineMealFlow);  //NPR5.53 [360258]
        //-NPR5.55 [382428]
        if not ShowPrintCategories then begin
            CurrFilterGr := FilterGroup;
            if CurrFilterGr <> 2 then begin
                FilterGroup(2);
                ShowPrintCategories := GetFilter("Status Object") = Format("Status Object"::WaiterPadLineMealFlow);
                FilterGroup(CurrFilterGr);
            end;
        end;
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        if ShowPrintCategories then
            ShowPrintCategories := ServingStepDiscoveryMethod = 0;
        //+NPR5.55 [382428]
    end;

    var
        ServingStepDiscoveryMethod: Integer;
        IsMultiSelectionMode: Boolean;
        PrintCategoriesEnabled: Boolean;
        Selected: Boolean;
        ShowPrintCategories: Boolean;
        StatusObjectVisible: Boolean;
        ServStepsLb: Label 'Serving Steps';

    local procedure AssignPrintCategories()
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        //-NPR5.55 [382428]
        TestField("Status Object", "Status Object"::WaiterPadLineMealFlow);
        TestField(Code);
        WaiterPadMgt.SelectPrintCategories(RecordId);
        //+NPR5.55 [382428]
    end;

    procedure SetMultiSelectionMode(Set: Boolean)
    begin
        //-NPR5.55 [382428]
        IsMultiSelectionMode := Set;
        //+NPR5.55 [382428]
    end;

    procedure SetDataset(var FlowStatus: Record "NPR NPRE Flow Status")
    begin
        //-NPR5.55 [382428]
        Copy(FlowStatus);
        //+NPR5.55 [382428]
    end;

    procedure GetDataset(var FlowStatus: Record "NPR NPRE Flow Status")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        //-NPR5.55 [382428]
        FlowStatus.Copy(Rec);
        if FlowStatus.GetFilters <> '' then begin
            RecRef.GetTable(FlowStatus);
            for i := 1 to RecRef.FieldCount do begin
                FldRef := RecRef.FieldIndex(i);
                if FldRef.GetFilter <> '' then
                    FldRef.SetRange();
            end;
        end;
        //+NPR5.55 [382428]
    end;

    local procedure GetDataCaptionExpr(): Text
    begin
        //-NPR5.55 [382428]
        case "Status Object" of
            "Status Object"::WaiterPadLineMealFlow:
                exit(ServStepsLb);
            else
                exit(Format("Status Object"));
        end;
        //+NPR5.55 [382428]
    end;
}

