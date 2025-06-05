page 6151447 "NPR Magento Item Pict. Factbox"
{
    Extensible = False;
    Caption = 'Webshop picture';
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            usercontrol("Image Viewer"; "NPR Image Viewer")
            {
                ApplicationArea = NPRMagento;

                trigger ControlAddInReady()
                begin
                    _ControlAddInReady := true;
                    LoadPicture();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        LoadPicture();
    end;

    var
        _MagentoSetup: Record "NPR Magento Setup";
        _Initialized: Boolean;
        _ControlAddInReady: Boolean;

    internal procedure LoadPicture()
    var
        TempMagentoPicture: Record "NPR Magento Picture" temporary;
        MagentoPictureLink: Record "NPR Magento Picture Link";
    begin
        if (not _ControlAddInReady) then
            exit;

        Initialize();

        if (not (_MagentoSetup.Get() and _MagentoSetup."Magento Enabled")) then
            exit;
        if (not (_MagentoSetup."Miniature Picture" in [_MagentoSetup."Miniature Picture"::SinglePicutre, _MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"])) then
            exit;

        MagentoPictureLink.SetRange("Item No.", Rec."No.");
        MagentoPictureLink.SetRange("Base Image", true);
        if (not MagentoPictureLink.FindFirst()) then
            exit;

        TempMagentoPicture.Init();
        TempMagentoPicture.Type := TempMagentoPicture.Type::Item;
        TempMagentoPicture.Name := MagentoPictureLink."Picture Name";

        CurrPage."Image Viewer".SetSource(TempMagentoPicture.GetMagentoUrl());
    end;

    local procedure Initialize()
    begin
        if _Initialized then
            exit;

        if _MagentoSetup.Get() then;
        _Initialized := true;
    end;
}
