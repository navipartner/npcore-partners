page 6151451 "Magento DragDropPic. Addin"
{
    // MAG1.14/MHA /20150508  CASE 211881 Object created - updated PictureViewer Addin to JavaScript version
    // MAG1.16/MHA /20150519  CASE 214257 Implemented multi file DragDrop
    // MAG1.17/MHA /20150616  CASE 215910 Added DataUri
    // MAG1.18/MHA /20150708  CASE 218286 Corrected HidePicture
    // MAG1.19/MHA /20150730  CASE 219087 DragDropPicture 1.01 update
    // MAG1.20/MHA /20150810  CASE 220153 DragDropPicture 1.02 update
    // MAG1.21/MHA /20151105  CASE 223835 Added function SetVariantValueCode() and added function SetHidePicture()
    // MAG1.22/MHA /20160107  CASE 230240 DragDropPicture 1.03 update - Resize removed
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.03/MHA /20170411  CASE 272066 DragDropPicture 1.04 update - DataUri Chunk Size increased and PictureSize added
    // MAG2.05/MHA /20170714  CASE 283777 Picture functionality moved to cu 6151419
    // MAG2.06/MHA /20170817  CASE 286203 Added function SetAutoOverwrite()
    // MAG2.10/MHA /20180206  CASE 302910 DragDropPicture 1.05 update - Resize() functionality completely removed as it cleared compression
    // MAG2.17/TS  /20181017  CASE 324862 Added Icon Picture
    // MAG2.22/MHA /20190625  CASE 359285 Added Variety variables
    // MAG2.25/MHA /20200401  CASE 385686 Added function OnSavePictureLinks()

    Caption = ' ';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    ShowFilter = false;
    SourceTable = "Magento Picture";

    layout
    {
        area(content)
        {
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DisplayPicture();
    end;

    trigger OnInit()
    begin
        PictureType := -1;
    end;

    trigger OnOpenPage()
    begin
        MagentoSetup.Get;
        MagentoEnabled := MagentoSetup."Magento Enabled";
    end;

    var
        MagentoSetup: Record "Magento Setup";
        TempMagentoPicture: Record "Magento Picture" temporary;
        MagentoPictureMgt: Codeunit "Magento Picture Mgt.";
        ControlAddInReady: Boolean;
        AutoOverwrite: Boolean;
        HidePicture: Boolean;
        Initialized: Boolean;
        IsLogoPicture: Boolean;
        MagentoEnabled: Boolean;
        Overwrite: Boolean;
        PictureDataUri: Text;
        Text001: Label '%1 pictures already exist:';
        PictureName: Text;
        PictureLinkNo: Code[20];
        PictureLinkVariantValueCode: Code[20];
        PictureType: Integer;
        Text00101: Label '\  - %1';
        Text00102: Label '\\Overwrite?';
        Text002: Label 'Clear Picture';
        Text003: Label 'DragAndDrop Picture';
        Text004: Label '&Item,&Brand,Item &Group,&Customer';
        PictureSize: Decimal;
        IsIconPicture: Boolean;
        VarietyTypeCode: Code[10];
        VarietyTableCode: Code[40];
        VarietyValueCode: Code[20];

    local procedure "--- Database"()
    begin
    end;

    local procedure ConfirmOverwrite(): Boolean
    var
        MagentoPicture: Record "Magento Picture";
        ConfirmText: Text;
        ExistingCount: Integer;
    begin
        //-MAG2.06 [286203]
        if AutoOverwrite then
          exit(true);
        //+MAG2.06 [286203]
        if not GuiAllowed then
          exit(false);

        ConfirmText := '';
        ExistingCount := 0;
        if TempMagentoPicture.FindSet then
          repeat
            if MagentoPicture.Get(PictureType,TempMagentoPicture.Name) then begin
              ExistingCount += 1;
              ConfirmText += StrSubstNo(Text00101,MagentoPicture.Name);
            end;
          until TempMagentoPicture.Next = 0;

        if ExistingCount = 0 then
          exit(true);

        ConfirmText := StrSubstNo(Text001,ExistingCount) + ConfirmText + Text00102;
        exit(Confirm(ConfirmText));
    end;

    local procedure SavePictures()
    var
        MagentoPicture: Record "Magento Picture";
        Skip: Boolean;
    begin
        Clear(TempMagentoPicture);
        if not TempMagentoPicture.FindSet then
          exit;
        if PictureType < 0 then
          PictureType := SelectPictureType();
        if PictureType < 0 then
          exit;

        Overwrite := ConfirmOverwrite();
        TempMagentoPicture.FindSet;
        repeat
          Skip := MagentoPicture.Get(PictureType,TempMagentoPicture.Name) and not Overwrite;
          if not Skip then begin
            SavePicture(PictureType,TempMagentoPicture);
            SavePictureLinks(PictureType,TempMagentoPicture);
            Commit;
          end;
        until TempMagentoPicture.Next = 0;
    end;

    local procedure SavePicture(PictureType: Integer;var TempMagentoPicture2: Record "Magento Picture" temporary)
    var
        MagentoPicture: Record "Magento Picture";
        Skip: Boolean;
    begin
        if MagentoPicture.Get(PictureType,TempMagentoPicture2.Name) then begin
          MagentoPicture."Size (kb)" := TempMagentoPicture."Size (kb)";
          Clear(MagentoPicture.Picture);
          MagentoPicture.Modify(true);
        end else begin
          MagentoPicture.Init;
          MagentoPicture := TempMagentoPicture2;
          MagentoPicture.Type := PictureType;
          Clear(MagentoPicture.Picture);
          MagentoPicture.Insert(true);
        end;
        //-MAG2.05 [283777]
        //MagentoMgt.SendMagentoPicture(MagentoPicture.Name,MagentoPicture.GetMagentoType(),TempMagentoPicture2.GetBase64());
        MagentoPictureMgt.DragDropPicture(MagentoPicture.Name,MagentoPicture.GetMagentoType(),TempMagentoPicture2.GetBase64());
        //+MAG2.05 [283777]
        Commit;
    end;

    [IntegrationEvent(false, TRUE)]
    local procedure OnSavePictureLinks(PictureType: Integer;var TempMagentoPicture2: Record "Magento Picture" temporary;var Handled: Boolean)
    begin
    end;

    local procedure SavePictureLinks(PictureType: Integer;var TempMagentoPicture2: Record "Magento Picture" temporary)
    var
        ItemGroup: Record "Magento Item Group";
        MagentoPictureLink: Record "Magento Picture Link";
        Brand: Record "Magento Brand";
        LineNo: Integer;
        Handled: Boolean;
    begin
        //-MAG2.25 [385686]
        OnSavePictureLinks(PictureType,TempMagentoPicture2,Handled);
        if Handled then
          exit;
        //+MAG2.25 [385686]
        if PictureLinkNo = '' then
          exit;

        case PictureType of
          TempMagentoPicture2.Type::Brand:
            begin
              Brand.Get(PictureLinkNo);
              if IsLogoPicture then
                Brand."Logo Picture" := TempMagentoPicture2.Name
              else
                Brand.Picture := TempMagentoPicture2.Name;
              Brand.Modify(true);
              exit;
            end;
          TempMagentoPicture2.Type::"Item Group":
            begin
              ItemGroup.Get(PictureLinkNo);
              //-MAG2.17 [324862]
              if IsIconPicture then
                 ItemGroup.Icon := TempMagentoPicture2.Name
              else
              //+MAG2.17 [324862]
                ItemGroup.Picture := TempMagentoPicture2.Name;
              ItemGroup.Modify(true);
              exit;
            end;
          else if PictureType <> TempMagentoPicture2.Type::Item then
            exit;
        end;

        Clear(MagentoPictureLink);
        //-MAG1.21
        //MagentoPictureLink.SETRANGE(Type,PictureType);
        //+MAG1.21
        MagentoPictureLink.SetRange("Item No.",PictureLinkNo);
        if MagentoPictureLink.FindLast then;
        LineNo := MagentoPictureLink."Line No." + 10000;

        Clear(MagentoPictureLink);
        //-MAG1.21
        //MagentoPictureLink.SETRANGE(Type,PictureType);
        //+MAG1.21
        MagentoPictureLink.SetRange("Item No.",PictureLinkNo);
        //-MAG1.21
        MagentoPictureLink.SetRange("Variant Value Code",PictureLinkVariantValueCode);
        //+MAG1.21
        //-MAG2.22 [359285]
        MagentoPictureLink.SetRange("Variety Type",VarietyTypeCode);
        MagentoPictureLink.SetRange("Variety Table",VarietyTableCode);
        MagentoPictureLink.SetRange("Variety Value",VarietyValueCode);
        //+MAG2.22 [359285]

        MagentoPictureLink.SetRange("Picture Name",TempMagentoPicture2.Name);
        if not MagentoPictureLink.FindFirst then begin
          LineNo += 10000;
          MagentoPictureLink.Init;
          //-MAG1.21
          //MagentoPictureLink.Type := TempMagentoPicture2.Type;
          //MagentoPictureLink."Item No." := PictureLinkNo;
          MagentoPictureLink."Item No." := PictureLinkNo;
          MagentoPictureLink."Variant Value Code" := PictureLinkVariantValueCode;
          //-MAG2.22 [359285]
          MagentoPictureLink."Variety Type" := VarietyTypeCode;
          MagentoPictureLink."Variety Table" := VarietyTableCode;
          MagentoPictureLink."Variety Value" := VarietyValueCode;
          //+MAG2.22 [359285]
          //+MAG1.21
          MagentoPictureLink."Line No." := LineNo;
          MagentoPictureLink."Picture Name" := TempMagentoPicture2.Name;
          MagentoPictureLink."Short Text" := TempMagentoPicture2.Name;
          //-MAG1.21
          //MagentoPictureLink."Entry No." := 0;
          //+MAG1.21
          MagentoPictureLink.Insert(true);
        end;
    end;

    local procedure "--- PictureAddin"()
    begin
    end;

    procedure DisplayPicture()
    var
        String: DotNet npNetString;
    begin
        if not ControlAddInReady then
          exit;
        if HidePicture then begin
          //CurrPage.DragDropAddin.DisplayData('');
          exit;
        end;

        if Picture.HasValue then begin
          //CurrPage.DragDropAddin.DisplayData(GetDataUri());
          exit;
        end;

        //CurrPage.DragDropAddin.DisplayData(GetMagentotUrl());
    end;

    procedure GetDataUri() DataUri: Text
    var
        Convert: DotNet npNetConvert;
        Image: DotNet npNetImage;
        ImageFormat: DotNet npNetImageFormat;
        MemoryStream: DotNet npNetMemoryStream;
        InStream: InStream;
    begin
        if not Picture.HasValue then
          exit;

        DataUri := 'data:image/';

        CalcFields(Picture);
        Picture.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream;
        CopyStream(MemoryStream,InStream);
        Image := Image.FromStream(MemoryStream);
        ImageFormat := Image.RawFormat;
        case true of
          ImageFormat.Equals(ImageFormat.Gif): DataUri += 'gif';
          ImageFormat.Equals(ImageFormat.Jpeg): DataUri += 'jpg';
          ImageFormat.Equals(ImageFormat.Png): DataUri += 'png';
        end;

        DataUri += ';base64,' + Convert.ToBase64String(MemoryStream.ToArray);
        exit(DataUri);
    end;

    procedure ReplacePicture(): Boolean
    var
        MagentoPicture: Record "Magento Picture";
        MagentoPictureLink: Record "Magento Picture Link";
    begin
    end;

    procedure "--- Aux"()
    begin
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId,SessionId) then
          exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure SelectPictureType() NewPictureType: Integer
    begin
        NewPictureType := StrMenu(Text004) - 1;
    end;

    procedure SetAutoOverwrite(NewAutoOverwrite: Boolean)
    begin
        //-MAG2.06 [286203]
        AutoOverwrite := NewAutoOverwrite;
        //+MAG2.06 [286203]
    end;

    procedure SetHidePicture(NewHidePicture: Boolean)
    begin
        //-MAG1.21
        HidePicture := NewHidePicture;
        //+MAG1.21
    end;

    procedure SetItemNo(ItemNo: Code[20])
    begin
        PictureType := Type::Item;
        PictureLinkNo := ItemNo;
        //-MAG1.21
        //HidePicture := TRUE;
        //+MAG1.21
    end;

    procedure SetItemGroupNo(ItemGroupNo: Code[20];NewIsIconPicture: Boolean)
    begin
        PictureType := Type::"Item Group";
        PictureLinkNo := ItemGroupNo;
        //-MAG2.17 [324862]
        IsIconPicture := NewIsIconPicture;
        //+MAG2.17 [324862]
    end;

    procedure SetBrandCode(BrandCode: Code[20];NewIsLogoPicture: Boolean)
    begin
        PictureType := Type::Brand;
        PictureLinkNo := BrandCode;
        IsLogoPicture := NewIsLogoPicture;
    end;

    local procedure SetPictureType(NewPictureType: Integer)
    begin
        PictureType := NewPictureType;
    end;

    procedure SetRecordPosition(PictureType: Integer;PictureName: Text)
    begin
        if Get(PictureType,PictureName) then;
    end;

    procedure SetVariantValueCode(NewVariantValueCode: Code[20])
    begin
        //-MAG1.21
        PictureLinkVariantValueCode := NewVariantValueCode;
        //+MAG1.21
    end;

    procedure SetVarietyFilters(NewVarietyTypeCode: Code[10];NewVarietyTableCode: Code[40];NewVarietyValueCode: Code[20])
    begin
        //-MAG2.22 [359285]
        VarietyTypeCode := NewVarietyTypeCode;
        VarietyTableCode := NewVarietyTableCode;
        VarietyValueCode := NewVarietyValueCode;
        //+MAG2.22 [359285]
    end;

    local procedure "--- Data Transfer"()
    begin
    end;

    local procedure EndDataStream()
    begin
        SaveTempPicture();
    end;

    procedure EndDataTransfer()
    begin
        PictureName := '';
        PictureDataUri := '';
        if not Initialized then begin
          TempMagentoPicture.DeleteAll;
          exit;
        end;
        if not TempMagentoPicture.FindSet then begin
          Initialized := false;
          exit;
        end;

        SavePictures();
        TempMagentoPicture.DeleteAll;
        Initialized := false;
    end;

    local procedure InitDataStream(Filename: Text;Filesize: Decimal)
    begin
        PictureName := Filename;
        PictureDataUri := '';
        //-MAG2.03 [272066]
        PictureSize := Filesize;
        //+MAG2.03 [272066]
    end;

    procedure InitDataTransfer()
    begin
        PictureName := '';
        PictureDataUri := '';
        TempMagentoPicture.DeleteAll;
        Initialized := true;
    end;

    procedure SaveTempPicture()
    var
        MemoryStream: DotNet npNetMemoryStream;
        RegEx: DotNet npNetRegex;
        Match: DotNet npNetMatch;
        Convert: DotNet npNetConvert;
        OutStr: OutStream;
        DataUri: Text;
    begin
        if not Initialized then
          exit;

        DataUri := PictureDataUri;
        PictureDataUri := '';
        RegEx := RegEx.Regex('data\:image/(.*?);base64,(.*)');
        Match := RegEx.Match(DataUri);
        if Match.Success then begin
          MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(Match.Groups.Item(2).Value));
          TempMagentoPicture.Init;
          TempMagentoPicture.Type := PictureType;
          TempMagentoPicture.Name := PictureName;
          //-MAG2.03 [272066]
          //TempMagentoPicture."Size (kb)" := ROUND(MemoryStream.Length / 1000,1);
          TempMagentoPicture."Size (kb)" := Round(PictureSize / 1000,1);
          //+MAG2.03 [272066]
          TempMagentoPicture.Picture.CreateOutStream(OutStr);
          CopyStream(OutStr,MemoryStream);
          TempMagentoPicture.Insert;
          MemoryStream.Dispose();
        end;
        PictureName := '';
    end;

    local procedure WriteDataStream(NewData: Text;Finalize: Boolean)
    begin
        PictureDataUri := PictureDataUri + Format(NewData);
    end;
}

