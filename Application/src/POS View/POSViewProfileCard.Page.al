page 6150636 "NPR POS View Profile Card"
{
    Caption = 'POS View Profile Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR POS View Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Control6014403; Picture)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field("POS Theme Code"; "POS Theme Code")
                {
                    ApplicationArea = All;
                }
                field("Line Order on Screen"; "Line Order on Screen")
                {
                    ApplicationArea = All;
                }
                field("Initial Sales View"; "Initial Sales View")
                {
                    ApplicationArea = All;
                }
                field("After End-of-Sale View"; "After End-of-Sale View")
                {
                    ApplicationArea = All;
                }
            }
            group("Number and Date Formatting")
            {
                field("Client Formatting Culture ID"; "Client Formatting Culture ID")
                {
                    ApplicationArea = All;
                }
                field("Client Decimal Separator"; "Client Decimal Separator")
                {
                    ApplicationArea = All;
                }
                field("Client Thousands Separator"; "Client Thousands Separator")
                {
                    ApplicationArea = All;
                }
                field("Client Date Separator"; "Client Date Separator")
                {
                    ApplicationArea = All;
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
                    ApplicationArea = All;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        DetectDecimalThousandsSeparator();
                        CurrPage.Update(true);
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
                    ApplicationArea = All;

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
                    ApplicationArea = All;

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
                action("Delete")
                {
                    Caption = 'Delete';
                    Image = Delete;
                    ApplicationArea = All;

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
