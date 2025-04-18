﻿table 6059822 "NPR Smart Email"
{
    Access = Internal;
    Caption = 'Smart Email';
    DrillDownPageId = "NPR Smart Email List";
    LookupPageId = "NPR Smart Email List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(3; Provider; Option)
        {
            Caption = 'Provider';
            OptionCaption = 'Campaign Monitor,Mailchimp';
            OptionMembers = "Campaign Monitor",Mailchimp;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Provider <> xRec.Provider then
                    Validate("Smart Email ID", '');
            end;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Merge Table ID"; Integer)
        {
            Caption = 'Merge Table ID';
            TableRelation = "Table Metadata";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TransactionalEmailVariable: Record "NPR Smart Email Variable";
            begin
                TransactionalEmailVariable.SetRange("Transactional Email Code", Code);
                if TransactionalEmailVariable.FindSet() then
                    repeat
                        if TransactionalEmailVariable."Merge Table ID" <> "Merge Table ID" then begin
                            TransactionalEmailVariable."Merge Table ID" := "Merge Table ID";
                            TransactionalEmailVariable."Field No." := 0;
                            TransactionalEmailVariable.Modify(true);
                        end;
                    until TransactionalEmailVariable.Next() = 0;
            end;
        }
        field(60; "Table Caption"; Text[80])
        {
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Merge Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Smart Email ID"; Text[50])
        {
            Caption = 'Smart Email ID';
            TableRelation = "NPR Trx JSON Result".ID where(Provider = field(Provider));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TransactionalEmailMgt: Codeunit "NPR Transactional Email Mgt.";
            begin
                if "Smart Email ID" <> '' then
                    TransactionalEmailMgt.GetSmartEmailDetails(Rec);
            end;
        }
        field(110; "Smart Email Name"; Text[50])
        {
            Caption = 'Smart Email Name';
            DataClassification = CustomerContent;
        }
        field(150; Status; Text[10])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(160; Subject; Text[100])
        {
            Caption = 'Subject';
            DataClassification = CustomerContent;
        }
        field(170; From; Text[80])
        {
            Caption = 'From';
            DataClassification = CustomerContent;
        }
        field(180; "Reply To"; Text[80])
        {
            Caption = 'Reply To';
            DataClassification = CustomerContent;
        }
        field(190; "Preview Url"; Text[200])
        {
            Caption = 'Preview Url';
            DataClassification = CustomerContent;
        }
        field(200; "NpXml Template Code"; Code[20])
        {
            Caption = 'NpXml Template Code';
            TableRelation = "NPR NpXml Template";
            DataClassification = CustomerContent;
        }
        field(300; "Merge Language (Mailchimp)"; Option)
        {
            Caption = 'Merge Language (Mailchimp)';
            OptionCaption = ' ,mailchimp,handlebars';
            OptionMembers = " ",mailchimp,handlebars;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        TransactionalEmailVariable: Record "NPR Smart Email Variable";
    begin
        TransactionalEmailVariable.SetRange("Transactional Email Code", Code);
        TransactionalEmailVariable.DeleteAll(true);
    end;
}

