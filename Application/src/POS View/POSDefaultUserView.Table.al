﻿table 6150712 "NPR POS Default User View"
{
    Access = Internal;
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
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(4; "User Name"; Code[250])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;

            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
                UserNameToValidate: Code[50];
            begin
                UserNameToValidate := CopyStr("User Name", 1, MaxStrLen(UserNameToValidate));
                UserSelection.ValidateUserName(UserNameToValidate);
                "User Name" := UserNameToValidate;
            end;
        }
        field(5; "POS View Code"; Code[10])
        {
            Caption = 'POS View Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS View";
        }
    }

    keys
    {
        key(Key1; ID)
        {
        }
    }

    procedure SetDefault(ParamType: Option Login,Sale,Payment,Balance,Locked; RegisterNo: Code[10]; ViewCode: Code[10])
    var
        DefaultView: Record "NPR POS Default User View";
    begin
        DefaultView.SetRange(Type, ParamType);
        DefaultView.SetRange("Register No.", RegisterNo);
        DefaultView.SetRange("User Name", UserId);
        if not DefaultView.FindFirst() then begin
            if ViewCode = '' then
                exit;
            DefaultView.Type := ParamType;
            DefaultView."Register No." := RegisterNo;
            DefaultView."User Name" := CopyStr(UserId, 1, MaxStrLen(DefaultView."User Name"));
            DefaultView.Insert();
        end;

        DefaultView."POS View Code" := ViewCode;
        if ViewCode <> '' then
            DefaultView.Modify()
        else
            DefaultView.Delete();

        Rec := DefaultView;
    end;

    procedure GetDefault(ParamType: Option Login,Sale,Payment,Balance,Locked; RegisterNo: Code[10]): Boolean
    var
        DefaultView: Record "NPR POS Default User View";
    begin
        DefaultView.SetRange(Type, ParamType);
        DefaultView.SetRange("Register No.", RegisterNo);
        DefaultView.SetRange("User Name", UserId);
        if DefaultView.FindFirst() then begin
            Rec := DefaultView;
            exit(true);
        end;
    end;
}
