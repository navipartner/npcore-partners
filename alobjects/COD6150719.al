codeunit 6150719 "POS Action Management"
{
    // NPR5.32.11/VB /20170621  CASE 281618 Added codeunit detection during action discovery. For this to properly work, this codeunit must be manually subscribed.
    //                                   (Alternatively, it could be single-instance, but that would be a bad choice, so please keep this manually subscribed.)
    // NPR5.38/BR  /20171122  CASE 295074 Added functions to Upgrade Parameter
    // NPR5.39/MMV /20180212 CASE 299114 Rolling back previous parameter upgrade approach
    // NPR5.40/VB  /20180228 CASE 306347 Adding functions to support action discovery changes

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        TextActionDoesNotExist: Label 'Action %1 does not exist, but it is used in %2.';
        TextUndefinedParameter: Label '%2 specifies a value for a parameter %3, that is not defined for action %1.';
        TextParameterNotDefined: Label 'Action %1 defines parameter %3, but the value for this parameter is not specified in %2.';
        TextParameterValueInvalid: Label '%2 specifies value [%5] for parameter %3, which is not a valid %4 as required by action %1.';
        DiscoveryState: Record "Event Subscription" temporary;
        ActionsDiscovered: Boolean;

    procedure LookupAction(var ActionCode: Code[20]): Boolean
    var
        POSAction: Record "POS Action";
        POSActions: Page "POS Actions";
    begin
        //-NPR5.40 [306347]
        POSActions.LookupMode := true;
        POSActions.SetSkipDiscovery(ActionsDiscovered);
        POSActions.SetAction(ActionCode);
        ActionsDiscovered := true;
        if POSActions.RunModal = ACTION::LookupOK then begin
          POSActions.GetRecord(POSAction);
          ActionCode := POSAction.Code;
          exit(true);
        end;
        //+NPR5.40 [306347]
    end;

    procedure IsValidActionConfiguration(POSSession: Codeunit "POS Session";ActionObject: DotNet npNetAction;Source: Text;var ErrorText: Text;RaiseEvent: Boolean): Boolean
    var
        WorkflowAction: DotNet npNetWorkflowAction;
    begin
        case ActionObject.Type of
          WorkflowAction.WorkflowAction().Type: exit(CheckWorkflowActionConfiguration(ActionObject,Source,ErrorText,RaiseEvent,POSSession));
        end;

        exit(true);
    end;

    local procedure CheckWorkflowActionConfiguration(ActionObject: DotNet npNetWorkflowAction;Source: Text;var ErrorText: Text;RaiseEvent: Boolean;POSSession: Codeunit "POS Session"): Boolean
    var
        POSAction: Record "POS Action";
        Parameter: Record "POS Action Parameter";
        Param: DotNet npNetKeyValuePair_Of_T_U;
        Value: Text;
        Severity: Integer;
    begin
        // Invalid situations
        // 2. Specifies parameters that do not exist
        // 3. Does not specify a parameter
        // 4. Specifies value of wrong type
        // 5. Specifies value that is not present in options

        // Action does not exist
        if not POSSession.IsSessionAction(ActionObject.Workflow.Name) then begin
          ErrorText := StrSubstNo(TextActionDoesNotExist,ActionObject.Workflow.Name,Source);
          ReportError(ActionObject,Source,ActionObject.Workflow.Name,ErrorText,100,RaiseEvent);
          exit(false);
        end;

        // Specifies an undefined parameter
        foreach Param in ActionObject.Parameters do begin
          if not Parameter.Get(ActionObject.Workflow.Name,Param.Key) and not (CopyStr(Param.Key,1,8) = '_option_') then begin
            ErrorText := StrSubstNo(TextUndefinedParameter,ActionObject.Workflow.Name,Source,Param.Key);
            ReportError(ActionObject,Source,ActionObject.Workflow.Name,ErrorText,10,RaiseEvent);
            exit(false);
          end;
        end;

        Parameter.SetRange("POS Action Code",ActionObject.Workflow.Name);
        if Parameter.FindSet then
          repeat
            // Parameter not specified
            if not ActionObject.Parameters.ContainsKey(Parameter.Name) then begin
              ErrorText := StrSubstNo(TextParameterNotDefined,ActionObject.Workflow.Name,Source,Parameter.Name);
              ReportError(ActionObject,Source,ActionObject.Workflow.Name,ErrorText,5,RaiseEvent);
              exit(false);
            end;

            // Parameter of incorrect type
            Value := Format(ActionObject.Parameters.Item(Parameter.Name));
            if not IsCorrectParameterValueType(Parameter,Value) then begin
              Severity := 3;
              if Parameter."Data Type" = Parameter."Data Type"::Option then begin
                Value := Format(ActionObject.Content.Item('param_option_' + Parameter.Name + 'originalValue'));
                Severity := 1;
              end;
              ErrorText := StrSubstNo(TextParameterValueInvalid,ActionObject.Workflow.Name,Source,Parameter.Name,Parameter."Data Type",Value);
              ReportError(ActionObject,Source,ActionObject.Workflow.Name,ErrorText,Severity,RaiseEvent);
              exit(false);
            end;
          until Parameter.Next = 0;

        exit(true);
    end;

    [TryFunction]
    local procedure IsCorrectParameterValueType(Parameter: Record "POS Action Parameter";var Value: Text)
    begin
        Parameter.Validate("Default Value",Value);
        if (Parameter."Data Type" = Parameter."Data Type"::Option) and (Value = '-1') then
          Parameter.FieldError("Default Value");
    end;

    local procedure ReportError(ActionObject: DotNet npNetAction;Source: Text;"Action": Text;ErrorText: Text;Severity: Integer;RaiseEvent: Boolean)
    begin
        ActionObject.Content.Add('error',ErrorText);
        ActionObject.Content.Add('errorSeverity',Severity);
        if RaiseEvent then
          OnInvalidActionConfiguration(Source,Action,ErrorText);
    end;

    local procedure InitializeDiscoveryState(var State: Record "Event Subscription" temporary)
    var
        EventSubscriber: Record "Event Subscription";
    begin
        //-NPR5.32.11 [281618]
        if not State.IsTemporary then
          Error('Function call on a non-temporary variable. This is a critical programming error.');

        State.DeleteAll();
        with EventSubscriber do begin
          SetRange("Publisher Object Type","Publisher Object Type"::Table);
          SetRange("Publisher Object ID",6150703);
          SetRange("Published Function",'OnDiscoverActions');
          if FindSet then
            repeat
              State := EventSubscriber;
              State.Insert();
            until Next = 0;
        end;
        //+NPR5.32.11 [281618]
    end;

    procedure InitializeActionDiscovery()
    begin
        //-NPR5.32.11 [281618]
        InitializeDiscoveryState(DiscoveryState);
        //+NPR5.32.11 [281618]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnActionDiscovered', '', false, false)]
    local procedure OnActionDiscovered(var Rec: Record "POS Action")
    var
        NewDiscoveryState: Record "Event Subscription" temporary;
    begin
        //-NPR5.32.11 [281618]
        InitializeDiscoveryState(NewDiscoveryState);
        if NewDiscoveryState.FindSet then
          repeat
            if DiscoveryState.Get(NewDiscoveryState."Subscriber Codeunit ID",NewDiscoveryState."Subscriber Function")
              and (DiscoveryState."Number of Calls" <> NewDiscoveryState."Number of Calls") then
            begin
              DiscoveryState."Number of Calls" := NewDiscoveryState."Number of Calls";
              Rec."Codeunit ID" := NewDiscoveryState."Subscriber Codeunit ID";
            end;
          until NewDiscoveryState.Next = 0;
        //+NPR5.32.11 [281618]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInvalidActionConfiguration(Source: Text;"Action": Text;ErrorText: Text)
    begin
    end;
}

