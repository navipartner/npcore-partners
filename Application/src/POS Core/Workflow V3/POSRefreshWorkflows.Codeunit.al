codeunit 6059798 "NPR POS Refresh Workflows"
{
    //V3 workflows are refreshed here. Routine has been decoupled from POS Action table, to avoid having global vars, event subscriber with sender ping pong.
    Access = Internal;
    procedure RefreshAll()
    var
        WorkflowOrdinal: Integer;
        WorkflowCaptionBuffer: Codeunit "NPR Workflow Caption Buffer";
    begin
        WorkflowCaptionBuffer.ClearAll();

        foreach WorkflowOrdinal in Enum::"NPR POS Workflow".Ordinals() do begin
            if WorkflowOrdinal <> 0 then //Skip LEGACY at the start of enum
                RefreshSpecific(WorkflowOrdinal);
        end;
    end;

    procedure RefreshSpecific(WorkflowOrdinal: Integer)
    var
        WorkflowConfig: Codeunit "NPR POS Workflow Config";
        ActionVersion: Text[32];
        POSAction: Record "NPR POS Action";
        ActionCode: Text;
        Workflow: Interface "NPR IPOS Workflow";
        MissingDescriptionLbl: Label 'Action %1 is missing a description caption';
    begin
        Workflow := Enum::"NPR POS Workflow".FromInteger(WorkflowOrdinal);
        ActionCode := Enum::"NPR POS Workflow".Names().Get(Enum::"NPR POS Workflow".Ordinals().IndexOf(WorkflowOrdinal));
        WorkflowConfig.SetActionCode(ActionCode);
        Workflow.Register(WorkflowConfig); //Workflow registers all config
        if (WorkflowConfig.GetWorkflowDescription() = '') then
            Error(MissingDescriptionLbl, ActionCode);

        BufferCaptions(ActionCode, WorkflowConfig); //Used by POS Session init and by POS Parameter Value page

        ActionVersion := WorkflowConfig.CalculateWorkflowHash();
        POSAction.SetRange(Code, ActionCode);
        POSAction.SetRange(Version, ActionVersion);
        if POSAction.IsEmpty() then
            RefreshAction(ActionCode, WorkflowConfig, ActionVersion, WorkflowOrdinal);
    end;


    local procedure RefreshAction(ActionCode: Text; WorkflowConfig: Codeunit "NPR POS Workflow Config"; ActionVersion: Text[32]; WorkflowOrdinal: Integer)
    var
        POSAction: Record "NPR POS Action";
        TempParameters: Record "NPR POS Action Parameter" temporary;
        Javascript: Text;
        Unattended: Boolean;
        BoundToDataSource: Boolean;
        DataSource: Text;
        CustomJSMethod: Text;
        CustomJSCode: Text;
        NonBlockingUI: Boolean;
        Description: Text;
        ActionParameters: Record "NPR POS Action Parameter";
    begin
        WorkflowConfig.GetWorkflowParameters(TempParameters, Javascript, Unattended, BoundToDataSource, DataSource, CustomJSMethod, CustomJSCode, NonBlockingUI, Description);

        POSAction.LockTable();
        if POSAction.Get(ActionCode) then
            POSAction.Delete();

        POSAction.Init();
# pragma warning disable AA0139
        POSAction.Code := ActionCode;
# pragma warning restore
        POSAction."Blocking UI" := not NonBlockingUI;
        POSAction."Bound to DataSource" := BoundToDataSource;
# pragma warning disable AA0139
        POSAction."Data Source Name" := DataSource;
# pragma warning restore
        POSAction.Version := ActionVersion;
        POSAction."Workflow Engine Version" := '3.0';
        POSAction."Workflow Implementation" := Enum::"NPR POS Workflow".FromInteger(WorkflowOrdinal);
        if Unattended then
            POSAction."Requires POS Type" := POSAction."Requires POS Type"::UNATTENDED;
        POSAction.StreamWorkflowToBlobV3(ActionCode, 'wf3:' + Javascript);
        POSAction.RegisterCustomJavaScriptLogicV3(CustomJSMethod, CustomJSCode);
        POSAction.Insert();

        ActionParameters.SetRange("POS Action Code", ActionCode);
        if not ActionParameters.IsEmpty() then
            ActionParameters.DeleteAll();

        if TempParameters.FindSet() then
            repeat
                ActionParameters := TempParameters;
# pragma warning disable AA0139
                ActionParameters."POS Action Code" := ActionCode;
# pragma warning restore
                ActionParameters.Insert();
            until TempParameters.Next() = 0;

        POSAction.OnAfterActionUpdated(POSAction); //triggers update of 'pos menu button', 'pos named action', 'pos ean box setup' parameters for this action.
    end;

    local procedure BufferCaptions(ActionCode: Text; WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        WorkflowCaptionBuffer: Codeunit "NPR Workflow Caption Buffer";
        ParameterNameCaption: Dictionary of [Text, Text];
        ParameterDescriptionCaption: Dictionary of [Text, Text];
        ParameterOptionCaption: Dictionary of [Text, Text];
        FrontendLabels: Dictionary of [Text, Text];
    begin
        WorkflowConfig.GetWorkflowCaptions(FrontEndLabels, ParameterNameCaption, ParameterDescriptionCaption, ParameterOptionCaption);
        WorkflowCaptionBuffer.AddWorkflowNameCaptions(ActionCode, ParameterNameCaption);
        WorkflowCaptionBuffer.AddWorkflowDescriptionCaptions(ActionCode, ParameterDescriptionCaption);
        WorkflowCaptionBuffer.AddWorkflowOptionCaptions(ActionCode, ParameterOptionCaption);
        WorkflowCaptionBuffer.AddFrontendLabels(ActionCode, FrontendLabels);
        WorkflowCaptionBuffer.AddActionDescription(ActionCode, WorkflowConfig.GetWorkflowDescription());
    end;
}