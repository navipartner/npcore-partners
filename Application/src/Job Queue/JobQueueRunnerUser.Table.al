table 6151290 "NPR Job Queue Runner User"
{
    Access = Internal;
    Caption = 'Job Queue Runner User';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            DataClassification = CustomerContent;
        }
        field(20; "JQ Runner User Name"; Text[50])
        {
            Caption = 'JQ Runner User Name';
            FieldClass = FlowField;
            CalcFormula = lookup("AAD Application".Description where("Client Id" = field("Client ID")));
        }
        field(30; "Failed Attempts"; Integer)
        {
            Caption = 'Failed Attempts';
            DataClassification = CustomerContent;
        }
        field(40; "Last Success Date Time"; DateTime)
        {
            Caption = 'Last Success Date Time';
            DataClassification = CustomerContent;
        }
        field(50; "Last Error Text"; Text[2048])
        {
            Caption = 'Last Error Text';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key1; "Failed Attempts")
        {
        }
    }
}
