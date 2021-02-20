page 6150633 "NPR NPRE Select Flow Status"
{
    Caption = 'Select Flow Status';
    DataCaptionExpression = GetDataCaptionExpr();
    DeleteAllowed = false;
    InsertAllowed = false;
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
                field(Selected; Selected)
                {
                    ApplicationArea = All;
                    Caption = 'Selected';
                    Editable = true;
                    Visible = IsMultiSelectionMode;
                    ToolTip = 'Specifies the value of the Selected field';

                    trigger OnValidate()
                    begin
                        Rec.Mark(Selected);
                    end;
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Status Object"; Rec."Status Object")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                    ToolTip = 'Specifies the value of the Status Object field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Flow Order"; Rec."Flow Order")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Flow Order field';
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsFilterString())
                {
                    ApplicationArea = All;
                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    Visible = ShowPrintCategories;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';

                    trigger OnDrillDown()
                    begin
                        AssignPrintCategories;
                    end;
                }
                field(Color; Rec.Color)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Icon Class"; Rec."Icon Class")
                {
                    ApplicationArea = All;
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
        ShowPrintCategories :=
          (Rec."Status Object" = Rec."Status Object"::WaiterPadLineMealFlow) and (ServingStepDiscoveryMethod = 0);
        PrintCategoriesEnabled := ShowPrintCategories and (Rec.Code <> '');
    end;

    trigger OnAfterGetRecord()
    begin
        Selected := Rec.Mark;
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
            ShowPrintCategories := ServingStepDiscoveryMethod = 0;
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
        Rec.TestField("Status Object", Rec."Status Object"::WaiterPadLineMealFlow);
        Rec.TestField(Code);
        WaiterPadMgt.SelectPrintCategories(Rec.RecordId);
    end;

    procedure SetMultiSelectionMode(Set: Boolean)
    begin
        IsMultiSelectionMode := Set;
    end;

    procedure SetDataset(var FlowStatus: Record "NPR NPRE Flow Status")
    begin
        Rec.Copy(FlowStatus);
    end;

    procedure GetDataset(var FlowStatus: Record "NPR NPRE Flow Status")
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
