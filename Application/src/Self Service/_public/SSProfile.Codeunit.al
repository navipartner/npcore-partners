codeunit 6059946 "NPR SS Profile"
{
    procedure ProfileExist(SelfServiceProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR SS Profile";
    begin
        Rec.SetRange(Code, SelfServiceProfileCode);
        exit(not Rec.IsEmpty());
    end;

    [NonDebuggable]
    procedure GetUnlockPIN(SelfServiceProfileCode: Code[20]): Text[30]
    var
        Rec: Record "NPR SS Profile";
    begin
        Rec.Get(SelfServiceProfileCode);
        exit(Rec."Kiosk Mode Unlock PIN");
    end;

    [NonDebuggable]
    procedure IsUnlockPINEnabled(SelfServiceProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR SS Profile";
    begin
        Rec.Get(SelfServiceProfileCode);
        exit(Rec."Kiosk Mode Unlock PIN" <> '');
    end;

    [NonDebuggable]
    procedure IsUnlockPINEnabledIfProfileExist(SelfServiceProfileCode: Code[20]): Boolean
    var
        Rec: Record "NPR SS Profile";
    begin
        if not Rec.Get(SelfServiceProfileCode) then
            exit;
        exit(Rec."Kiosk Mode Unlock PIN" <> '');
    end;

    [NonDebuggable]
    procedure GetUnlockPINIfProfileExist(SelfServiceProfileCode: Code[20]): Text[30]
    var
        Rec: Record "NPR SS Profile";
    begin
        if not Rec.Get(SelfServiceProfileCode) then
            Rec.Init();
        exit(Rec."Kiosk Mode Unlock PIN");
    end;

    [NonDebuggable]
    procedure UpsertProfile(SelfServiceProfileCode: Code[20]; Description: Text; UnlockPin: Text[30]): Text[30]
    var
        Rec: Record "NPR SS Profile";
    begin
        if not Rec.Get(SelfServiceProfileCode) then begin
            Rec.Code := SelfServiceProfileCode;
            Rec.Init();
            Rec.Insert();
        end;
        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
        Rec."Kiosk Mode Unlock PIN" := UnlockPin;
        Rec.Modify();
    end;        
}