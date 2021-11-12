table 6014614 "NPR DotNet Assembly"
{
    Caption = '.NET Assembly';
    DataPerCompany = false;

    fields
    {
        field(1; "Assembly Name"; Text[250])
        {
            Caption = 'Assembly Name';
            DataClassification = CustomerContent;
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; Assembly; BLOB)
        {
            Caption = 'Assembly';
            DataClassification = CustomerContent;
        }
        field(11; "Debug Information"; BLOB)
        {
            Caption = 'Debug Information';
            DataClassification = CustomerContent;
        }
        field(12; "MD5 Hash"; Text[32])
        {
            Caption = 'MD5 Hash';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Assembly Name", "User ID")
        {
        }
    }


    procedure InstallAssembly(var InStr: InStream)
    var
        Asmbl: Record "NPR DotNet Assembly";
        MemStream: DotNet MemoryStream;
        OutStr: OutStream;
        MD5: DotNet MD5;
        Byte: DotNet Byte;
        Asm: DotNet NPRNetAssembly;
    begin
        with Asmbl do begin
            Init();
            MemStream := MemStream.MemoryStream();
            CopyStream(MemStream, InStr);
            Asm := Asm.Load(MemStream.ToArray());
            "Assembly Name" := Asm.FullName;
            Assembly.CreateOutStream(OutStr);
            MemStream.Seek(0, 0);
            CopyStream(OutStr, MemStream);
            MemStream.Seek(0, 0);
            MD5 := MD5.Create();
            foreach Byte in MD5.ComputeHash(MemStream) do
                "MD5 Hash" += Byte.ToString('x2');

            Insert();
        end;
    end;
}

