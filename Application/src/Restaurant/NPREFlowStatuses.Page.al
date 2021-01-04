page 6150679 "NPR NPRE Flow Statuses"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Flow Statuses';
    DataCaptionExpression = GetDataCaptionExpr();
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Flow Status";
    SourceTableView = SORTING("Status Object", "Flow Order");
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Status Object"; "Status Object")
                {
                    ApplicationArea = All;
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                    ToolTip = 'Specifies the value of the Status Object field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Flow Order"; "Flow Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Flow Order field';
                }
                field(AssignedPrintCategories; AssignedPrintCategoriesAsFilterString())
                {
                    ApplicationArea = All;
                    Caption = 'Print/Prod. Categories';
                    Visible = ShowPrintCategories;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';

                    trigger OnDrillDown()
                    begin
                        AssignPrintCategories;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print/Prod. Categories action';

                    trigger OnAction()
                    begin
                        AssignPrintCategories;  //#360258 [360258]
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ShowPrintCategories :=
          ("Status Object" = "Status Object"::WaiterPadLineMealFlow) and (ServingStepDiscoveryMethod = 0);
        PrintCategoriesEnabled := ShowPrintCategories and (Code <> '');
    end;

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        CurrFilterGr: Integer;
    begin
        StatusObjectVisible := not CurrPage.LookupMode;
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        if ServingStepDiscoveryMethod = 0 then begin
            ShowPrintCategories := GetFilter("Status Object") = Format("Status Object"::WaiterPadLineMealFlow);
            if not ShowPrintCategories then begin
                CurrFilterGr := FilterGroup;
                if CurrFilterGr <> 2 then begin
                    FilterGroup(2);
                    ShowPrintCategories := GetFilter("Status Object") = Format("Status Object"::WaiterPadLineMealFlow);
                    FilterGroup(CurrFilterGr);
                end;
            end;
        end;
    end;

    var
        ServingStepDiscoveryMethod: Integer;
        PrintCategoriesEnabled: Boolean;
        ShowPrintCategories: Boolean;
        StatusObjectVisible: Boolean;
        ServStepsLb: Label 'Serving Steps';

    local procedure AssignPrintCategories()
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        TestField("Status Object", "Status Object"::WaiterPadLineMealFlow);
        TestField(Code);
        WaiterPadMgt.SelectPrintCategories(RecordId);
    end;

    local procedure GetDataCaptionExpr(): Text
    begin
        case "Status Object" of
            "Status Object"::WaiterPadLineMealFlow:
                exit(ServStepsLb);
            else
                exit(Format("Status Object"));
        end;
    end;
}

