page 6014406 "NPR POS View Picture"
{
    Extensible = False;
    Caption = 'POS View Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "NPR POS View Profile";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field(Image; Rec.Image)
            {

                ShowCaption = false;
                ToolTip = 'Specifies the value of the Picture field';
                ApplicationArea = NPRRetail;
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
                ToolTip = 'Import a picture file.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    FileManagement: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    InStr: InStream;
                    FileName: Text;
                    MimeTypeLbl: Label 'image/%1', Locked = true;
                begin
                    Rec.TestField(Code);

                    if Rec.Image.HasValue() then
                        if not Confirm(OverrideImageQst) then
                            exit;

                    FileName := FileManagement.BLOBImport(TempBlob, '');
                    if FileName = '' then
                        exit;

                    if TempBlob.Length() > 150000 then
                        Error(PicTooBigErr);

                    Clear(Rec.Image);
                    TempBlob.CreateInStream(InStr);
                    Rec.Image.ImportStream(InStr, FileManagement.GetFileNameWithoutExtension(FileName), StrSubstNo(MimeTypeLbl, Rec.GetDefaultExtension()));
                    Rec.Modify(true);
                end;
            }
            action(ExportPicture)
            {

                Caption = 'Export';
                Enabled = DeleteExportEnabled;
                Image = Export;
                ToolTip = 'Export the picture to a file.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    FileManagement: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                    ToFile: Text;
                begin
                    Rec.TestField(Code);

                    ToFile := Rec.GetDefaultMediaDescription();
                    TempBlob.CreateOutStream(OutStr);
                    Rec.Image.ExportStream(OutStr);
                    FileManagement.BLOBExport(TempBlob, ToFile, true);
                end;
            }
            action(DeletePicture)
            {

                Caption = 'Delete';
                Enabled = DeleteExportEnabled;
                Image = Delete;
                ToolTip = 'Delete the record.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.TestField(Code);

                    if not Confirm(DeleteImageQst) then
                        exit;

                    Clear(Rec.Image);
                    Rec.Modify(true);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions();
    end;

    var
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        PicTooBigErr: Label 'The picture is too big, please choose another one that is less than 150 KB.';
        DeleteExportEnabled: Boolean;

    local procedure SetEditableOnPictureActions()
    begin
        DeleteExportEnabled := Rec.Image.HasValue();
    end;
}
