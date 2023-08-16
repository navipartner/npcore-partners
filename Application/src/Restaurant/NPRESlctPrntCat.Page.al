﻿page 6150668 "NPR NPRE Slct Prnt Cat."
{
    Extensible = False;
    Caption = 'Select Print/Prod. Categories';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    SourceTable = "NPR NPRE Print/Prod. Cat.";
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
                    ToolTip = 'Specifies a code to identify this print/production category.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ToolTip = 'Specifies a text that describes the category.';
                    ApplicationArea = NPRRetail;
                }
                field("Print Tag"; Rec."Print Tag")
                {
                    Editable = false;
                    Visible = ShowPrintTags;
                    ToolTip = 'Specifies the list of assigned print tags.';
                    ApplicationArea = NPRRetail;
                }
                field(AssignedServingSteps; AssignedServingStepsAsString())
                {
                    Caption = 'Appl. Only for Serving Steps';
                    Editable = false;
                    Visible = ShowApplOnServingStep;
                    ToolTip = 'Specifies the list of serving steps this category is applied for.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        ShowServingSteps();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Selected := Rec.Mark();
    end;

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        ServingStepDiscoveryMethod: Enum "NPR NPRE Serv.Step Discovery";
    begin
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintTags := ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Legacy (using print tags)";
        ShowApplOnServingStep := (ServingStepDiscoveryMethod = ServingStepDiscoveryMethod::"Item Routing Profiles") and (SourceRecID.TableNo <> 0);
    end;

    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        TempAssignedFlowStatus: Record "NPR NPRE Assigned Flow Status" temporary;
        FlowStatus: Record "NPR NPRE Flow Status";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SourceRecID: RecordID;
        IsMultiSelectionMode: Boolean;
        Selected: Boolean;
        ShowApplOnServingStep: Boolean;
        ShowPrintTags: Boolean;

    internal procedure SetMultiSelectionMode(Set: Boolean)
    begin
        IsMultiSelectionMode := Set;
    end;

    internal procedure SetDataset(var PrintCategory: Record "NPR NPRE Print/Prod. Cat.")
    begin
        Rec.Copy(PrintCategory);
    end;

    internal procedure GetDataset(var PrintCategory: Record "NPR NPRE Print/Prod. Cat.")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        PrintCategory.Copy(Rec);
        if PrintCategory.GetFilters <> '' then begin
            RecRef.GetTable(PrintCategory);
            for i := 1 to RecRef.FieldCount do begin
                FldRef := RecRef.FieldIndex(i);
                if FldRef.GetFilter <> '' then
                    FldRef.SetRange();
            end;
        end;
    end;

    internal procedure SetSourceRecID(NewSourceRecID: RecordID)
    begin
        SourceRecID := NewSourceRecID;
    end;

    local procedure InitAssignedPrintCategory(): Boolean
    begin
        if not ShowApplOnServingStep then
            exit(false);
        AssignedPrintCategory."Table No." := SourceRecID.TableNo;
        AssignedPrintCategory."Record ID" := SourceRecID;
        AssignedPrintCategory."Print/Prod. Category Code" := Rec.Code;
        exit(true);
    end;

    local procedure AssignedServingStepsAsString(): Text
    begin
        if not InitAssignedPrintCategory() then
            exit('');
        exit(WaiterPadMgt.AssignedFlowStatusesAsFilterString(AssignedPrintCategory.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow, TempAssignedFlowStatus));
    end;

    local procedure ShowServingSteps()
    begin
        if not InitAssignedPrintCategory() then
            exit;
        WaiterPadMgt.SelectFlowStatuses(AssignedPrintCategory.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow, TempAssignedFlowStatus);
    end;

    internal procedure SetAssignedFlowStatusRecordset(var AssignedFlowStatusIn: Record "NPR NPRE Assigned Flow Status")
    begin
        TempAssignedFlowStatus.Copy(AssignedFlowStatusIn, true);
    end;

    internal procedure GetAssignedFlowStatusRecordset(var AssignedFlowStatusOut: Record "NPR NPRE Assigned Flow Status")
    begin
        AssignedFlowStatusOut.Copy(TempAssignedFlowStatus, true);
    end;
}
