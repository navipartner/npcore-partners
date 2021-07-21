table 6014522 "NPR BTF Service Setup"
{
    DataClassification = CustomerContent;
    Caption = 'BTwentyFour Service Setup';
    LookupPageId = "NPR BTF Service Setup";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'API Version';
        }
        field(2; Name; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
        field(3; "Service URL"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Service URL';
            ExtendedDatatype = URL;

            trigger OnValidate()
            var
                ServiceAPI: Codeunit "NPR BTF Service API";
            begin
                ServiceAPI.VerifyServiceURL(Rec."Service URL");
            end;
        }
        field(5; "About API"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'About API';
        }
        field(6; "Subscription-Key"; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Subscription Key';
        }
        field(7; Environment; Enum "NPR BTF Environment")
        {
            DataClassification = CustomerContent;
            Caption = 'Environment';
        }
        field(8; Username; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User Name';
        }
        field(9; Portal; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Portal';
        }
        field(10; "Authroization EndPoint ID"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Authorization EndPoint ID';
            TableRelation = "NPR BTF Service EndPoint"."EndPoint ID" where("Service Code" = field(Code));
        }
        field(11; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';

            trigger OnValidate()
            var
                ServiceEndPoint: Record "NPR BTF Service EndPoint";
            begin
                ServiceEndPoint.SetRange("Service Code", Rec.Code);
                if ServiceEndPoint.FindSet(true) then
                    repeat
                        ServiceEndPoint.Validate(Enabled, Rec.Enabled);
                        ServiceEndPoint.Modify();
                    until ServiceEndPoint.Next() = 0;
            end;
        }
        field(12; Password; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Password';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    var
        RenameNotAllowedErr: Label 'Rename not allowed. Instead, delete and recreate record.';

    trigger OnDelete()
    var
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
        ServiceAPI: Codeunit "NPR BTF Service API";
    begin
        ServiceAPI.DeleteJobQueueCategory(Rec.Code);
        ServiceEndPoint.Setrange("Service Code", Rec.Code);
        if not ServiceEndPoint.IsEmpty() then
            ServiceEndPoint.DeleteAll(true);
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr);
    end;

    procedure RegisterService(NewCode: Code[20]; NewServiceURL: Text; NewName: Text; NewAboutAPI: Text; NewSubscriptionKey: Text; NewEnvironment: Enum "NPR BTF Environment"; NewUsername: Text; NewPortal: Text; NewEnabled: Boolean; NewPassword: Text)
    begin
        Code := NewCode;
        if Find() then
            exit;

        Init();
        InitService(NewServiceURL, NewName, NewAboutAPI, NewSubscriptionKey, NewEnvironment, NewUsername, NewPortal, NewPassword, NewEnabled);
        OnAfterInit();
        Insert();
    end;

    procedure InitService(NewServiceURL: Text; NewName: Text; NewAboutAPI: Text; NewSubscriptionKey: Text; NewEnvironment: Enum "NPR BTF Environment"; NewUsername: Text; NewPortal: Text; NewPassword: Text; NewEnabled: Boolean)
    begin
        "Service URL" := CopyStr(NewServiceURL, 1, MaxStrLen("Service URL"));
        Name := copystr(NewName, 1, MaxStrLen(Name));
        "About API" := CopyStr(NewAboutAPI, 1, MaxStrLen("About API"));
        "Subscription-Key" := CopyStr(NewSubscriptionKey, 1, MaxStrLen("Subscription-Key"));
        Environment := NewEnvironment;
        Username := CopyStr(NewUsername, 1, MaxStrLen(Username));
        Portal := CopyStr(NewPortal, 1, MaxStrLen(Portal));
        Password := CopyStr(NewPassword, 1, MaxStrLen(Password));
        Enabled := NewEnabled;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInit()
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnRegisterService()
    begin
    end;
}
