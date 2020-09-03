table 6060143 "NPR MM Foreign Members. Setup"
{
    // MM1.23/TSA/20170612  CASE 257011 Initial version
    // #334163/JDH /20181109 CASE 334163 Added captions to fields
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'External Validation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(2; "Manager Code"; Code[20])
        {
            Caption = 'Manager Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Foreign Members. Setup"."Manager Code" WHERE("Community Code" = FILTER(''));
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Invokation Priority"; Integer)
        {
            Caption = 'Invokation Priority';
            DataClassification = CustomerContent;
        }
        field(40; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
        }
        field(50; "Append Local Prefix"; Code[10])
        {
            Caption = 'Append Local Prefix';
            DataClassification = CustomerContent;
        }
        field(55; "Remove Local Prefix"; Code[10])
        {
            Caption = 'Remove Local Prefix';
            DataClassification = CustomerContent;
        }
        field(60; "Append Local Suffix"; Code[10])
        {
            Caption = 'Append Local Suffix';
            DataClassification = CustomerContent;
            Enabled = false;
        }
        field(65; "Remove Local Suffix"; Code[10])
        {
            Caption = 'Remove Local Suffix';
            DataClassification = CustomerContent;
            Enabled = false;
        }
    }

    keys
    {
        key(Key1; "Community Code", "Manager Code")
        {
        }
        key(Key2; "Invokation Priority")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin
        if ("Community Code" <> '') then begin
            ForeignMembershipSetup.Get('', "Manager Code");
            Description := ForeignMembershipSetup.Description;
            "Append Local Prefix" := "Community Code" + '-';
        end;
    end;

    procedure RegisterManager(ManagerCode: Code[20]; Description: Text[50])
    var
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin
        if (not ForeignMembershipSetup.Get('', ManagerCode)) then begin
            ForeignMembershipSetup."Community Code" := '';
            ForeignMembershipSetup."Manager Code" := ManagerCode;
            ForeignMembershipSetup.Description := Description;
            ForeignMembershipSetup."Invokation Priority" := 10;
            ForeignMembershipSetup.Disabled := true;
            ForeignMembershipSetup.Insert();
        end;
    end;
}

