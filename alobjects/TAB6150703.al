table 6150703 "POS Action"
{
    // NPR5.32.11/VB /20170621  CASE 281618 Added "Blocking UI", Tooltip and "Codeunit ID" fields. Extended action discovery functionality.
    // NPR5.38/BR  /20180126  CASE 303453 Fixed bug in refreshing POS Actions
    // NPR5.39/VB  /20180209  CASE 304928 Making sure discovery is forced when Workflow BLOB field contains no data (to prevent error reported in this case).
    // NPR5.39/MMV /20180209  CASE 299114 Added publisher for modules that need to act on updated actions.
    // NPR5.40/VB  /20180228  CASE 306347 Performance improvement due to parameters in BLOB and physical-table action discovery
    // NPR5.40/MMV /20180307  CASE 307453 Added update handling of POS action within new temp structure.
    // NPR5.43/VB  /20180611  CASE 314603 Implemented secure method behavior functionality.
    // NPR5.44/VB  /20180705  CASE 286547 Fixed issue with custom javascript code not being properly passed to the front end.
    // NPR5.44/JDH /20180731  CASE 323499 Changed all functions to be External
    // NPR5.46/MHA /20180927  CASE 329621 Removed redundant INSERT/MODIFY that caused error during Upgrade procedure in HandleActionUpdates()
    // NPR5.50/VB  /20181205  CASE 338666 Supporting Workflows 2.0
    //                                    Modifying the behavior of "Subscriber Instances Allowed" - it's now obsolete.

    Caption = 'POS Action';
    DrillDownPageID = "POS Actions";
    LookupPageID = "POS Actions";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(3;Version;Text[30])
        {
            Caption = 'Version';
        }
        field(4;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(5;Workflow;BLOB)
        {
            Caption = 'Workflow';
        }
        field(6;Type;Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Generic,Button,BackEnd';
            OptionMembers = Generic,Button,BackEnd;
        }
        field(7;"Subscriber Instances Allowed";Option)
        {
            Caption = 'Subscriber Instances Allowed';
            OptionCaption = 'Single,Multiple';
            OptionMembers = Single,Multiple;
        }
        field(8;"Bound to DataSource";Boolean)
        {
            Caption = 'Bound to DataSource';
            Editable = false;
        }
        field(9;"Custom JavaScript Logic";BLOB)
        {
            Caption = 'Custom JavaScript Logic';
        }
        field(10;"Data Source Name";Code[50])
        {
            Caption = 'Data Source Name';

            trigger OnLookup()
            var
                DataSource: Record "POS Data Source (Discovery)";
            begin
                DataSource.LookupDataSource("Data Source Name");
            end;
        }
        field(11;"Blocking UI";Boolean)
        {
            Caption = 'Blocking UI';
            Description = 'NPR5.32.11';
        }
        field(12;Tooltip;Text[250])
        {
            Caption = 'Tooltip';
            Description = 'NPR5.32.11';
        }
        field(13;"Codeunit ID";Integer)
        {
            Caption = 'Codeunit ID';
            Description = 'NPR5.32.11';
            Editable = false;
        }
        field(14;"Secure Method Code";Code[10])
        {
            Caption = 'Secure Method Code';
            Description = 'NPR5.43';
            TableRelation = "POS Secure Method";
        }
        field(15;"Workflow Engine Version";Text[30])
        {
            Caption = 'Workflow Engine Version';
            InitValue = '1.0';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //-NPR5.40 [307453]
        //DeleteParameters();
        DeleteParameters(Code);
        //+NPR5.40 [307453]
    end;

    var
        DiscoveredAction: Record "POS Action" temporary;
        POSSession: Codeunit "POS Session";
        WorkflowObj: DotNet npNetWorkflow;
        WorkflowInvocationParameters: DotNet npNetDictionary_Of_T_U;
        WorkflowInvocationContext: DotNet npNetDictionary_Of_T_U;
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
        tmpUpdatedActions: Record "POS Action" temporary;
        Text007: Label 'You have called a Workflow 1.0 function in the context of a Workflow 2.0 discovery process.';
        Text008: Label 'You have called a Workflow 2.0 function in the context of a Workflow 1.0 discovery process.';

    [Scope('Personalization')]
    procedure SetSession(SessionIn: Codeunit "POS Session")
    begin
        POSSession := SessionIn;
    end;

    local procedure DeleteParameters(ActionCode: Text)
    var
        Param: Record "POS Action Parameter";
    begin
        //-NPR5.40 [307453]
        //Param.SETRANGE("POS Action Code",Code);
        Param.SetRange("POS Action Code",ActionCode);
        //+NPR5.40 [307453]
        Param.DeleteAll();
    end;

    local procedure InitializeWorkflowDiscovery()
    begin
        Clear(WorkflowObj);
        ActionInDiscovery := '';
    end;

    local procedure MakeSureDiscoveryIsAllowed("Action": Text)
    var
        FrontEnd: Codeunit "POS Front End Management";
    begin
        if ActionInDiscovery <> '' then
          FrontEnd.ReportBug(StrSubstNo(Text002,Action,ActionInDiscovery));

        DiscoveredAction.Code := Action;
        if DiscoveredAction.Find then begin
            FrontEnd.ReportBug(StrSubstNo(Text004,Action));
          exit;
        end;
        DiscoveredAction.Insert;
    end;

    [Scope('Personalization')]
    procedure DiscoverAction("Code": Code[20];Description: Text[250];Version: Text[30];Type: Integer;AllowedInstances: Option): Boolean
    begin
        if (ActionInRefresh <> '') and (ActionInRefresh <> Code) then
          exit(false);

        MakeSureDiscoveryIsAllowed(Code);
        //-NPR5.40 [306347]
        //POSSession.DiscoverSessionAction(Code);
        //+NPR5.40 [306347]

        //-NPR5.40 [307453]
        // INIT();
        //
        // Rec.Code := Code;
        // IF FIND AND (ActionInRefresh <> Code) AND (Rec.Version >= Version) AND (Workflow.HASVALUE OR (Rec.Type = Rec.Type::BackEnd)) THEN
        //  EXIT(FALSE);
        //
        // DeleteParameters();

        //-NPR5.50 [338666]
        Version20 := false;
        //+NPR5.50 [338666]

        ActionUpdateRequired := ActionUpdateCheck(Code, Version);

        if not (IsTemporary or ActionUpdateRequired) then
          exit(false);

        if ActionUpdateRequired then
          DeleteParameters(Code);

        Init();
        Rec.Code := Code;
        //+NPR5.40 [307453]
        Rec.Description := Description;
        Rec.Version := Version;
        Rec.Type := Type;

        //-NPR5.40 [307453]
        //OnActionDiscovered(Rec);
        if ActionUpdateRequired then
          OnActionDiscovered(Rec);
        //+NPR5.40 [307453]

        if not Insert then ;

        if (ActionInRefresh = Code) then
         Modify;

        if Rec.Type <> Rec.Type::BackEnd then begin
          WorkflowObj := WorkflowObj.Workflow();
          WorkflowObj.Name := Code;
          ActionInDiscovery := Code;
        end else
          InitializeWorkflowDiscovery();

        //-NPR5.40 [306347]
        if Rec.IsTemporary then
          POSSession.DiscoverSessionAction(Rec);
        //+NPR5.40 [306347]

        //-NPR5.40 [307453]
        //-NPR5.39 [299114]
        // tmpUpdatedActions := Rec;
        // tmpUpdatedActions.INSERT;
        //+NPR5.39 [299114]
        //+NPR5.40 [307453]

        exit(true);
    end;

    procedure DiscoverAction20("Code": Code[20];Description: Text[250];Version: Text[30]): Boolean
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

        Init();
        Rec.Code := Code;
        Rec.Description := Description;
        Rec.Version := Version;
        Rec."Workflow Engine Version" := '2.0';

        if ActionUpdateRequired then
          OnActionDiscovered(Rec);

        if not Insert then ;

        if (ActionInRefresh = Code) then
         Modify;

        if Rec.Type <> Rec.Type::BackEnd then begin
          WorkflowObj := WorkflowObj.Workflow();
          WorkflowObj.Name := Code;
          ActionInDiscovery := Code;
          WorkflowObj.Content.Add('engineVersion','2.0');
        end else
          InitializeWorkflowDiscovery();

        if Rec.IsTemporary then
          POSSession.DiscoverSessionAction(Rec);

        exit(true);
    end;

    local procedure ActionUpdateCheck("Code": Text;Version: Text): Boolean
    var
        POSAction: Record "POS Action";
    begin
        //-NPR5.40 [307453]
        POSAction.SetRange(Code, Code);
        POSAction.SetRange(Version, Version);
        if POSAction.IsEmpty then begin
          tmpUpdatedActions.Code := Code;
          tmpUpdatedActions.Insert;
          exit(true);
        end;
        //+NPR5.40 [307453]
    end;

    local procedure HandleActionUpdates()
    var
        POSAction: Record "POS Action";
    begin
        //-NPR5.40 [307453]
        tmpUpdatedActions.SetAutoCalcFields(Workflow);
        tmpUpdatedActions.SetAutoCalcFields("Custom JavaScript Logic");
        if tmpUpdatedActions.FindSet then
          repeat
            //-NPR5.46 [329621]
            // POSAction := tmpUpdatedActions;
            // IF NOT POSAction.INSERT THEN
            //   POSAction.MODIFY;
            // OnAfterActionUpdated(POSAction);
            OnAfterActionUpdated(tmpUpdatedActions);
            //+NPR5.46 [329621]
          until tmpUpdatedActions.Next = 0;
        //+NPR5.40 [307453]
    end;

    [Scope('Personalization')]
    procedure RegisterWorkflowStep(Label: Text;"Code": Text)
    var
        FrontEnd: Codeunit "POS Front End Management";
        WorkflowStep: DotNet npNetWorkflowStep;
    begin
        if IsNull(WorkflowObj) then
          FrontEnd.ReportBug(Text001);

        //-NPR5.50 [338666]
        RequireVersion10();
        //+NPR5.50 [338666]

        WorkflowStep := WorkflowStep.WorkflowStep();
        WorkflowStep.Label := Label;
        WorkflowStep.Code := Code;
        WorkflowObj.Steps.Add(WorkflowStep);
    end;

    [Scope('Personalization')]
    procedure RegisterWorkflow(WithOnBeforeWorkflowEvent: Boolean)
    var
        FrontEnd: Codeunit "POS Front End Management";
    begin
        //-NPR5.50 [338666]
        RequireVersion10();
        //+NPR5.50 [338666]

        if Type = Type::BackEnd then
          FrontEnd.ReportBug(StrSubstNo(Text003,Code,Type));

        WorkflowObj.RequestContext := WithOnBeforeWorkflowEvent;
        StreamWorkflowToBlob();
        Modify();
        //-NPR5.40 [307453]
        UpdateActionBuffers();
        //+NPR5.40 [307453]

        InitializeWorkflowDiscovery();
    end;

    [Scope('Personalization')]
    procedure RegisterWorkflow20("Code": Text)
    var
        FrontEnd: Codeunit "POS Front End Management";
        WorkflowStep: DotNet npNetWorkflowStep;
    begin
        //-NPR5.50 [338666]
        RequireVersion20();

        if Type = Type::BackEnd then
          FrontEnd.ReportBug(StrSubstNo(Text003,Code,Type));

        WorkflowStep := WorkflowStep.WorkflowStep();
        WorkflowStep.Code := Code;
        WorkflowObj.Steps.Add(WorkflowStep);

        StreamWorkflowToBlob();
        Modify();
        UpdateActionBuffers();

        InitializeWorkflowDiscovery();
        //+NPR5.50 [338666]
    end;

    [Scope('Personalization')]
    procedure RegisterTextParameter(Name: Text;DefaultValue: Text)
    var
        Param: Record "POS Action Parameter";
    begin
        RegisterParameter(Name,Param."Data Type"::Text,DefaultValue,'');
    end;

    [Scope('Personalization')]
    procedure RegisterIntegerParameter(Name: Text;DefaultValue: Integer)
    var
        Param: Record "POS Action Parameter";
    begin
        RegisterParameter(Name,Param."Data Type"::Integer,Format(DefaultValue,0,9),'');
    end;

    [Scope('Personalization')]
    procedure RegisterDateParameter(Name: Text;DefaultValue: Date)
    var
        Param: Record "POS Action Parameter";
    begin
        RegisterParameter(Name,Param."Data Type"::Date,Format(DefaultValue,0,9),'');
    end;

    [Scope('Personalization')]
    procedure RegisterBooleanParameter(Name: Text;DefaultValue: Boolean)
    var
        Param: Record "POS Action Parameter";
    begin
        RegisterParameter(Name,Param."Data Type"::Boolean,Format(DefaultValue,0,9),'');
    end;

    [Scope('Personalization')]
    procedure RegisterDecimalParameter(Name: Text;DefaultValue: Decimal)
    var
        Param: Record "POS Action Parameter";
    begin
        RegisterParameter(Name,Param."Data Type"::Decimal,Format(DefaultValue,0,9),'');
    end;

    [Scope('Personalization')]
    procedure RegisterOptionParameter(Name: Text;Options: Text;DefaultValue: Text)
    var
        Param: Record "POS Action Parameter";
    begin
        RegisterParameter(Name,Param."Data Type"::Option,DefaultValue,Options);
    end;

    local procedure RegisterParameter(Name: Text;DataType: Option;DefaultValue: Text;Options: Text)
    var
        Param: Record "POS Action Parameter";
    begin
        //-NPR5.40 [307453]
        if not ActionUpdateRequired then
          exit;
        //+NPR5.40 [307453]

        Param."POS Action Code" := Code;
        Param.Name := Name;
        Param."Data Type" := DataType;
        Param."Default Value" := DefaultValue;
        if DataType = Param."Data Type"::Option then
          Param.Options := Options;

        //-NPR5.40 [306347]
        if not IsTemporary then
          Param.Validate("Default Value");
        //+NPR5.40 [306347]

        Param.Insert;
    end;

    [Scope('Personalization')]
    procedure RegisterDataBinding()
    begin
        "Bound to DataSource" := true;
        Modify;
        //-NPR5.40 [307453]
        UpdateActionBuffers();
        //+NPR5.40 [307453]
    end;

    [Scope('Personalization')]
    procedure RegisterDataSourceBinding(DataSource: Code[50])
    begin
        "Bound to DataSource" := true;
        "Data Source Name" := DataSource;
        Modify;
        //-NPR5.40 [307453]
        UpdateActionBuffers();
        //+NPR5.40 [307453]
    end;

    [Scope('Personalization')]
    procedure RegisterCustomJavaScriptLogic(Method: Text;JavaScriptCode: Text)
    var
        Dictionary: DotNet npNetDictionary_Of_T_U;
        MemStr: DotNet npNetMemoryStream;
        StreamWriter: DotNet npNetStreamWriter;
        OutStr: OutStream;
    begin
        //-NPR5.44 [286547]
        if not IsTemporary then
          CalcFields("Custom JavaScript Logic");
        //+NPR5.44 [286547]
        if "Custom JavaScript Logic".HasValue then begin
          GetCustomJavaScriptLogic(Dictionary);
          if Dictionary.ContainsKey(Method) then
            Dictionary.Remove(Method);
        end else
          CreateDotNetDict(Dictionary);

        Dictionary.Add(Method,JavaScriptCode);
        StreamCustomJavaScriptToBlob(Dictionary);
        Modify;
        //-NPR5.40 [307453]
        UpdateActionBuffers();
        //+NPR5.40 [307453]
    end;

    [Scope('Personalization')]
    procedure RegisterDataSource(Name: Code[50])
    begin
        "Data Source Name" := Name;
        //-NPR5.40 [306347]
        Modify;
        //+NPR5.40 [306347]
        //-NPR5.40 [307453]
        UpdateActionBuffers();
        //+NPR5.40 [307453]
    end;

    [Scope('Personalization')]
    procedure RegisterBlockingUI(Blocking: Boolean)
    begin
        //-NPR5.32.11 [281618]
        "Blocking UI" := Blocking;
        Modify;
        //+NPR5.32.11 [281618]
        //-NPR5.40 [307453]
        UpdateActionBuffers();
        //+NPR5.40 [307453]
    end;

    [Scope('Personalization')]
    procedure RegisterTooltip(TooltipIn: Text)
    begin
        //-NPR5.32.11 [281618]
        Tooltip := CopyStr(TooltipIn,1,MaxStrLen(Tooltip));
        Modify;
        //+NPR5.32.11 [281618]
        //-NPR5.40 [307453]
        UpdateActionBuffers();
        //+NPR5.40 [307453]
    end;

    [Scope('Personalization')]
    procedure RegisterSecureMethod(SecureMethodCode: Code[10])
    begin
        //-NPR5.43 [314603]
        "Secure Method Code" := SecureMethodCode;
        //+NPR5.43
    end;

    [Scope('Personalization')]
    procedure IsThisAction("Code": Code[20]): Boolean
    begin
        exit(Rec.Code = Code);
    end;

    local procedure UpdateActionBuffers()
    begin
        //-NPR5.40 [307453]
        if Rec.IsTemporary then
          POSSession.DiscoverSessionAction(Rec);

        if tmpUpdatedActions.Get(Rec.Code) then begin
          tmpUpdatedActions := Rec;
          tmpUpdatedActions.Modify;
        end;
        //+NPR5.40 [307453]
    end;

    [Scope('Personalization')]
    procedure RefreshWorkflow()
    var
        "Action": Record "POS Action";
    begin
        ActionInRefresh := Code;
        OnDiscoverActions();
        //-NPR5.39 [299114]
        if tmpUpdatedActions.Find then
          OnAfterActionUpdated(tmpUpdatedActions);
        //+NPR5.39 [299114]
    end;

    local procedure StreamWorkflowToBlob()
    var
        MemStr: DotNet npNetMemoryStream;
        StreamWriter: DotNet npNetStreamWriter;
        OutStr: OutStream;
    begin
        Clear(Workflow);
        Workflow.CreateOutStream(OutStr);
        StreamWriter := StreamWriter.StreamWriter(OutStr);
        StreamWriter.Write(WorkflowObj.ToJsonString());
        StreamWriter.Flush();
        StreamWriter.Close();
    end;

    local procedure StreamCustomJavaScriptToBlob(Dictionary: DotNet npNetDictionary_Of_T_U)
    var
        Converters: DotNet npNetArray;
        Converter: DotNet npNetJsonConverter;
        KeyValuePairConverter: DotNet npNetKeyValuePairConverter;
        MemStr: DotNet npNetMemoryStream;
        StreamWriter: DotNet npNetStreamWriter;
        JsonConvert: DotNet npNetJsonConvert;
        OutStr: OutStream;
    begin
        Converters := Converters.CreateInstance(GetDotNetType(Converter),1);
        Converters.SetValue(KeyValuePairConverter.KeyValuePairConverter,0);

        Clear("Custom JavaScript Logic");
        "Custom JavaScript Logic".CreateOutStream(OutStr);
        StreamWriter := StreamWriter.StreamWriter(OutStr);
        StreamWriter.Write(JsonConvert.SerializeObject(Dictionary,Converters));
        StreamWriter.Flush();
        StreamWriter.Close();
        //-NPR5.44 [286547]
        Modify;
        //+NPR5.44 [286547]
    end;

    [Scope('Personalization')]
    procedure GetCustomJavaScriptLogic(var "Object": DotNet npNetObject)
    var
        Dictionary: DotNet npNetDictionary_Of_T_U;
        KeyValuePair: DotNet npNetKeyValuePair_Of_T_U;
        JObject: DotNet npNetJObject;
        StreamReader: DotNet npNetStreamReader;
        InStr: InStream;
    begin
        //-NPR5.44 [286547]
        if not IsTemporary then
          CalcFields("Custom JavaScript Logic");
        //+NPR5.44 [286547]
        "Custom JavaScript Logic".CreateInStream(InStr);
        StreamReader := StreamReader.StreamReader(InStr);
        JObject := JObject.Parse(StreamReader.ReadToEnd());
        StreamReader.Close();

        CreateDotNetDict(Dictionary);
        foreach KeyValuePair in JObject do
          Dictionary.Add(KeyValuePair.Key,Format(KeyValuePair.Value));

        Object := Dictionary;
    end;

    local procedure CreateDotNetDict(var Dict: DotNet npNetDictionary_Of_T_U)
    var
        Type: DotNet npNetType;
        Activator: DotNet npNetActivator;
        Arr: DotNet npNetArray;
    begin
        Arr := Arr.CreateInstance(GetDotNetType(Type),2);
        Arr.SetValue(GetDotNetType(''),0);
        Arr.SetValue(GetDotNetType(''),1);

        Type := GetDotNetType(Dict);
        Type := Type.MakeGenericType(Arr);

        Dict := Activator.CreateInstance(Type);
    end;

    local procedure CheckParameter(Name: Text;Value: Variant;FrontEnd: Codeunit "POS Front End Management")
    var
        Parameter: Record "POS Action Parameter";
    begin
        if not Parameter.Get(Code,Name) then
          FrontEnd.ReportBug(StrSubstNo(Text005,Name,Code));

        if ((Parameter."Data Type" = Parameter."Data Type"::Boolean) and (not Value.IsBoolean)) or
          (Parameter."Data Type" = Parameter."Data Type"::Date) and (not Value.IsDate) or
          (Parameter."Data Type" = Parameter."Data Type"::Decimal) and (not IsValueNumeric(Value)) or
          (Parameter."Data Type" = Parameter."Data Type"::Integer) and (not IsValueInteger(Value))
        then
          FrontEnd.ReportBug(StrSubstNo(Text006,Parameter."Data Type",Name,Code));
    end;

    local procedure IsValueNumeric(Value: Variant): Boolean
    begin
        exit(Value.IsBigInteger or Value.IsDecimal or Value.IsInteger or Value.IsChar);
    end;

    local procedure IsValueInteger(Value: Variant): Boolean
    begin
        exit(Value.IsBigInteger or Value.IsInteger or Value.IsChar);
    end;

    local procedure SetWorkflowInvocationDictionary(var Dictionary: DotNet npNetDictionary_Of_T_U;Name: Text;Value: Variant)
    begin
        if IsNull(Dictionary) then
          Dictionary := Dictionary.Dictionary();

        if Dictionary.ContainsKey(Name) then
          Dictionary.Remove(Name);

        Dictionary.Add(Name,Value);
    end;

    [Scope('Personalization')]
    procedure SetWorkflowInvocationParameter(Name: Text;Value: Variant;FrontEnd: Codeunit "POS Front End Management")
    begin
        CheckParameter(Name,Value,FrontEnd);
        SetWorkflowInvocationDictionary(WorkflowInvocationParameters,Name,Value);
    end;

    [Scope('Personalization')]
    procedure SetWorkflowInvocationContext(Name: Text;Value: Variant)
    begin
        SetWorkflowInvocationDictionary(WorkflowInvocationContext,Name,Value);
    end;

    [Scope('Personalization')]
    procedure GetWorkflowInvocationContext(var WorkflowInvocationParametersOut: DotNet npNetDictionary_Of_T_U;var WorkflowInvocationContextOut: DotNet npNetDictionary_Of_T_U)
    begin
        WorkflowInvocationParametersOut := WorkflowInvocationParameters;
        WorkflowInvocationContextOut := WorkflowInvocationContext;
    end;

    [Scope('Personalization')]
    procedure DiscoverActions()
    var
        CodeunitInstanceDetector: Codeunit "POS Action Management";
    begin
        //-NPR5.39 [299114]
        //-NPR5.40 [306347]
        CodeunitInstanceDetector.InitializeActionDiscovery();
        BindSubscription(CodeunitInstanceDetector);
        //+NPR5.40 [306347]
        OnDiscoverActions();
        //-NPR5.40 [306347]
        UnbindSubscription(CodeunitInstanceDetector);
        //+NPR5.40 [306347]

        //-NPR5.40 [307453]
        // IF tmpUpdatedActions.FINDSET THEN REPEAT
        //  OnAfterActionUpdated(tmpUpdatedActions);
        // UNTIL tmpUpdatedActions.NEXT = 0;
        HandleActionUpdates();
        //+NPR5.40 [307453]
        //+NPR5.39 [299114]
    end;

    local procedure RequireVersion10()
    var
        FrontEnd: Codeunit "POS Front End Management";
    begin
        //-NPR5.50 [338666]
        if Version20 then
          FrontEnd.ReportBug(Text007);
        //+NPR5.50 [338666]
    end;

    local procedure RequireVersion20()
    var
        FrontEnd: Codeunit "POS Front End Management";
    begin
        //-NPR5.50 [338666]
        if not Version20 then
          FrontEnd.ReportBug(Text008);
        //+NPR5.50 [338666]
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnRegisterActionWorkflow(Workflow: DotNet npNetWorkflow;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnDiscoverActions()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnActionDiscovered(var Rec: Record "POS Action")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterActionUpdated("Action": Record "POS Action")
    begin
    end;
}

