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
        MediaSvgHelper: Codeunit "NPR CloudflareMediaSvgHelper";
        _ControlAddInReady: Boolean;
        _HaveImage: Boolean;
        _HaveImageFor: Guid;

        _ConfirmDeleteImage: Label 'Are you sure you want to delete the picture?';
        _ConfirmOverrideImage: Label 'The existing picture will be replaced. Do you want to continue?';

    internal procedure RefreshImage()
    begin
        Clear(_HaveImageFor);
        LoadImage();
    end;

    internal procedure LoadImage()
    var
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
        ImageUrl: Text;
    begin
        if (not _ControlAddInReady) then
            exit;

        if (Rec.SystemId = _HaveImageFor) then
            exit;

        CurrPage."Image Viewer".SetSource(MediaSvgHelper.SpinnerSvg());
        CurrPage.Update(false);

        _HaveImage := MemberMedia.GetMemberImageUrl(Rec.SystemId, ENUM::"NPR CloudflareMediaVariants"::THUMBNAIL, 300, ImageUrl);

        if (not _HaveImage) then
            _HaveImage := MigrateLocalImage(Rec, ImageUrl);

        if (_HaveImage) then begin
            CurrPage."Image Viewer".SetSource(ImageUrl);
            _HaveImageFor := Rec.SystemId;
        end else begin
            CurrPage."Image Viewer".SetSource(MediaSvgHelper.NoPictureAvailableImage());
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


}
