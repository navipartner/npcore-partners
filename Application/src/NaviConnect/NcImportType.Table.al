table 6151505 "NPR Nc Import Type"
{
    Caption = 'Nc Import Type';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Nc Import Types";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            Description = 'NC2.12';
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(7; "Keep Import Entries for"; Duration)
        {
            Caption = 'Keep Import Entries for';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
        }
        field(10; "Lookup Codeunit ID"; Integer)
        {
            Caption = 'Lookup Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NC2.12';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
            ValidateTableRelation = false;
        }
        field(20; "Import Codeunit ID"; Integer)
        {
            Caption = 'Import Codeunit ID';
            DataClassification = CustomerContent;
            Description = 'NC2.12';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
            ValidateTableRelation = false;
        }
        field(100; "Webservice Enabled"; Boolean)
        {
            Caption = 'Webservice Enabled';
            DataClassification = CustomerContent;
        }
        field(105; "Webservice Codeunit ID"; Integer)
        {
            Caption = 'Webservice Codeunit ID';
            DataClassification = CustomerContent;
        }
        field(110; "Webservice Function"; Text[80])
        {
            Caption = 'Webservice Function';
            DataClassification = CustomerContent;
            Description = 'NC1.22';
        }
        field(200; "Ftp Enabled"; Boolean)
        {
            Caption = 'Ftp Enabled';
            DataClassification = CustomerContent;
        }
        field(203; Sftp; Boolean)
        {
            Caption = 'Sftp';
            DataClassification = CustomerContent;
            Description = 'NC2.16';
        }
        field(205; "Ftp Host"; Text[250])
        {
            Caption = 'Ftp Host';
            DataClassification = CustomerContent;
        }
        field(210; "Ftp Port"; Integer)
        {
            Caption = 'Ftp Port';
            DataClassification = CustomerContent;
        }
        field(215; "Ftp User"; Text[50])
        {
            Caption = 'Ftp User';
            DataClassification = CustomerContent;
        }
        field(220; "Ftp Password"; Text[50])
        {
            Caption = 'Ftp Password';
            DataClassification = CustomerContent;
        }
        field(225; "Ftp Passive"; Boolean)
        {
            Caption = 'Ftp Passive';
            DataClassification = CustomerContent;
        }
        field(226; "Ftp EncMode"; Enum "NPR Nc FTP Encryption mode")
        {
            Caption = 'Ftp Encryption mode';
            DataClassification = CustomerContent;
            InitValue = "None";
        }
        field(230; "Ftp Path"; Text[250])
        {
            Caption = 'Ftp Path';
            DataClassification = CustomerContent;
        }
        field(235; "Ftp Backup Path"; Text[250])
        {
            Caption = 'Ftp Backup Path';
            DataClassification = CustomerContent;
            Description = 'NC2.01';
        }
        field(240; "Ftp Binary"; Boolean)
        {
            Caption = 'Ftp Binary';
            DataClassification = CustomerContent;
            Description = 'NC2.08';
        }
        field(245; "Ftp Filename"; Text[250])
        {
            Caption = 'Ftp Filename';
            DataClassification = CustomerContent;
        }
        field(300; "Send e-mail on Error"; Boolean)
        {
            Caption = 'Send e-mail on Error';
            DataClassification = CustomerContent;
            Description = 'NC2.02';
        }
        field(305; "E-mail address on Error"; Text[250])
        {
            Caption = 'E-mail address on Error';
            DataClassification = CustomerContent;
            Description = 'NC2.02';
        }
        field(400; "Server File Enabled"; Boolean)
        {
            Caption = 'Server File Enabled';
            DataClassification = CustomerContent;
            Description = 'NC2.12';
            ObsoleteState = Removed;
            ObsoleteReason = 'This field is not going to be used anymore. In Cloud environment we can not store files on server, so we will always store it on Client device. (Field value would always be true).';
        }
        field(405; "Server File Path"; Text[250])
        {
            Caption = 'Server File Path';
            DataClassification = CustomerContent;
            Description = 'NC2.12';
            ObsoleteState = Removed;
            ObsoleteReason = 'This field is not going to be used anymore. In Cloud environment we can not store files on server, so we will always store it on Client device. (Field value would always be true).';
        }
        field(500; "XML Stylesheet"; BLOB)
        {
            Caption = 'XML Stylesheet';
            DataClassification = CustomerContent;
        }
        field(520; "Max. Retry Count"; Integer)
        {
            BlankZero = true;
            Caption = 'Max. Retry Count';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            MinValue = 0;
        }
        field(530; "Delay between Retries"; Duration)
        {
            Caption = 'Delay between Retries';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(600; "Import List Update Handler"; Enum "NPR Nc IL Update Handler")
        {
            Caption = 'Import List Update Handler';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Import List Update Handler" <> "Import List Update Handler"::Default then begin
                    "Ftp Enabled" := false;
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Webservice Codeunit ID")
        {
        }
    }

    trigger OnInsert()
    begin
        UpdateWebservice();
    end;

    trigger OnModify()
    begin
        if ("Webservice Codeunit ID" <> xRec."Webservice Codeunit ID") or ("Webservice Enabled" <> xRec."Webservice Enabled") or (xRec.Description <> Description) then
            UpdateWebservice();
    end;

    procedure UpdateWebservice()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not ("Webservice Enabled" and (Description = '') and ("Webservice Codeunit ID" > 0)) then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, "Webservice Codeunit ID", Description, true);
    end;
}