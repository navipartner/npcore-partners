table 6059784 "TM Ticket Type"
{
    // NPR4.16/TSA/20150803/TM1.00 CASE xxxxx Brought fields from 6.2 forward
    // NPR4.16/TSA/20150803/TM1.00 CASE xxxxx Added new field "Defer Revenue" to control how revenue should be posted when sales != admission date
    // TM1.03/TSA/20160113  CASE 231260 - Added option "Admission Registration" Individual/Group to handle single ticket admission for groups
    // TM1.11/TSA/20160324  CASE 234960 - Added "Not Blank" property on primary key
    // TM1.10/TSA/20160329  CASE 237661 - Change primary key length from 20 to 10
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15/TSA/20160530  CASE 240831 Field 40 default true, hidden
    // TM1.16/TSA/20160628  CASE 245455 Added option to have greater control on ticket valid from / to
    // TM1.18/TSA/20161220  CASE 261405 Added field Membership Sales Item No.
    // TM1.26/TSA /20171103 CASE 285601 Added DIY Ticket Layout Code for specifying ticket layou on ticket server
    // TM1.27/TSA /20171211 CASE 269456 Added print template support fields
    // TM1.38/TSA /20181012 CASE 332109 Adding NP-Pass for tickets

    Caption = 'Ticket Type';
    LookupPageID = "TM Ticket Type";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(15; "Related Ticket Type"; Code[20])
        {
            Caption = 'Related Ticket Type';
            TableRelation = "TM Ticket Type";
        }
        field(20; "Print Ticket"; Boolean)
        {
            Caption = 'Print Ticket';
        }
        field(21; "Print Object ID"; Integer)
        {
            Caption = 'Print Object ID';
            TableRelation = IF ("Print Object Type" = CONST (CODEUNIT)) AllObj."Object ID" WHERE ("Object Type" = CONST (Codeunit))
            ELSE
            IF ("Print Object Type" = CONST (REPORT)) AllObj."Object ID" WHERE ("Object Type" = CONST (Report));
        }
        field(22; "Print Object Type"; Option)
        {
            Caption = 'Print Objekt Type';
            InitValue = TEMPLATE;
            OptionCaption = 'Codeunit,Report,Template';
            OptionMembers = "CODEUNIT","REPORT",TEMPLATE;
        }
        field(23; "Admission Registration"; Option)
        {
            Caption = 'Admission Registration';
            Description = 'TM1.03';
            OptionCaption = 'Individual,Group';
            OptionMembers = INDIVIDUAL,GROUP;
        }
        field(30; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(31; "External Ticket Pattern"; Code[30])
        {
            Caption = 'External Ticket Pattern';
        }
        field(35; "Ticket Configuration Source"; Option)
        {
            Caption = 'Ticket Configuration Source';
            OptionCaption = 'Ticket Type,Ticket BOM';
            OptionMembers = TICKET_TYPE,TICKET_BOM;
        }
        field(40; "Is Ticket"; Boolean)
        {
            Caption = 'Ticket';
            Description = 'DEPRECIATE';
            InitValue = true;
        }
        field(41; "Is Reservation"; Boolean)
        {
            Caption = 'Reservation';
            Description = 'DEPRECIATE';
        }
        field(45; "Duration Formula"; DateFormula)
        {
            Caption = 'Duration Formula';
            Description = 'TM1.00';
        }
        field(46; "Max No. Of Entries"; Integer)
        {
            Caption = 'Max No. Of Entries';
            Description = 'TM1.00';
        }
        field(60; "Activation Method"; Option)
        {
            Caption = 'Activation Method';
            Description = 'TM1.00';
            OptionCaption = 'Scan,(POS) Default Admission,Invoice,(POS) All Admissions,Not Applicable';
            OptionMembers = SCAN,POS_DEFAULT,INVOICE,POS_ALL,NA;
        }
        field(61; "Defer Revenue"; Boolean)
        {
            Caption = 'Defer Revenue';
            Description = 'TM1.00';
        }
        field(62; "Ticket Entry Validation"; Option)
        {
            Caption = 'Ticket Entry Validation';
            Description = 'TM1.00';
            OptionCaption = 'Single,Same Day,Multiple,Not Applicable';
            OptionMembers = SINGLE,SAME_DAY,MULTIPLE,NA;
        }
        field(70; "Membership Sales Item No."; Code[20])
        {
            Caption = 'Membership Sales Item No.';
            TableRelation = Item;
        }
        field(80; "RP Template Code"; Code[20])
        {
            Caption = 'RP Template Code';
            TableRelation = "RP Template Header";

            trigger OnValidate()
            begin
                TestField("Print Object Type", "Print Object Type"::TEMPLATE);
            end;
        }
        field(100; "DIY Print Layout Code"; Text[30])
        {
            Caption = 'Ticket Layout Code';
        }
        field(200; "eTicket Template"; BLOB)
        {
            Caption = 'eTicket Template';
            Description = '//-TM1.38 [332109]';
        }
        field(210; "eTicket Type Code"; Text[30])
        {
            Caption = 'eTicket Type Code';
            Description = '//-TM1.38 [332109]';
        }
        field(220; "eTicket Activated"; Boolean)
        {
            Caption = 'eTicket Activated';
            Description = '//-TM1.38 [332109]';

            trigger OnValidate()
            var
                TicketSetup: Record "TM Ticket Setup";
            begin

                if ("eTicket Activated") then begin
                    TicketSetup.Get();
                    TicketSetup.TestField("NP-Pass Token");

                    TestField("eTicket Type Code");
                    CalcFields("eTicket Template");
                    if (not Rec."eTicket Template".HasValue()) then
                        Error('%1 is not initialized.', Rec.FieldCaption("eTicket Template"));

                end;
            end;
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

    var
        ErrNonUniqueItem: Label 'Error. Item No. %1 is allready used.';
        FileManagement: Codeunit "File Management";

    procedure EditPassTemplate()
    var
        Path: Text[1024];
    begin

        Path := ExportPassTemplate(false);
        RunPassTemplateEditor(Path, FieldCaption("eTicket Template"));
        ImportPassTemplate(Path, false);
        FileManagement.DeleteClientFile(Path);
    end;

    local procedure ExportPassTemplate(UseDialog: Boolean) Path: Text[1024]
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        outstream: OutStream;
        instream: InStream;
        PassData: Text;
        ToFile: Text;
        IsDownloaded: Boolean;
    begin

        CalcFields("eTicket Template");
        if (not "eTicket Template".HasValue()) then begin
            PassData := TicketRequestManager.GetDefaultTemplate();
            "eTicket Template".CreateOutStream(outstream);
            outstream.Write(PassData);
            Modify();
            CalcFields("eTicket Template");
        end;

        "eTicket Template".CreateInStream(instream);

        if (not UseDialog) then begin
            ToFile := FileManagement.ClientTempFileName('json');
        end else begin
            ToFile := 'template.json';
        end;

        IsDownloaded := DownloadFromStream(instream, 'Export', '', '', ToFile);
        if (IsDownloaded) then
            exit(ToFile);

        Error('Export failed.');
    end;

    local procedure ImportPassTemplate(Path: Text[1024]; UseDialog: Boolean)
    var
        TempBlob: Record TempBlob temporary;
        outstream: OutStream;
        instream: InStream;
    begin

        if (UseDialog) then begin
            FileManagement.BLOBImport(TempBlob, '*.json');
        end else begin
            FileManagement.BLOBImport(TempBlob, Path);
        end;

        TempBlob.Blob.CreateInStream(instream);
        "eTicket Template".CreateOutStream(outstream, TEXTENCODING::UTF8);
        CopyStream(outstream, instream);

        Modify(true);
    end;

    local procedure RunPassTemplateEditor(Path: Text[1024]; desc: Text[100])
    var
        ret: Integer;
        f: File;
        extra: Text[30];
    begin

        RunCmdModal('"notepad.exe" "' + Path + '"');
    end;

    procedure RunCmdModal(Command: Text[250]) int: Integer
    var
        i: Integer;
    begin
        Error('AL-Conversion: TODO #361414');
    end;
}

