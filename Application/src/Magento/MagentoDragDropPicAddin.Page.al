page 6151451 "NPR Magento DragDropPic. Addin"
{
    Caption = ' ';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR Magento Picture";

    layout
    {
        area(content)
        {
            usercontrol(DragDropAddin; "NPR DragDrop")
            {
                ApplicationArea = All;

                trigger AddInReady();
                begin
                    ControlAddInReady := true;
                    CurrPage.DragDropAddin.SetCaption('drop-text', Text003);
                    DisplayPicture();
                    CurrPage.Update(false);
                end;

                trigger EndDataStream();
                begin
                    EndDataStream();
                end;

                trigger EndDataTransfer();
                begin
                    EndDataTransfer();
                    DisplayPicture();
                    if IsWebClient() then
                        CurrPage.Update(false);
                end;

                trigger InitDataStream(FileName: Text; FileSize: Decimal);
                begin
                    InitDataStream(FileName, FileSize);
                end;

                trigger InitDataTransfer();
                begin
                    InitDataTransfer();
                end;

                trigger WriteDataStream(Data: Text; Finalize: Boolean);
                begin
                    WriteDataStream(data, finalize);
                end;
            }
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
        MagentoSetup: Record "NPR Magento Setup";
        TempMagentoPicture: Record "NPR Magento Picture" temporary;
        MagentoPictureMgt: Codeunit "NPR Magento Picture Mgt.";
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

    local procedure ConfirmOverwrite(): Boolean
    var
        MagentoPicture: Record "NPR Magento Picture";
        ConfirmText: Text;
        ExistingCount: Integer;
    begin
        if AutoOverwrite then
            exit(true);
        if not GuiAllowed then
            exit(false);

        ConfirmText := '';
        ExistingCount := 0;
        if TempMagentoPicture.FindSet then
            repeat
                if MagentoPicture.Get(PictureType, TempMagentoPicture.Name) then begin
                    ExistingCount += 1;
                    ConfirmText += StrSubstNo(Text00101, MagentoPicture.Name);
                end;
            until TempMagentoPicture.Next = 0;

        if ExistingCount = 0 then
            exit(true);

        ConfirmText := StrSubstNo(Text001, ExistingCount) + ConfirmText + Text00102;
        exit(Confirm(ConfirmText));
    end;

    local procedure SavePictures()
    var
        MagentoPicture: Record "NPR Magento Picture";
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
            Skip := MagentoPicture.Get(PictureType, TempMagentoPicture.Name) and not Overwrite;
            if not Skip then begin
                SavePicture(PictureType, TempMagentoPicture);
                SavePictureLinks(PictureType, TempMagentoPicture);
                Commit;
            end;
        until TempMagentoPicture.Next = 0;
    end;

    local procedure SavePicture(PictureType: Integer; var TempMagentoPicture2: Record "NPR Magento Picture" temporary)
    var
        MagentoPicture: Record "NPR Magento Picture";
        Skip: Boolean;
    begin
        if MagentoPicture.Get(PictureType, TempMagentoPicture2.Name) then begin
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
        MagentoPictureMgt.DragDropPicture(MagentoPicture.Name, MagentoPicture.GetMagentoType(), TempMagentoPicture2.GetBase64());
        Commit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSavePictureLinks(PictureType: Integer; var TempMagentoPicture2: Record "NPR Magento Picture" temporary; var Handled: Boolean)
    begin
    end;

    local procedure SavePictureLinks(PictureType: Integer; var TempMagentoPicture2: Record "NPR Magento Picture" temporary)
    var
        ItemGroup: Record "NPR Magento Category";
        MagentoPictureLink: Record "NPR Magento Picture Link";
        Brand: Record "NPR Magento Brand";
        LineNo: Integer;
        Handled: Boolean;
    begin
        OnSavePictureLinks(PictureType, TempMagentoPicture2, Handled);
        if Handled then
            exit;
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
                    if IsIconPicture then
                        ItemGroup.Icon := TempMagentoPicture2.Name
                    else
                        ItemGroup.Picture := TempMagentoPicture2.Name;
                    ItemGroup.Modify(true);
                    exit;
                end;
            else
                if PictureType <> TempMagentoPicture2.Type::Item then
                    exit;
        end;

        Clear(MagentoPictureLink);
        MagentoPictureLink.SetRange("Item No.", PictureLinkNo);
        if MagentoPictureLink.FindLast then;
        LineNo := MagentoPictureLink."Line No." + 10000;

        Clear(MagentoPictureLink);
        MagentoPictureLink.SetRange("Item No.", PictureLinkNo);
        MagentoPictureLink.SetRange("Variant Value Code", PictureLinkVariantValueCode);
        MagentoPictureLink.SetRange("Variety Type", VarietyTypeCode);
        MagentoPictureLink.SetRange("Variety Table", VarietyTableCode);
        MagentoPictureLink.SetRange("Variety Value", VarietyValueCode);

        MagentoPictureLink.SetRange("Picture Name", TempMagentoPicture2.Name);
        if not MagentoPictureLink.FindFirst then begin
            LineNo += 10000;
            MagentoPictureLink.Init;
            MagentoPictureLink."Item No." := PictureLinkNo;
            MagentoPictureLink."Variant Value Code" := PictureLinkVariantValueCode;
            MagentoPictureLink."Variety Type" := VarietyTypeCode;
            MagentoPictureLink."Variety Table" := VarietyTableCode;
            MagentoPictureLink."Variety Value" := VarietyValueCode;
            MagentoPictureLink."Line No." := LineNo;
            MagentoPictureLink."Picture Name" := TempMagentoPicture2.Name;
            MagentoPictureLink."Short Text" := TempMagentoPicture2.Name;
            MagentoPictureLink.Insert(true);
        end;
    end;

    local procedure "--- PictureAddin"()
    begin
    end;

    procedure DisplayPicture()
    var
        String: DotNet NPRNetString;
    begin
        if not ControlAddInReady then
            exit;
        if HidePicture then begin
            CurrPage.DragDropAddin.DisplayData('');
            exit;
        end;

        if Picture.HasValue then begin
            CurrPage.DragDropAddin.DisplayData(GetDataUri());
            exit;
        end;

        CurrPage.DragDropAddin.DisplayData(GetMagentotUrl());
    end;

    procedure GetDataUri() DataUri: Text
    var
        Convert: DotNet NPRNetConvert;
        Image: DotNet NPRNetImage;
        ImageFormat: DotNet NPRNetImageFormat;
        MemoryStream: DotNet NPRNetMemoryStream;
        InStream: InStream;
    begin
        if not Picture.HasValue then
            exit;

        DataUri := 'data:image/';

        CalcFields(Picture);
        Picture.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream;
        CopyStream(MemoryStream, InStream);
        Image := Image.FromStream(MemoryStream);
        ImageFormat := Image.RawFormat;
        case true of
            ImageFormat.Equals(ImageFormat.Gif):
                DataUri += 'gif';
            ImageFormat.Equals(ImageFormat.Jpeg):
                DataUri += 'jpg';
            ImageFormat.Equals(ImageFormat.Png):
                DataUri += 'png';
        end;

        DataUri += ';base64,' + Convert.ToBase64String(MemoryStream.ToArray);
        exit(DataUri);
    end;

    procedure ReplacePicture(): Boolean
    var
        MagentoPicture: Record "NPR Magento Picture";
        MagentoPictureLink: Record "NPR Magento Picture Link";
    begin
    end;

    procedure "--- Aux"()
    begin
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure SelectPictureType() NewPictureType: Integer
    begin
        NewPictureType := StrMenu(Text004) - 1;
    end;

    procedure SetAutoOverwrite(NewAutoOverwrite: Boolean)
    begin
        AutoOverwrite := NewAutoOverwrite;
    end;

    procedure SetHidePicture(NewHidePicture: Boolean)
    begin
        HidePicture := NewHidePicture;
    end;

    procedure SetItemNo(ItemNo: Code[20])
    begin
        PictureType := Type::Item;
        PictureLinkNo := ItemNo;
    end;

    procedure SetItemGroupNo(ItemGroupNo: Code[20]; NewIsIconPicture: Boolean)
    begin
        PictureType := Type::"Item Group";
        PictureLinkNo := ItemGroupNo;
        IsIconPicture := NewIsIconPicture;
    end;

    procedure SetBrandCode(BrandCode: Code[20]; NewIsLogoPicture: Boolean)
    begin
        PictureType := Type::Brand;
        PictureLinkNo := BrandCode;
        IsLogoPicture := NewIsLogoPicture;
    end;

    local procedure SetPictureType(NewPictureType: Integer)
    begin
        PictureType := NewPictureType;
    end;

    procedure SetRecordPosition(PictureType: Integer; PictureName: Text)
    begin
        if Get(PictureType, PictureName) then;
    end;

    procedure SetVariantValueCode(NewVariantValueCode: Code[20])
    begin
        PictureLinkVariantValueCode := NewVariantValueCode;
    end;

    procedure SetVarietyFilters(NewVarietyTypeCode: Code[10]; NewVarietyTableCode: Code[40]; NewVarietyValueCode: Code[20])
    begin
        VarietyTypeCode := NewVarietyTypeCode;
        VarietyTableCode := NewVarietyTableCode;
        VarietyValueCode := NewVarietyValueCode;
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

    local procedure InitDataStream(Filename: Text; Filesize: Decimal)
    begin
        PictureName := Filename;
        PictureDataUri := '';
        PictureSize := Filesize;
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
        MemoryStream: DotNet NPRNetMemoryStream;
        RegEx: DotNet NPRNetRegex;
        Match: DotNet NPRNetMatch;
        Convert: DotNet NPRNetConvert;
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
            TempMagentoPicture."Size (kb)" := Round(PictureSize / 1000, 1);
            TempMagentoPicture.Picture.CreateOutStream(OutStr);
            CopyStream(OutStr, MemoryStream);
            TempMagentoPicture.Insert;
            MemoryStream.Dispose();
        end;
        PictureName := '';
    end;

    local procedure WriteDataStream(NewData: Text; Finalize: Boolean)
    begin
        PictureDataUri := PictureDataUri + Format(NewData);
    end;
}
