page 6151447 "NPR Magento Item Pict. Factbox"
{
    Caption = 'Picture';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            group(Control6151400)
            {
                ShowCaption = false;
                Visible = HasPicture;
            }
            field("TempMagentoPicture.Picture"; TempMagentoPicture.Picture)
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the TempMagentoPicture.Picture field';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        LoadPicture();
    end;

    var
        TempMagentoPicture: Record "NPR Magento Picture" temporary;
        MagentoSetup: Record "NPR Magento Setup";
        Initialized: Boolean;
        HasPicture: Boolean;

    procedure LoadPicture()
    var
        MagentoPicture: Record "NPR Magento Picture";
        MagentoPictureLink: Record "NPR Magento Picture Link";
    begin
        HasPicture := false;
        Initialize();
        if not (MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;
        if not (MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"]) then
            exit;
        Clear(TempMagentoPicture.Picture);
        MagentoPictureLink.SetRange("Item No.", Rec."No.");
        MagentoPictureLink.SetRange("Base Image", true);
        if not MagentoPictureLink.FindFirst() then
            exit;

        if not MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
            exit;

        if MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then begin
            TempMagentoPicture.Init();
            TempMagentoPicture := MagentoPicture;
        end else begin
            TempMagentoPicture.Init();
            TempMagentoPicture.Type := TempMagentoPicture.Type::Item;
            TempMagentoPicture.Name := MagentoPictureLink."Picture Name";
        end;

        TempMagentoPicture.DownloadPicture(TempMagentoPicture);
        HasPicture := TempMagentoPicture.Picture.HasValue;
    end;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        if MagentoSetup.Get() then;
        Initialized := true;
    end;
}