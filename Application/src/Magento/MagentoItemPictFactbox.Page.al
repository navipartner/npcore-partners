page 6151447 "NPR Magento Item Pict. Factbox"
{
    Extensible = False;
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
            field("Magento Picture"; TempMagentoPicture.Image)
            {

                ShowCaption = false;
                ToolTip = 'Specifies the value of the TempMagentoPicture.Picture field';
                ApplicationArea = NPRRetail;
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
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        HasPicture := false;
        Initialize();
        if not (MagentoSetup.Get() and MagentoSetup."Magento Enabled") then
            exit;
        if not (MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre, MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"]) then
            exit;
        Clear(TempMagentoPicture.Image);
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
        TempBlob.CreateOutStream(OutStr);
        TempMagentoPicture.Image.ExportStream(OutStr);
        HasPicture := TempBlob.HasValue();
    end;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        if MagentoSetup.Get() then;
        Initialized := true;
    end;
}
