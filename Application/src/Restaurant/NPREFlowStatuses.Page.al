page 6150679 "NPR NPRE Flow Statuses"
{
    Extensible = False;
    Caption = 'Flow Statuses';
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Status Object"; Rec."Status Object")
                {

                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                    ToolTip = 'Specifies the value of the Status Object field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Flow Order"; Rec."Flow Order")
                {

                    ToolTip = 'Specifies the value of the Flow Order field';
                    ApplicationArea = NPRRetail;
                }
                field("Waiter Pad Status Code"; Rec."Waiter Pad Status Code")
                {

                    Visible = IsServingSteps;
                    ToolTip = 'Specifies the value of the Waiter Pad Status Code field';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsFilterString())
                {

                    Caption = 'Print/Prod. Categories';
                    Visible = ShowPrintCategories;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        AssignPrintCategories();
                    end;
                }
                field("Available in Front-End"; Rec."Available in Front-End")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether this status will be visible in restaurant view';
                }
                field(Color; Rec.Color)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the color of the status in restaurant view';
                }
                field("Status Color Priority"; Rec."Status Color Priority")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the priority this status''s color will take, when defining table colors in restaurant view. Higher number means higher priority';
                }
                field("Icon Class"; Rec."Icon Class")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the icon of the status in restaurant view';
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

                    ToolTip = 'Executes the Print/Prod. Categories action';
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
