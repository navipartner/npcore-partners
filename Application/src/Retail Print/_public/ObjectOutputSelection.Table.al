table 6014580 "NPR Object Output Selection"
{
    Caption = 'Object Output Selection';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(2; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionCaption = 'Codeunit,,';
            OptionMembers = "Codeunit","Report","XMLPort";
            DataClassification = CustomerContent;
        }
        field(3; "Object ID"; Integer)
        {
            Caption = 'Codeunit ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Codeunit));
            DataClassification = CustomerContent;
        }
        field(5; "Object Name"; Text[80])
        {
            Caption = 'Object Name';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved to a flowfield';
        }
        field(8; "Print Template"; Code[20])
        {
            Caption = 'Print Template';
            TableRelation = "NPR RP Template Header".Code;
            DataClassification = CustomerContent;
        }
        field(10; "Output Type"; Enum "NPR Object Output Type")
        {
            Caption = 'Output Type';
            DataClassification = CustomerContent;
        }
        field(11; "Output Path"; Text[250])
        {
            Caption = 'Output Path';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                OnLookupOutputPath(Rec);
            end;
        }
        field(20; "Codeunit Name"; Text[249])
        {
            Caption = 'Codeunit Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Object ID")));
        }
    }

    keys
    {
        key(Key1; "User ID", "Object Type", "Object ID", "Print Template")
        {
        }
    }

    [IntegrationEvent(false, false)]
    local procedure OnLookupOutputPath(var ObjectOutputSelection: Record "NPR Object Output Selection")
    begin
    end;
}

