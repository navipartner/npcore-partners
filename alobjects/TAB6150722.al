table 6150722 "POS Theme Dependency"
{
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    Caption = 'POS Theme Dependency';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Theme Code"; Code[10])
        {
            Caption = 'POS Theme Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Theme";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Auto-Update GUID"; Guid)
        {
            Caption = 'Auto-Update GUID';
            DataClassification = CustomerContent;
            Description = 'This field is used only to notify the client of the change in the dependency, so that the client "knows" when to cache, and when to update the local dependency cache';
            Editable = false;
        }
        field(4; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(11; "Dependency Type"; Option)
        {
            Caption = 'Dependency Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Logo,Background,Stylesheet,JavaScript';
            OptionMembers = Logo,Background,Stylesheet,JavaScript;

            trigger OnValidate()
            begin
                TestField(Blocked, false);

                if ("Dependency Type" <> xRec."Dependency Type") then
                    exit;

                Clear("Dependency Code");
            end;
        }
        field(12; "Target Type"; Option)
        {
            Caption = 'Target Type';
            DataClassification = CustomerContent;
            OptionCaption = 'View,View Type,Client';
            OptionMembers = View,"View Type",Client;

            trigger OnValidate()
            begin
                TestField(Blocked, false);

                if ("Target Type" = xRec."Target Type") then
                    exit;

                Clear("Target Code");
                Clear("Target View Type");
            end;
        }
        field(13; "Target Code"; Code[20])
        {
            Caption = 'Target Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Target Type" = CONST(View)) "POS View";

            trigger OnValidate()
            begin
                TestField(Blocked, false);
            end;
        }
        field(14; "Target View Type"; Option)
        {
            Caption = 'Target View Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Login,Sale,Payment';
            OptionMembers = Login,Sale,Payment;

            trigger OnValidate()
            begin
                TestField(Blocked, false);
            end;
        }
        field(31; "Dependency Code"; Code[10])
        {
            Caption = 'Dependency Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Dependency Type" = FILTER(Logo | Background)) "Web Client Dependency".Code WHERE(Type = CONST(DataUri))
            ELSE
            IF ("Dependency Type" = CONST(Stylesheet)) "Web Client Dependency".Code WHERE(Type = CONST(CSS))
            ELSE
            IF ("Dependency Type" = CONST(JavaScript)) "Web Client Dependency".Code WHERE(Type = CONST(JavaScript));

            trigger OnValidate()
            begin
                TestField(Blocked, false);
            end;
        }
    }

    keys
    {
        key(Key1; "POS Theme Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    begin
        "Auto-Update GUID" := CreateGuid();
    end;
}

