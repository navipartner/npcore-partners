page 6150679 "NPR NPRE Flow Statuses"
{
    Caption = 'Flow Statuses';
    DataCaptionExpression = GetDataCaptionExpr();
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Flow Status";
    SourceTableView = SORTING("Status Object", "Flow Order");
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Status Object"; Rec."Status Object")
                {
                    ApplicationArea = All;
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                    ToolTip = 'Specifies the value of the Status Object field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Flow Order"; Rec."Flow Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Flow Order field';
                }
                field("Waiter Pad Status Code"; Rec."Waiter Pad Status Code")
                {
                    ApplicationArea = All;
                    Visible = IsServingSteps;
                    ToolTip = 'Specifies the value of the Waiter Pad Status Code field';
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsFilterString())
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
                field("Available in Front-End"; Rec."Available in Front-End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Available in Front-End field';
                }
                field(Color; Rec.Color)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Color field';
                }
                field("Icon Class"; Rec."Icon Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Icon Class field';
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = ShowPrintCategories;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print/Prod. Categories action';

                    trigger OnAction()
                    begin
                        AssignPrintCategories;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsServingSteps := Rec."Status Object" = Rec."Status Object"::WaiterPadLineMealFlow;
        ShowPrintCategories := IsServingSteps and (ServingStepDiscoveryMethod = 0);
        PrintCategoriesEnabled := ShowPrintCategories and (Rec.Code <> '');
    end;

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        CurrFilterGr: Integer;
    begin
        StatusObjectVisible := not CurrPage.LookupMode;

        IsServingSteps := Rec.GetFilter("Status Object") = Format(Rec."Status Object"::WaiterPadLineMealFlow);
        if not IsServingSteps then begin
            CurrFilterGr := Rec.FilterGroup;
            if CurrFilterGr <> 2 then begin
                Rec.FilterGroup(2);
                IsServingSteps := Rec.GetFilter("Status Object") = Format(Rec."Status Object"::WaiterPadLineMealFlow);
                Rec.FilterGroup(CurrFilterGr);
            end;
        end;

        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintCategories := IsServingSteps and (ServingStepDiscoveryMethod = 0);
    end;

    var
        ServingStepDiscoveryMethod: Integer;
        IsServingSteps: Boolean;
        PrintCategoriesEnabled: Boolean;
        ShowPrintCategories: Boolean;
        StatusObjectVisible: Boolean;
        ServStepsLb: Label 'Serving Steps';

    local procedure AssignPrintCategories()
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        Rec.TestField("Status Object", Rec."Status Object"::WaiterPadLineMealFlow);
        Rec.TestField(Code);
        WaiterPadMgt.SelectPrintCategories(Rec.RecordId);
    end;

    local procedure GetDataCaptionExpr(): Text
    begin
        case Rec."Status Object" of
            Rec."Status Object"::WaiterPadLineMealFlow:
                exit(ServStepsLb);
            else
                exit(Format(Rec."Status Object"));
        end;
    end;
}
