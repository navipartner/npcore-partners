codeunit 6059924 "NPR Image Mgt."
{
    procedure UpdateRecordImage(No: Code[20]; CalledFrom: Option Contact,Member; ImageFilePath: Text)
    var
        Contact: Record Contact;
        Member: Record "NPR MM Member";
        RecRef: RecordRef;
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        IStr: InStream;
        OStr: OutStream;
    begin
        FileMgt.BLOBImportFromServerFile(TempBlob, ImageFilePath);

        case CalledFrom of
            CalledFrom::Contact:
                begin
                    TempBlob.CreateInStream(IStr);
                    Contact.Get(No);
                    Contact.Image.ImportStream(IStr, 'Facial Recognition');
                    Contact.Modify();
                end;
            CalledFrom::Member:
                begin
                    Member.SetRange("External Member No.", No);
                    if Member.FindFirst() then begin
                        RecRef.GetTable(Member);
                        TempBlob.ToRecordRef(RecRef, Member.FieldNo(Picture));
                        RecRef.Modify();
                    end;
                end;
        end;
    end;
}