page 6014567 "NPR Retail Logo Factbox"
{
    Extensible = False;
    Caption = 'Retail Logo Factbox';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR Retail Logo";

    layout
    {
        area(content)
        {
            field(Width; Rec.Width)
            {

                ToolTip = 'Specifies the value of the Width field';
                ApplicationArea = NPRRetail;
            }
            field(Height; Rec.Height)
            {

                ToolTip = 'Specifies the value of the Height field';
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
                    if Rec."POS Logo".HasValue() then
                        if not Confirm(OverrideImageQst) then
                            exit;

                    FileName := FileManagement.BLOBImport(TempBlob, '');
                    if FileName = '' then
                        exit;

                    Clear(Rec."POS Logo");
                    TempBlob.CreateInStream(InStr);
                    Rec."POS Logo".ImportStream(InStr, FileName);
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
                    Rec."POS Logo".ExportStream(OutStr);
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

                    Clear(Rec."POS Logo");
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
        DeleteExportEnabled := Rec."POS Logo".HasValue();
    end;
}

