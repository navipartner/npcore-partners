table 6150703 "NPR POS Action"
{
    Caption = 'POS Action';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Actions";
    LookupPageID = "NPR POS Actions";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Text that should follow user language cannot be table data. Changed to page variable populated runtime in workflow v3.';
        }
        field(3; Version; Text[32])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
        }
        field(4; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(5; Workflow; BLOB)
        {
            Caption = 'Workflow';
            DataClassification = CustomerContent;
        }
        field(6; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Generic,Button,BackEnd';
            OptionMembers = Generic,Button,BackEnd;
            ObsoleteState = Pending;
            ObsoleteReason = 'Was never implemented fully. Not needed in v3 workflows';
        }
        field(7; "Subscriber Instances Allowed"; Option)
        {
            Caption = 'Subscriber Instances Allowed';
            DataClassification = CustomerContent;
            OptionCaption = 'Single,Multiple';
            OptionMembers = Single,Multiple;
            ObsoleteState = Pending;
            ObsoleteReason = 'Was never implemented fully. Not needed in v3 workflows';
        }
        field(8; "Bound to DataSource"; Boolean)
        {
            Caption = 'Bound to DataSource';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Custom JavaScript Logic"; BLOB)
        {
            Caption = 'Custom JavaScript Logic';
            DataClassification = CustomerContent;
        }
        field(10; "Data Source Name"; Code[50])
        {
            Caption = 'Data Source Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                DataSource: Record "NPR POS Data Source Discovery";
            begin
                DataSource.LookupDataSource("Data Source Name");
            end;
        }
        field(11; "Blocking UI"; Boolean)
        {
            Caption = 'Blocking UI';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.11';
        }
        field(12; Tooltip; Text[250])
        {
            Caption = 'Tooltip';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.11';
            ObsoleteState = Pending;
            ObsoleteReason = 'Was never implemented by any of our actions. A reimplementation should probably be only a POS menu button level, not here.';
        }
        field(13; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NPR5.32.11';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by enum for workflow v3. This implementation also assumed that EventSubscription."Number of Calls" count increased by +1 within user session but it was across entire NST. So it never worked robustly.';
        }
        field(14; "Secure Method Code"; Code[10])
        {
            Caption = 'Secure Method Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.43';
            TableRelation = "NPR POS Secure Method";
            ObsoleteState = Pending;
            ObsoleteReason = 'Was never implemented by any of our actions. A reimplementation should probably be only a POS menu button level, not here.';
        }
        field(15; "Workflow Engine Version"; Text[30])
        {
            Caption = 'Workflow Engine Version';
            DataClassification = CustomerContent;
            InitValue = '1.0';
        }
        field(20; "Requires POS Type"; Option)
        {
            Caption = 'Requires POS Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Attended,Unattended';
            OptionMembers = ATTENDED,UNATTENDED;
        }
        field(40; "Workflow Implementation"; Enum "NPR POS Workflow")
        {
            DataClassification = CustomerContent;
            Caption = 'Workflow Implementation';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    begin
        DeleteParameters(Code);
    end;

    var
        TempDiscoveredAction: Record "NPR POS Action" temporary;
        POSSession: Codeunit "NPR POS Session";
        WorkflowObj: Codeunit "NPR Workflow";
        WorkflowInvocationParameters: JsonObject;
        WorkflowInvocationContext: JsonObject;
        ActionInDiscovery: Text;
        Text001: Label 'A workflow step cannot be registered because the Workflow object has not been instantiated.';
        Text002: Label 'Discovery has started for action %1 while discovery for action %2 has not yet completed.';
        Text003: Label 'You must not register a workflow for action %1 because it is of type %2.';
        ActionInRefresh: Text;
        Text004: Label 'Action %1 has already been discovered. It seems that there are more codeunits subscribing to this action, and this action does not allow multiple subscribers.';
        Text005: Label 'Attempting to set parameter %1 on action %2 before invoking workflow, however this parameter does not exist for that action.';
        Text006: Label 'Attempting to set a non-%1 value to a %1 parameter %2 on action %3.';
        ActionUpdateRequired: Boolean;
        Version20: Boolean;
        TempUpdatedActions: Record "NPR POS Action" temporary;
        Text007: Label 'You have called a Workflow 1.0 function in the context of a Workflow 2.0 discovery process.';
        Text008: Label 'You have called a Workflow 2.0 function in the context of a Workflow 1.0 discovery process.';

    local procedure DeleteParameters(ActionCode: Text)
    var
        Param: Record "NPR POS Action Parameter";
    begin
        Param.SetRange("POS Action Code", ActionCode);
        Param.DeleteAll();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure InitializeWorkflowDiscovery()
    begin
        Clear(WorkflowObj);
        ActionInDiscovery := '';
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure MakeSureDiscoveryIsAllowed("Action": Text)
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if ActionInDiscovery <> '' then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text002, Action, ActionInDiscovery));

        TempDiscoveredAction.Code := CopyStr(Action, 1, MaxStrLen(TempDiscoveredAction.Code));
        if TempDiscoveredAction.Find() then begin
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text004, Action));
            exit;
        end;
        TempDiscoveredAction.Insert();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure DiscoverAction("Code": Code[20]; Description: Text[250]; Version: Text[30]; Type: Integer; AllowedInstances: Option): Boolean
    var
        xPOSAction: Record "NPR POS Action";
    begin
        if (ActionInRefresh <> '') and (ActionInRefresh <> Code) then
            exit(false);

        MakeSureDiscoveryIsAllowed(Code);
        Version20 := false;
        ActionUpdateRequired := ActionUpdateCheck(Code, Version);
        if not ActionUpdateRequired then
            UpdateMLDescription(Code, Description);

        if not (IsTemporary or ActionUpdateRequired) then
            exit(false);

        if ActionUpdateRequired then
            DeleteParameters(Code);

        if not xPOSAction.Get(Code) then
            xPOSAction.Init();

        Init();
        Rec.Code := Code;
        Rec.Description := Description;
        Rec.Version := Version;
        Rec.Type := Type;
        Rec."Blocking UI" := true;
        Rec.Blocked := xPOSAction.Blocked;

        if ActionUpdateRequired then
            OnActionDiscovered(Rec);

        if not Insert() then;

        if (ActionInRefresh = Code) then
            Modify();

        if Rec.Type <> Rec.Type::BackEnd then begin
            Clear(WorkflowObj);
            WorkflowObj.SetName(Code);
            ActionInDiscovery := Code;
        end else
            InitializeWorkflowDiscovery();

        if Rec.IsTemporary then
            POSSession.DiscoverSessionAction(Rec);

        exit(true);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure DiscoverAction20("Code": Code[20]; Description: Text[250]; Version: Text[32]): Boolean
    var
        xPOSAction: Record "NPR POS Action";
    begin
        if (ActionInRefresh <> '') and (ActionInRefresh <> Code) then
            exit(false);

        MakeSureDiscoveryIsAllowed(Code);

        Version20 := true;
        ActionUpdateRequired := ActionUpdateCheck(Code, Version);

        if not (IsTemporary or ActionUpdateRequired) then
            exit(false);

        if ActionUpdateRequired then
            DeleteParameters(Code);

        if not xPOSAction.Get(Code) then
            xPOSAction.Init();

        Init();
        Rec.Code := Code;
        Rec.Description := Description;
        Rec.Version := Version;
        Rec."Workflow Engine Version" := '2.0';
        Rec."Blocking UI" := true;
        Rec.Blocked := xPOSAction.Blocked;

        if ActionUpdateRequired then
            OnActionDiscovered(Rec);

        if not Insert() then;

        if (ActionInRefresh = Code) then
            Modify();

        if Rec.Type <> Rec.Type::BackEnd then begin
            Clear(WorkflowObj);
            WorkflowObj.SetName(Code);
            ActionInDiscovery := Code;
            WorkflowObj.Content().Add('engineVersion', '2.0');
        end else
            InitializeWorkflowDiscovery();

        if Rec.IsTemporary then
            POSSession.DiscoverSessionAction(Rec);

        exit(true);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure ActionUpdateCheck("Code": Text; Version: Text): Boolean
    var
        POSAction: Record "NPR POS Action";
    begin
        POSAction.SetRange(Code, Code);
        POSAction.SetRange(Version, Version);
        if POSAction.IsEmpty then begin
            TempUpdatedActions.Code := CopyStr(Code, 1, MaxStrLen(TempUpdatedActions.Code));
            TempUpdatedActions.Insert();
            exit(true);
        end;
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure HandleActionUpdates()
    begin
        TempUpdatedActions.SetAutoCalcFields(Workflow);
        TempUpdatedActions.SetAutoCalcFields("Custom JavaScript Logic");
        if TempUpdatedActions.FindSet() then
            repeat
                OnAfterActionUpdated(TempUpdatedActions);
            until TempUpdatedActions.Next() = 0;
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterWorkflowStep(Label: Text; "Code": Text)
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        WorkflowStep: JsonObject;
    begin
        if ActionInDiscovery = '' then
            FrontEnd.ReportBugAndThrowError(Text001);

        RequireVersion10();
        WorkflowStep.Add('Label', Label);
        WorkflowStep.Add('Code', Code);
        WorkflowObj.Steps().Add(WorkflowStep);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterWorkflow(WithOnBeforeWorkflowEvent: Boolean)
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        RequireVersion10();

        if Type = Type::BackEnd then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text003, Code, Type));

        WorkflowObj.SetRequestContext(WithOnBeforeWorkflowEvent);
        StreamWorkflowToBlob();
        Modify();
        UpdateActionBuffers();

        InitializeWorkflowDiscovery();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterWorkflow20("Code": Text)
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        WorkflowStep: JsonObject;
    begin
        RequireVersion20();

        if Type = Type::BackEnd then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text003, Code, Type));

        WorkflowStep.Add('Code', Code);
        WorkflowObj.Steps().Add(WorkflowStep);

        StreamWorkflowToBlob();
        Modify();
        UpdateActionBuffers();

        InitializeWorkflowDiscovery();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterTextParameter(Name: Text; DefaultValue: Text)
    var
        Param: Record "NPR POS Action Parameter";
    begin
        RegisterParameter(Name, Param."Data Type"::Text, DefaultValue, '');
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterIntegerParameter(Name: Text; DefaultValue: Integer)
    var
        Param: Record "NPR POS Action Parameter";
    begin
        RegisterParameter(Name, Param."Data Type"::Integer, Format(DefaultValue, 0, 9), '');
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterDateParameter(Name: Text; DefaultValue: Date)
    var
        Param: Record "NPR POS Action Parameter";
    begin
        RegisterParameter(Name, Param."Data Type"::Date, Format(DefaultValue, 0, 9), '');
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterBooleanParameter(Name: Text; DefaultValue: Boolean)
    var
        Param: Record "NPR POS Action Parameter";
    begin
        RegisterParameter(Name, Param."Data Type"::Boolean, Format(DefaultValue, 0, 9), '');
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterDecimalParameter(Name: Text; DefaultValue: Decimal)
    var
        Param: Record "NPR POS Action Parameter";
    begin
        RegisterParameter(Name, Param."Data Type"::Decimal, Format(DefaultValue, 0, 9), '');
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterOptionParameter(Name: Text; Options: Text; DefaultValue: Text)
    var
        Param: Record "NPR POS Action Parameter";
    begin
        RegisterParameter(Name, Param."Data Type"::Option, DefaultValue, Options);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure RegisterParameter(Name: Text; DataType: Option; DefaultValue: Text; Options: Text)
    var
        Param: Record "NPR POS Action Parameter";
    begin
        if not ActionUpdateRequired then
            exit;

        Param."POS Action Code" := Code;
        Param.Name := CopyStr(Name, 1, MaxStrLen(Param.Name));
        Param."Data Type" := DataType;
        Param."Default Value" := CopyStr(DefaultValue, 1, MaxStrLen(Param."Default Value"));
        if DataType = Param."Data Type"::Option then
            Param.Options := CopyStr(Options, 1, MaxStrLen(Param.Options));

        if not IsTemporary then
            Param.Validate("Default Value");

        Param.Insert();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterDataBinding()
    begin
        "Bound to DataSource" := true;
        Modify();
        UpdateActionBuffers();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterDataSourceBinding(DataSource: Code[50])
    begin
        "Bound to DataSource" := true;
        "Data Source Name" := DataSource;
        Modify();
        UpdateActionBuffers();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterCustomJavaScriptLogic(Method: Text; JavaScriptCode: Text)
    var
        Json: JsonObject;
    begin
        if not IsTemporary then
            CalcFields("Custom JavaScript Logic");
        if "Custom JavaScript Logic".HasValue() then begin
            Json := GetCustomJavaScriptLogic();
            if Json.Contains(Method) then
                Json.Remove(Method);
        end;

        Json.Add(Method, JavaScriptCode);
        StreamCustomJavaScriptToBlob(Json);
        Modify();
        UpdateActionBuffers();
    end;

    procedure RegisterCustomJavaScriptLogicV3(Method: Text; JavaScriptCode: Text)
    var
        Json: JsonObject;
    begin
        CalcFields("Custom JavaScript Logic");
        if "Custom JavaScript Logic".HasValue() then begin
            Json := GetCustomJavaScriptLogic();
            if Json.Contains(Method) then
                Json.Remove(Method);
        end;

        Json.Add(Method, JavaScriptCode);
        StreamCustomJavaScriptToBlobV3(Json);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterDataSource(Name: Code[50])
    begin
        "Data Source Name" := Name;
        Modify();
        UpdateActionBuffers();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterBlockingUI(Blocking: Boolean)
    begin
        "Blocking UI" := Blocking;
        Modify();
        UpdateActionBuffers();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterTooltip(TooltipIn: Text)
    begin
        Tooltip := CopyStr(TooltipIn, 1, MaxStrLen(Tooltip));
        Modify();
        UpdateActionBuffers();
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RegisterSecureMethod(SecureMethodCode: Code[10])
    begin
        "Secure Method Code" := SecureMethodCode;
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure IsThisAction("Code": Code[20]): Boolean
    begin
        exit(Rec.Code = Code);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure UpdateActionBuffers()
    begin
        if Rec.IsTemporary then
            POSSession.DiscoverSessionAction(Rec);

        if TempUpdatedActions.Get(Rec.Code) then begin
            TempUpdatedActions := Rec;
            TempUpdatedActions.Modify();
        end;
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    procedure RefreshWorkflow()
    begin
        ActionInRefresh := Code;
        OnDiscoverActions();
        if TempUpdatedActions.Find() then
            OnAfterActionUpdated(TempUpdatedActions);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure StreamWorkflowToBlob()
    var
        OutStr: OutStream;
    begin
        Clear(Workflow);
        Workflow.CreateOutStream(OutStr);
        WorkflowObj.GetJson().WriteTo(OutStr);
    end;

    internal procedure StreamWorkflowToBlobV3(ActionCode: Text; Javascript: Text)
    var
        OutStr: OutStream;
        WorkflowStep: JsonObject;
        WorkflowWrapper: Codeunit "NPR Workflow";
    begin
        WorkflowWrapper.SetName(ActionCode);
        ActionInDiscovery := Code;
        WorkflowWrapper.Content().Add('engineVersion', '2.0');
        WorkflowStep.Add('Code', Javascript);
        WorkflowWrapper.Steps().Add(WorkflowStep);

        Clear(Workflow);
        Workflow.CreateOutStream(OutStr);
        WorkflowWrapper.GetJson().WriteTo(OutStr);
    end;


    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure StreamCustomJavaScriptToBlob(Json: JsonObject)
    var
        OutStr: OutStream;
    begin
        Clear("Custom JavaScript Logic");
        "Custom JavaScript Logic".CreateOutStream(OutStr);
        Json.WriteTo(OutStr);
        Modify();
    end;

    local procedure StreamCustomJavaScriptToBlobV3(Json: JsonObject)
    var
        OutStr: OutStream;
    begin
        Clear("Custom JavaScript Logic");
        "Custom JavaScript Logic".CreateOutStream(OutStr);
        Json.WriteTo(OutStr);
    end;

    procedure GetCustomJavaScriptLogic() Json: JsonObject
    var
        InStr: InStream;
    begin
        if not IsTemporary then
            CalcFields("Custom JavaScript Logic");

        "Custom JavaScript Logic".CreateInStream(InStr);
        Json.ReadFrom(InStr);
    end;

    local procedure CheckParameter(Name: Text; Value: Variant; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Parameter: Record "NPR POS Action Parameter";
    begin
        if not Parameter.Get(Code, Name) then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text005, Name, Code));

        if ((Parameter."Data Type" = Parameter."Data Type"::Boolean) and (not Value.IsBoolean)) or
          (Parameter."Data Type" = Parameter."Data Type"::Date) and (not Value.IsDate) or
          (Parameter."Data Type" = Parameter."Data Type"::Decimal) and (not IsValueNumeric(Value)) or
          (Parameter."Data Type" = Parameter."Data Type"::Integer) and (not IsValueInteger(Value))
        then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text006, Parameter."Data Type", Name, Code));
    end;

    local procedure IsValueNumeric(Value: Variant): Boolean
    begin
        exit(Value.IsBigInteger or Value.IsDecimal or Value.IsInteger or Value.IsChar);
    end;

    local procedure IsValueInteger(Value: Variant): Boolean
    begin
        exit(Value.IsBigInteger or Value.IsInteger or Value.IsChar);
    end;

    local procedure SetWorkflowInvocationDictionary(var Json: JsonObject; Name: Text; Value: Variant)
    var
        JsonMgt: Codeunit "NPR POS JSON Management";
    begin
        if Json.Contains(Name) then
            Json.Remove(Name);

        JsonMgt.AddVariantValueToJsonObject(Json, Name, Value);
    end;

    procedure SetWorkflowInvocationParameter(Name: Text; Value: Variant; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        CheckParameter(Name, Value, FrontEnd);
        SetWorkflowInvocationDictionary(WorkflowInvocationParameters, Name, Value);
    end;

    procedure SetWorkflowInvocationParameterUnsafe(Name: Text; Value: Variant)
    begin
        SetWorkflowInvocationDictionary(WorkflowInvocationParameters, Name, Value);
    end;


    procedure SetWorkflowInvocationContext(Name: Text; Value: Variant)
    begin
        SetWorkflowInvocationDictionary(WorkflowInvocationContext, Name, Value);
    end;

    procedure GetWorkflowInvocationContext(var WorkflowInvocationParametersOut: JsonObject; var WorkflowInvocationContextOut: JsonObject)
    begin
        WorkflowInvocationParametersOut := WorkflowInvocationParameters;
        WorkflowInvocationContextOut := WorkflowInvocationContext;
    end;

    procedure DiscoverActions()
    var
        DiscoverAllWorkflows: Codeunit "NPR POS Refresh Workflows";
    begin
        OnDiscoverActions(); //v1+v2
        HandleActionUpdates(); //v1+v2

        DiscoverAllWorkflows.RefreshAll(); //v3
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure RequireVersion10()
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if Version20 then
            FrontEnd.ReportBugAndThrowError(Text007);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure RequireVersion20()
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if not Version20 then
            FrontEnd.ReportBugAndThrowError(Text008);
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    [IntegrationEvent(TRUE, false)]
    local procedure OnDiscoverActions()
    begin
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    [IntegrationEvent(false, false)]
    local procedure OnActionDiscovered(var Rec: Record "NPR POS Action")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterActionUpdated("Action": Record "NPR POS Action")
    begin
    end;

    procedure SetWorkflowTypeAttended()
    begin
        "Requires POS Type" := "Requires POS Type"::ATTENDED;
        POSSession.DiscoverSessionAction(Rec);
        if (IsTemporary()) then
            UpdatePersistentRecordPOSType(Rec);
    end;

    procedure SetWorkflowTypeUnattended()
    begin
        "Requires POS Type" := "Requires POS Type"::UNATTENDED;
        POSSession.DiscoverSessionAction(Rec);
        if (IsTemporary()) then
            UpdatePersistentRecordPOSType(Rec);
    end;

    local procedure UpdatePersistentRecordPOSType(ActionIn: Record "NPR POS Action")
    var
        POSAction: Record "NPR POS Action";
    begin
        if POSAction.Get(ActionIn."Code") then begin
            POSAction."Requires POS Type" := ActionIn."Requires POS Type";
            POSAction.Modify();
        end;
    end;

    procedure GetWorkflowType(): Integer
    begin
        exit("Requires POS Type");
    end;

    [Obsolete('Delete when final v1/v2 workflow is gone')]
    local procedure UpdateMLDescription("Code": Code[20]; Description: Text[250])
    var
        POSAction: Record "NPR POS Action";
    begin
        if POSAction.Get(Code) then
            if POSAction.Description <> Description then begin
                POSAction.Description := Description;
                POSAction.Modify();
            end;
    end;
}
