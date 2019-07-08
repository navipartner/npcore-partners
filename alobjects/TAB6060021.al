table 6060021 "GIM - WS Received File"
{
    Caption = 'GIM - WS Received File';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"Doc. Type Code";Code[10])
        {
            Caption = 'Doc. Type Code';
        }
        field(20;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
        }
        field(30;"File Container";BLOB)
        {
            Caption = 'File Container';
        }
        field(31;"File Extension";Text[30])
        {
            Caption = 'File Extension';
        }
        field(32;"File Name";Text[250])
        {
            Caption = 'File Name';
        }
        field(40;"File Processed";Boolean)
        {
            Caption = 'File Processed';
        }
        field(50;"Received At";DateTime)
        {
            Caption = 'Received At';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure ProcessFile()
    var
        FileFetch: Codeunit "GIM - File Fetch";
    begin
        FileFetch.SetDataSource(2);
        FileFetch.SetWebServiceFile(Rec);
        FileFetch.Run;
    end;
}

