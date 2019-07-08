page 6151411 "Magento Pictures"
{
    // MAG1.01/HSK/20150129 CASE 205438 Added functions:
    //                                 - CountRelations() - Counts the number of picture links.
    //                                 - DrillDownCounter() - Page.RUN of picture links data.
    // MAG1.04/MH/20150209  CASE 199932 Updated PictureViewer Addin
    // MAG1.09/MH/20150316  CASE 206395 Updated Layout with Repeater-Picture-Blob
    // MAG1.12/MH/20150403  CASE 210709 Removed Picture field due to performance
    // MAG1.14/MH/20150508  CASE 211881 Updated PictureViewer Addin to JavaScript version
    // MAG1.21/MHA/20151118 CASE 223835 Type deleted from Picture Link and Added Miniature
    // MAG1.22/MHA/20160421 CASE 230240 Changed "Size (kb)" to Non Visible
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG10.00.2.00/MHA/20161118  CASE 258544 Changed Miniature to use Picture instead of TempItem.Picture

    Caption = 'Magento Pictures';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Magento Picture";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Control6150622)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field(MiniatureLine;TempMagentoPicture.Picture)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Miniature';
                        Editable = false;
                        Visible = MiniatureLinePicture;
                    }
                    field(Type;Type)
                    {
                    }
                    field(Name;Name)
                    {
                    }
                    field("Count";Counter)
                    {
                        Caption = 'Count';

                        trigger OnDrillDown()
                        begin
                            DrillDownCounter();
                        end;
                    }
                    field("Last Date Modified";"Last Date Modified")
                    {
                    }
                    field("Last Time Modified";"Last Time Modified")
                    {
                    }
                    field("Size (kb)";"Size (kb)")
                    {
                        Visible = false;
                    }
                }
            }
        }
        area(factboxes)
        {
            part(DragDropAddin;"Magento DragDropPic. Addin")
            {
                Caption = 'DragAndDrop Picture';
                ShowFilter = false;
                SubPageLink = Type=FIELD(Type),
                              Name=FIELD(Name);
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnAfterGetRecord()
    var
        TempMagentoPicture2: Record "Magento Picture" temporary;
    begin
        CountRelations();
        //-MAG10.00.2.00 [258544]
        // //-MAG1.21
        // CLEAR(TempItemPicture);
        // IF MiniatureLinePicture THEN
        //  DownloadPicture(TempItemPicture);
        // //+MAG1.21
        if TempMagentoPicture.Get(Type,Name) then begin
          TempMagentoPicture.CalcFields(Picture);
          exit;
        end;
        Clear(TempMagentoPicture2);
        if MiniatureLinePicture then
          DownloadPicture(TempMagentoPicture2);

        TempMagentoPicture.Init;
        TempMagentoPicture := Rec;
        TempMagentoPicture.Picture := TempMagentoPicture2.Picture;
        TempMagentoPicture.Insert;
        //+MAG10.00.2.00 [258544]
    end;

    trigger OnInit()
    begin
        //-MAG1.21
        GetMiniatureSetup();
        CurrPage.DragDropAddin.PAGE.SetHidePicture(not MiniatureSinglePicture);
        //+MAG1.21
    end;

    var
        MagentoSetup: Record "Magento Setup";
        TempMagentoPicture: Record "Magento Picture" temporary;
        Counter: Integer;
        MiniatureLinePicture: Boolean;
        MiniatureSinglePicture: Boolean;

    procedure CountRelations()
    var
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoItemGroup: Record "Magento Item Group";
        MagentoBrand: Record "Magento Brand";
        MagentoAttributeLabel: Record "Magento Attribute Label";
    begin
        Counter := 0;
        case Type of
          Type::Item:
            begin
              //-MAG1.21
              //MagentoPictureLink.SETRANGE(Type,Type::Item);
              //+MAG1.21
              MagentoPictureLink.SetRange("Picture Name",Name);
              Counter := MagentoPictureLink.Count;
            end;
          Type::"Item Group":
            begin
              MagentoItemGroup.SetRange(Picture,Name);
              Counter := MagentoItemGroup.Count;
            end;
          Type::Brand:
            begin
              MagentoBrand.SetRange(Picture,Name);
              Counter := MagentoBrand.Count;
            end;
          Type::Customer:
            begin
              MagentoAttributeLabel.SetRange(Image,Name);
              Counter := MagentoAttributeLabel.Count;
            end;
        end;
    end;

    procedure DrillDownCounter()
    var
        Item: Record Item;
        MagentoPictureLink: Record "Magento Picture Link";
        MagentoItemGroup: Record "Magento Item Group";
        MagentoBrand: Record "Magento Brand";
        TempItem: Record Item temporary;
    begin
        if Counter <> 0 then begin
          case Type of
            Type::Item:
              begin
                TempItem.DeleteAll;
                Clear(MagentoPictureLink);
                //-MAG1.21
                //MagentoPictureLink.SETRANGE(Type,Type::Item);
                //+MAG1.21
                MagentoPictureLink.SetRange("Picture Name",Name);
                if MagentoPictureLink.FindSet then
                  repeat
                    if not TempItem.Get(MagentoPictureLink."Item No.") then begin
                      Item.Get(MagentoPictureLink."Item No.");
                      TempItem.Init;
                      TempItem := Item;
                      TempItem.Insert;
                    end;
                  until MagentoPictureLink.Next = 0;
                PAGE.Run(PAGE::"Retail Item List",TempItem);
              end;
            Type::"Item Group":
              begin
                Clear(MagentoItemGroup);
                MagentoItemGroup.SetRange(Picture,Name);
                PAGE.Run(PAGE::"Magento Item Group List",MagentoItemGroup);
              end;
            Type::Brand:
              begin
                Clear(MagentoBrand);
                MagentoBrand.SetRange(Picture,Name);
                PAGE.Run(PAGE::"Magento Brands",MagentoBrand);
              end;
          end;
        end;
    end;

    local procedure "--- Miniature"()
    begin
    end;

    local procedure GetMiniatureSetup()
    begin
        //-MAG1.21
        if not MagentoSetup.Get then
          exit;
        MiniatureSinglePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::SinglePicutre,MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        MiniatureLinePicture := MagentoSetup."Miniature Picture" in [MagentoSetup."Miniature Picture"::LinePicture,MagentoSetup."Miniature Picture"::"SinglePicture+LinePicture"];
        //+MAG1.21
    end;
}

