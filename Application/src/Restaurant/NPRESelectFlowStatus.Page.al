page 6150633 "NPR NPRE Select Flow Status"
{
    Extensible = False;
    Caption = 'Select Flow Status';
    DataCaptionExpression = GetDataCaptionExpr();
    DeleteAllowed = false;
    InsertAllowed = false;
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
                field(Selected; Selected)
                {

                    Caption = 'Selected';
                    Editable = true;
                    Visible = IsMultiSelectionMode;
                    ToolTip = 'Specifies the value of the Selected field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.Mark(Selected);
                    end;
                }
                field("Code"; Rec.Code)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Status Object"; Rec."Status Object")
                {

                    Editable = false;
                    Enabled = StatusObjectVisible;
                    Visible = StatusObjectVisible;
                    ToolTip = 'Specifies the value of the Status Object field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Flow Order"; Rec."Flow Order")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Flow Order field';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedPrintCategories; Rec.AssignedPrintCategoriesAsFilterString())
                {

                    Caption = 'Print/Prod. Categories';
                    Editable = false;
                    Visible = ShowPrintCategories;
                    ToolTip = 'Specifies the value of the Print/Prod. Categories field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        AssignPrintCategories();
                    end;
                }
                field(Color; Rec.Color)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the color of the status in restaurant view';
                    Editable = false;
                    Visible = false;
                }
                field("Icon Class"; Rec."Icon Class")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the icon of the status in restaurant view';
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
        ShowPrintCategories :=
          (Rec."Status Object" = Rec."Status Object"::WaiterPadLineMealFlow) and (ServingStepDiscoveryMethod = 0);
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
