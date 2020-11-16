codeunit 6059922 "NPR Contact Subscribers"
{
    [EventSubscriber(ObjectType::Page, Page::"Contact Picture", 'OnAfterActionEvent', 'ImportPicture', false, false)]
    local procedure ProcessPicture_OnAfterImportPicture(var Rec: Record Contact)
    var
        FacialRecognitionSetup: Record "NPR Facial Recogn. Setup";
        FacialRecognitionDetect: Codeunit "NPR Detect Face";
        FacialRecognitionPersonGroup: Codeunit "NPR Create Person Group";
        FacialRecognitionPerson: Codeunit "NPR Create Person";
        FacialRecognitionPersonFace: Codeunit "NPR Add Person Face";
        FacialRecognitionTrainPersonGroup: Codeunit "NPR Train Person Group";
        ImageFilePath: Text;
        EntryNo: Integer;
        CalledFrom: Option Contact,Member;
    begin
        if not Rec.Image.HasValue then
            exit;

        if not FacialRecognitionSetup.FindFirst() then
            exit;

        if Rec."Name" = '' then
            exit;

        FacialRecognitionPersonGroup.CreatePersonGroup(Rec, true);

        FacialRecognitionPerson.CreatePerson(Rec, true);

        FacialRecognitionDetect.DetectFace(Rec, ImageFilePath, EntryNo, true, CalledFrom::Contact);

        if EntryNo = 0 then
            exit;

        if FacialRecognitionPersonFace.AddPersonFace(Rec, ImageFilePath, EntryNo) then
            FacialRecognitionTrainPersonGroup.TrainPersonGroup(Rec, true);
    end;
}