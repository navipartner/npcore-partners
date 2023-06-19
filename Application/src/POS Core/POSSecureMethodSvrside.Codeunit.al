codeunit 6150736 "NPR POS Secure Method Svrside"
{
    Access = Internal;

    var
        FrontEndCached: Codeunit "NPR POS Front End Management";
        SecureMethodHelper: Codeunit "NPR POS Secure Method Helper";
        RequestId: Integer;
        Text001: Label 'No handler responded to server-side password validation event for %1.';
        Text002: Label 'any salesperson password.';
        Text003: Label 'current sales person password.';
        Text004: Label 'supervisors password.';
        Text005: Label 'Retail Setup Open Register Password.';
        Text006: Label 'You are not authorized to execute this action. Function requires %1';
        Text008: Label 'Retail Setup Admin Password.';
        SecureContextId: Text;

    local procedure MethodName(): Text
    begin
        exit('SecureMethod');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnCustomMethod_SecureMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSSetup: Codeunit "NPR POS Setup";
        ActionHandled: Boolean;
        ActionType: Text;
        SecureMethod: Text;
    begin
        if Method <> MethodName() then
            exit;

        Handled := true;

        SecureMethodHelper.ClearAll();
        FrontEndCached := FrontEnd;

        ActionType := GetJText(Context.AsToken(), 'action');
        if ActionType = 'validate' then begin
            POSSession.GetSetup(POSSetup);
            POSSetup.GetPOSUnit(POSUnit);
            RequestId := GetJInt(Context.AsToken(), 'requestId');
            if POSAuditLogMgt.IsEnabled(POSUnit."POS Audit Profile") then
                SecureMethodValidateWithAuditLog(Context, FrontEnd, POSUnit, ActionHandled)
            else
                SecureMethodValidate(Context, FrontEnd, POSUnit, ActionHandled);

            if not ActionHandled then
                FrontEnd.ReportBugAndThrowError(StrSubstNo(Text001, SecureMethod));
        end;
    end;

    procedure SecureMethodValidate(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; POSUnit: Record "NPR POS Unit"; var ActionHandled: Boolean)
    var
        SecureMethod: Text;
    begin
        SecureMethod := GetJText(Context.AsToken(), 'method');
        ParseButton(Context);

        OnSecureMethodValidatePassword(SecureMethod, GetJText(Context.AsToken(), 'password'), POSUnit, ActionHandled);
    end;

    procedure SecureMethodValidateWithAuditLog(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; POSUnit: Record "NPR POS Unit"; var ActionHandled: Boolean)
    var
        AuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        ActionRecordId: RecordId;
        ButtonParameter: Text;
        ButtonType: Text;
        DescriptionLog: Text;
        SecureMethod: Text;
        WorkflowName: Text;
    begin
        SecureMethod := GetJText(Context.AsToken(), 'method');
        ParseButton(Context, WorkflowName, ButtonType, ButtonParameter);

        AuditLogMgt.PreparePOSActionAuthDescription(WorkflowName, ButtonType, ButtonParameter, POSUnit, ActionRecordId, DescriptionLog);

        OnSecureMethodValidatePasswordWithLog(SecureMethod, GetJText(Context.AsToken(), 'password'), POSUnit, DescriptionLog, ActionRecordId, ActionHandled);
    end;

    [BusinessEvent(true)]
#pragma warning disable AA0150
    local procedure OnSecureMethodValidatePassword(Method: Text; Password: Text; POSUnit: Record "NPR POS Unit"; var Handled: Boolean)
#pragma warning restore
    begin
    end;

    [BusinessEvent(true)]
#pragma warning disable AA0150
    local procedure OnSecureMethodValidatePasswordWithLog(Method: Text; Password: Text; POSUnit: Record "NPR POS Unit"; DescriptionLog: Text; ActionRecordId: RecordId; var Handled: Boolean)
#pragma warning restore
    begin
    end;

    procedure ConfirmPassword(AuthorizedBy: Text)
    begin
        FrontEndCached.ValidateSecureMethodPassword(RequestId, true, false, '', AuthorizedBy);
    end;

    procedure RejectPassword(SkipUI: Boolean; Reason: Text)
    begin
        FrontEndCached.ValidateSecureMethodPassword(RequestId, false, SkipUI, Reason, '');
    end;

    #region Default security methods provided out-of-the-box

    procedure AnySalespersonMethodCode(): Code[10]
    begin
        exit('ANY-SALESP');
    end;

    procedure CurrentSalespersonMethodCode(): Code[10]
    begin
        exit('CUR-SALESP');
    end;

    procedure SupervisorSalespersonMethodCode(): Code[10]
    begin
        exit('SUPERVISOR');
    end;

    local procedure RetailOpenRegisterPasswordMethodCode(): Code[10]
    begin
        exit('REGIST-PWD');
    end;

    local procedure RetaiAdminPasswordMethodCode(): Code[10]
    begin
        exit('ADMIN-PWD');
    end;

    #endregion

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Secure Method", 'OnDiscoverSecureMethods', '', true, true)]
    local procedure OnDiscoverSecureMethods(var Sender: Record "NPR POS Secure Method")
    begin
        Sender.DiscoverSecureMethod(AnySalespersonMethodCode(), Text002, Sender.Type::"Password Server");
        Sender.DiscoverSecureMethod(CurrentSalespersonMethodCode(), Text003, Sender.Type::"Password Server");
        Sender.DiscoverSecureMethod(SupervisorSalespersonMethodCode(), Text004, Sender.Type::"Password Server");
        Sender.DiscoverSecureMethod(RetailOpenRegisterPasswordMethodCode(), Text005, Sender.Type::"Password Server");
        Sender.DiscoverSecureMethod(RetaiAdminPasswordMethodCode(), Text008, Sender.Type::"Password Server");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Secure Method Svrside", 'OnSecureMethodValidatePassword', '', true, true)]
    local procedure OnValidatePassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; Method: Text; Password: Text; POSUnit: Record "NPR POS Unit"; var Handled: Boolean)
    begin
        Handled := true;
        case Method of
            AnySalespersonMethodCode():
                ValidateSalespersonPassword(Sender, false, Password);
            CurrentSalespersonMethodCode():
                ValidateCurrentSalesperson(Sender, Password);
            SupervisorSalespersonMethodCode():
                ValidateSalespersonPassword(Sender, true, Password);
            RetailOpenRegisterPasswordMethodCode():
                ValidatePOSUnitOpenRegisterPassword(Sender, POSUnit, Password);
            RetaiAdminPasswordMethodCode():
                ValidatePOSUnitAdminPassword(Sender, POSUnit, Password);
            else
                Handled := false;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Secure Method Svrside", 'OnSecureMethodValidatePasswordWithLog', '', true, true)]
    local procedure OnValidatePasswordWithLog(var Sender: Codeunit "NPR POS Secure Method Svrside"; Method: Text; Password: Text; POSUnit: Record "NPR POS Unit"; DescriptionLog: Text; ActionRecordId: RecordId; var Handled: Boolean)
    var
        AuthorizedBy: Code[20];
    begin
        Handled := true;
        case Method of
            AnySalespersonMethodCode():
                if ValidateSalespersonPassword(Sender, false, Password, AuthorizedBy) then
                    LogActionAuthorization(AuthorizedBy, DescriptionLog, POSUnit."No.", ActionRecordId);
            CurrentSalespersonMethodCode():
                if ValidateCurrentSalesperson(Sender, Password, AuthorizedBy) then
                    LogActionAuthorization(AuthorizedBy, DescriptionLog, POSUnit."No.", ActionRecordId);
            SupervisorSalespersonMethodCode():
                if ValidateSalespersonPassword(Sender, true, Password, AuthorizedBy) then
                    LogActionAuthorization(AuthorizedBy, DescriptionLog, POSUnit."No.", ActionRecordId);
            RetailOpenRegisterPasswordMethodCode():
                if ValidatePOSUnitOpenRegisterPassword(Sender, POSUnit, Password, AuthorizedBy) then
                    LogActionAuthorization(AuthorizedBy, DescriptionLog, POSUnit."No.", ActionRecordId);
            RetaiAdminPasswordMethodCode():
                if ValidatePOSUnitAdminPassword(Sender, POSUnit, Password, AuthorizedBy) then
                    LogActionAuthorization(AuthorizedBy, DescriptionLog, POSUnit."No.", ActionRecordId);
            else
                Handled := false;
        end;
    end;

    local procedure ValidateSalespersonPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; RequireSupervisor: Boolean; Password: Text): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        exit(ValidateSalespersonPassword(Sender, RequireSupervisor, Password, Salesperson));
    end;

    local procedure ValidateSalespersonPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; RequireSupervisor: Boolean; Password: Text; var SalespersonCode: Code[20]): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
        Success: Boolean;
    begin
        Success := ValidateSalespersonPassword(Sender, RequireSupervisor, Password, Salesperson);
        SalespersonCode := Salesperson.Code;
        exit(Success);
    end;

    local procedure ValidateSalespersonPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; RequireSupervisor: Boolean; Password: Text; var Salesperson: Record "Salesperson/Purchaser"): Boolean
    var
        ContextId: Text;
        Reason: Text;
    begin
        if (RequireSupervisor) then
            Reason := StrSubstNo(Text006, Text004)
        else
            Reason := StrSubstNo(Text006, Text002);

        if (Password = '') then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        Salesperson.SetFilter("NPR Register Password", '=%1&<>%2', Password, '');
        if (Salesperson.FindFirst()) then begin
            if ((RequireSupervisor) and not (Salesperson."NPR Supervisor POS")) then begin
                Sender.RejectPassword(false, Reason);
                exit;
            end;

            Sender.ConfirmPassword(Salesperson.Code);
            ContextId := Sender.GetContextId();
            SecureMethodHelper.AddSalespersonCodeToContext(ContextId, Salesperson.Code);
            exit(true);

        end;

        Sender.RejectPassword(false, Reason);
    end;

    local procedure ValidateCurrentSalesperson(var Sender: Codeunit "NPR POS Secure Method Svrside"; Password: Text): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        exit(ValidateCurrentSalesperson(Sender, Password, Salesperson));
    end;

    local procedure ValidateCurrentSalesperson(var Sender: Codeunit "NPR POS Secure Method Svrside"; Password: Text; var SalespersonCode: Code[20]): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
        Success: Boolean;
    begin
        Success := ValidateCurrentSalesperson(Sender, Password, Salesperson);
        SalespersonCode := Salesperson.Code;
        exit(Success);
    end;

    local procedure ValidateCurrentSalesperson(var Sender: Codeunit "NPR POS Secure Method Svrside"; Password: Text; var Salesperson: Record "Salesperson/Purchaser"): Boolean
    var
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        ContextId: Text;
        Reason: Text;
    begin
        Reason := StrSubstNo(Text006, Text003);

        if (Password = '') then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        if (not POSSession.GetFrontEnd(POSFrontEndManagement, false)) then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        POSSession.GetSetup(POSSetup);
        POSSetup.GetSalespersonRecord(Salesperson);

        if (Password = Salesperson."NPR Register Password") then begin
            Sender.ConfirmPassword(Salesperson.Code);
            ContextId := Sender.GetContextId();
            SecureMethodHelper.AddSalespersonCodeToContext(ContextId, Salesperson.Code);
            exit(true);
        end;

        // Allow supervisor
        ValidateSalespersonPassword(Sender, true, Password, Salesperson);
    end;

    local procedure ValidatePOSUnitOpenRegisterPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; POSUnit: Record "NPR POS Unit"; Password: Text; var SecurityProfileCode: Code[20]): Boolean
    var
        Success: Boolean;
    begin
        Success := ValidatePOSUnitOpenRegisterPassword(Sender, POSUnit, Password);
        SecurityProfileCode := POSUnit."POS Security Profile";
        exit(Success);
    end;

    local procedure ValidatePOSUnitOpenRegisterPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; POSUnit: Record "NPR POS Unit"; Password: Text): Boolean
    var
        SecurityProfile: Codeunit "NPR POS Security Profile";
        Reason: Text;
    begin
        Reason := StrSubstNo(Text006, Text005);

        if (Password = '') then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        if SecurityProfile.IsUnlockPasswordValidIfProfileExist(POSUnit."POS Security Profile", Password) then begin
            Sender.ConfirmPassword('OpenReg');
            exit(true);
        end;

        Sender.RejectPassword(false, Reason);
    end;

    local procedure ValidatePOSUnitAdminPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; POSUnit: Record "NPR POS Unit"; Password: Text; var SecurityProfileCode: Code[20]): Boolean
    var
        Success: Boolean;
    begin
        Success := ValidatePOSUnitAdminPassword(Sender, POSUnit, Password);
        SecurityProfileCode := POSUnit."POS Security Profile";
        exit(Success);
    end;

    local procedure ValidatePOSUnitAdminPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; POSUnit: Record "NPR POS Unit"; Password: Text): Boolean
    var
        SecurityProfile: Codeunit "NPR POS Security Profile";
        Reason: Text;
    begin
        Reason := StrSubstNo(Text006, Text008);

        if (Password = '') then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        if SecurityProfile.IsUnblockDiscountPasswordValidIfProfileExist(POSUnit."POS Security Profile", Password) then begin
            Sender.ConfirmPassword('SysAdmin');

            exit(true);
        end;

        Sender.RejectPassword(false, Reason);
    end;

    local procedure LogActionAuthorization(AuthorizedBy: Code[20]; Description: Text; POSUnitNo: Code[10]; ActionRecordId: RecordId)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        SalespersonLbl: Label 'Salesperson %1 ';
    begin
        Description := StrSubstNo(SalespersonLbl, AuthorizedBy) + Description;
        POSAuditLogMgt.CreateEntryExtended(ActionRecordId, POSAuditLog."Action Type"::ACTION_AUTH, 0, '', POSUnitNo, Description, '');
    end;

    local procedure GetJText(Token: JsonToken; Path: Text): Text
    var
        JValue: JsonValue;
    begin
        if GetJValue(Token, Path, JValue) then
            if not (JValue.IsNull() or JValue.IsUndefined()) then
                exit(JValue.AsText());
        exit('');

    end;

    local procedure GetJValue(Token: JsonToken; Path: Text; var JValue: JsonValue): Boolean
    var
        Token2: JsonToken;
    begin
        if not Token.SelectToken(Path, Token2) then
            exit(false);
        JValue := Token2.AsValue();
        if JValue.IsNull() or JValue.IsUndefined() then
            exit(false);
        exit(true);
    end;

    local procedure GetJInt(Token: JsonToken; Path: Text): Integer
    var
        JValue: JsonValue;
    begin
        if GetJValue(Token, Path, JValue) then
            if not (JValue.IsNull() or JValue.IsUndefined()) then
                exit(JValue.AsInteger());
        exit(0);
    end;

    internal procedure GetContextId(): Text
    begin
        exit(SecureContextId);
    end;

    internal procedure ParseButton(Context: JsonObject; var WorkflowName: Text; var ButtonType: Text; var ButtonParameter: Text)
    var
        JObj: JsonObject;
        JToken: JsonToken;
    begin
        if Context.Get('button', JToken) then begin
            JObj := JToken.AsObject();
            WorkflowName := GetJText(JObj.AsToken(), 'workflow');
            ButtonType := GetJText(JObj.AsToken(), 'type');
            ButtonParameter := GetJText(JObj.AsToken(), 'parameter');
            SecureContextId := GetJText(JObj.AsToken(), 'secureMethodContextId');
            if SecureContextId <> '' then
                SecureMethodHelper.AddContextId(SecureContextId);
        end;
    end;

    internal procedure ParseButton(Context: JsonObject)
    var
        JObj: JsonObject;
        JToken: JsonToken;
    begin
        if Context.Get('button', JToken) then begin
            JObj := JToken.AsObject();
            SecureContextId := GetJText(JObj.AsToken(), 'secureMethodContextId');
            if SecureContextId <> '' then
                SecureMethodHelper.AddContextId(SecureContextId);
        end;
    end;
}
