codeunit 6059924 "NPR Face Image Mgt."
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Refractored to old code MCS Face Recognition';
    procedure UploadAndCheckImage(var ImageInStream: InStream; var ErrorMessage: Text) IsError: Boolean
    var
        FileExtension: Text;
        ReturnedFilePath: Text;
        SelectImage: Label 'Select image';
        ImageFileFilter: Label 'Image Files (*.gif;*.png;*.jpg;*.jpeg;*.bmp)|*.gif;*.png;*.jpg;*.jpeg;*.bmp';
        ImageHelpers: Codeunit "Image Helpers";
        ImgCantBeProcessed: Label 'Media not supported \ \Image can''t be processed. \Please use .gif .png .jpg .jpeg or .bmp images .';
    begin
        if not UploadIntoStream(SelectImage, '', ImageFileFilter, ReturnedFilePath, ImageInStream) then
            exit;

        FileExtension := ImageHelpers.GetImageType(ImageInStream);

        if not (LowerCase(FileExtension) in ['gif', 'jpg', 'jpeg', 'png', 'bmp']) then begin
            IsError := true;
            ErrorMessage := ImgCantBeProcessed;
            exit;
        end;
    end;

    procedure UpdateRecordImage(No: Code[20]; CalledFrom: Option Contact,Member; IStr: InStream)
    var
        Contact: Record Contact;
        Member: Record "NPR MM Member";
        RecRef: RecordRef;
        OStr: OutStream;
    begin

        case CalledFrom of
            CalledFrom::Contact:
                begin
                    Contact.Get(No);
                    Contact.Image.ImportStream(IStr, 'Facial Recognition');
                    Contact.Modify();
                end;
            CalledFrom::Member:
                begin
                    Member.SetRange("External Member No.", No);
                    if Member.FindFirst() then begin
                        Member.Picture.CreateOutStream(OStr);
                        CopyStream(OStr, IStr);
                    end;
                end;
        end;
    end;
}