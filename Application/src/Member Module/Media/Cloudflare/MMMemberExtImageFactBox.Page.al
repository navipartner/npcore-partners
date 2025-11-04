page 6185102 "NPR MMMemberExtImageFactBox"
{
    Extensible = False;
    Caption = 'Member Image';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR MM Member";

    layout
    {
        area(content)
        {
            UserControl("Image Viewer"; "NPR Image Viewer")
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
            action(ImportPicture)
            {

                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import an image.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
                begin
                    if (_HaveImage) then
                        if (not Confirm(_ConfirmOverrideImage)) then
                            exit;

                    MemberMedia.ImportMemberImageFromFileWithUI(Rec.SystemId);
                    Clear(_HaveImageFor);

                    CurrPage.Update(false);
                end;
            }

            action(OpenOriginalPicture)
            {
                Caption = 'Open Original';
                Enabled = _HaveImage;
                Image = View;
                ToolTip = 'Open the original image in a new browser tab.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
                    ImageUrl: Text;
                begin
                    if (not MemberMedia.GetMemberImageUrl(Rec.SystemId, ENUM::"NPR CloudflareMediaVariants"::ORIGINAL, 300, ImageUrl)) then
                        exit;

                    Hyperlink(ImageUrl);
                end;
            }

            action(DeletePicture)
            {
                Caption = 'Delete';
                Enabled = _HaveImage;
                Image = Delete;
                ToolTip = 'Remove image from member.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
                begin
                    if (not Confirm(_ConfirmDeleteImage)) then
                        exit;

                    MemberMedia.UnlinkMemberImage(Rec.SystemId);
                    Clear(_HaveImageFor);
                    CurrPage.Update(false);
                end;
            }
            action(ViewMediaCard)
            {
                Caption = 'View Media Card';
                Enabled = _HaveImage;
                Image = Card;
                ToolTip = 'View the media card.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    MediaLink: Record "NPR CloudflareMediaLink";
                begin
                    if (MediaLink.Get(Database::"NPR MM Member", Rec.SystemId, Enum::"NPR CloudflareMediaSelector"::MEMBER_PHOTO)) then
                        Page.RunModal(Page::"NPR CloudflareMediaLinkCard", MediaLink);
                    Clear(_HaveImageFor);
                    CurrPage.Update(false);
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
        _HaveImageFor: Guid;

        _ConfirmDeleteImage: Label 'Are you sure you want to delete the picture?';
        _ConfirmOverrideImage: Label 'The existing picture will be replaced. Do you want to continue?';

    internal procedure LoadImage()
    var
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
        ImageUrl: Text;
    begin
        if (not _ControlAddInReady) then
            exit;

        if (Rec.SystemId = _HaveImageFor) then
            exit;

        CurrPage."Image Viewer".SetSource(SpinnerSvg());
        CurrPage.Update(false);

        _HaveImage := MemberMedia.GetMemberImageUrl(Rec.SystemId, ENUM::"NPR CloudflareMediaVariants"::THUMBNAIL, 300, ImageUrl);

        if (not _HaveImage) then
            _HaveImage := MigrateLocalImage(Rec, ImageUrl);

        if (_HaveImage) then begin
            CurrPage."Image Viewer".SetSource(ImageUrl);
            _HaveImageFor := Rec.SystemId;
        end else begin
            CurrPage."Image Viewer".SetSource(NoPictureAvailableImage());
            CLear(_HaveImageFor);
        end;
    end;

    local procedure MigrateLocalImage(Member: Record "NPR MM Member"; var ImageUrl: Text): Boolean
    var
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InsStr: InStream;
    begin
        if (not Member.Image.HasValue()) then
            exit(false);

        TempBlob.CreateOutStream(OutStr);
        Member.Image.ExportStream(OutStr);
        TempBlob.CreateInStream(InsStr);

        if (not MemberMedia.PutMemberImageFromStream(Member.SystemId, '', InsStr)) then
            exit(false);

        if (MemberMedia.GetMemberImageUrl(Rec.SystemId, ENUM::"NPR CloudflareMediaVariants"::THUMBNAIL, 300, ImageUrl)) then begin
            Clear(Member.Image);
            Member.Modify();
        end;

        exit(true);
    end;

    local procedure NoPictureAvailableImage(): Text
    var
        DataUrl: Label 'data:image/svg+xml,%1', locked = true;
        NoPictureAvailable: Label '<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-camera-off"><line x1="1" y1="1" x2="23" y2="23"></line><path d="M21 21H3a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2z"></path><path d="M12 17a5 5 0 0 0 0-10c-1.38 0-2.63.56-3.54 1.46"></path><path d="M8.12 8.12a5 5 0 0 0 7.76 7.76"></path></svg>', Locked = true;
    begin
        exit(StrSubstNo(DataUrl, NoPictureAvailable));
    end;

    local procedure SpinnerSvg() Spinner: Text
    var
        DataUrl: Label 'data:image/svg+xml,%1', locked = true;
    begin
        Spinner :=
            '<svg width="40" height="40" viewBox="0 0 120 120" xmlns="http://www.w3.org/2000/svg" fill="currentColor" aria-label="loading" role="img">' +
            '<!-- row 1 -->' +
            '<circle cx="20" cy="20" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0s" repeatCount="indefinite"/></circle>' +
            '<circle cx="60" cy="20" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.2s" repeatCount="indefinite"/></circle>' +
            '<circle cx="100" cy="20" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.4s" repeatCount="indefinite"/></circle>' +
            '<!-- row 2 -->' +
            '<circle cx="20" cy="60" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.2s" repeatCount="indefinite"/></circle>' +
            '<circle cx="60" cy="60" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.4s" repeatCount="indefinite"/></circle>' +
            '<circle cx="100" cy="60" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.6s" repeatCount="indefinite"/></circle>' +
            '<!-- row 3 -->' +
            '<circle cx="20" cy="100" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.4s" repeatCount="indefinite"/></circle>' +
            '<circle cx="60" cy="100" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.6s" repeatCount="indefinite"/></circle>' +
            '<circle cx="100" cy="100" r="10"><animate attributeName="opacity" values="1;.2;1" dur="1.2s" begin="0.8s" repeatCount="indefinite"/></circle>' +
            '</svg>';
        exit(StrSubstNo(DataUrl, Spinner));
    end;

}
