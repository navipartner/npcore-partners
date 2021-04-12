table 6150733 "NPR POS Admin. Template"
{
    // NPR5.51/JAKUBV/20190903  CASE 352582 Transport NPR5.51 - 3 September 2019

    Caption = 'POS Administrative Template';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Admin. Template List";
    LookupPageID = "NPR POS Admin. Template List";

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Version; Text[10])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
            Editable = false;
            InitValue = '1.0';
        }
        field(4; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Draft,Active,Retired';
            OptionMembers = Draft,Active,Retired;
        }
        field(5; "Persist on Client"; Boolean)
        {
            Caption = 'Persist on Client';
            DataClassification = CustomerContent;
        }
        field(10; "Role Center"; Option)
        {
            Caption = 'Role Center';
            DataClassification = CustomerContent;
            OptionCaption = 'Not Defined,Visible,Disabled,Hidden,Password';
            OptionMembers = "Not Defined",Visible,Disabled,Hidden,Password;
        }
        field(11; "Role Center Password"; Text[30])
        {
            Caption = 'Role Center Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(12; Configuration; Option)
        {
            Caption = 'Configuration';
            DataClassification = CustomerContent;
            OptionCaption = 'Not Defined,Visible,Disabled,Hidden,Password';
            OptionMembers = "Not Defined",Visible,Disabled,Hidden,Password;
        }
        field(13; "Configuration Password"; Text[30])
        {
            Caption = 'Configuration Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Scope: Record "NPR POS Admin. Template Scope";
    begin
        Scope.SetRange("POS Admin. Template Id", Id);
        Scope.DeleteAll();
    end;

    trigger OnInsert()
    begin
        if IsNullGuid(Id) then
            Id := CreateGuid();
    end;
}

