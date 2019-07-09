codeunit 6150736 "POS Secure Method Server-side"
{
    // NPR5.43/VB  /20180611  CASE 314603 Implemented secure method behavior functionality.
    // NPR5.46/TSA /20180914 CASE 314603 Adding the system default security methods


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'No handler responded to server-side password validation event for %1.';
        FrontEndCached: Codeunit "POS Front End Management";
        RequestId: Integer;
        Text002: Label 'any salesperson password.';
        Text003: Label 'current sales person password.';
        Text004: Label 'supervisors password.';
        Text005: Label 'Retail Setup Open Register Password.';
        Text006: Label 'You are not authorized to execute this action. Function requires %1';
        Text007: Label 'A supervisor salesperson is required for this action.';
        Text008: Label 'Retail Setup Admin Password.';

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnCustomMethod_SecureMethod(Method: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        SecureMethod: Text;
        ActionHandled: Boolean;
    begin
        if Method <> 'SecureMethod' then
          exit;

        Handled := true;

        FrontEndCached := FrontEnd;
        JSON.InitializeJObjectParser(Context,FrontEnd);

        case JSON.GetString('action',true) of
          'validate':
            begin
              SecureMethod := JSON.GetString('method',true);
              RequestId := JSON.GetInteger('requestId',true);
              OnSecureMethodValidatePassword(SecureMethod,JSON.GetString('password',true),ActionHandled);
              if not ActionHandled then
                FrontEnd.ReportBug(StrSubstNo(Text001,SecureMethod));
            end;
        end;
    end;

    [BusinessEvent(TRUE)]
    local procedure OnSecureMethodValidatePassword(Method: Text;Password: Text;var Handled: Boolean)
    begin
    end;

    procedure ConfirmPassword(AuthorizedBy: Text)
    begin
        FrontEndCached.ValidateSecureMethodPassword(RequestId,true,false,'', AuthorizedBy);
    end;

    procedure RejectPassword(SkipUI: Boolean;Reason: Text)
    begin
        FrontEndCached.ValidateSecureMethodPassword(RequestId,false,SkipUI,Reason, '');
    end;

    local procedure "---System Default Security Methods"()
    begin
        // Following are the default security methods provided out-of-the-box
    end;

    procedure AnySalespersonMethodCode(): Code[10]
    begin
        exit ('ANY-SALESP');
    end;

    procedure CurrentSalespersonMethodCode(): Code[10]
    begin
        exit ('CUR-SALESP');
    end;

    procedure SupervisorSalespersonMethodCode(): Code[10]
    begin
        exit ('SUPERVISOR');
    end;

    local procedure RetailOpenRegisterPasswordMethodCode(): Code[10]
    begin
        exit ('REGIST-PWD');
    end;

    local procedure RetaiAdminPasswordMethodCode(): Code[10]
    begin
        exit ('ADMIN-PWD');
    end;

    [EventSubscriber(ObjectType::Table, 6150725, 'OnDiscoverSecureMethods', '', true, true)]
    local procedure OnDiscoverSecureMethods(var Sender: Record "POS Secure Method")
    begin

        Sender.DiscoverSecureMethod (AnySalespersonMethodCode (), Text002, Sender.Type::"Password Server");
        Sender.DiscoverSecureMethod (CurrentSalespersonMethodCode (), Text003, Sender.Type::"Password Server");
        Sender.DiscoverSecureMethod (SupervisorSalespersonMethodCode (), Text004, Sender.Type::"Password Server");
        Sender.DiscoverSecureMethod (RetailOpenRegisterPasswordMethodCode (), Text005, Sender.Type::"Password Server");
        Sender.DiscoverSecureMethod (RetaiAdminPasswordMethodCode (), Text008, Sender.Type::"Password Server");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150736, 'OnSecureMethodValidatePassword', '', true, true)]
    local procedure OnValidatePassword(var Sender: Codeunit "POS Secure Method Server-side";Method: Text;Password: Text;var Handled: Boolean)
    begin

        Handled := true;
        case Method of
          AnySalespersonMethodCode()              : ValidateSalespersonPassword (Sender, false, Password);
          CurrentSalespersonMethodCode()          : ValidateCurrentSalesperson (Sender, Password);
          SupervisorSalespersonMethodCode()       : ValidateSalespersonPassword (Sender, true, Password);
          RetailOpenRegisterPasswordMethodCode()  : ValidateRetailSetupOpenRegisterPassword (Sender, Password);
          RetaiAdminPasswordMethodCode()          : ValidateRetailSetupAdminPassword (Sender, Password);
          else
            Handled := false;
        end;
    end;

    local procedure ValidateSalespersonPassword(var Sender: Codeunit "POS Secure Method Server-side";RequireSupervisor: Boolean;Password: Text): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
        Reason: Text;
    begin

        if (RequireSupervisor) then
          Reason := StrSubstNo (Text006, Text004)
        else
          Reason := StrSubstNo (Text006, Text002);

        if (Password = '') then begin
          Sender.RejectPassword (false, Reason);
          exit;
        end;

        Salesperson.SetFilter ("Register Password", '=%1&<>%2', Password, '');
        if (Salesperson.FindFirst()) then begin
          if ((RequireSupervisor) and not (Salesperson."Supervisor POS")) then begin
            Sender.RejectPassword (false, Reason);
            exit;
          end;

          Sender.ConfirmPassword (Salesperson.Code);
          exit (true);

        end;

        Sender.RejectPassword (false, Reason);
    end;

    local procedure ValidateCurrentSalesperson(var Sender: Codeunit "POS Secure Method Server-side";Password: Text): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
        POSFrontEndManagement: Codeunit "POS Front End Management";
        POSSession: Codeunit "POS Session";
        POSSetup: Codeunit "POS Setup";
        Reason: Text;
    begin

        Reason := StrSubstNo (Text006, Text003);

        if (Password = '') then begin
          Sender.RejectPassword (false, Reason);
          exit;
        end;

        if (not POSSession.IsActiveSession (POSFrontEndManagement)) then begin
          Sender.RejectPassword (false, Reason);
          exit;
        end;

        POSFrontEndManagement.GetSession (POSSession);
        POSSession.GetSetup (POSSetup);
        POSSetup.GetSalespersonRecord (Salesperson);

        if (Password = Salesperson."Register Password") then begin
          Sender.ConfirmPassword (Salesperson.Code);
          exit (true);
        end;

        // Allow supervisor
        ValidateSalespersonPassword (Sender, true, Password);
    end;

    local procedure ValidateRetailSetupOpenRegisterPassword(var Sender: Codeunit "POS Secure Method Server-side";Password: Text): Boolean
    var
        RetailSetup: Record "Retail Setup";
        Reason: Text;
    begin

        Reason := StrSubstNo (Text006, Text005);

        if (Password = '') then begin
          Sender.RejectPassword (false, Reason);
          exit;
        end;

        RetailSetup.Get();
        if (Password = RetailSetup."Open Register Password") then begin
          Sender.ConfirmPassword ('OpenReg');
          exit (true);
        end;

        Sender.RejectPassword (false, Reason);
    end;

    local procedure ValidateRetailSetupAdminPassword(var Sender: Codeunit "POS Secure Method Server-side";Password: Text): Boolean
    var
        RetailSetup: Record "Retail Setup";
        Reason: Text;
    begin

        Reason := StrSubstNo (Text006, Text008);

        if (Password = '') then begin
          Sender.RejectPassword (false, Reason);
          exit;
        end;

        RetailSetup.Get();
        // Caption is "Administrator Password"
        if (Password = RetailSetup."Password on unblock discount") then begin
          Sender.ConfirmPassword ('SysAdmin');
          exit (true);
        end;

        Sender.RejectPassword (false, Reason);
    end;
}

