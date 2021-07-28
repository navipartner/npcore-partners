codeunit 6150716 "NPR POS Stargate Management"
{
    // NPR5.33/VB  /20170628  CASE 282239 Modified logic to properly handle Stargate errors and issues.
    // NPR5.37/VB /20170929  CASE 291777 Short-term solution for just-in-time Stargate synchronization in Major Tom

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        Requests: DotNet NPRNetDictionary_Of_T_U;
        States: DotNet NPRNetDictionary_Of_T_U;
        RepeatCounts: DotNet NPRNetDictionary_Of_T_U;
        InstallRepeatCounts: DotNet NPRNetDictionary_Of_T_U;
        TextUnhandledStargateError: Label 'An unhandled Stargate error of type %1 has occurred while executing method %2, step %3.\\The error message is:\%4';
        TextUnsupportedStargateMethodError: Label 'An unknown or unsupported Stargate method %1 has been invoked. You must register the corresponding Stargate package for this method before you can call it.';
        TextDeserializationError: Label 'Stargate was unable to process the response envelope for type %1 due to an exception of type %2.\\The error message is:\%3';
        TextUnexpectedResponseTypeError: Label 'Stargate has received a response of type %1 while a response of type %2 was expected.';
        TextTooManyAttemptsError: Label 'Too many failed attempts at sending request %1.\\This indicates a problem with automatic installation of Stargate assemblies.';
        TextExpectedAppGatewayResponse: Label 'Stargate method %1 expects a response for event %2, but either no subscribers handled it, or an active subscriber failed to indicate successful handling of the event.';
        LastKnownActionName: Text;

    procedure StoreRequest(Request: DotNet NPRNetRequest0; ActionName: Text; Step: Text)
    var
        State: Option SendingRequest,InstallingAssemblies,RepeatingRequest;
        RepeatCount: Integer;
        InstallRepeatCount: Integer;
    begin
        MakeSureActionInfoInitialized(ActionName);
        RetrieveState(ActionName, State, RepeatCount, InstallRepeatCount);
        case State of
            State::InstallingAssemblies:
                exit;
            State::SendingRequest:
                begin
                    if Requests.ContainsKey(ActionName) then
                        Requests.Remove(ActionName);
                    Requests.Add(ActionName, Request);
                end;
            State::RepeatingRequest:
                SetRepeatCount(ActionName, RepeatCount + 1);
        end;
    end;

    procedure ResetRequestState(ActionName: Text)
    begin
        if not IsNull(States) then
            if States.ContainsKey(ActionName) then
                States.Remove(ActionName);

        if not IsNull(Requests) then
            if Requests.ContainsKey(ActionName) then
                States.Remove(ActionName);

        if not IsNull(RepeatCounts) then
            if RepeatCounts.ContainsKey(ActionName) then
                RepeatCounts.Remove(ActionName);

        if not IsNull(InstallRepeatCounts) then
            if InstallRepeatCounts.ContainsKey(ActionName) then
                InstallRepeatCounts.Remove(ActionName);
    end;

    procedure DeviceResponse(Method: Text; Response: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ActionName: Text; Step: Text)
    var
        Envelope: DotNet NPRNetResponseEnvelope0;
        State: Option SendingRequest,InstallingAssemblies,RepeatingRequest;
        RepeatCount: Integer;
        InstallRepeatCount: Integer;
    begin
        Envelope := Envelope.FromString(Response);
        RetrieveState(ActionName, State, RepeatCount, InstallRepeatCount);

        if not Envelope.Success then begin
            if State = State::InstallingAssemblies then begin
                InstallRepeatCount += 1;
                SetInstallRepeatCount(ActionName, InstallRepeatCount);
            end;

            if (RepeatCount = 5) or (InstallRepeatCount = 5) then
                ThrowTooManyAttemptsError(Method, FrontEnd, ActionName);

            ProcessErrorResponse(Envelope, POSSession, FrontEnd, Method, ActionName, Step);
            exit;
        end;

        if (State = State::InstallingAssemblies) then begin
            CompleteInstallingMissingAssemblies(Envelope, FrontEnd, ActionName, Step)
        end else begin
            if Requests.ContainsKey(Method) then
                Requests.Remove(Method);
            OnDeviceResponse(ActionName, Step, Envelope, POSSession, FrontEnd);
        end;
    end;

    procedure DeviceError(Method: Text; Response: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        OnDeviceDoesNotSupportStargate(Method, Response, POSSession, FrontEnd);
        FrontEnd.AbortWorkflows();
    end;

    procedure AppGatewayProtocol(ActionName: Text; StepName: Text; EventName: Text; SerializedData: Text; DoCallback: Boolean; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        ResponseData: Text;
        Handled: Boolean;
    begin
        OnAppGatewayProtocol(FrontEnd, ActionName, StepName, EventName, SerializedData, DoCallback, ResponseData, Handled);

        if not Handled then
            FrontEnd.ReportBugAndThrowError(
              StrSubstNo(
                TextExpectedAppGatewayResponse,
                ActionName,
                EventName));

        if DoCallback then
            FrontEnd.AppGatewayProtocolResponse(EventName, ResponseData);
    end;

    procedure AppGatewayProtocolClosed(ActionName: Text; StepName: Text; SerializedData: Text; Forced: Boolean; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Handled: Boolean;
    begin
        OnAppGatewayProtocolClosed(FrontEnd, ActionName, StepName, SerializedData, Forced, Handled);

        if not Handled then
            FrontEnd.ReportBugAndThrowError(
              StrSubstNo(
                TextExpectedAppGatewayResponse,
                ActionName,
                'ProtocolClosed')); // This is a non-localizable constant
    end;

    procedure DeserializeEnvelope(Envelope: DotNet NPRNetResponseEnvelope0; var Response: DotNet NPRNetResponse1; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Type: DotNet NPRNetType;
    begin
        Type := GetDotNetType(Response);

        if Envelope.ResponseTypeName <> Type.FullName then
            ThrowUnexpectedResponseTypeError(Type, Envelope.ResponseTypeName, FrontEnd, LastKnownActionName);

        if not TryDeserializeEnvelope(Envelope, Response) then
            ThrowDeserializationError(GetLastErrorObject(), Type, FrontEnd, LastKnownActionName);
    end;

    [TryFunction]
    local procedure TryDeserializeEnvelope(Envelope: DotNet NPRNetResponseEnvelope0; var Response: DotNet NPRNetResponse1)
    begin
        Response := Envelope.Deserialize(GetDotNetType(Response));
    end;

    local procedure MakeSureActionInfoInitialized(ActionName: Text)
    var
        State: Option SendingRequest,InstallingAssemblies,RepeatingRequest;
    begin
        if IsNull(Requests) then
            Requests := Requests.Dictionary();

        if IsNull(States) then
            States := States.Dictionary();
        if IsNull(RepeatCounts) then
            RepeatCounts := RepeatCounts.Dictionary();
        if IsNull(InstallRepeatCounts) then
            InstallRepeatCounts := InstallRepeatCounts.Dictionary();

        if not States.ContainsKey(ActionName) then
            States.Add(ActionName, State::SendingRequest);
        if not RepeatCounts.ContainsKey(ActionName) then
            RepeatCounts.Add(ActionName, 0);
        if not InstallRepeatCounts.ContainsKey(ActionName) then
            InstallRepeatCounts.Add(ActionName, 0);
    end;

    local procedure RetrieveState(ActionName: Text; var State: Option; var RepeatCount: Integer; var InstallRepeatCount: Integer)
    begin
        State := States.Item(ActionName);
        RepeatCount := RepeatCounts.Item(ActionName);
        InstallRepeatCount := InstallRepeatCounts.Item(ActionName);
    end;

    local procedure SetState(ActionName: Text; State: Option SendingRequest,InstallingAssemblies,RepeatingRequest)
    begin
        if States.ContainsKey(ActionName) then
            States.Remove(ActionName);
        States.Add(ActionName, State);
    end;

    local procedure SetRepeatCount(ActionName: Text; RepeatCount: Integer)
    begin
        if RepeatCounts.ContainsKey(ActionName) then
            RepeatCounts.Remove(ActionName);
        RepeatCounts.Add(ActionName, RepeatCount);
    end;

    local procedure SetInstallRepeatCount(ActionName: Text; InstallRepeatCount: Integer)
    begin
        if InstallRepeatCounts.ContainsKey(ActionName) then
            InstallRepeatCounts.Remove(ActionName);
        InstallRepeatCounts.Add(ActionName, InstallRepeatCount);
    end;

    local procedure ProcessErrorResponse(Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Method: Text; ActionName: Text; Step: Text)
    var
        ErrorResponse: DotNet NPRNetErrorResponse0;
        InvalidMethodException: DotNet NPRNetInvalidMethodException;
    begin
        LastKnownActionName := ActionName;
        DeserializeEnvelope(Envelope, ErrorResponse, FrontEnd);
        case true of
            ErrorResponse.ExceptionType.Equals(GetDotNetType(InvalidMethodException)):
                InstallMissingAssemblies(FrontEnd, Method, ActionName, Step);
            else
                DeviceErrorResponse(POSSession, FrontEnd, Method, ActionName, Step, ErrorResponse);
        end;
    end;

    local procedure DeviceErrorResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Method: Text; ActionName: Text; Step: Text; ErrorResponse: DotNet NPRNetErrorResponse0)
    var
        Handled: Boolean;
    begin
        OnDeviceErrorResponse(ActionName, Step, ErrorResponse, POSSession, FrontEnd, Handled);

        if not Handled then
            ThrowUnhandledStargateError(ErrorResponse, FrontEnd, Method, ActionName, Step);
    end;

    local procedure InstallMissingAssemblies(FrontEnd: Codeunit "NPR POS Front End Management"; Method: Text; ActionName: Text; Step: Text)
    var
        StargateMethod: Record "NPR POS Stargate Pckg. Method";
        StargatePackage: Record "NPR POS Stargate Package";
        Package: DotNet NPRNetPackage;
        Request: DotNet NPRNetPackageRequest;
        State: Option SendingRequest,InstallingAssemblies,RepeatingRequest;
        StargatePackageJSON: Text;
    begin
        SetState(ActionName, State::InstallingAssemblies);

        if (not StargateMethod.Get(Method)) or (not StargatePackage.Get(StargateMethod."Package Name")) then
            ThrowUnsupportedStargateMethodError(FrontEnd, Method, ActionName);
        StargatePackage.CalcFields(JSON);
        StargatePackage.JSON.Export(StargatePackageJSON);
        Package := Package.FromJsonString(StargatePackageJSON);
        Package.Name := StargatePackage.Name;
        Package.Version := StargatePackage.Version;

        Request := Package.ToRequest();
        FrontEnd.InvokeDeviceInternal(Request, ActionName, Step, false);
    end;

    local procedure CompleteInstallingMissingAssemblies(Envelope: DotNet NPRNetResponseEnvelope0; FrontEnd: Codeunit "NPR POS Front End Management"; ActionName: Text; Step: Text)
    var
        Request: DotNet NPRNetRequest0;
        EmptyResponse: DotNet NPRNetEmptyResponse;
        State: Option SendingRequest,InstallingAssemblies,RepeatingRequest;
    begin
        LastKnownActionName := ActionName;
        DeserializeEnvelope(Envelope, EmptyResponse, FrontEnd);

        Request := Requests.Item(ActionName);
        SetState(ActionName, State::RepeatingRequest);
        FrontEnd.InvokeDeviceInternal(Request, ActionName, Step, true);
    end;

    local procedure ThrowUnhandledStargateError(ErrorResponse: DotNet NPRNetErrorResponse0; FrontEnd: Codeunit "NPR POS Front End Management"; Method: Text; ActionName: Text; Step: Text)
    var
        ErrorMessage: Text;
    begin
        ErrorMessage :=
          StrSubstNo(
            TextUnhandledStargateError,
            ErrorResponse.ExceptionTypeFullName,
            Method,
            Step,
            ErrorResponse.ErrorMessage);
        ResetRequestState(ActionName);
        FrontEnd.AbortWorkflows();
        FrontEnd.ReportBugAndThrowError(ErrorMessage);
    end;

    local procedure ThrowUnsupportedStargateMethodError(FrontEnd: Codeunit "NPR POS Front End Management"; Method: Text; ActionName: Text)
    var
        ErrorMessage: Text;
    begin
        ErrorMessage :=
          StrSubstNo(
            TextUnsupportedStargateMethodError,
            Method);
        ResetRequestState(ActionName);
        FrontEnd.AbortWorkflows();
        FrontEnd.ReportBugAndThrowError(ErrorMessage);
    end;

    local procedure ThrowDeserializationError(Exception: DotNet NPRNetException; Type: DotNet NPRNetType; FrontEnd: Codeunit "NPR POS Front End Management"; ActionName: Text)
    begin
        ResetRequestState(ActionName);
        FrontEnd.AbortWorkflows();
        FrontEnd.ReportBugAndThrowError(
          StrSubstNo(
            TextDeserializationError,
            Type.FullName,
            Exception.GetType(),
            Exception.Message));
    end;

    local procedure ThrowUnexpectedResponseTypeError(var ExpectedType: DotNet NPRNetType; ActualTypeName: Text; FrontEnd: Codeunit "NPR POS Front End Management"; ActionName: Text)
    begin
        ResetRequestState(ActionName);
        FrontEnd.AbortWorkflows();
        FrontEnd.ReportBugAndThrowError(
          StrSubstNo(
            TextUnexpectedResponseTypeError,
            ExpectedType.FullName,
            ActualTypeName));
    end;

    local procedure ThrowTooManyAttemptsError(Method: Text; FrontEnd: Codeunit "NPR POS Front End Management"; ActionName: Text)
    begin
        ResetRequestState(ActionName);
        FrontEnd.AbortWorkflows();
        FrontEnd.ReportBugAndThrowError(
          StrSubstNo(
            TextTooManyAttemptsError,
            Method));
    end;

    [BusinessEvent(false)]
    local procedure OnDeviceResponse(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [BusinessEvent(false)]
#pragma warning disable AA0150
    local procedure OnDeviceErrorResponse(ActionName: Text; Step: Text; Response: DotNet NPRNetErrorResponse0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
#pragma warning restore
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnDeviceDoesNotSupportStargate(ActionName: Text; Response: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [BusinessEvent(false)]
#pragma warning disable AA0150
    local procedure OnAppGatewayProtocol(FrontEnd: Codeunit "NPR POS Front End Management"; ActionName: Text; Step: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
#pragma warning restore
    begin
    end;

    [BusinessEvent(false)]
#pragma warning disable AA0150
    local procedure OnAppGatewayProtocolClosed(FrontEnd: Codeunit "NPR POS Front End Management"; ActionName: Text; Step: Text; Data: Text; Forced: Boolean; var Handled: Boolean)
#pragma warning restore
    begin
    end;
}

