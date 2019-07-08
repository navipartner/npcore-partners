table 6151090 "Nc RapidConnect Setup"
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.17/MHA /20181122  CASE 335927 Added field 110 "Export File Type"

    Caption = 'Nc RapidConnect Setup';
    DrillDownPageID = "Nc RapidConnect Setup";
    LookupPageID = "Nc RapidConnect Setup";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(10;"Package Code";Code[20])
        {
            Caption = 'Package Code';
            TableRelation = "Config. Package";
        }
        field(100;"Export Enabled";Boolean)
        {
            Caption = 'Export Enabled';
        }
        field(105;"Task Processor Code";Code[20])
        {
            Caption = 'Task Processor Code';
            TableRelation = "Nc Task Processor";
        }
        field(110;"Export File Type";Option)
        {
            Caption = 'Export File Type';
            Description = 'NC2.17';
            OptionCaption = '.xml,.xlsx';
            OptionMembers = ".xml",".xlsx";
        }
        field(200;"Import Enabled";Boolean)
        {
            Caption = 'Import Enabled';
        }
        field(205;"Import Type";Code[20])
        {
            Caption = 'Import Type';
            TableRelation = "Nc Import Type" WHERE ("Import Codeunit ID"=CONST(6151092));
        }
        field(210;"Ftp Host";Text[250])
        {
            Caption = 'Ftp Host';
        }
        field(215;"Ftp Port";Integer)
        {
            Caption = 'Ftp Port';
        }
        field(220;"Ftp User";Text[50])
        {
            Caption = 'Ftp User';
        }
        field(225;"Ftp Password";Text[50])
        {
            Caption = 'Ftp Password';
        }
        field(230;"Ftp Passive";Boolean)
        {
            Caption = 'Ftp Passive';
        }
        field(235;"Ftp Path";Text[250])
        {
            Caption = 'Ftp Path';
        }
        field(240;"Ftp Backup Path";Text[250])
        {
            Caption = 'Ftp Backup Path';
        }
        field(245;"Ftp Binary";Boolean)
        {
            Caption = 'Ftp Binary';
        }
        field(250;"Validate Package";Boolean)
        {
            Caption = 'Validate Package';
        }
        field(255;"Apply Package";Boolean)
        {
            Caption = 'Apply Package';
        }
        field(260;"Disable Data Log on Import";Boolean)
        {
            Caption = 'Disable Data Log on Import';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Package Code","Export Enabled","Task Processor Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NcRapidConnectEndpoint: Record "Nc RapidConnect Endpoint";
        NcRapidConnectTrigger: Record "Nc RapidConnect Trigger Table";
    begin
        NcRapidConnectTrigger.SetRange("Setup Code",Code);
        if NcRapidConnectTrigger.FindFirst then
          NcRapidConnectTrigger.DeleteAll;

        NcRapidConnectEndpoint.SetRange("Setup Code",Code);
        if NcRapidConnectEndpoint.FindFirst then
          NcRapidConnectEndpoint.DeleteAll;
    end;
}

