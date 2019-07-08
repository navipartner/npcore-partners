table 6014623 ".NET Assembly"
{
    // NPR4.17/VB/20151106 CASE 219641 Object created to support automatic assembly deployment
    // NPR5.00.01/VB/20160126  CASE 232615 Changing DataPerCompany to No
    // NPR5.01/VB/20160223 CASE 234541 Support for storing and using debug information at assembly deployment
    // NPR5.37/MMV /20171019 CASE 293066 Added hash support.

    Caption = '.NET Assembly';
    DataPerCompany = false;

    fields
    {
        field(1;"Assembly Name";Text[250])
        {
            Caption = 'Assembly Name';
        }
        field(2;"User ID";Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;

            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.ValidateUserID("User ID");
            end;
        }
        field(10;Assembly;BLOB)
        {
            Caption = 'Assembly';
        }
        field(11;"Debug Information";BLOB)
        {
            Caption = 'Debug Information';
        }
        field(12;"MD5 Hash";Text[32])
        {
            Caption = 'MD5 Hash';
        }
    }

    keys
    {
        key(Key1;"Assembly Name","User ID")
        {
        }
    }

    fieldgroups
    {
    }

    procedure InstallAssembly(var InStr: InStream;var Asm: DotNet Assembly;Name: Text;DebugFileName: Text)
    var
        Asmbl: Record ".NET Assembly";
        MemStream: DotNet MemoryStream;
        MemStreamPdb: DotNet MemoryStream;
        [RunOnClient]
        IOFile: DotNet File;
        OutStr: OutStream;
        MD5: DotNet MD5;
        Byte: DotNet Byte;
    begin
        with Asmbl do begin
          MemStream := MemStream.MemoryStream();
          CopyStream(MemStream,InStr);
          Asm := Asm.Load(MemStream.ToArray());

          if Name = '' then begin
            "Assembly Name" := Asm.FullName;
          end else
            "Assembly Name" := Name;

          Assembly.CreateOutStream(OutStr);
          MemStream.Seek(0,0);
          CopyStream(OutStr,MemStream);
          //-NPR5.37 [293066]
          MemStream.Seek(0,0);
          MD5 := MD5.Create();
          foreach Byte in MD5.ComputeHash(MemStream) do
            "MD5 Hash" += Byte.ToString('x2');
          //+NPR5.37 [293066]

          if (DebugFileName <> '') and IOFile.Exists(DebugFileName) then begin
            MemStreamPdb := MemStreamPdb.MemoryStream(IOFile.ReadAllBytes(DebugFileName));
            MemStreamPdb.Seek(0,0);
            "Debug Information".CreateOutStream(OutStr);
            CopyStream(OutStr,MemStreamPdb);
          end;

          if Insert() then
            Modify();
        end;
    end;
}

