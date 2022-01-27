table 6150734 "NPR POS Admin. Template Scope"
{
    Access = Internal;
    Caption = 'POS Admin. Template Scope';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Admin. Template Id"; Guid)
        {
            Caption = 'POS Admin. Template Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Admin. Template";
        }
        field(2; "Applies To"; Option)
        {
            Caption = 'Applies To';
            DataClassification = CustomerContent;
            InitValue = User;
            OptionCaption = 'All,User,POS Unit';
            OptionMembers = All,User,"POS Unit";

            trigger OnValidate()
            begin
                if ("Applies To" <> xRec."Applies To") then
                    Clear("Applies To Code");
            end;
        }
        field(3; "Applies To Code"; Code[50])
        {
            Caption = 'Applies To Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Applies To" = CONST(User)) "User Setup"."User ID"
            ELSE
            IF ("Applies To" = CONST("POS Unit")) "NPR POS Unit";
        }
    }

    keys
    {
        key(Key1; "POS Admin. Template Id", "Applies To", "Applies To Code")
        {
        }
        key(Key2; "Applies To", "Applies To Code") { }
    }

    fieldgroups
    {
    }
}

