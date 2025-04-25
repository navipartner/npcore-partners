table 6150971 "NPR MM Member Info. Int. Setup"
{
    Access = Internal;
    Caption = 'Member Info Integration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "CustCard RequestCustInfo Act."; Enum "NPR MM Add. Info. Request")
        {
            Caption = 'Request Customer Info. Action';
            DataClassification = CustomerContent;
        }
        field(3; "MembCapt PhoneNo. OnAssistEdit"; Enum "NPR MM Add. Info. Request")
        {
            Caption = 'Phone No. OnAssistEdit Integr.';
            DataClassification = CustomerContent;
        }
        field(4; "Implicit Phone No. Prefix"; Text[5])
        {
            Caption = 'Implicit Phone No. Prefix';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MissingOperatorPrefixErr: Label 'The prefix must start with a ''+'' operator.';
            begin
                if "Implicit Phone No. Prefix".Replace('-', '').Replace(' ', '').Substring(1, 1) <> '+' then
                    Error(MissingOperatorPrefixErr);
            end;
        }
        field(5; "Request Return Info"; Enum "NPR Return Info. Request")
        {
            Caption = 'Request Return Info';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
        }
    }
}
