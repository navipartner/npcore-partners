page 6185105 "NPR CloudflareImageFactBox"
{
    Extensible = False;
    Caption = 'Cloudflare Image Link';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR CloudflareMediaLink";
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            UserControl("Image Viewer"; "NPR Image Viewer")
            {
                ApplicationArea = NPRRetail;

                trigger ControlAddInReady()
                begin
                    _ControlAddInReady := true;
                    LoadImage();
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OpenOriginalPicture)
            {
                Caption = 'Open Original';
                Enabled = _HaveImage;
                Image = View;
                ToolTip = 'Open the original image in a new browser tab.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ImageUrl: Text;
                begin
                    if (not GetImageUrl(Rec.MediaKey, ENUM::"NPR CloudflareMediaVariants"::ORIGINAL, ImageUrl)) then
                        exit;

                    Hyperlink(ImageUrl);
                end;
            }
        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        LoadImage();
    end;

    var
        MediaSvgHelper: Codeunit "NPR CloudflareMediaSvgHelper";
        _ControlAddInReady: Boolean;
        _HaveImage: Boolean;
        _HaveImageFor: Text[200];

    internal procedure LoadImage()
    var
        ImageUrl: Text;
    begin
        if (not _ControlAddInReady) then
            exit;

        if (Rec.MediaKey = _HaveImageFor) then
            exit;

        _HaveImage := GetImageUrl(Rec.MediaKey, ENUM::"NPR CloudflareMediaVariants"::THUMBNAIL, ImageUrl);

        if (_HaveImage) then begin
            _HaveImageFor := Rec.MediaKey;
            CurrPage."Image Viewer".SetSource(ImageUrl);
        end;

        if (not _HaveImage) then begin
            CurrPage."Image Viewer".SetSource(MediaSvgHelper.NoPictureAvailableImage());
            CLear(_HaveImageFor);
        end;

        CurrPage.Update(false);
    end;

    local procedure GetImageUrl(MediaKey: Text[200]; ImageVariant: ENUM "NPR CloudflareMediaVariants"; var ImageUrl: Text): Boolean
    var
        MediaFacade: Codeunit "NPR CloudflareMediaFacade";
        MediaResponse: JsonObject;
        JToken: JsonToken;
    begin
        if (not _ControlAddInReady) then
            exit(false);

        if (Rec.MediaKey = '') then
            exit(false);

        if (not MediaFacade.GetMediaUrl(MediaKey, ImageVariant, 300, MediaResponse)) then
            exit(false);

        if (not MediaResponse.Get('url', JToken)) then
            exit(false);

        ImageUrl := JToken.AsValue().AsText();
        exit(ImageUrl <> '');
    end;

}
