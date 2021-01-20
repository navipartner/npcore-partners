page 6150668 "NPR NPRE Slct Prnt Cat."
{
    Caption = 'Select Print/Prod. Categories';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NPRE Print/Prod. Cat.";

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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Print Tag"; Rec."Print Tag")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = ShowPrintTags;
                    ToolTip = 'Specifies the value of the Print Tag field';
                }
                field(AssignedServingSteps; AssignedServingStepsAsString())
                {
                    ApplicationArea = All;
                    Caption = 'Appl. Only for Serving Steps';
                    Editable = false;
                    Visible = ShowApplOnServingStep;
                    ToolTip = 'Specifies the value of the Appl. Only for Serving Steps field';

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
        Selected := Rec.Mark;
    end;

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        ServingStepDiscoveryMethod: Integer;
    begin
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintTags := ServingStepDiscoveryMethod = 0;
        ShowApplOnServingStep := (ServingStepDiscoveryMethod = 1) and (SourceRecID.TableNo <> 0);
    end;

    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        AssignedFlowStatusTmp: Record "NPR NPRE Assigned Flow Status" temporary;
        FlowStatus: Record "NPR NPRE Flow Status";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SourceRecID: RecordID;
        IsMultiSelectionMode: Boolean;
        Selected: Boolean;
        ShowApplOnServingStep: Boolean;
        ShowPrintTags: Boolean;

    procedure SetMultiSelectionMode(Set: Boolean)
    begin
        IsMultiSelectionMode := Set;
    end;

    procedure SetDataset(var PrintCategory: Record "NPR NPRE Print/Prod. Cat.")
    begin
        Rec.Copy(PrintCategory);
    end;

    procedure GetDataset(var PrintCategory: Record "NPR NPRE Print/Prod. Cat.")
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

    procedure SetSourceRecID(NewSourceRecID: RecordID)
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
        exit(WaiterPadMgt.AssignedFlowStatusesAsFilterString(AssignedPrintCategory.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow, AssignedFlowStatusTmp));
    end;

    local procedure ShowServingSteps()
    begin
        if not InitAssignedPrintCategory() then
            exit;
        WaiterPadMgt.SelectFlowStatuses(AssignedPrintCategory.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow, AssignedFlowStatusTmp);
    end;

    procedure SetAssignedFlowStatusRecordset(var AssignedFlowStatusIn: Record "NPR NPRE Assigned Flow Status")
    begin
        AssignedFlowStatusTmp.Copy(AssignedFlowStatusIn, true);
    end;

    procedure GetAssignedFlowStatusRecordset(var AssignedFlowStatusOut: Record "NPR NPRE Assigned Flow Status")
    begin
        AssignedFlowStatusOut.Copy(AssignedFlowStatusTmp, true);
    end;
}