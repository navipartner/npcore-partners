codeunit 6059922 "NPR Contact Subscribers"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Refractored to old code MCS Face Recognition';
    EventSubscriberInstance = Manual;
    [EventSubscriber(ObjectType::Page, Page::"Contact Picture", 'OnAfterActionEvent', 'ImportPicture', false, false)]
    local procedure ProcessPicture_OnAfterImportPicture(var Rec: Record Contact)
    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        FacialRecognitionDetect: Codeunit "NPR Detect Face";
        FacialRecognitionPersonGroup: Codeunit "NPR Create Person Group";
        FacialRecognitionPerson: Codeunit "NPR Create Person";
        FacialRecognitionPersonFace: Codeunit "NPR Add Person Face";
        FacialRecognitionTrainPersonGroup: Codeunit "NPR Train Person Group";
        ImageStream: InStream;
        EntryNo: Integer;
        CalledFrom: Option Contact,Member;
        IsError: Boolean;
        ErrorMessage: Text;
    begin
        if not Rec.Image.HasValue then
            exit;

        if not FacialRecognitionSetup.Get() then
            exit;

        if Rec."Name" = '' then
            exit;

        FacialRecognitionPersonGroup.CreatePersonGroup(Rec, true);

        FacialRecognitionPerson.CreatePerson(Rec, true);

        FacialRecognitionDetect.DetectFace(Rec, ImageStream, EntryNo, true, CalledFrom::Contact, IsError, ErrorMessage);

        if IsError then begin
            Message(ErrorMessage);
            exit;
        end;


        if FacialRecognitionPersonFace.AddPersonFace(Rec, ImageStream, EntryNo) then
            FacialRecognitionTrainPersonGroup.TrainPersonGroup(Rec, true);
    end;
}