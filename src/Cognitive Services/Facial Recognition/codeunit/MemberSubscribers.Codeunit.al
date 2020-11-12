codeunit 6059923 "NPR Member Subscribers"
{
    [EventSubscriber(ObjectType::Page, Page::"NPR MM Member Card", 'OnAfterActionEvent', 'Take Picture', false, false)]
    local procedure ProcessPicture_OnAfterTaketPicture(var Rec: Record "NPR MM Member")
    begin
        ProcessPicture(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR MM Member Card", 'OnAfterActionEvent', 'Import Picture', false, false)]
    local procedure ProcessPicture_OnAfterImportPicture(var Rec: Record "NPR MM Member")
    begin
        ProcessPicture(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR MM Member Card", 'OnAfterValidateEvent', 'Picture', false, false)]
    local procedure ProcessPicture_OnAfterValidatePicture(var Rec: Record "NPR MM Member")
    begin
        ProcessPicture(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterMemberCreateEvent', '', false, false)]
    local procedure ProcessPicture_OnAfterCreateMember(var Member: Record "NPR MM Member")
    var
        Member2: Record "NPR MM Member";
    begin
        Member2.Get(Member."Entry No.");
        ProcessPicture(Member2);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR MM Member Info Capture", 'OnAfterActionEvent', 'Take Picture ', false, false)]
    local procedure ProcessPicture_OnAfterTaketPicture2(var Rec: Record "NPR MM Member Info Capture")
    var
        Member: Record "NPR MM Member";
    begin
        if Member.Get(Rec."Member Entry No") then
            ProcessPicture(Member);
    end;

    local procedure ProcessPicture(var Rec: Record "NPR MM Member")
    var
        Contact: Record Contact;
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
        if not Rec.Picture.HasValue then
            exit;

        if not FacialRecognitionSetup.FindFirst() then
            exit;

        if not Contact.Get(Rec."Contact No.") then
            exit;

        if Contact."Name" = '' then
            exit;

        FacialRecognitionPersonGroup.CreatePersonGroup(Contact, true);

        FacialRecognitionPerson.CreatePerson(Contact, true);

        FacialRecognitionDetect.DetectFace(Contact, ImageFilePath, EntryNo, true, CalledFrom::Member);

        if EntryNo = 0 then
            exit;

        if FacialRecognitionPersonFace.AddPersonFace(Contact, ImageFilePath, EntryNo) then
            FacialRecognitionTrainPersonGroup.TrainPersonGroup(Contact, true);
    end;
}