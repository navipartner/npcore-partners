page 6151308 "NPR MM Member Picture"
{
    Caption = 'MM Member Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "NPR MM Member";

    layout
    {
        area(content)
        {
            // field(Picture; Rec.Image)
            field(Picture; Rec.Picture)
            {
                ApplicationArea = Basic, Suite, Invoicing;
                ShowCaption = false;
                ToolTip = 'Specifies the picture that has been inserted for the item.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportPicture)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture file.';

                trigger OnAction()
                var
                    FileManagement: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    OuStr: OutStream;
                    InStr: InStream;
                    FileName: Text;
                begin
                    // if Rec.Image.HasValue() then
                    if Rec.Picture.HasValue() then
                        if not Confirm(OverrideImageQst) then
                            exit;

                    FileName := FileManagement.BLOBImport(TempBlob, '');
                    if FileName = '' then
                        exit;

                    // Clear(Rec.Image);
                    // Rec.Image.ImportStream(InStr, FileName);
                    Clear(Rec.Picture);
                    TempBlob.CreateInStream(InStr);
                    Rec.Picture.CreateOutStream(OuStr);
                    CopyStream(OuStr, InStr);
                    Rec.Modify(true);
                end;
            }
            // action(ExportPicture)
            // {
            //     ApplicationArea = Basic, Suite;
            //     Caption = 'Export';
            //     Enabled = DeleteExportEnabled;
            //     Image = Export;
            //     ToolTip = 'Export the picture to a file.';

            //     trigger OnAction()
            //     var
            //         TenantMedia: Record "Tenant Media";
            //         FileManagement: Codeunit "File Management";
            //         TempBlob: Codeunit "Temp Blob";
            //         OutStr: OutStream;
            //         ToFile: Text;
            //     begin
            //         Rec.GetImageContent(TenantMedia);
            //         ToFile := TenantMedia."File Name";
            //         TempBlob.CreateOutStream(OutStr);
            //         Rec.Image.ExportStream(OutStr);
            //         FileManagement.BLOBExport(TempBlob, ToFile, true);
            //     end;
            // }
            action(DeletePicture)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delete';
                Enabled = DeleteExportEnabled;
                Image = Delete;
                ToolTip = 'Delete the record.';

                trigger OnAction()
                begin
                    if not Confirm(DeleteImageQst) then
                        exit;

                    // Clear(Rec.Image);
                    Clear(Rec.Picture);
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
        DeleteExportEnabled: Boolean;

    local procedure SetEditableOnPictureActions()
    begin
        // DeleteExportEnabled := Rec.Image.HasValue();
        DeleteExportEnabled := Rec.Picture.HasValue();
    end;
}

