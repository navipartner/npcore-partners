table 6151411 "NPR Magento Picture"
{
    Caption = 'Magento Picture';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Pictures";
    LookupPageID = "NPR Magento Pictures";
    PasteIsValid = false;

    fields
    {
        field(1; Type; Enum "NPR Magento Picture Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(90; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(100; Picture; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            // ObsoleteState = Removed;
            // ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(101; "Size (kb)"; Decimal)
        {
            Caption = 'Size (kb)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(102; "Mime Type"; Text[30])
        {
            Caption = 'Mime Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(103; Image; Media)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
        }
        field(110; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(1000; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(1001; "Last Time Modified"; Time)
        {
            Caption = 'Last Time Modified';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; Type, Name)
        {
        }
    }

    trigger OnDelete()
    var
        MagentoBrand: Record "NPR Magento Brand";
        MagentoItemGroup: Record "NPR Magento Category";
        MagentoPictureLink: Record "NPR Magento Picture Link";
    begin
        case Type of
            Type::Item:
                begin
                    MagentoPictureLink.SetRange("Picture Name", Name);
                    if MagentoPictureLink.FindFirst() then
                        MagentoPictureLink.DeleteAll();
                end;
            Type::Brand:
                begin
                    MagentoBrand.SetRange(Picture, Name);
                    if MagentoBrand.FindFirst() then
                        MagentoBrand.ModifyAll(Picture, '');

                    Clear(MagentoBrand);
                    MagentoBrand.SetRange("Logo Picture", Name);
                    if MagentoBrand.FindFirst() then
                        MagentoBrand.ModifyAll("Logo Picture", '');
                end;
            Type::"Item Group":
                begin
                    MagentoItemGroup.SetRange(Picture, Name);
                    if MagentoItemGroup.FindFirst() then
                        MagentoItemGroup.ModifyAll(Picture, '');
                end;
        end;
    end;

    trigger OnInsert()
    begin
        TestPictureSize();
        "Entry No." := 0;

        "Last Date Modified" := Today();
        "Last Time Modified" := Time;
    end;

    trigger OnModify()
    begin
        TestPictureSize();
        "Last Date Modified" := Today();
        "Last Time Modified" := Time;
    end;

    var
        MagentoSetup: Record "NPR Magento Setup";
        Text000: Label 'Picture Size exceeds max.';
        ErrorCannotAccesUrl: Label 'Cannot access URL %1.\\Failed with HTTP status code %2';

    procedure DownloadPicture(var TempMagentoPicture: Record "NPR Magento Picture" temporary): Boolean
    var
        Stream: InStream;
        PictureUrl: Text;
        OuStr: OutStream;
    begin
        // Clear(TempMagentoPicture.Image);
        Clear(TempMagentoPicture.Picture);
        PictureUrl := GetMagentoUrl();
        if PictureUrl = '' then
            exit;
        if not TryDownloadPicture(PictureUrl, Stream) then
            exit;

        // TempMagentoPicture.Image.ImportStream(Stream, Rec.FieldName(Image));
        // exit(TempMagentoPicture.Image.HasValue());
        TempMagentoPicture.Picture.CreateOutStream(OuStr);
        CopyStream(OuStr, Stream);

        exit(TempMagentoPicture.Picture.HasValue);
    end;

    [TryFunction]
    procedure TryDownloadPicture(PictureUrl: Text; var Stream: InStream)
    var
        WebClient: HttpClient;
        Response: HttpResponseMessage;
    begin
        WebClient.Get(PictureUrl, Response);
        if (not Response.IsSuccessStatusCode()) then
            Error(ErrorCannotAccesUrl, PictureUrl, Response.HttpStatusCode);

        Response.Content.ReadAs(Stream);
    end;

    [TryFunction]
    procedure TryCheckPicture()
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        PictureUrl: Text;
    begin
        PictureUrl := GetMagentoUrl();
        Request.Method := 'HEAD';
        Request.SetRequestUri(PictureUrl);
        Client.Send(Request, Response);
        if (not Response.IsSuccessStatusCode()) then
            Error(ErrorCannotAccesUrl, PictureUrl, Response.HttpStatusCode);
    end;

    procedure GetBase64() Base64: Text
    var
        // TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
    // OutStr: OutStream;
    begin
        // if not Image.HasValue() then
        if not Picture.HasValue() then
            exit;

        // TempBlob.CreateOutStream(OutStr);
        // Rec.Image.ExportStream(OutStr);
        // TempBlob.CreateInStream(InStr);
        // Base64 := Base64Convert.ToBase64(InStr);
        CalcFields(Picture);
        Picture.CreateInStream(InStr);
        Base64 := Base64Convert.ToBase64(InStr);
    end;

    procedure GetMagentoType(): Text
    begin
        case Type of
            Type::Item:
                exit('product');
            Type::Brand:
                exit('manufacturer');
            Type::"Item Group":
                exit('category');
            Type::Customer:
                exit('customer');
        end;

        exit('');
    end;

    procedure GetMagentoUrl() MagentoUrl: Text
    var
        Handled: Boolean;
    begin
        OnGetMagentoUrl(MagentoUrl, Handled);
        if Handled then
            exit(MagentoUrl);

        MagentoUrl := '';
        if Name = '' then
            exit('');

        if MagentoSetup."Magento Url" = '' then
            MagentoSetup.Get();
        MagentoUrl := MagentoSetup."Magento Url" + 'media/catalog/' + GetMagentoType() + '/api/' + Name;
        exit(MagentoUrl);
    end;

    procedure TestPictureSize()
    begin
        if "Size (kb)" <= 0 then
            exit;

        if (not MagentoSetup.Get()) or (MagentoSetup."Max. Picture Size" <= 0) then
            MagentoSetup."Max. Picture Size" := 512;

        if "Size (kb)" > MagentoSetup."Max. Picture Size" then
            Error(Text000);
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnGetMagentoUrl(var MagentoUrl: Text; var Handled: Boolean)
    begin
    end;

    // procedure GetImageContent(var TenantMedia: Record "Tenant Media")
    // begin
    //     TenantMedia.Init();
    //     if not Rec.Image.HasValue() then
    //         exit;
    //     if TenantMedia.Get(Rec.Image.MediaId()) then
    //         TenantMedia.CalcFields(Content);
    // end;    
}
