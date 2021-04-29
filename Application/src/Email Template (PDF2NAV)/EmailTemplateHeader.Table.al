table 6014462 "NPR E-mail Template Header"
{
    Caption = 'E-mail Template Header';
    DrillDownPageID = "NPR E-mail Templates";
    LookupPageID = "NPR E-mail Templates";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(20; "HTML Template"; BLOB)
        {
            Caption = 'HTML Template';
            Description = 'Using external HTML Editor from Web - Retail Setup (Magento integration)';
            DataClassification = CustomerContent;
        }
        field(25; "Use HTML Template"; Boolean)
        {
            Caption = 'Use HTML Template';
            DataClassification = CustomerContent;
        }
        field(40; Filename; Text[30])
        {
            Caption = 'Filename';
            DataClassification = CustomerContent;
        }
        field(50; "Verify Recipient"; Boolean)
        {
            Caption = 'Verify Recipient';
            DataClassification = CustomerContent;
        }
        field(51; "Sender as bcc"; Boolean)
        {
            Caption = 'Sender as bcc';
            DataClassification = CustomerContent;
        }
        field(52; Subject; Text[250])
        {
            Caption = 'Subject';
            DataClassification = CustomerContent;
        }
        field(53; "From E-mail Address"; Text[80])
        {
            Caption = 'From E-mail Address';
            DataClassification = CustomerContent;
        }
        field(54; "From E-mail Name"; Text[80])
        {
            Caption = 'From E-mail Name';
            DataClassification = CustomerContent;
        }
        field(60; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            Description = 'Report Selection - If 0 default report is chosen.';
            DataClassification = CustomerContent;
        }
        field(65; "Report Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; Group; Code[20])
        {
            Caption = 'Group';
            DataClassification = CustomerContent;
        }
        field(80; "Transactional E-mail"; Option)
        {
            Caption = 'Transactional E-mail';
            OptionCaption = ' ,Smart Email';
            OptionMembers = " ","Smart Email";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Transactional E-mail" = 0 then
                    "Transactional E-mail Code" := '';
            end;
        }
        field(82; "Transactional E-mail Code"; Code[20])
        {
            Caption = 'Transactional E-mail Code';
            TableRelation = IF ("Transactional E-mail" = CONST("Smart Email")) "NPR Smart Email" WHERE("Merge Table ID" = FIELD("Table No."));
            DataClassification = CustomerContent;
        }
        field(90; "Fieldnumber Start Tag"; Text[10])
        {
            Caption = 'Fieldnumber Start Tag';
            InitValue = '{';
            DataClassification = CustomerContent;
        }
        field(92; "Fieldnumber End Tag"; Text[10])
        {
            Caption = 'Fieldnumber End Tag';
            InitValue = '}';
            DataClassification = CustomerContent;
        }
        field(100; "Default Recipient Address"; Text[250])
        {
            Caption = 'Default recipient e-mail address';
            DataClassification = CustomerContent;
        }
        field(101; "Default Recipient Address CC"; Text[250])
        {
            Caption = 'Default recipient e-mail address (CC)';
            Description = 'PN1.06';
            DataClassification = CustomerContent;
        }
        field(102; "Default Recipient Address BCC"; Text[250])
        {
            Caption = 'Default recipient e-mail address (BCC)';
            Description = 'PN1.06';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnDelete()
    var
        EmailAttachment: Record "NPR E-mail Attachment";
        EmailTemplateFilter: Record "NPR E-mail Template Filter";
        EmailTemplateLine: Record "NPR E-mail Templ. Line";
    begin
        EmailTemplateFilter.SetRange("E-mail Template Code", Code);
        EmailTemplateFilter.DeleteAll();

        EmailTemplateLine.SetRange("E-mail Template Code", Code);
        EmailTemplateLine.DeleteAll();

        EmailAttachment.SetRange("Primary Key", GetPosition(false));
        EmailAttachment.DeleteAll();
    end;
}

