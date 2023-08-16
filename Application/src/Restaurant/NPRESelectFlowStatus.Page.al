page 6150633 "NPR NPRE Select Flow Status"
{
    Extensible = False;
    Caption = 'Select Flow Status';
    DataCaptionExpression = GetDataCaptionExpr();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
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
                field(Selected; Selected)
                {
                    Caption = 'Selected';
                    Editable = true;
                    Visible = IsMultiSelectionMode;
                    ToolTip = 'Specifies if this line is selected.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.Mark(Selected);
                    end;
                }
                field("Code"; Rec.Code)
                {
                    Editable = false;
                    ToolTip = 'Specifies a code to identify this status.';
                    ApplicationArea = NPRRetail;
                }
                field("Status Object"; Rec."Status Object")
                {
                    Editable = false;
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                    ToolTip = 'Specifies the object this status is applicable for.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ToolTip = 'Specifies a text that describes the status.';
                    ApplicationArea = NPRRetail;
                }
                field("Flow Order"; Rec."Flow Order")
                {
                    Editable = false;
                    ToolTip = 'Specifies the place the status takes in the flow. The higher the number, the further in the flow the status is placed.';
                    ApplicationArea = NPRRetail;
                }
                field(Auxiliary; Rec.Auxiliary)
                {
                    Editable = false;
                    ToolTip = 'Specifies whether this is an auxiliary meal flow (serving) step. When requested, auxiliary steps do not update waiter pad current serving step.';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsFilterString())
                {
                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    Visible = ShowPrintCategories;
                    ToolTip = 'Specifies the list of assigned item print/production categories.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        AssignPrintCategories();
                    end;
                }
                field(Color; Rec.Color)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the color of the status in restaurant view.';
                    Editable = false;
                    Visible = false;
                }
                field("Icon Class"; Rec."Icon Class")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the icon of the status in restaurant view.';
                    Editable = false;
                    Visible = false;
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
        ShowPrintCategories :=
            (Rec."Status Object" = Rec."Status Object"::WaiterPadLineMealFlow) and (ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Legacy (using print tags)");
        PrintCategoriesEnabled := ShowPrintCategories and (Rec.Code <> '');
    end;

    trigger OnAfterGetRecord()
    begin
        Selected := Rec.Mark();
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
        ShowPrintCategories := Rec.GetFilter("Status Object") = Format(Rec."Status Object"::WaiterPadLineMealFlow);
        if not ShowPrintCategories then begin
            CurrFilterGr := Rec.FilterGroup;
            if CurrFilterGr <> 2 then begin
                Rec.FilterGroup(2);
                ShowPrintCategories := Rec.GetFilter("Status Object") = Format(Rec."Status Object"::WaiterPadLineMealFlow);
                Rec.FilterGroup(CurrFilterGr);
            end;
        end;
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        if ShowPrintCategories then
            ShowPrintCategories := ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Legacy (using print tags)";
    end;

    var
        ServingStepDiscoveryMethod: Enum "NPR NPRE Serv.Step Discovery";
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
        Rec.TestField("Status Object", Rec."Status Object"::WaiterPadLineMealFlow);
        Rec.TestField(Code);
        WaiterPadMgt.SelectPrintCategories(Rec.RecordId);
    end;

    internal procedure SetMultiSelectionMode(Set: Boolean)
    begin
        IsMultiSelectionMode := Set;
    end;

    internal procedure SetDataset(var FlowStatus: Record "NPR NPRE Flow Status")
    begin
        Rec.Copy(FlowStatus);
    end;

    internal procedure GetDataset(var FlowStatus: Record "NPR NPRE Flow Status")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        FlowStatus.Copy(Rec);
        if FlowStatus.GetFilters <> '' then begin
            RecRef.GetTable(FlowStatus);
            for i := 1 to RecRef.FieldCount do begin
                FldRef := RecRef.FieldIndex(i);
                if FldRef.GetFilter <> '' then
                    FldRef.SetRange();
            end;
        end;
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
