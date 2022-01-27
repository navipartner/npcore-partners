table 6059997 "NPR Scanner Service Log"
{
    Access = Internal;
    Caption = 'Scanner Service Log';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used.';

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(2; "Request Start"; DateTime)
        {
            Caption = 'Request Start';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(3; "Request End"; DateTime)
        {
            Caption = 'Request End';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(4; "Request Data"; BLOB)
        {
            Caption = 'Request Data';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(5; "Request Function"; Text[30])
        {
            Caption = 'Request Function';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6; "Response Data"; BLOB)
        {
            Caption = 'Response Data';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(7; "Internal Request"; Boolean)
        {
            Caption = 'Internal Request';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(8; "Internal Log No."; Guid)
        {
            Caption = 'Internal Log No.';
            DataClassification = CustomerContent;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(9; "Debug Request Data"; Text[250])
        {
            Caption = 'Debug Request Data';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(10; "Current User"; Text[250])
        {
            Caption = 'Current User';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }

    keys
    {
        key(Key1; Id)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        key(Key2; "Request Start")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }

    fieldgroups
    {
    }
}

