page 6150875 "NPR Meal Flow Stat. Step"
{
    Extensible = False;
    Caption = 'Meal Flow Statuses';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Flow status";
    SourceTableTemporary = true;
    UsageCategory = None;

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
                    Editable = false;
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
                    ToolTip = 'Specifies the value of the Waiter Pad Status Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"NPR NPRE Select Flow Status", TempFlowStatus_) = Action::LookupOK then begin
                            Rec."Waiter Pad Status Code" := TempFlowStatus_.Code;
                        end;
                    end;
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

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintCategories := (ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Legacy (using print tags)");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Status Object" := Rec."Status Object"::WaiterPadLineMealFlow;
    end;

    var
        ServingStepDiscoveryMethod: Enum "NPR NPRE Serv.Step Discovery";
        ShowPrintCategories: Boolean;
        TempFlowStatus_: Record "NPR NPRE Flow status" temporary;

    internal procedure CopyTempWaiterPadStatuses(var FlowStatus: Record "NPR NPRE Flow status")
    begin
        if FlowStatus.FindSet() then
            repeat
                TempFlowStatus_ := FlowStatus;
                if not TempFlowStatus_.Insert() then
                    TempFlowStatus_.Modify();
            until FlowStatus.Next() = 0;
    end;

    internal procedure CopyLiveData()
    var
        FlowStatus: Record "NPR NPRE Flow status";
    begin
        Rec.DeleteAll();

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        if FlowStatus.FindSet() then
            repeat
                Rec := FlowStatus;
                if not Rec.Insert() then
                    Rec.Modify();
            until FlowStatus.Next() = 0;
    end;

    local procedure AssignPrintCategories()
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        Rec.TestField("Status Object", Rec."Status Object"::WaiterPadLineMealFlow);
        Rec.TestField(Code);
        WaiterPadMgt.SelectPrintCategories(Rec.RecordId);
    end;

    internal procedure MealFlowStatusesToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateMealFlowStatuses()
    var
        FlowStatus: Record "NPR NPRE Flow status";
    begin
        if Rec.FindSet() then
            repeat
                FlowStatus := Rec;
                if not FlowStatus.Insert() then
                    FlowStatus.Modify();
            until Rec.Next() = 0;
    end;
}
