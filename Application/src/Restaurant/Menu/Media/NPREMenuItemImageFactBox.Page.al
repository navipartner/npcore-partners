#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150925 "NPR NPREMenuItemImageFactBox"
{
    Extensible = False;
    Caption = 'Menu Item Picture';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR NPRE Menu Item";

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
            action(ImportPicture)
            {
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture for this menu item.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MenuItemMedia: Codeunit "NPR NPREMenuItemPictureHandler";
                begin
                    if (_HaveImage) then
                        if (not Confirm(_ConfirmOverrideImage)) then
                            exit;

                    MenuItemMedia.ImportMenuItemPictureFromFileWithUI(Rec.SystemId);
                    Clear(_HaveImageFor);

                    CurrPage.Update(false);
                end;
            }

            action(OpenOriginalPicture)
            {
                Caption = 'Open Original';
                Enabled = _HaveImage;
                Image = View;
                ToolTip = 'Open the original picture in a new browser tab.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MenuItemMedia: Codeunit "NPR NPREMenuItemPictureHandler";
                    ImageUrl: Text;
                begin
                    if (not MenuItemMedia.GetPictureUrl(Rec.SystemId, ENUM::"NPR CloudflareMediaVariants"::ORIGINAL, 300, ImageUrl)) then
                        exit;

                    Hyperlink(ImageUrl);
                end;
            }

            action(DeletePicture)
            {
                Caption = 'Delete';
                Enabled = _HaveImage;
                Image = Delete;
                ToolTip = 'Remove picture from menu item.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MenuItemMedia: Codeunit "NPR NPREMenuItemPictureHandler";
                begin
                    if (not Confirm(_ConfirmDeleteImage)) then
                        exit;

                    MenuItemMedia.UnlinkPicture(Rec.SystemId);
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
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MediaLink: Record "NPR CloudflareMediaLink";
                begin
                    if (MediaLink.Get(Database::"NPR NPRE Menu Item", Rec.SystemId, Enum::"NPR CloudflareMediaSelector"::MENU_ITEM_PICTURE)) then
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

    internal procedure LoadImage()
    var
        MenuItemMedia: Codeunit "NPR NPREMenuItemPictureHandler";
        ImageUrl: Text;
    begin
        if (not _ControlAddInReady) then
            exit;

        if (Rec.SystemId = _HaveImageFor) then
            exit;

        CurrPage."Image Viewer".SetSource(MediaSvgHelper.SpinnerSvg());
        CurrPage.Update(false);

        _HaveImage := MenuItemMedia.GetPictureUrl(Rec.SystemId, ENUM::"NPR CloudflareMediaVariants"::LARGE, 300, ImageUrl);

        if (_HaveImage) then begin
            CurrPage."Image Viewer".SetSource(ImageUrl);
            _HaveImageFor := Rec.SystemId;
        end else begin
            CurrPage."Image Viewer".SetSource(MediaSvgHelper.NoPictureAvailableImage());
            Clear(_HaveImageFor);
        end;
    end;

}
#endif
