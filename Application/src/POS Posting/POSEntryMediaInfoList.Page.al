page 6059873 "NPR POS Entry Media Info List"
{
    Caption = 'POS Entry Media Info List';
    PageType = List;
    SourceTable = "NPR POS Entry Media Info";
    PopulateAllFields = true;
    InsertAllowed = false;
    Extensible = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Image; format(Rec.Image.HasValue))
                {
                    Caption = 'Image Added';
                    ToolTip = 'Specifies the value of the Image field.';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {
                    ToolTip = 'Specifies the value of the Comment field.';
                    ApplicationArea = NPRRetail;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(ViewImage; "NPR POSEntryMediaImageFactBox")
            {
                Caption = 'Image';
                Editable = false;
                SubPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddNew)
            {
                Caption = 'Add New (Import Image)';
                Image = NewDepreciationBook;
                ToolTip = 'Add new entry with image related to POS Entry imported from files';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = New;
                PromotedOnly = true;

                trigger OnAction()
                var
                    EntryNo: Integer;
                begin
                    if Evaluate(EntryNo, Rec.GetFilter("Pos Entry No.")) then;
                    Rec.CreateNewEntry2(EntryNo, 0, false);
                    CurrPage.Update();
                end;
            }
            action(TakePictere)
            {
                Caption = 'Add New (Take Picture)';
                Image = Camera;
                ToolTip = 'Add new entry with image related to POS Entry added using camera';
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = New;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    EntryNo: Integer;
                begin
                    if Evaluate(EntryNo, Rec.GetFilter("Pos Entry No.")) then;
                    Rec.CreateNewEntry2(EntryNo, 1, false);
                    CurrPage.Update();
                end;
            }


            action(SaveToDisc)
            {
                Caption = 'Save Image';
                ToolTip = 'Executes the Save Image action';
                Image = Save;
                ApplicationArea = NPRRetail;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    FileManagement: Codeunit "File Management";
                    FilePath: Text[1024];
                    FileBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                begin
                    if Rec."Image".HasValue() then begin
                        FilePath := 'POS_Entry_' + format(Rec."Pos Entry No.") + '.png';
                        FileBlob.CreateOutStream(OutStr);
                        Rec.Image.ExportStream(OutStr);
                        FileManagement.BLOBExport(FileBlob, FilePath, true);
                    end;
                end;
            }
        }
    }
}