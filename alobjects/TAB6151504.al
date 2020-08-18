table 6151504 "Nc Import Entry"
{
    // NC1.00/MHA /20150113  CASE 199932 Refactored object from Web Integration
    // NC1.01/MHA /20150120  CASE 204133 Added Field 6 Type
    // NC1.16/TS  /20150423  CASE 212103 Added Options "Return Order" and "Customer" to field 6 Type
    //                                   Added Field 20 Import Count
    // NC1.17/MHA /20150622  CASE 216970 Updated caption for field 70220322 "NaviPartner Case Url"
    // NC1.21/TTH /20151118  CASE 227358 Replacing Type option field with Import type and deleted field 20 "Import Count"
    // NC1.22/TSA /20151207  CASE 228983 Added fields 30 Document ID, 35 Sequence No.
    //                                   Changed field 7 length from 50 to 100
    //                                   Added new key on field 30, 35
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161014  CASE 255397 Added key to be used with Cleanup: Import Type,Date,Imported
    // NC2.02/MHA /20170227  CASE 262318 Added fields 15 "Last Error E-mail Sent at" and 17 "Last Error E-mail Sent to"
    // NC2.12/MHA /20180418  CASE 308107 Length of field 3 "Code" extended from 10 to 20 and caption added to fields 30,35
    // NC2.16/MHA /20180907  CASE 313184 Added fields 40,45,50 for diagnostics
    // NC2.23/MHA /20190927  CASE 369170 Field 70220322 "NaviPartner Case Url" Removed
    // NPR5.55/MHA /20200604  CASE 408100 Added fields 60 "Import Count", 70 "Import Started by", 80 "Server Instance Id", 90 "Session Id"

    Caption = 'Nc Import Entry';

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(3;"Import Type";Code[20])
        {
            Caption = 'Import Type';
            Description = 'NC1.21,NC2.12';
            TableRelation = "Nc Import Type";
        }
        field(5;Date;DateTime)
        {
            Caption = 'Date';
        }
        field(7;"Document Name";Text[100])
        {
            Caption = 'Document Name';
            Description = 'NC1.22';
        }
        field(8;"Document Source";BLOB)
        {
            Caption = 'Document Source';

            trigger OnLookup()
            begin
                CalcFields("Document Source");
                "Document Source".Export(TemporaryPath + "Document Name");
                HyperLink(TemporaryPath + "Document Name");
            end;
        }
        field(9;Imported;Boolean)
        {
            Caption = 'Imported';
        }
        field(10;"Runtime Error";Boolean)
        {
            Caption = 'Runtime Error';

            trigger OnValidate()
            begin
                Clear("Last Error Message");
            end;
        }
        field(11;"Last Error Message";BLOB)
        {
            Caption = 'Last Error Message';

            trigger OnLookup()
            begin
                //-NC1.16
                //CALCFIELDS("Last Error Message");
                //"Last Error Message".EXPORT(TEMPORARYPATH + 'ErrorMessage.txt');
                //Utility.RunCmdModal('C:\windows\system32\notepad.exe' + ' ' + TEMPORARYPATH + 'ErrorMessage.txt')
                //+NC1.16
            end;
        }
        field(12;"Error Message";Text[250])
        {
            Caption = 'Error Message';
        }
        field(15;"Last Error E-mail Sent at";DateTime)
        {
            Caption = 'Last Error E-mail Sent at';
            Description = 'NC2.02';
        }
        field(17;"Last Error E-mail Sent to";Text[250])
        {
            Caption = 'Last Error E-mail Sent to';
            Description = 'NC2.02';
        }
        field(30;"Document ID";Text[100])
        {
            Caption = 'Document ID';
            Description = 'NC1.22,NC2.12';
        }
        field(35;"Sequence No.";Integer)
        {
            Caption = 'Sequence No.';
            Description = 'NC1.22,NC2.12';
        }
        field(40;"Import Started at";DateTime)
        {
            Caption = 'Import Started at';
            Description = 'NC2.16';
            Editable = false;
        }
        field(45;"Import Completed at";DateTime)
        {
            Caption = 'Import Completed at';
            Description = 'NC2.16';
            Editable = false;
        }
        field(50;"Import Duration";Decimal)
        {
            Caption = 'Import Duration (sec.)';
            Description = 'NC2.16';
            Editable = false;
        }
        field(60;"Import Count";Integer)
        {
            BlankZero = true;
            Caption = 'Import Count';
            Description = 'NPR5.55';
            MinValue = 0;
        }
        field(70;"Import Started by";Code[50])
        {
            Caption = 'Import Started by';
            Description = 'NPR5.55';
        }
        field(80;"Server Instance Id";Integer)
        {
            Caption = 'Server Instance Id';
            Description = 'NPR5.55';
        }
        field(90;"Session Id";Integer)
        {
            Caption = 'Session Id';
            Description = 'NPR5.55';
        }
        field(100;"Earliest Import Datetime";DateTime)
        {
            Caption = 'Earliest Import Datetime';
            Description = 'NPR5.55';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Document ID","Sequence No.")
        {
        }
        key(Key3;"Import Type",Date,Imported)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if Date = 0DT then
          Date := CurrentDateTime;
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";

    procedure LoadXmlDoc(var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        InStr: InStream;
    begin
        //-NC1.16
        CalcFields("Document Source");
        if not "Document Source".HasValue then
          exit(false);

        "Document Source".CreateInStream(InStr);
        if not IsNull(XmlDoc) then
          Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument();
        XmlDoc.Load(InStr);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        Clear(InStr);
        exit(true);
        //+NC1.16
    end;

    procedure HasActiveImport(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        //-NPR5.55 [408100]
        if "Import Completed at" > "Import Started at" then
          exit(false);

        if not GetActiveSession(ActiveSession) then
          exit(false);

        if ActiveSession."User ID" <> "Import Started by" then
          exit(false);

        exit(ActiveSession."Login Datetime" <= "Import Started at");
        //+NPR5.55 [408100]
    end;

    local procedure GetActiveSession(var ActiveSession: Record "Active Session"): Boolean
    begin
        //-NPR5.55 [408100]
        Clear(ActiveSession);

        if "Server Instance Id" <= 0 then
          exit(false);
        if "Session Id" <= 0 then
          exit(false);

        exit(ActiveSession.Get("Server Instance Id","Session Id"));
        //+NPR5.55 [408100]
    end;
}

