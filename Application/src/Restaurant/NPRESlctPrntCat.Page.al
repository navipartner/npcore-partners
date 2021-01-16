page 6150668 "NPR NPRE Slct Prnt Cat."
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20200102 CASE 360258 Possibility to send to kitchen only selected waiter pad lines or lines of specific print category
    // NPR5.55/ALPO/20200422 CASE 360258 More user friendly print category selection using multi-selection mode
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

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
                        Mark(Selected);  //NPR5.55 [360258]
                    end;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Print Tag"; "Print Tag")
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
                        ShowServingSteps();  //NPR5.55 [382428]
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Selected := Mark;  //NPR5.55 [360258]
    end;

    trigger OnOpenPage()
    var
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        ServingStepDiscoveryMethod: Integer;
    begin
        //-NPR5.55 [382428]
        ServingStepDiscoveryMethod := SetupProxy.ServingStepDiscoveryMethod();
        ShowPrintTags := ServingStepDiscoveryMethod = 0;
        ShowApplOnServingStep := (ServingStepDiscoveryMethod = 1) and (SourceRecID.TableNo <> 0);
        //+NPR5.55 [382428]
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
        //-NPR5.55 [360258]
        IsMultiSelectionMode := Set;
        //+NPR5.55 [360258]
    end;

    procedure SetDataset(var PrintCategory: Record "NPR NPRE Print/Prod. Cat.")
    begin
        //-NPR5.55 [360258]
        Copy(PrintCategory);
        //+NPR5.55 [360258]
    end;

    procedure GetDataset(var PrintCategory: Record "NPR NPRE Print/Prod. Cat.")
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        i: Integer;
    begin
        //-NPR5.55 [360258]
        PrintCategory.Copy(Rec);
        if PrintCategory.GetFilters <> '' then begin
            RecRef.GetTable(PrintCategory);
            for i := 1 to RecRef.FieldCount do begin
                FldRef := RecRef.FieldIndex(i);
                if FldRef.GetFilter <> '' then
                    FldRef.SetRange();
            end;
        end;
        //+NPR5.55 [360258]
    end;

    procedure SetSourceRecID(NewSourceRecID: RecordID)
    begin
        //-NPR5.55 [382428]
        SourceRecID := NewSourceRecID;
        //+NPR5.55 [382428]
    end;

    local procedure InitAssignedPrintCategory(): Boolean
    begin
        //-NPR5.55 [382428]
        if not ShowApplOnServingStep then
            exit(false);
        AssignedPrintCategory."Table No." := SourceRecID.TableNo;
        AssignedPrintCategory."Record ID" := SourceRecID;
        AssignedPrintCategory."Print/Prod. Category Code" := Code;
        exit(true);
        //+NPR5.55 [382428]
    end;

    local procedure AssignedServingStepsAsString(): Text
    begin
        //-NPR5.55 [382428]
        if not InitAssignedPrintCategory() then
            exit('');
        exit(WaiterPadMgt.AssignedFlowStatusesAsFilterString(AssignedPrintCategory.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow, AssignedFlowStatusTmp));
        //+NPR5.55 [382428]
    end;

    local procedure ShowServingSteps()
    begin
        //-NPR5.55 [382428]
        if not InitAssignedPrintCategory() then
            exit;
        WaiterPadMgt.SelectFlowStatuses(AssignedPrintCategory.RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow, AssignedFlowStatusTmp);
        //+NPR5.55 [382428]
    end;

    procedure SetAssignedFlowStatusRecordset(var AssignedFlowStatusIn: Record "NPR NPRE Assigned Flow Status")
    begin
        //-NPR5.55 [382428]
        AssignedFlowStatusTmp.Copy(AssignedFlowStatusIn, true);
        //+NPR5.55 [382428]
    end;

    procedure GetAssignedFlowStatusRecordset(var AssignedFlowStatusOut: Record "NPR NPRE Assigned Flow Status")
    begin
        //-NPR5.55 [382428]
        AssignedFlowStatusOut.Copy(AssignedFlowStatusTmp, true);
        //+NPR5.55 [382428]
    end;
}

