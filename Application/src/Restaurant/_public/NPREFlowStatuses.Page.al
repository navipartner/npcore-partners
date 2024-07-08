page 6150679 "NPR NPRE Flow Statuses"
{
    Caption = 'Flow Statuses';
    ContextSensitiveHelpPage = 'docs/restaurant/explanation/restaurant_flow/';
    DataCaptionExpression = GetDataCaptionExpr();
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Flow Status";
    SourceTableView = SORTING("Status Object", "Flow Order");
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this status.';
                    ApplicationArea = NPRRetail;
                }
                field("Status Object"; Rec."Status Object")
                {
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                    ToolTip = 'Specifies the object this status is applicable for.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the status.';
                    ApplicationArea = NPRRetail;
                }
                field("Flow Order"; Rec."Flow Order")
                {
                    ToolTip = 'Specifies the place the status takes in the flow. The higher the number, the further in the flow the status is placed.';
                    ApplicationArea = NPRRetail;
                }
                field(Auxiliary; Rec.Auxiliary)
                {
                    Visible = IsServingSteps;
                    ToolTip = 'Specifies whether this is an auxiliary meal flow (serving) step. When requested, auxiliary steps do not update waiter pad current serving step.';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad Status Code"; Rec."Waiter Pad Status Code")
                {
                    Visible = IsServingSteps;
                    ToolTip = 'Specifies the code for the waiter pad status that is assigned to waiter pads together with this serving step.';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsFilterString())
                {
                    Caption = 'Print/Prod. Categories';
                    Visible = ShowPrintCategories;
                    ToolTip = 'Specifies the list of assigned item print/production categories.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        AssignPrintCategories();
                    end;
                }
                field("Available in Front-End"; Rec."Available in Front-End")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether this status is visible in restaurant view.';
                }
                field(Color; Rec.Color)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the color of the status in restaurant view.';
                }
                field("Status Color Priority"; Rec."Status Color Priority")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the priority this status takes, when defining table colors in restaurant view. Higher number means higher priority.';
                }
                field("Icon Class"; Rec."Icon Class")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the icon of the status in restaurant view.';
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
                    ToolTip = 'View or edit assigned item print/production categories for the record.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        AssignPrintCategories();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsServingSteps := Rec."Status Object" = Rec."Status Object"::WaiterPadLineMealFlow;
        ShowPrintCategories := IsServingSteps and (ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Legacy (using print tags)");
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
        ShowPrintCategories := IsServingSteps and (ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Legacy (using print tags)");
    end;

    var
        ServingStepDiscoveryMethod: Enum "NPR NPRE Serv.Step Discovery";
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
