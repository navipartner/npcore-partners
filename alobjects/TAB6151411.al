table 6151411 "Magento Picture"
{
    // MAG1.00/MHA /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG1.01/MHA /20150113  CASE 199932 Added Field 101 "Size (kb)"
    // MAG1.04/TR  /20150209  CASE 206156 Added option type to type field : Customer
    // MAG1.09/MHA /20150316  CASE 206395 Changed SubType to Bitmap for field 100 Picture
    // MAG1.14/MHA /20150423  CASE 211881 Added function GetUrl()
    // MAG1.16/MHA /20150401  CASE 210548 Removed Type::Attribute and added Type::Customer
    // MAG1.17/MHA /20150622  CASE 215533 Magento Url moved from NaviConnect Setup to Magento Setup
    // MAG1.21/MHA /20151118  CASE 223835 Added function DownloadMiniature()
    // MAG1.22/MHA /20160418  CASE 230240 Added function TestPictureSize()
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/TS  /20161005  CASE 253978 Exit Manufacture instead of Brand
    // MAG2.08/MHA /20171016  CASE 292926 Added Publisher OnGetMagentoUrl()
    // MAG2.09/TS  /20171113  CASE 296169 Magento Urls can be https

    Caption = 'Magento Picture';
    DrillDownPageID = "Magento Pictures";
    LookupPageID = "Magento Pictures";
    PasteIsValid = false;

    fields
    {
        field(1;Type;Option)
        {
            Caption = 'Type';
            Description = 'MAG1.04,MAG1.16';
            OptionCaption = 'Item,Brand,Item Group,Customer';
            OptionMembers = Item,Brand,"Item Group",Customer;
        }
        field(90;Name;Text[250])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(100;Picture;BLOB)
        {
            Caption = 'Picture';
            Description = 'MAG1.09';
            SubType = Bitmap;
        }
        field(101;"Size (kb)";Decimal)
        {
            Caption = 'Size (kb)';
            Description = 'MAG1.01';
            Editable = false;
        }
        field(110;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(1000;"Last Date Modified";Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(1001;"Last Time Modified";Time)
        {
            Caption = 'Last Time Modified';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;Type,Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        //-MAG1.22
        TestPictureSize();
        //+MAG1.22
        "Entry No." := 0;

        "Last Date Modified" := Today;
        "Last Time Modified" := Time;
    end;

    trigger OnModify()
    begin
        //-MAG1.22
        TestPictureSize();
        //+MAG1.22
        "Last Date Modified" := Today;
        "Last Time Modified" := Time;
    end;

    var
        MagentoSetup: Record "Magento Setup";
        MagentoFunctions: Codeunit "Magento Functions";
        Text000: Label 'Picture Size exceeds max.';

    procedure DownloadPicture(var TempMagentoPicture: Record "Magento Picture" temporary): Boolean
    var
        MagentoPicture: Record "Magento Picture";
        MemoryStream: DotNet MemoryStream;
        OutStream: OutStream;
        PictureUrl: Text;
    begin
        //-MAG1.21
        //-MAG10.00.2.00 [258544]
        //CLEAR(TempItem.Picture);
        Clear(TempMagentoPicture.Picture);
        //+MAG10.00.2.00 [258544]
        PictureUrl := GetMagentotUrl();
        if PictureUrl = '' then
          exit;
        //-MAG2.01
        // WebClient := WebClient.WebClient();
        // ASSERTERROR BEGIN
        //  MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData(PictureUrl));
        //  ERROR('');
        // END;
        // IF GETLASTERRORTEXT <> '' THEN
        //  EXIT;
        if not TryDownloadPicture(PictureUrl,MemoryStream) then
          exit;
        //+MAG2.01
        if MemoryStream.Length = 0 then
          exit;
        //-MAG10.00.2.00 [258544]
        //TempItem.Picture.CREATEOUTSTREAM(OutStream);
        TempMagentoPicture.Picture.CreateOutStream(OutStream);
        //+MAG10.00.2.00 [258544]
        MemoryStream.WriteTo(OutStream);

        //-MAG10.00.2.00 [258544]
        //EXIT(TempItem.Picture.HASVALUE);
        exit(TempMagentoPicture.Picture.HasValue);
        //+MAG10.00.2.00 [258544]
        //+MAG1.21
    end;

    [TryFunction]
    procedure TryDownloadPicture(PictureUrl: Text;var MemoryStream: DotNet MemoryStream)
    var
        WebClient: DotNet WebClient;
    begin
        //-MAG2.01
        WebClient := WebClient.WebClient();
        MemoryStream := MemoryStream.MemoryStream(WebClient.DownloadData(PictureUrl));
        //+MAG2.01
    end;

    procedure GetBase64() Value: Text
    var
        BinaryReader: DotNet BinaryReader;
        MemoryStream: DotNet MemoryStream;
        Convert: DotNet Convert;
        FieldRef: FieldRef;
        InStr: InStream;
    begin
        Value := '';

        if Picture.HasValue then begin
          CalcFields(Picture);
          Picture.CreateInStream(InStr);
          MemoryStream := InStr;
          BinaryReader := BinaryReader.BinaryReader(InStr);
          Value := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));
          MemoryStream.Dispose;
        end;

        exit(Value);
    end;

    procedure GetMagentoType(): Text
    begin
        case Type of
          Type::Item: exit('product');
          //-MAG2.01
          //Type::Brand: EXIT('brand');
          Type::Brand: exit('manufacturer');
          //+MAG2.01
          Type::"Item Group": exit('category');
          Type::Customer: exit('customer');
        end;

        exit('');
    end;

    procedure GetMagentotUrl() MagentoUrl: Text
    var
        Handled: Boolean;
    begin
        //-MAG2.08 [292926]
        OnGetMagentoUrl(MagentoUrl,Handled);
        if Handled then
          exit(MagentoUrl);

        MagentoUrl := '';
        //+MAG2.08 [292926]
        if Name = '' then
          exit('');

        if MagentoSetup."Magento Url" = '' then
          MagentoSetup.Get;
        //-MAG2.09 [296169]
        //String := MagentoSetup."Magento Url" + 'media/catalog/' + GetMagentoType() + '/api/' + Name;
        //EXIT(String.Replace('https','http'));
        MagentoUrl := MagentoSetup."Magento Url" + 'media/catalog/' + GetMagentoType() + '/api/' + Name;
        exit(MagentoUrl);
        //+MAG2.09 [296169]
    end;

    procedure TestPictureSize()
    begin
        //-MAG1.22
        if "Size (kb)" <= 0 then
          exit;

        if (not MagentoSetup.Get) or (MagentoSetup."Max. Picture Size" <= 0) then
          MagentoSetup."Max. Picture Size" := 512;

        if "Size (kb)" > MagentoSetup."Max. Picture Size" then
          Error(Text000);
        //+MAG1.22
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnGetMagentoUrl(var MagentoUrl: Text;var Handled: Boolean)
    begin
        //-MAG2.08 [292926]
        //+MAG2.08 [292926]
    end;
}

