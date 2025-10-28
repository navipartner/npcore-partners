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
            CurrPage."Image Viewer".SetSource(NoPictureAvailableImage());
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

    local procedure NoPictureAvailableImage(): Text
    var
        DataUrl: Label 'data:image/svg+xml,%1', locked = true;
        NoPictureAvailable: Label '<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-camera-off"><line x1="1" y1="1" x2="23" y2="23"></line><path d="M21 21H3a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2z"></path><path d="M12 17a5 5 0 0 0 0-10c-1.38 0-2.63.56-3.54 1.46"></path><path d="M8.12 8.12a5 5 0 0 0 7.76 7.76"></path></svg>', Locked = true;
    begin
        exit(StrSubstNo(DataUrl, NoPictureAvailable));
    end;

}
