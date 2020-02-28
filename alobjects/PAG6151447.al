page 6151447 "Magento Item Picture Factbox"
{
    // MAG1.22/MHA /20160422  CASE 239060 Object created
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG10.00.2.00/MHA/20161118  CASE 258544 Changed Miniature to use Picture instead of TempItem.Picture
    // NPR5.42/MHA /20170828  CASE 287064 LoadPicture() only downloads picture if Miniature is set in Magento Setup
    // MAG2.20/MHA/20190502  CASE 353499 Magento Integration
    // MAG2.24/MHA /20191203  CASE 379760 Added Find Picture code to LoadPicture()

    Caption = 'Picture';
    PageType = CardPart;
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
            field("TempMagentoPicture.Picture";TempMagentoPicture.Picture)
            {
                ShowCaption = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        LoadPicture();
    end;

    var
        TempMagentoPicture: Record "Magento Picture" temporary;
        MagentoSetup: Record "Magento Setup";
        Initialized: Boolean;
        HasPicture: Boolean;

    procedure LoadPicture()
    var
        MagentoPicture: Record "Magento Picture";
        MagentoPictureLink: Record "Magento Picture Link";
    begin
        //-MAG2.20 [353499]
        HasPicture := false;
        //+MAG2.20 [353499]
        //-NPR5.42 [287064]
        Initialize();
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
          exit;
        if not (MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre,MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"]) then
          exit;
        //+MAG2.20 [353499]
        //+NPR5.42 [287064]
        //-MAG2.24 [379760]
        Clear(TempMagentoPicture.Picture);
        MagentoPictureLink.SetRange("Item No.","No.");
        MagentoPictureLink.SetRange("Base Image",true);
        if not MagentoPictureLink.FindFirst then
          exit;

        if not MagentoPicture.Get(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") then
          exit;
        //+MAG2.24 [379760]

        if MagentoPicture.Get(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") then begin
          TempMagentoPicture.Init;
          TempMagentoPicture := MagentoPicture;
        end else begin
          TempMagentoPicture.Init;
          TempMagentoPicture.Type := TempMagentoPicture.Type::Item;
          TempMagentoPicture.Name := MagentoPictureLink."Picture Name";
        end;

        //-MAG10.00.2.00 [258544]
        //TempMagentoPicture.DownloadPicture(TempItem);
        //Picture := TempItem.Picture;
        //HasPicture := Picture.HASVALUE;
        TempMagentoPicture.DownloadPicture(TempMagentoPicture);
        HasPicture := TempMagentoPicture.Picture.HasValue;
        //+MAG10.00.2.00 [258544]
        //+MAG2.20 [353499]
    end;

    local procedure Initialize()
    begin
        //-NPR5.42 [287064]
        if Initialized then
          exit;

        if MagentoSetup.Get then;
        Initialized := true;
        //+NPR5.42 [287064]
    end;
}

