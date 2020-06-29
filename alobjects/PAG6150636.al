page 6150636 "POS View Profile Card"
{
    // NPR5.49/TJ  /20190201 CASE 335739 New object

    Caption = 'POS View Profile Card';
    PageType = Card;
    SourceTable = "POS View Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                }
                field(Control6014403; Picture)
                {
                    ShowCaption = false;
                }
                field("POS Theme Code"; "POS Theme Code")
                {
                }
                field("Line Order on Screen"; "Line Order on Screen")
                {
                }
            }
            group("Number and Date Formatting")
            {
                field("Client Formatting Culture ID"; "Client Formatting Culture ID")
                {
                }
                field("Client Decimal Separator"; "Client Decimal Separator")
                {
                }
                field("Client Thousands Separator"; "Client Thousands Separator")
                {
                }
                field("Client Date Separator"; "Client Date Separator")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action(DetectSeparators)
                {
                    Caption = 'Detect Decimal and Thousands Separators';
                    Image = SuggestNumber;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //-NPR4.14
                        DetectDecimalThousandsSeparator();
                        CurrPage.Update(true);
                        //+NPR4.14
                    end;
                }
            }
            group(Picture)
            {
                Caption = 'Picture';
                action(Import)
                {
                    Caption = 'Import';
                    Image = Import;

                    trigger OnAction()
                    var
                        PicConfirmReplace: Label 'Replace the existing picture?';
                        PictureExists: Boolean;
                        FileMgt: Codeunit "File Management";
                        Name: Text[250];
                        TempBlob: Codeunit "Temp Blob";
                        TextName: Text[200];
                        RecRef: RecordRef;
                    begin
                        PictureExists := Picture.HasValue;

                        Clear(TempBlob);
                        Name := FileMgt.BLOBImport(TempBlob, TextName);

                        RecRef.GetTable(Rec);
                        TempBlob.ToRecordRef(RecRef, FieldNo(Picture));
                        RecRef.SetTable(Rec);

                        if Name = '' then
                            exit;
                        if PictureExists then
                            if not Confirm(PicConfirmReplace, false) then
                                exit;

                        CurrPage.SaveRecord;
                    end;
                }
                action(Export)
                {
                    Caption = 'Export';
                    Image = Export;

                    trigger OnAction()
                    var
                        FileMgt: Codeunit "File Management";
                        TempBlob: Codeunit "Temp Blob";
                    begin
                        if Picture.HasValue then begin
                            CalcFields(Picture);
                            TempBlob.FromRecord(Rec, FieldNo(Picture));
                            FileMgt.BLOBExport(TempBlob, '*.bmp', true);
                        end;
                    end;
                }
                action(Delete)
                {
                    Caption = 'Delete';
                    Image = Delete;

                    trigger OnAction()
                    var
                        PicConfDelete: Label 'Delete the picture?';
                    begin
                        if Picture.HasValue then
                            if Confirm(PicConfDelete, false) then begin
                                Clear(Picture);
                                CurrPage.SaveRecord;
                            end;
                    end;
                }
            }
        }
    }
}

