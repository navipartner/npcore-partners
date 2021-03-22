codeunit 6059941 "NPR NaviDocs Handl. Prof. Tmpl"
{
    var
        NaviDocsHandlingProfileTxt: Label 'Add Description here';
        DataTypeManagement: Codeunit "Data Type Management";

    procedure DoHandleNaviDocs(RecordVariant: Variant): Boolean
    var
        Handled: Boolean;
    begin
        OnDoHandleNaviDocs(RecordVariant, Handled);
        exit(Handled);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDoHandleNaviDocs(RecordVariant: Variant; var Handled: Boolean)
    begin
    end;

    procedure AddToNaviDocs(RecordVariant: Variant; Recepient: Text; ReportID: Integer; DelayUntil: DateTime)
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        RecRef: RecordRef;
    begin
        if NaviDocsHandlingProfileCode <> '' then begin
            DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
            NaviDocsManagement.AddDocumentEntryWithHandlingProfile(RecRef, NaviDocsHandlingProfileCode, ReportID, Recepient, DelayUntil);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NaviDocs Management", 'OnAddHandlingProfilesToLibrary', '', true, true)]
    local procedure AddNaviDocsHandlingProfile()
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
    begin
        if NaviDocsHandlingProfileCode <> '' then
            NaviDocsManagement.AddHandlingProfileToLibrary(NaviDocsHandlingProfileCode, NaviDocsHandlingProfileTxt, false, false, false, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NaviDocs Management", 'OnShowTemplate', '', false, false)]
    local procedure ShowTemplateFromNaviDocs(var RequestHandled: Boolean; NaviDocsEntry: Record "NPR NaviDocs Entry")
    var
        RecRef: RecordRef;
    begin
        if RequestHandled or (NaviDocsEntry."Document Handling Profile" <> NaviDocsHandlingProfileCode) then
            exit;
        RequestHandled := true;

        if not RecRef.Get(NaviDocsEntry."Record ID") then
            exit;

        // Add code to Show the template here
        Message('Showing the Template');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NaviDocs Management", 'OnManageDocument', '', false, false)]
    local procedure HandleNaviDocsDocument(var IsDocumentHandled: Boolean; ProfileCode: Code[20]; var NaviDocsEntry: Record "NPR NaviDocs Entry"; ReportID: Integer; var WithSuccess: Boolean; var ErrorMessage: Text)
    var
        RecRef: RecordRef;
    begin
        if IsDocumentHandled or (ProfileCode <> NaviDocsHandlingProfileCode) then
            exit;

        if RecRef.Get(NaviDocsEntry."Record ID") then;

        if not DoHandleNaviDocs(RecRef) then
            ErrorMessage := 'Something went wrong';

        IsDocumentHandled := true;
        WithSuccess := ErrorMessage = '';
    end;

    local procedure NaviDocsHandlingProfileCode(): Text
    begin
        //Let function return the HandlingProfileCode
        exit('');
    end;
}

