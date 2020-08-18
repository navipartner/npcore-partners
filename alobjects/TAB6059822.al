table 6059822 "Smart Email"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.44/THRO/20180723 CASE 310042 Added field 200 "NpXml Template Code"
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider option Mailchimp + field "Merge Language (Mailchimp)"

    Caption = 'Smart Email';
    DrillDownPageID = "Smart Email List";
    LookupPageID = "Smart Email List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(3;Provider;Option)
        {
            Caption = 'Provider';
            OptionCaption = 'Campaign Monitor,Mailchimp';
            OptionMembers = "Campaign Monitor",Mailchimp;

            trigger OnValidate()
            begin
                //-NPR5.55 [343266]
                if Provider <> xRec.Provider then
                  Validate("Smart Email ID",'');
                //+NPR5.55 [343266]
            end;
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(50;"Merge Table ID";Integer)
        {
            Caption = 'Merge Table ID';
            TableRelation = "Table Metadata";

            trigger OnValidate()
            var
                TransactionalEmailVariable: Record "Smart Email Variable";
            begin
                TransactionalEmailVariable.SetRange("Transactional Email Code",Code);
                if TransactionalEmailVariable.FindSet then
                  repeat
                    if TransactionalEmailVariable."Merge Table ID" <> "Merge Table ID" then begin
                      TransactionalEmailVariable."Merge Table ID" := "Merge Table ID";
                      TransactionalEmailVariable."Field No." := 0;
                      TransactionalEmailVariable."Field Name" := '';
                      TransactionalEmailVariable.Modify(true);
                    end;
                  until TransactionalEmailVariable.Next = 0;
            end;
        }
        field(60;"Table Caption";Text[80])
        {
            CalcFormula = Lookup("Table Metadata".Caption WHERE (ID=FIELD("Merge Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;"Smart Email ID";Text[50])
        {
            Caption = 'Smart Email ID';
            TableRelation = "Transactional JSON Result".ID WHERE (Provider=FIELD(Provider));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                TransactionalEmailMgt: Codeunit "Transactional Email Mgt.";
            begin
                if "Smart Email ID" <> '' then
                  //-NPR5.55 [343266]
                  TransactionalEmailMgt.GetSmartEmailDetails(Rec);
                  //+NPR5.55 [343266]
            end;
        }
        field(110;"Smart Email Name";Text[50])
        {
            Caption = 'Smart Email Name';
        }
        field(150;Status;Text[10])
        {
            Caption = 'Status';
        }
        field(160;Subject;Text[100])
        {
            Caption = 'Subject';
        }
        field(170;From;Text[80])
        {
            Caption = 'From';
        }
        field(180;"Reply To";Text[80])
        {
            Caption = 'Reply To';
        }
        field(190;"Preview Url";Text[200])
        {
            Caption = 'Preview Url';
        }
        field(200;"NpXml Template Code";Code[20])
        {
            Caption = 'NpXml Template Code';
            TableRelation = "NpXml Template";
        }
        field(300;"Merge Language (Mailchimp)";Option)
        {
            Caption = 'Merge Language (Mailchimp)';
            OptionCaption = ' ,mailchimp,handlebars';
            OptionMembers = " ",mailchimp,handlebars;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        TransactionalEmailVariable: Record "Smart Email Variable";
    begin
        TransactionalEmailVariable.SetRange("Transactional Email Code",Code);
        TransactionalEmailVariable.DeleteAll(true);
    end;
}

