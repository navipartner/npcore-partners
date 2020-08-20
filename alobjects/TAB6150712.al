table 6150712 "POS Default User View"
{
    // NPR5.36/NPKNAV/20171003  CASE 289011 Transport NPR5.36 - 3 October 2017

    Caption = 'POS Default User View';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Login,Sale,Payment,Balance,Locked';
            OptionMembers = Login,Sale,Payment,Balance,Locked;
        }
        field(3; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = Register;
        }
        field(4; "User Name"; Code[250])
        {
            Caption = 'User Name';
            DataClassification = CustomerContent;
        }
        field(5; "POS View Code"; Code[10])
        {
            Caption = 'POS View Code';
            DataClassification = CustomerContent;
            TableRelation = "POS View";
        }
    }

    keys
    {
        key(Key1; ID)
        {
        }
    }

    fieldgroups
    {
    }

    procedure SetDefault(Type: Option Login,Sale,Payment,Balance,Locked; RegisterNo: Code[10]; ViewCode: Code[10])
    var
        DefaultView: Record "POS Default User View";
    begin
        DefaultView.SetRange(Type, Type);
        DefaultView.SetRange("Register No.", RegisterNo);
        DefaultView.SetRange("User Name", UserId);
        if not DefaultView.FindFirst then begin
            if ViewCode = '' then
                exit;
            DefaultView.Type := Type;
            DefaultView."Register No." := RegisterNo;
            DefaultView."User Name" := UserId;
            DefaultView.Insert;
        end;

        DefaultView."POS View Code" := ViewCode;
        if ViewCode <> '' then
            DefaultView.Modify
        else
            DefaultView.Delete;

        Rec := DefaultView;
    end;

    procedure GetDefault(Type: Option Login,Sale,Payment,Balance,Locked; RegisterNo: Code[10]): Boolean
    var
        DefaultView: Record "POS Default User View";
    begin
        DefaultView.SetRange(Type, Type);
        DefaultView.SetRange("Register No.", RegisterNo);
        DefaultView.SetRange("User Name", UserId);
        if DefaultView.FindFirst then begin
            Rec := DefaultView;
            exit(true);
        end;
    end;
}

