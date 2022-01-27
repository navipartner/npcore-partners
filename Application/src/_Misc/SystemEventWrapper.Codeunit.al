codeunit 6014427 "NPR System Event Wrapper"
{
    Access = Internal;
    procedure MakeDateFilter(var DateFilterText: Text)
    var
        FilterTokens: Codeunit "Filter Tokens";
    begin
        FilterTokens.MakeDateFilter(DateFilterText);
    end;

    procedure ApplicationVersion() ApplicationVersion: Text[248]
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        exit(ApplicationSystemConstants.ApplicationVersion());
    end;

    procedure ApplicationBuild(): Text[80]
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        exit(ApplicationSystemConstants.ApplicationBuild());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCompanyClose()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCompanyClose()
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterCaptionClassTranslate(Language: Integer; CaptionExpression: Text[1024]; var Caption: Text[1024])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindPrinter(ReportID: Integer; var PrinterName: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnDatabaseInsert(RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnDatabaseModify(RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnDatabaseDelete(RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetApplicationVersion(var AppVersion: Text[80])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeCompanyClose', '', true, true)]
    local procedure LogInManagementOnBeforeCompanyClose()
    begin
        OnBeforeCompanyClose();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterCompanyClose', '', true, true)]
    local procedure LogInManagementOnAfterCompanyClose()
    begin
        OnAfterCompanyClose();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnAfterCaptionClassResolve', '', true, true)]
    local procedure CaptionClassOnAfterCaptionClassTranslate(Language: Integer; CaptionExpression: Text; var Caption: Text[1024])
    begin
        OnAfterCaptionClassTranslate(Language, CopyStr(CaptionExpression, 1, 1024), Caption);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterGetPrinterName', '', true, true)]
    local procedure ReportManagementOnAfterFindPrinter(ReportID: Integer; var PrinterName: Text[250])
    begin
        OnAfterFindPrinter(ReportID, PrinterName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterGetDatabaseTableTriggerSetup', '', true, true)]
    local procedure GlobalTriggerManagementOnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
        OnAfterGetDatabaseTableTriggerSetup(TableId, OnDatabaseInsert, OnDatabaseModify, OnDatabaseDelete, OnDatabaseRename);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseInsert', '', true, true)]
    local procedure GlobalTriggerManagementOnAfterOnDatabaseInsert(RecRef: RecordRef)
    begin
        OnAfterOnDatabaseInsert(RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseModify', '', true, true)]
    local procedure GlobalTriggerManagementOnAfterOnDatabaseModify(RecRef: RecordRef)
    begin
        OnAfterOnDatabaseModify(RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseDelete', '', true, true)]
    local procedure GlobalTriggerManagementOnAfterOnDatabaseDelete(RecRef: RecordRef)
    begin
        OnAfterOnDatabaseDelete(RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnAfterOnDatabaseRename', '', true, true)]
    local procedure GlobalTriggerManagementOnAfterOnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef)
    begin
        OnAfterOnDatabaseRename(RecRef, xRecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application System Constants", 'OnAfterGetApplicationVersion', '', true, true)]
    local procedure ApplicationSystemConstantsOnAfterGetApplicationVersion(var ApplicationVersion: Text[248])
    begin
        OnAfterGetApplicationVersion(ApplicationVersion);
    end;
}

