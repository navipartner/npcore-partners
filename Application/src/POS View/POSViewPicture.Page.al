page 6014406 "NPR POS View Picture"
{
    Caption = 'POS View Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "NPR POS View Profile";

    layout
    {
        area(Content)
        {
            field(Control6014403; Rec.Picture)
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the value of the Picture field';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Import)
            {
                Caption = 'Import';
                Image = Import;
                ApplicationArea = All;
                ToolTip = 'Executes the Import action';

                trigger OnAction()
                var
                    PicConfirmReplace: Label 'Replace the existing picture?';
                    PicTooBig: Label 'The picture is too big, please choose another one that is less than 150 kB.';
                    PictureExists: Boolean;
                    FileMgt: Codeunit "File Management";
                    Name: Text[250];
                    TempBlob: Codeunit "Temp Blob";
                    TextName: Text[200];
                    RecRef: RecordRef;
                    Size: Integer;
                begin
                    PictureExists := Rec.Picture.HasValue;

                    Clear(TempBlob);
                    Name := FileMgt.BLOBImport(TempBlob, TextName);

                    if Name = '' then
                        exit;
                    if PictureExists then
                        if not Confirm(PicConfirmReplace, false) then
                            exit;


                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo(Picture));
                    RecRef.SetTable(Rec);


                    Size := TempBlob.Length();
                    if Size > 150000 then
                        Error(PicTooBig);





                    CurrPage.SaveRecord;
                end;
            }
            action(Export)
            {
                Caption = 'Export';
                Image = Export;
                ApplicationArea = All;
                ToolTip = 'Executes the Export action';

                trigger OnAction()
                var
                    FileMgt: Codeunit "File Management";
                    TempBlob: Codeunit "Temp Blob";
                begin
                    if Rec.Picture.HasValue() then begin
                        Rec.CalcFields(Picture);
                        TempBlob.FromRecord(Rec, Rec.FieldNo(Picture));
                        FileMgt.BLOBExport(TempBlob, '*.bmp', true);
                    end;
                end;
            }
            action("Delete")
            {
                Caption = 'Delete';
                Image = Delete;
                ApplicationArea = All;
                ToolTip = 'Executes the Delete action';

                trigger OnAction()
                var
                    PicConfDelete: Label 'Delete the picture?';
                begin
                    if Rec.Picture.HasValue() then
                        if Confirm(PicConfDelete, false) then begin
                            Clear(Rec.Picture);
                            CurrPage.SaveRecord;
                        end;
                end;
            }
        }
    }
}