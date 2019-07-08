table 6151505 "Nc Import Type"
{
    // NC1.21/TTH /20151117  CASE 227358 New object
    // NC1.22/MHA /20151202  CASE 227358 Added field 110 "Webservice Function"
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161012  CASE 242552 Added field 235 "Ftp Backup Path"
    // NC2.01/MHA /20161014  CASE 255397 Added field 7 "Keep Import Entries for"
    // NC2.02/MHA /20170223  CASE 262318 Added fields 300 "Send e-mail on Error" and 305 "E-mail address on Error"
    // NC2.08/BR  /20171221  CASE 295322 Added Fields 240 "Ftp Binary" and 245 "Ftp Filename"
    // NC2.12/MHA /20180418  CASE 308107 Length of field 1 "Code" extended from 10 to 20 and caption added to fields 10,20
    // NC2.12/MHA /20180502  CASE 313362 Added fields 400 "Server File Enabled", 405 "Server File Path"
    // NC2.16/MHA /20180917  CASE 328432 Added field 203 "Sftp"

    Caption = 'Nc Import Type';
    LookupPageID = "Nc Import Types";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            Description = 'NC2.12';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(7;"Keep Import Entries for";Duration)
        {
            Caption = 'Keep Import Entries for';
            Description = 'NC2.01';
        }
        field(10;"Lookup Codeunit ID";Integer)
        {
            Caption = 'Lookup Codeunit ID';
            Description = 'NC2.12';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(20;"Import Codeunit ID";Integer)
        {
            Caption = 'Import Codeunit ID';
            Description = 'NC2.12';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Codeunit));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(100;"Webservice Enabled";Boolean)
        {
            Caption = 'Webservice Enabled';
        }
        field(105;"Webservice Codeunit ID";Integer)
        {
            Caption = 'Webservice Codeunit ID';
        }
        field(110;"Webservice Function";Text[80])
        {
            Caption = 'Webservice Function';
            Description = 'NC1.22';
        }
        field(200;"Ftp Enabled";Boolean)
        {
            Caption = 'Ftp Enabled';
        }
        field(203;Sftp;Boolean)
        {
            Caption = 'Sftp';
            Description = 'NC2.16';
        }
        field(205;"Ftp Host";Text[250])
        {
            Caption = 'Ftp Host';
        }
        field(210;"Ftp Port";Integer)
        {
            Caption = 'Ftp Port';
        }
        field(215;"Ftp User";Text[50])
        {
            Caption = 'Ftp User';
        }
        field(220;"Ftp Password";Text[50])
        {
            Caption = 'Ftp Password';
        }
        field(225;"Ftp Passive";Boolean)
        {
            Caption = 'Ftp Passive';
        }
        field(230;"Ftp Path";Text[250])
        {
            Caption = 'Ftp Path';
        }
        field(235;"Ftp Backup Path";Text[250])
        {
            Caption = 'Ftp Backup Path';
            Description = 'NC2.01';
        }
        field(240;"Ftp Binary";Boolean)
        {
            Caption = 'Ftp Binary';
            Description = 'NC2.08';
        }
        field(245;"Ftp Filename";Text[250])
        {
            Caption = 'Ftp Filename';
        }
        field(300;"Send e-mail on Error";Boolean)
        {
            Caption = 'Send e-mail on Error';
            Description = 'NC2.02';
        }
        field(305;"E-mail address on Error";Text[250])
        {
            Caption = 'E-mail address on Error';
            Description = 'NC2.02';
        }
        field(400;"Server File Enabled";Boolean)
        {
            Caption = 'Server File Enabled';
            Description = 'NC2.12';
        }
        field(405;"Server File Path";Text[250])
        {
            Caption = 'Server File Path';
            Description = 'NC2.12';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Webservice Codeunit ID")
        {
        }
    }

    fieldgroups
    {
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
        WebService: Record "Web Service";
    begin
        if not ("Webservice Enabled" and (Description = '') and ("Webservice Codeunit ID" > 0)) then
          exit;

        if WebService.Get("Webservice Codeunit ID",Description) then begin
          WebService."Object Type" := WebService."Object Type"::Codeunit;
          WebService."Object ID" := "Webservice Codeunit ID";
          WebService."Service Name" := Description;
          WebService.Published := true;
          WebService.Modify(true);
          exit;
        end;

        WebService.Init;
        WebService."Object Type" := WebService."Object Type"::Codeunit;
        WebService."Object ID" := "Webservice Codeunit ID";
        WebService."Service Name" := Description;
        WebService.Published := true;
        WebService.Insert(true);
    end;
}

