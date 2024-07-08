codeunit 6059916 "NPR POS Security Profile"
{
    procedure ProfileExist(POSSecurityProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        Rec.SetRange(Code, POSSecurityProfileCode);
        exit(not Rec.IsEmpty());
    end;

    [NonDebuggable]
    procedure IsUnblockDiscountPasswordSet(POSSecurityProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        Rec.Get(POSSecurityProfileCode);
        exit(Rec."Password on Unblock Discount" <> '');
    end;

    [NonDebuggable]
    procedure IsUnblockDiscountPasswordSetIfProfileExist(POSSecurityProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        if not Rec.Get(POSSecurityProfileCode) then
            exit;
        exit(Rec."Password on Unblock Discount" <> '');
    end;

    [NonDebuggable]
    procedure UpgradeUnblockPasswordDiscount(POSSecurityProfileCode: Code[20]; Password: Text[4]): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        if not Rec.Get(POSSecurityProfileCode) then
            exit;
        if Rec."Password on Unblock Discount" <> '' then
            exit;
        Rec."Password on Unblock Discount" := Password;
        Rec.Modify();
    end;

    [NonDebuggable]
    procedure IsUnblockDiscountPasswordValid(POSSecurityProfileCode: Code[20]; EnteredPassword: Text): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        Rec.Get(POSSecurityProfileCode);
        exit(Rec."Password on Unblock Discount" = EnteredPassword);
    end;

    [NonDebuggable]
    procedure IsUnblockDiscountPasswordValidIfProfileExist(POSSecurityProfileCode: Code[20]; EnteredPassword: Text): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        if not Rec.Get(POSSecurityProfileCode) then
            exit;
        exit(Rec."Password on Unblock Discount" = EnteredPassword);
    end;

    [NonDebuggable]
    procedure IsUnlockPasswordSet(POSSecurityProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        Rec.Get(POSSecurityProfileCode);
        exit(Rec."Unlock Password" <> '');
    end;

    [NonDebuggable]
    procedure IsUnlockPasswordSetIfProfileExist(POSSecurityProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        if not Rec.Get(POSSecurityProfileCode) then
            exit;
        exit(Rec."Unlock Password" <> '');
    end;

    [NonDebuggable]
    procedure IsUnlockPasswordValid(POSSecurityProfileCode: Code[20]; EnteredPassword: Text): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        Rec.Get(POSSecurityProfileCode);
        exit(Rec."Unlock Password" = EnteredPassword);
    end;

    [NonDebuggable]
    procedure IsUnlockPasswordValidIfProfileExist(POSSecurityProfileCode: Code[20]; EnteredPassword: Text): Boolean
    var
        Rec: Record "NPR POS Security Profile";
    begin
        if not Rec.Get(POSSecurityProfileCode) then
            exit;
        exit(Rec."Unlock Password" = EnteredPassword);
    end;

    procedure GetLockTimeout(POSSecurityProfileCode: Code[20]) LockTimeoutInSeconds: Integer
    var
        Rec: Record "NPR POS Security Profile";
        Handled: Boolean;
    begin
        Rec.Get(POSSecurityProfileCode);

        case Rec."Lock Timeout" of
            Rec."Lock Timeout"::"30S":
                LockTimeoutInSeconds := 30;
            Rec."Lock Timeout"::"60S":
                LockTimeoutInSeconds := 60;
            Rec."Lock Timeout"::"90S":
                LockTimeoutInSeconds := 90;
            Rec."Lock Timeout"::"120S":
                LockTimeoutInSeconds := 120;
            Rec."Lock Timeout"::"600S":
                LockTimeoutInSeconds := 600;
            else begin
                OnGetLockTimeout(Rec."Lock Timeout", LockTimeoutInSeconds, Handled);
                if not Handled then
                    LockTimeoutInSeconds := 0;
            end;
        end;
    end;

    procedure GetLockTimeoutIfProfileExist(POSSecurityProfileCode: Code[20]) LockTimeoutInSeconds: Integer
    var
        Rec: Record "NPR POS Security Profile";
        Handled: Boolean;
    begin
        if not Rec.Get(POSSecurityProfileCode) then
            exit;

        case Rec."Lock Timeout" of
            Rec."Lock Timeout"::"30S":
                LockTimeoutInSeconds := 30;
            Rec."Lock Timeout"::"60S":
                LockTimeoutInSeconds := 60;
            Rec."Lock Timeout"::"90S":
                LockTimeoutInSeconds := 90;
            Rec."Lock Timeout"::"120S":
                LockTimeoutInSeconds := 120;
            Rec."Lock Timeout"::"600S":
                LockTimeoutInSeconds := 600;
            else begin
                OnGetLockTimeout(Rec."Lock Timeout", LockTimeoutInSeconds, Handled);
                if not Handled then
                    LockTimeoutInSeconds := 0;
            end;
        end;
    end;

    procedure GetPOSButtonRefreshTimeIfProfileExist(POSSecurityProfileCode: Code[20]) TimeInSeconds: Integer
    var
        Rec: Record "NPR POS Security Profile";
        Handled: Boolean;
    begin
        if not Rec.Get(POSSecurityProfileCode) then
            exit;

        case Rec."POS Buttons Refresh Time" of
            Rec."POS Buttons Refresh Time"::"30S":
                TimeInSeconds := 30;
            Rec."POS Buttons Refresh Time"::"60S":
                TimeInSeconds := 60;
            Rec."POS Buttons Refresh Time"::"90S":
                TimeInSeconds := 90;
            Rec."POS Buttons Refresh Time"::"120S":
                TimeInSeconds := 120;
            Rec."POS Buttons Refresh Time"::"600S":
                TimeInSeconds := 600;
            else begin
                OnGetPOSButtonsRefreshTime(Rec."POS Buttons Refresh Time", TimeInSeconds, Handled);
                if not Handled then
                    TimeInSeconds := 0;
            end;
        end;
    end;


    [IntegrationEvent(true, false)]
    local procedure OnGetLockTimeout(LockTimeout: Enum "NPR POS View LockTimeout"; var LockTimeoutInSeconds: Integer; var Handled: Boolean)
    begin
    end;


    [IntegrationEvent(true, false)]
    local procedure OnGetPOSButtonsRefreshTime(RefreshTime: Enum "NPR POS View LockTimeout"; var TimeInSeconds: Integer; var Handled: Boolean)
    begin
    end;
}