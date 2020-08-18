table 6059823 "Smart Email Variable"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added field "Variable Type" - used in Mandrill integration

    Caption = 'Smart Email Variable';

    fields
    {
        field(1;"Transactional Email Code";Code[20])
        {
            Caption = 'Transactional Email Code';
            TableRelation = "Smart Email";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Variable Name";Text[100])
        {
            Caption = 'Variable Name';
        }
        field(20;"Variable Type";Option)
        {
            Caption = 'Variable Type';
            OptionCaption = ' ,Mailchimp,Handlebars';
            OptionMembers = " ",Mailchimp,Handlebars;
        }
        field(50;"Merge Table ID";Integer)
        {
            Caption = 'Merge Table ID';
        }
        field(60;"Field No.";Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Merge Table ID"));

            trigger OnValidate()
            begin
                if "Field No." <> 0 then
                  "Const Value" := '';
            end;
        }
        field(62;"Field Name";Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Merge Table ID"),
                                                              "No."=FIELD("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70;"Const Value";Text[100])
        {
            Caption = 'Const Value';

            trigger OnValidate()
            begin
                if "Const Value" <> '' then
                  "Field No." := 0;
            end;
        }
    }

    keys
    {
        key(Key1;"Transactional Email Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

