﻿codeunit 6059941 "NPR NaviDocs Handl. Prof. Tmpl"
{
    Access = Internal;

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

    procedure AddToNaviDocs(RecordVariant: Variant; Recepient: Text[80]; ReportID: Integer; DelayUntil: DateTime)
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        RecRef: RecordRef;
    begin
        if NaviDocsHandlingProfileCode() <> '' then begin
            DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
            NaviDocsManagement.AddDocumentEntryWithHandlingProfile(RecRef, NaviDocsHandlingProfileCode(), ReportID, Recepient, DelayUntil);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDoHandleNaviDocs(RecordVariant: Variant; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NaviDocs Management", 'OnAddHandlingProfilesToLibrary', '', true, true)]
    local procedure AddNaviDocsHandlingProfile()
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
    begin
        if NaviDocsHandlingProfileCode() <> '' then
            NaviDocsManagement.AddHandlingProfileToLibrary(NaviDocsHandlingProfileCode(), NaviDocsHandlingProfileTxt, false, false, false, false);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NaviDocs Management", 'OnManageDocument', '', false, false)]
    local procedure HandleNaviDocsDocument(var IsDocumentHandled: Boolean; ProfileCode: Code[20]; var NaviDocsEntry: Record "NPR NaviDocs Entry"; ReportID: Integer; var WithSuccess: Boolean; var ErrorMessage: Text)
    var
        RecRef: RecordRef;
    begin
        if IsDocumentHandled or (ProfileCode <> NaviDocsHandlingProfileCode()) then
            exit;

        if RecRef.Get(NaviDocsEntry."Record ID") then;

        if not DoHandleNaviDocs(RecRef) then
            ErrorMessage := 'Something went wrong';

        IsDocumentHandled := true;
        WithSuccess := ErrorMessage = '';
    end;

    local procedure NaviDocsHandlingProfileCode(): Code[20]
    begin
        //Let function return the HandlingProfileCode
        exit('');
    end;
}

