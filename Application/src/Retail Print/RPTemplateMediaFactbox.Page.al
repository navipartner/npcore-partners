﻿page 6014629 "NPR RP Template Media Factbox"
{
    Extensible = False;
    Caption = 'Template Media Factbox';
    Editable = false;
    InsertAllowed = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR RP Template Media Info";

    layout
    {
        area(content)
        {
            field(URL; Rec.URL)
            {

                ExtendedDatatype = URL;
                ToolTip = 'Specifies the url of the Template Media Factbox';
                ApplicationArea = NPRRetail;
            }
            field(Description; Rec.Description)
            {
                ToolTip = 'Specifies the description of the Template Media Factbox';
                ApplicationArea = NPRRetail;
            }
            field(Picture; Rec.Image)
            {

                ShowCaption = false;
                ToolTip = 'Specifies the picture that has been inserted for the item.';
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
                begin
                    if Rec.Image.HasValue() then
                        if not Confirm(OverrideImageQst) then
                            exit;

                    FileName := FileManagement.BLOBImport(TempBlob, '');
                    if FileName = '' then
                        exit;

                    Clear(Rec.Image);
                    TempBlob.CreateInStream(InStr);
                    Rec.Image.ImportStream(InStr, FileName);
                    Rec.Modify(true);
                end;
            }
            action(ExportPicture)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Export';
                Enabled = DeleteExportEnabled;
                Image = Export;
                ToolTip = 'Export the picture to a file.';

                trigger OnAction()
                var
                    TenantMedia: Record "Tenant Media";
                    FileManagement: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                    ToFile: Text;
                begin
                    Rec.GetImageContent(TenantMedia);
                    ToFile := TenantMedia."File Name";
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
        DeleteExportEnabled: Boolean;

    local procedure SetEditableOnPictureActions()
    begin
        DeleteExportEnabled := Rec.Image.HasValue();
    end;
}

