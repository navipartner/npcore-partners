table 6150966 "NPR MM VippsMP Login Setup"
{
    Access = Internal;
    Caption = 'Vipps MobilePay Login Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; Environment; Enum "NPR MM Add. Info. Req. Config.")
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
        }
        field(3; "Cust. Card Name"; Boolean)
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(4; "Cust. Card Birthdate"; Boolean)
        {
            Caption = 'Birthdate';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(5; "Cust. Card E-Mail"; Boolean)
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(6; "Cust. Card Address"; Boolean)
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(7; "Cust. Card Delegated Consents"; Boolean)
        {
            Caption = 'Marketing Consents';
            DataClassification = CustomerContent;
        }
        field(8; "Member Card Name"; Boolean)
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(9; "Member Card Birthdate"; Boolean)
        {
            Caption = 'Birthdate';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(10; "Member Card E-Mail"; Boolean)
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(11; "Member Card Address"; Boolean)
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(12; "Member Card Delegated Consents"; Boolean)
        {
            Caption = 'Marketing Consents';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
        }
    }

    internal procedure GetScope(Target: Integer): Text[70]
    var
        Scope: Text[70];
    begin
        Scope := 'openid';

        case Target of
            Database::"NPR MM Member Info Capture":
                begin
                    if "Member Card Name" then
                        Scope += ' name';
                    if "Member Card Birthdate" then
                        Scope += ' birthDate';
                    if "Member Card E-Mail" then
                        Scope += ' email';
                    if "Member Card Address" then
                        Scope += ' address';
                    if "Member Card Delegated Consents" then
                        Scope += ' delegatedConsents';
                end;
            Database::Customer:
                begin
                    if "Cust. Card Name" then
                        Scope += ' name';
                    if "Cust. Card Birthdate" then
                        Scope += ' birthDate';
                    if "Cust. Card E-Mail" then
                        Scope += ' email';
                    if "Cust. Card Address" then
                        Scope += ' address';
                    if "Cust. Card Delegated Consents" then
                        Scope += ' delegatedConsents';
                end;
        end;

        exit(Scope);
    end;
}
