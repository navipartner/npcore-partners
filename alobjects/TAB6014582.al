table 6014582 "OAuth Token"
{
    // NPR5.22/MMV/20160415 CASE 228382 Created table
    // NPR5.26/MMV /20160826 CASE 246209 Added AddOrUpdate() function.
    // NPR5.29/MMV /20161207 CASE 260366 Changed field 2 type from text to BLOB. Data upgrade is handled by CU 6059991.
    // NPR5.30/MMV /20170208 CASE 261964 Added field "Expires In (Seconds)"
    //                                   Added functions GetValue() & IsExpired().

    Caption = 'OAuth Token';

    fields
    {
        field(1;"Token Name";Code[20])
        {
            Caption = 'Token Name';
        }
        field(2;"Token Value";BLOB)
        {
            Caption = 'Token Value';
        }
        field(3;"Time Stamp";DateTime)
        {
            Caption = 'Time Stamp';
        }
        field(4;"Expires In (Seconds)";Integer)
        {
            Caption = 'Expires In (Seconds)';
        }
    }

    keys
    {
        key(Key1;"Token Name")
        {
        }
    }

    fieldgroups
    {
    }

    procedure AddOrUpdate(TokenName: Text;TokenValue: Text;TimeStamp: DateTime;ExpiresInSeconds: Integer) Result: Boolean
    var
        TempBlob: Record TempBlob temporary;
        OutStream: OutStream;
    begin
        //-NPR5.30 [261964]
        LockTable;
        //+NPR5.30 [261964]

        TempBlob.Blob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(TokenValue);
        TempBlob.Insert;

        if Get(TokenName) then begin
          "Token Value" := TempBlob.Blob;
          //-NPR5.30 [261964]
          "Expires In (Seconds)" := ExpiresInSeconds;
          if TimeStamp <> 0DT then
            "Time Stamp" := TimeStamp
          else
          //+NPR5.30 [261964]
            "Time Stamp"  := CreateDateTime(Today, Time);
          Result := Modify;
        end else begin
          Init;
          "Token Name"  := TokenName;
          "Token Value" := TempBlob.Blob;
          //-NPR5.30 [261964]
          "Expires In (Seconds)" := ExpiresInSeconds;
          if TimeStamp <> 0DT then
            "Time Stamp" := TimeStamp
          else
          //+NPR5.30 [261964]
            "Time Stamp"  := CreateDateTime(Today, Time);
          Result := Insert;
        end;

        //-NPR5.30 [261964]
        Commit;
        //+NPR5.30 [261964]
    end;

    procedure GetValue(): Text
    var
        InStream: InStream;
        Value: Text;
    begin
        //-NPR5.30 [261964]
        if not "Token Value".HasValue then
          exit('');

        CalcFields("Token Value");
        "Token Value".CreateInStream(InStream, TEXTENCODING::UTF8);
        InStream.ReadText(Value);

        exit(Value);
        //+NPR5.30 [261964]
    end;

    procedure IsExpired(): Boolean
    var
        Deadline: DateTime;
    begin
        //-NPR5.30 [261964]
        if ("Time Stamp" = 0DT) or ("Expires In (Seconds)" = 0) then
          exit(false);

        Deadline := "Time Stamp" + ("Expires In (Seconds)" * 1000);
        exit(Deadline < CreateDateTime(Today, Time));
        //+NPR5.30 [261964]
    end;
}

