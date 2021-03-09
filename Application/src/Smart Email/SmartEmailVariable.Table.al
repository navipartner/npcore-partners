table 6059823 "NPR Smart Email Variable"
{
    Caption = 'Smart Email Variable';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Transactional Email Code"; Code[20])
        {
            Caption = 'Transactional Email Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Smart Email";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Variable Name"; Text[100])
        {
            Caption = 'Variable Name';
            DataClassification = CustomerContent;
        }
        field(20; "Variable Type"; Option)
        {
            Caption = 'Variable Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Mailchimp,Handlebars';
            OptionMembers = " ",Mailchimp,Handlebars;
        }
        field(50; "Merge Table ID"; Integer)
        {
            Caption = 'Merge Table ID';
            DataClassification = CustomerContent;
        }
        field(60; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Merge Table ID"));

            trigger OnValidate()
            begin
                if "Field No." <> 0 then
                    "Const Value" := '';
            end;
        }
        field(62; "Field Name"; Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE(TableNo = FIELD("Merge Table ID"),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; "Const Value"; Text[100])
        {
            Caption = 'Const Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Const Value" <> '' then
                    "Field No." := 0;
            end;
        }
    }

    keys
    {
        key(Key1; "Transactional Email Code", "Line No.")
        {
        }
    }

}

