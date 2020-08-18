page 6150679 "NPRE Flow Statuses"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Flow Statuses';
    DataCaptionExpression = GetDataCaptionExpr();
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPRE Flow Status";
    SourceTableView = SORTING("Status Object","Flow Order");
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Status Object";"Status Object")
                {
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                }
                field(Description;Description)
                {
                }
                field("Flow Order";"Flow Order")
                {
                }
                field(PrintCategories;AssignedPrintCategoriesAsFilterString())
                {
                    Caption = 'Print/Prod. Categories';
                    Visible = ShowPrintCategories;

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
        SetupProxy: Codeunit "NPRE Restaurant Setup Proxy";
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
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
    begin
        TestField("Status Object","Status Object"::WaiterPadLineMealFlow);
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

