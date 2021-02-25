page 6150636 "NPR POS View Profile Card"
{
    Caption = 'POS View Profile Card';
    PageType = Card;
    SourceTable = "NPR POS View Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Control6014403; Rec.Picture)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("POS Theme Code"; Rec."POS Theme Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Theme Code field';
                }
                field("Line Order on Screen"; Rec."Line Order on Screen")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                }
                field("Initial Sales View"; Rec."Initial Sales View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial Sales View field';
                }
                field("After End-of-Sale View"; Rec."After End-of-Sale View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the After End-of-Sale View field';
                }
                field("POS - Show discount fields"; "POS - Show discount fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Discount field';
                }
                field("Lock Timeout"; "Lock Timeout")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lock Timeout field';
                }
            }
            group("Number and Date Formatting")
            {
                field("Client Formatting Culture ID"; Rec."Client Formatting Culture ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Formatting Culture ID field';
                }
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Decimal Separator field';
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Thousands Separator field';
                }
                field("Client Date Separator"; Rec."Client Date Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Date Separator field';
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
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Detect Decimal and Thousands Separators action';

                    trigger OnAction()
                    begin
                        Rec.DetectDecimalThousandsSeparator();
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
                    ToolTip = 'Executes the Import action';

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
                        PictureExists := Rec.Picture.HasValue;

                        Clear(TempBlob);
                        Name := FileMgt.BLOBImport(TempBlob, TextName);

                        RecRef.GetTable(Rec);
                        TempBlob.ToRecordRef(RecRef, Rec.FieldNo(Picture));
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
                    ToolTip = 'Executes the Export action';

                    trigger OnAction()
                    var
                        FileMgt: Codeunit "File Management";
                        TempBlob: Codeunit "Temp Blob";
                    begin
                        if Rec.Picture.HasValue then begin
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
                        if Rec.Picture.HasValue then
                            if Confirm(PicConfDelete, false) then begin
                                Clear(Rec.Picture);
                                CurrPage.SaveRecord;
                            end;
                    end;
                }
            }
        }
    }
}
