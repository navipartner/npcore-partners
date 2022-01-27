codeunit 6150736 "NPR POS Secure Method Svrside"
{
    Access = Internal;
    var
        Text001: Label 'No handler responded to server-side password validation event for %1.';
        FrontEndCached: Codeunit "NPR POS Front End Management";
        RequestId: Integer;
        Text002: Label 'any salesperson password.';
        Text003: Label 'current sales person password.';
        Text004: Label 'supervisors password.';
        Text005: Label 'Retail Setup Open Register Password.';
        Text006: Label 'You are not authorized to execute this action. Function requires %1';
        Text008: Label 'Retail Setup Admin Password.';
        ReadingErr: Label 'reading in %1';

    local procedure MethodName(): Text
    begin
        exit('SecureMethod');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnCustomMethod_SecureMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        JSON: Codeunit "NPR POS JSON Management";
        SecureMethod: Text;
        ActionHandled: Boolean;
    begin
        if Method <> MethodName() then
            exit;

        Handled := true;

        FrontEndCached := FrontEnd;
        JSON.InitializeJObjectParser(Context, FrontEnd);

        case JSON.GetStringOrFail('action', StrSubstNo(ReadingErr, MethodName())) of
            'validate':
                begin
                    POSSession.GetSetup(POSSetup);
                    POSSetup.GetPOSUnit(POSUnit);
                    SecureMethod := JSON.GetStringOrFail('method', StrSubstNo(ReadingErr, MethodName()));
                    RequestId := JSON.GetIntegerOrFail('requestId', StrSubstNo(ReadingErr, MethodName()));
                    OnSecureMethodValidatePassword(SecureMethod, JSON.GetStringOrFail('password', StrSubstNo(ReadingErr, MethodName())), POSUnit, ActionHandled);
                    if not ActionHandled then
                        FrontEnd.ReportBugAndThrowError(StrSubstNo(Text001, SecureMethod));
                end;
        end;
    end;

    [BusinessEvent(TRUE)]
#pragma warning disable AA0150
    local procedure OnSecureMethodValidatePassword(Method: Text; Password: Text; POSUnit: Record "NPR POS Unit"; var Handled: Boolean)
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

    local procedure ValidateSalespersonPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; RequireSupervisor: Boolean; Password: Text): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
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
            exit(true);

        end;

        Sender.RejectPassword(false, Reason);
    end;

    local procedure ValidateCurrentSalesperson(var Sender: Codeunit "NPR POS Secure Method Svrside"; Password: Text): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        Reason: Text;
    begin

        Reason := StrSubstNo(Text006, Text003);

        if (Password = '') then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        if (not POSSession.IsActiveSession(POSFrontEndManagement)) then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        POSFrontEndManagement.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetSalespersonRecord(Salesperson);

        if (Password = Salesperson."NPR Register Password") then begin
            Sender.ConfirmPassword(Salesperson.Code);
            exit(true);
        end;

        // Allow supervisor
        ValidateSalespersonPassword(Sender, true, Password);
    end;

    local procedure ValidatePOSUnitOpenRegisterPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; POSUnit: Record "NPR POS Unit"; Password: Text): Boolean
    var
        POSViewProfile: Record "NPR POS View Profile";
        Reason: Text;
    begin
        Reason := StrSubstNo(Text006, Text005);

        if (Password = '') then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        POSUnit.GetProfile(POSViewProfile);
        if (Password = POSViewProfile."Open Register Password") then begin
            Sender.ConfirmPassword('OpenReg');
            exit(true);
        end;

        Sender.RejectPassword(false, Reason);
    end;

    local procedure ValidatePOSUnitAdminPassword(var Sender: Codeunit "NPR POS Secure Method Svrside"; POSUnit: Record "NPR POS Unit"; Password: Text): Boolean
    var
        POSSecurityProfile: Record "NPR POS Security Profile";
        Reason: Text;
    begin

        Reason := StrSubstNo(Text006, Text008);

        if (Password = '') then begin
            Sender.RejectPassword(false, Reason);
            exit;
        end;

        POSUnit.GetProfile(POSSecurityProfile);
        if (Password = POSSecurityProfile."Password on Unblock Discount") then begin
            Sender.ConfirmPassword('SysAdmin');
            exit(true);
        end;

        Sender.RejectPassword(false, Reason);
    end;
}
