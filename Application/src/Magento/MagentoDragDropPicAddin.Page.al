page 6151451 "NPR Magento DragDropPic. Addin"
{
    Extensible = False;
    Caption = ' ';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR Magento Picture";

    layout
    {
        area(content)
        {
            usercontrol(DragDropAddin; "NPR DragDrop")
            {
                ApplicationArea = NPRRetail;

                trigger AddInReady();
                begin
                    ControlAddInReady := true;
                    CurrPage.DragDropAddin.SetCaption('drop-text', DragAndDropPictureLbl);
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
                    WriteDataStream(data);
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
        _PictureType := -1;
    end;

    trigger OnOpenPage()
    begin
        MagentoSetup.Get();
    end;

    var
        Base64Images: Dictionary of [Text, Text];
        MagentoSetup: Record "NPR Magento Setup";
        TempMagentoPicture: Record "NPR Magento Picture" temporary;
        MagentoPictureMgt: Codeunit "NPR Magento Picture Mgt.";
        ControlAddInReady: Boolean;
        AutoOverwrite: Boolean;
        HidePicture: Boolean;
        Initialized: Boolean;
        IsLogoPicture: Boolean;
        Overwrite: Boolean;
        PictureDataUri: Text;
        PicturesAlreadyExistLbl: Label '%1 pictures already exist:', Comment = '%1 = number of pictures';
        _PictureName: Text;
        PictureLinkNo: Code[20];
        PictureLinkVariantValueCode: Code[20];
        _PictureType: Integer;
        Text00101: Label '\  - %1';
        ConfirmOverwriteLbl: Label '\\Overwrite?';
        DragAndDropPictureLbl: Label 'DragAndDrop Picture';
        SelectPictureTypeLbl: Label '&Item,&Brand,Item &Group,&Customer';
        PictureNamesMustBeUniqueErr: Label 'Picture names must be unique. Please rename your pictures, so the same name does not occur!';
        PictureSize: Decimal;
        IsIconPicture: Boolean;
        VarietyTypeCode: Code[10];
        VarietyTableCode: Code[40];
        VarietyValueCode: Code[50];

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
        if TempMagentoPicture.FindSet() then
            repeat
                if MagentoPicture.Get(_PictureType, TempMagentoPicture.Name) then begin
                    ExistingCount += 1;
                    ConfirmText += StrSubstNo(Text00101, MagentoPicture.Name);
                end;
            until TempMagentoPicture.Next() = 0;

        if ExistingCount = 0 then
            exit(true);

        ConfirmText := StrSubstNo(PicturesAlreadyExistLbl, ExistingCount) + ConfirmText + ConfirmOverwriteLbl;
        exit(Confirm(ConfirmText));
    end;

    local procedure SavePictures()
    var
        MagentoPicture: Record "NPR Magento Picture";
        Skip: Boolean;
        Base64: Text;
    begin
        Clear(TempMagentoPicture);
        if (TempMagentoPicture.IsEmpty()) then
            exit;

        if _PictureType < 0 then
            _PictureType := SelectPictureType();
        if _PictureType < 0 then
            exit;

        Overwrite := ConfirmOverwrite();
        TempMagentoPicture.FindSet();
        repeat
            Skip := MagentoPicture.Get(_PictureType, TempMagentoPicture.Name) and not Overwrite;
            if not Skip then begin
                Base64Images.Get(TempMagentoPicture.Name, Base64);
                SavePicture(_PictureType, Base64, TempMagentoPicture);
                SavePictureLinks(_PictureType, TempMagentoPicture);
                Commit();
            end;
        until TempMagentoPicture.Next() = 0;
    end;

    local procedure SavePicture(PictureType: Integer; Base64: Text; var TempMagentoPicture2: Record "NPR Magento Picture" temporary)
    var
        MagentoPicture: Record "NPR Magento Picture";
    begin
        if MagentoPicture.Get(PictureType, TempMagentoPicture2.Name) then begin
            MagentoPicture."Size (kb)" := TempMagentoPicture."Size (kb)";
            MagentoPicture.Modify(true);
        end else begin
            MagentoPicture.Init();
            MagentoPicture := TempMagentoPicture2;
            MagentoPicture.Type := "NPR Magento Picture Type".FromInteger(PictureType);
            MagentoPicture.Insert(true);
        end;
        MagentoPictureMgt.DragDropPicture(MagentoPicture.Name, MagentoPicture.GetMagentoType(), Base64);
        Commit();
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
            TempMagentoPicture2.Type::Brand.AsInteger():
                begin
                    Brand.Get(PictureLinkNo);
                    if IsLogoPicture then
                        Brand."Logo Picture" := TempMagentoPicture2.Name
                    else
                        Brand.Picture := TempMagentoPicture2.Name;
                    Brand.Modify(true);
                    exit;
                end;
            TempMagentoPicture2.Type::"Item Group".AsInteger():
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
                if PictureType <> TempMagentoPicture2.Type::Item.AsInteger() then
                    exit;
        end;

        Clear(MagentoPictureLink);
        MagentoPictureLink.SetRange("Item No.", PictureLinkNo);
        if MagentoPictureLink.FindLast() then;
        LineNo := MagentoPictureLink."Line No." + 10000;

        Clear(MagentoPictureLink);
        MagentoPictureLink.SetRange("Item No.", PictureLinkNo);
        MagentoPictureLink.SetRange("Variety Type", VarietyTypeCode);
        MagentoPictureLink.SetRange("Variety Table", VarietyTableCode);
        MagentoPictureLink.SetRange("Variety Value", VarietyValueCode);
        MagentoPictureLink.SetRange("Picture Name", TempMagentoPicture2.Name);
        if (not MagentoPictureLink.IsEmpty()) then
            exit;

        LineNo += 10000;
        MagentoPictureLink.Init();
        MagentoPictureLink."Item No." := PictureLinkNo;
        MagentoPictureLink."Variety Type" := VarietyTypeCode;
        MagentoPictureLink."Variety Table" := VarietyTableCode;
        MagentoPictureLink."Variety Value" := VarietyValueCode;
        MagentoPictureLink."Line No." := LineNo;
        MagentoPictureLink."Picture Name" := TempMagentoPicture2.Name;
        MagentoPictureLink."Short Text" := TempMagentoPicture2.Name;
        MagentoPictureLink.Insert(true);
    end;

    internal procedure DisplayPicture()
    begin
        if not ControlAddInReady then
            exit;
        if HidePicture then begin
            CurrPage.DragDropAddin.DisplayData('');
            exit;
        end;

        CurrPage.DragDropAddin.DisplayData(Rec.GetMagentoUrl());
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure SelectPictureType() NewPictureType: Integer
    begin
        NewPictureType := StrMenu(SelectPictureTypeLbl) - 1;
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
        _PictureType := Rec.Type::Item.AsInteger();
        PictureLinkNo := ItemNo;
    end;

    procedure SetItemGroupNo(ItemGroupNo: Code[20]; NewIsIconPicture: Boolean)
    begin
        _PictureType := Rec.Type::"Item Group".AsInteger();
        PictureLinkNo := ItemGroupNo;
        IsIconPicture := NewIsIconPicture;
    end;

    procedure SetBrandCode(BrandCode: Code[20]; NewIsLogoPicture: Boolean)
    begin
        _PictureType := Rec.Type::Brand.AsInteger();
        PictureLinkNo := BrandCode;
        IsLogoPicture := NewIsLogoPicture;
    end;

    procedure SetRecordPosition(PictureType: Integer; PictureName: Text)
    begin
        if Rec.Get(PictureType, PictureName) then;
    end;

    [Obsolete('We are going to use field 60 "Variety Value" from the same table.', 'NPR24.0')]
    procedure SetVariantValueCode(NewVariantValueCode: Code[20])
    begin
#pragma warning disable AA0206
        PictureLinkVariantValueCode := NewVariantValueCode;
#pragma warning restore AA0206
    end;

    procedure SetVarietyFilters(NewVarietyTypeCode: Code[10]; NewVarietyTableCode: Code[40]; NewVarietyValueCode: Code[50])
    begin
        VarietyTypeCode := NewVarietyTypeCode;
        VarietyTableCode := NewVarietyTableCode;
        VarietyValueCode := NewVarietyValueCode;
    end;

    local procedure EndDataStream()
    var
        NpRegEx: Codeunit "NPR RegEx";
        Base64: Text;
    begin
        // We are done receiving data for each picture.
        if not Initialized then
            exit;

        Base64 := NpRegEx.ExtractMagentoPicture(PictureDataUri, _PictureName, PictureSize, _PictureType, TempMagentoPicture);
        Base64Images.Set(_PictureName, Base64);

        // Reset data for next picture.
        PictureDataUri := '';
        _PictureName := '';
        PictureSize := 0;
    end;

    internal procedure EndDataTransfer()
    begin
        // We are done receiving data for all pictures.
        _PictureName := '';
        PictureDataUri := '';
        PictureSize := 0;

        if not Initialized then begin
            TempMagentoPicture.DeleteAll();
            exit;
        end;

        if not TempMagentoPicture.FindSet() then begin
            Initialized := false;
            exit;
        end;

        SavePictures();
        TempMagentoPicture.DeleteAll();
        Initialized := false;
    end;

    local procedure InitDataStream(Filename: Text; Filesize: Decimal)
    begin
        // We are initiating a new stream of data of a picture.
        if (TempMagentoPicture.Get(_PictureType, Filename)) then
            Error(PictureNamesMustBeUniqueErr);

        _PictureName := Filename;
        PictureDataUri := '';
        PictureSize := Filesize;
    end;

    internal procedure InitDataTransfer()
    begin
        // We are initiating a new transfer of a batch of pictures.
        _PictureName := '';
        PictureDataUri := '';
        TempMagentoPicture.DeleteAll();
        Initialized := true;
    end;

    local procedure WriteDataStream(NewData: Text)
    begin
        // Write more data to the existing data we received.
        PictureDataUri := PictureDataUri + Format(NewData);
    end;
}
