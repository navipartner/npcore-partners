page 6059897 "NPR Data Log Setup"
{
    Extensible = False;
    Caption = 'Data Log Setup';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Manage,Process,Data Log';
    SourceTable = "NPR Data Log Setup (Table)";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Table Name");
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObjectsWithCaption: Record AllObjWithCaption;
                    begin
                        AllObjectsWithCaption.FilterGroup(2);
                        AllObjectsWithCaption.SetRange("Object Type", AllObjectsWithCaption."Object Type"::Table);
                        AllObjectsWithCaption.FilterGroup(0);
                        if Page.RunModal(Page::"All Objects with Caption", AllObjectsWithCaption) = Action::LookupOK then begin
                            Text := Format(AllObjectsWithCaption."Object ID");
                            exit(true);
                        end;
                        exit(false);
                    end;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Insertion"; Rec."Log Insertion")
                {
                    ToolTip = 'Specifies the value of the Log Insertion field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Modification"; Rec."Log Modification")
                {
                    ToolTip = 'Specifies the value of the Log Modification field';
                    ApplicationArea = NPRRetail;
                }
                field("Ignored Fields"; Rec."Ignored Fields")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Ignored Fields field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.TestField("Log Modification");
                        AssistEditIgnoreList();
                    end;
                }
                field("Log Deletion"; Rec."Log Deletion")
                {
                    ToolTip = 'Specifies the value of the Log Deletion field';
                    ApplicationArea = NPRRetail;
                }
                field("Keep Log for"; Rec."Keep Log for")
                {
                    ToolTip = 'Specifies the value of the Keep Log For field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(DoCleanDataLog)
            {
                Caption = 'Clean Data Log';
                Image = ClearLog;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Clean Data Log action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    CleanDataLog();
                end;
            }
            action("Add Records to Data Log")
            {
                Caption = 'Add Records to Data Log';
                Image = AddAction;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Add Records to Data Log action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    AddRecordsToDataLog();
                end;
            }
            action(SetupIgnoreList)
            {
                Caption = 'Set Ignored Fields';
                Image = MaintenanceRegistrations;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Executes the Set Ignored Fields action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    AssistEditIgnoreList();
                end;
            }
        }
        area(navigation)
        {
            action(DataLogSubscribers)
            {
                Caption = 'Data Log Subscribers';
                Image = ContactPerson;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR Data Log Subscribers";
                RunPageLink = "Table ID" = FIELD("Table ID");
                ToolTip = 'Executes the Data Log Subscribers action';
                ApplicationArea = NPRRetail;
            }
            action(DataLog)
            {
                Caption = 'Data Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR Data Log Records";
                RunPageLink = "Table ID" = FIELD("Table ID");
                RunPageView = sorting("Table ID") order(descending);
                ShortCutKey = 'Ctrl+F7';
                ToolTip = 'Executes the Data Log action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        Text002: Label '%1 record quantity withing the filter:  %2\Do you wish to add the records to Data Log?';
        Text003: Label 'Data Log Filters - %1', Comment = '%1 = Table Name';
        Text004: Label 'Adding records to Data Log: @1@@@@@@@@@@@@@@@@@@@@@@@';

    local procedure AddRecordsToDataLog()
    var
        RecRef: RecordRef;
        DataLogMgt: Codeunit "NPR Data Log Management";
        Filters: Text;
        Window: Dialog;
        Counter: Integer;
        Total: Integer;
    begin
        if not RunDynamicRequestPage(Filters, '') then
            exit;

        if not SetFiltersOnTable(Filters, RecRef) then
            exit;

        Total := RecRef.Count();
        if not Confirm(StrSubstNo(Text002, Rec."Table Name", Total), true) then
            exit;

        Counter := 0;
        Window.Open(Text004);
        repeat
            Counter += 1;
            Window.Update(1, Round((Counter / Total) * 10000, 1));
            DataLogMgt.LogDatabaseInsert(RecRef);
        until RecRef.Next() = 0;
        Window.Close();
    end;

    internal procedure CleanDataLog()
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
        RetentionPolicy: Record "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        ManualPolicyApplicationQst: Label 'Expired Data Log record deletion is managed by NPR Retention Policy. Would you like to manually apply the policy now?';
        ManualPolicyApplicationMsg: Label 'Data Log retention policy has been applied.';
#else
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        DataLogDeletionQst: Label 'All old Data Log Records will be deleted.\Continue?';
#endif
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
        if Confirm(ManualPolicyApplicationQst, false) then begin
            RetentionPolicy.SetRange("Table Id", Database::"NPR Data Log Record");
            Page.Run(Page::"NPR Retention Policy", RetentionPolicy);
            if RetentionPolicy.FindFirst() then
                if RetentionPolicy.Enabled then begin
                    RetentionPolicyMgmt.ApplyOneRetentionPolicyManually(RetentionPolicy);
                    Message(ManualPolicyApplicationMsg);
                end;
        end;
#else
        if Confirm(DataLogDeletionQst, false) then
            DataLogSubscriberMgt.CleanDataLog();
#endif
        CurrPage.Update(false);
    end;

    local procedure RunDynamicRequestPage(var ReturnFilters: Text; Filters: Text): Boolean
    var
        TableMetadata: Record "Table Metadata";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        RecRef: RecordRef;
        KyRef: KeyRef;
        FldRef: FieldRef;
        j: Integer;
        DynamicRequestPageField: Record "Dynamic Request Page Field";
        DynamicRequestPageField1: Record "Dynamic Request Page Field";
    begin
        if not TableMetadata.Get(Rec."Table ID") then
            exit(false);

        DynamicRequestPageField.SetRange("Table ID", Rec."Table ID");
        if not DynamicRequestPageField.FindSet() then begin
            RecRef.Open(Rec."Table ID");
            RecRef.CurrentKeyIndex(1);
            KyRef := RecRef.KeyIndex(1);
            for j := 1 to KyRef.FieldCount do begin
                Clear(FldRef);
                FldRef := RecRef.FieldIndex(j);
                DynamicRequestPageField1.Init();
                DynamicRequestPageField1.Validate("Table ID", Rec."Table ID");
                DynamicRequestPageField1.Validate("Field ID", FldRef.Number);
                DynamicRequestPageField1.Insert(true);
                Commit();
            end;
        end;

        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, CopyStr(Rec."Table Name", 1, 20), Rec."Table ID") then
            exit(false);
        if Filters <> '' then
            if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(FilterPageBuilder, Filters, CopyStr(Rec."Table Name", 1, 20), Rec."Table ID") then
                exit(false);

        FilterPageBuilder.PageCaption := StrSubstNo(Text003, Rec."Table Name");
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters := RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, CopyStr(Rec."Table Name", 1, 20), Rec."Table ID");

        exit(true);
    end;

    local procedure SetFiltersOnTable(Filters: Text; var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        OutStream: OutStream;
    begin
        RecRef.Open(Rec."Table ID");

        if Filters = '' then
            exit(RecRef.FindSet());

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(Filters);

        if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
            exit(false);

        exit(RecRef.FindSet());
    end;

    local procedure AssistEditIgnoreList()
    var
        "Field": Record "Field";
        DataLogSetupFieldList: Page "NPR Data Log Setup Ignore List";
    begin
        Field.FilterGroup(2);
        Field.SetRange(TableNo, Rec."Table ID");
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.FilterGroup(0);
        DataLogSetupFieldList.SetTableView(Field);
        DataLogSetupFieldList.RunModal();
        Rec.CalcFields("Ignored Fields");
    end;
}
