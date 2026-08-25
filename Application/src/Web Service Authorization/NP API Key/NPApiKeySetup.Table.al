table 6059949 "NPR NP API Key Setup"
{
    Access = Internal;
    Caption = 'API Key Authorization Setup';
    DataClassification = CustomerContent;
    LookupPageId = "NPR NP API Key Setup List";
    DrillDownPageId = "NPR NP API Key Setup List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "API Key"; Guid)
        {
            Caption = 'API Key';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec.Enabled then
                    if not HasApiKey() then
                        Error(_ApiKeyMissingErr, Rec.FieldCaption("API Key"));
            end;
        }
        field(20; "Key Secret Hint"; Text[30])
        {
            Caption = 'Key Secret Hint';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        _ApiKeyMissingErr: Label 'The %1 must be set before enabling this setup.', Comment = '%1 = API Key field caption';

    // Caller must Insert/Modify afterwards: on a first-time set the new "API Key" GUID only exists on Rec,
    // so without persisting it the stored secret is unreachable - not even OnDelete can clean it up.
    [NonDebuggable]
    procedure SetApiKey(NewApiKey: Text)
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        // Clearing the key is a removal - otherwise SetLongApiPassword would store '' and BuildKeyHint('')
        // returns '******', leaving HasApiKey() = false while the hint claims a key exists.
        if NewApiKey = '' then begin
            RemoveApiKey();
            exit;
        end;

        WebServiceAuthHelper.SetLongApiPassword(NewApiKey, Rec."API Key");
        Rec."Key Secret Hint" := CopyStr(BuildKeyHint(NewApiKey), 1, MaxStrLen(Rec."Key Secret Hint"));
    end;

    [NonDebuggable]
    local procedure BuildKeyHint(ApiKey: Text): Text
    var
        MaskLbl: Label '******', Locked = true;
    begin
        // 12 is the shortest length where revealing the first and last 4 characters still leaves at least
        // 4 characters masked (the windows already stop overlapping at 8, but 8-11 chars would hide 0-3).
        // This is a human-readable hint for long JWT-style keys; shorter keys show only the mask.
        if StrLen(ApiKey) < 12 then
            exit(MaskLbl);
        exit(CopyStr(ApiKey, 1, 4) + MaskLbl + CopyStr(ApiKey, StrLen(ApiKey) - 3, 4));
    end;

    [NonDebuggable]
    procedure GetApiKey(): Text
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        exit(WebServiceAuthHelper.GetApiPassword(Rec."API Key"));
    end;

    procedure HasApiKey(): Boolean
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        exit(WebServiceAuthHelper.HasApiPassword(Rec."API Key"));
    end;

    procedure RemoveApiKey()
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        Rec."Key Secret Hint" := '';
        Rec.Enabled := false;
        if WebServiceAuthHelper.HasApiPassword(Rec."API Key") then
            WebServiceAuthHelper.RemoveApiPassword(Rec."API Key");
    end;

    trigger OnDelete()
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        if WebServiceAuthHelper.HasApiPassword(Rec."API Key") then
            WebServiceAuthHelper.RemoveApiPassword(Rec."API Key");
    end;
}
