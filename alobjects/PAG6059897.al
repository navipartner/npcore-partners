page 6059897 "Data Log Setup"
{
    // DL1.00/MHA /20140801  NP-AddOn: Data Log
    //   - This Page contains Setup information of which Record Changes to log.
    // DL1.01/MHA /20140820  NP-AddOn: Data Log
    //   - Added Menu Item: Data Log Subscribers for defining consumers of the Data Log.
    // DL1.07/MHA /20150515  CASE 214248 Added field "Last Log Update Entry No." and "Last Date Modified"
    // DL1.11/MHA /20160601  CASE 242299 Functionality to Add Records to Data Log using Dynamice Request Page
    // DL1.12/TR  /20161012  CASE 250790 Added COPYSTR on "Table Name" as RequestPageParametersHelper functions only takes text parameter of size 20.
    // DL1.13/MHA /20170801  CASE 285518 Removed NPR5.27 from Version List and replaced with DL1.12
    // DL1.15/BR  /20171128  CASE 297941 Add Primary Key fields to FilterRequestPage so that data log is visible in Web Client
    // NPR5.40/TS  /20180319  CASE 308461 Reworked Adding field filter
    // NPR5.41/BHR  /20180419  CASE 308556 Filter is not being applied on the RequestPage. Another workaround implemented.

    Caption = 'Data Log Setup';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Manage,Process,Data Log';
    SourceTable = "Data Log Setup (Table)";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID"; "Table ID")
                {
                }
                field("Table Name"; "Table Name")
                {
                }
                field("Log Insertion"; "Log Insertion")
                {
                }
                field("Log Modification"; "Log Modification")
                {
                }
                field("Log Deletion"; "Log Deletion")
                {
                }
                field("Keep Log for"; "Keep Log for")
                {
                }
                field("User ID"; "User ID")
                {
                }
                field("Last Date Modified"; "Last Date Modified")
                {
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
                PromotedCategory = Process;

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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //-DL1.11
                    AddRecordsToDataLog();
                    //+DL1.11
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
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Data Log Subscribers";
                RunPageLink = "Table ID" = FIELD("Table ID");
            }
            action(DataLog)
            {
                Caption = 'Data Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "Data Log Records";
                RunPageLink = "Table ID" = FIELD("Table ID");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }

    var
        Text001: Label 'All old Data Log Records will be deleted\Continue?';
        Text002: Label '%1 record quantity withing the filter:  %2\Do you wish to add the records to Data Log?';
        DataLogMgt: Codeunit "Data Log Management";
        DataLogSubscriberMgt: Codeunit "Data Log Subscriber Mgt.";
        Text003: Label 'Data Log Filters - %1', Comment = '%1 = Table Name';
        Text004: Label 'Adding records to Data Log: @1@@@@@@@@@@@@@@@@@@@@@@@';

    local procedure AddRecordsToDataLog()
    var
        RecRef: RecordRef;
        DataLogMgt: Codeunit "Data Log Management";
        Filters: Text;
        Window: Dialog;
        Counter: Integer;
        Total: Integer;
    begin
        //-DL1.11
        if not RunDynamicRequestPage(Filters, '') then
            exit;

        if not SetFiltersOnTable(Filters, RecRef) then
            exit;

        Total := RecRef.Count;
        if not Confirm(StrSubstNo(Text002, "Table Name", Total), true) then
            exit;

        Counter := 0;
        Window.Open(Text004);
        repeat
            Counter += 1;
            Window.Update(1, Round((Counter / Total) * 10000, 1));
            DataLogMgt.OnDatabaseInsert(RecRef);
        until RecRef.Next = 0;
        Window.Close;
        //+DL1.11
    end;

    procedure CleanDataLog()
    begin
        if Confirm(Text001, false) then
            //-DL1.07
            //DataLogMgt.CleanDataLog();
            DataLogSubscriberMgt.CleanDataLog();
        //+DL1.07
        CurrPage.Update(false);
    end;

    local procedure RunDynamicRequestPage(var ReturnFilters: Text; Filters: Text): Boolean
    var
        TableMetadata: Record "Table Metadata";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        FieldRec: Record "Field";
        RecRef: RecordRef;
        KyRef: KeyRef;
        FldRef: FieldRef;
        j: Integer;
        DynamicRequestPageField: Record "Dynamic Request Page Field";
        DynamicRequestPageField1: Record "Dynamic Request Page Field";
    begin
        //-DL1.11
        if not TableMetadata.Get("Table ID") then
            exit(false);

        //-NPR5.41 [308556]
        DynamicRequestPageField.SetRange("Table ID", "Table ID");
        if not DynamicRequestPageField.FindSet then begin
            RecRef.Open("Table ID");
            RecRef.CurrentKeyIndex(1);
            KyRef := RecRef.KeyIndex(1);
            for j := 1 to KyRef.FieldCount do begin
                Clear(FldRef);
                FldRef := RecRef.FieldIndex(j);
                DynamicRequestPageField1.Init;
                DynamicRequestPageField1.Validate("Table ID", "Table ID");
                DynamicRequestPageField1.Validate("Field ID", FldRef.Number);
                DynamicRequestPageField1.Insert(true);
                Commit;
            end;
        end;
        //+NPR5.41 [308556]

        //-DL1.12 [250790]
        //IF NOT RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder,"Table Name","Table ID") THEN
        if not RequestPageParametersHelper.BuildDynamicRequestPage(FilterPageBuilder, CopyStr("Table Name", 1, 20), "Table ID") then
            //+DL1.12 [250790]
            exit(false);
        if Filters <> '' then
            //-DL1.12 [250790]
            //IF NOT RequestPageParametersHelper.SetViewOnDynamicRequestPage(
            //FilterPageBuilder,Filters,"Table Name","Table ID")
            if not RequestPageParametersHelper.SetViewOnDynamicRequestPage(
             FilterPageBuilder, Filters, CopyStr("Table Name", 1, 20), "Table ID")
          //+DL1.12 [250790]
          then
                exit(false);
        //-NPR5.40 [308461]
        //-DL1.15 [297941]
        //RecRef.OPEN("Table ID");

        //RecRef.CURRENTKEYINDEX(1);
        //KyRef := RecRef.KEYINDEX(1);
        //FOR j := 1 TO KyRef.FIELDCOUNT DO BEGIN
        //FOR j := 1 TO 3 DO BEGIN
        //  CLEAR(FldRef);
        //  //FldRef := KyRef.FIELDINDEX(j);
        //  FldRef := RecRef.FIELDINDEX(j);
        //  //FilterPageBuilder.ADDFIELDNO(COPYSTR("Table Name",1,20),FldRef.NUMBER);
        //  FilterPageBuilder.ADDFIELDNO(COPYSTR("Table Name",1,MAXSTRLEN("Table Name")),FldRef.NUMBER);
        //END;
        //+DL1.15 [297941]
        //-NPR5.41 [308556]
        // RecRef.OPEN("Table ID");
        // FOR j := 1 TO 3 DO BEGIN
        //  FilterPageBuilder.ADDRECORDREF(COPYSTR("Table Name",1,MAXSTRLEN("Table Name")),RecRef);
        //  FldRef := RecRef.FIELDINDEX(j);
        //  FilterPageBuilder.ADDFIELDNO(COPYSTR("Table Name",1,MAXSTRLEN("Table Name")),FldRef.NUMBER);
        // END;
        //+NPR5.41 [308556]
        //+NPR5.40 [308461]
        FilterPageBuilder.PageCaption := StrSubstNo(Text003, "Table Name");
        if not FilterPageBuilder.RunModal then
            exit(false);

        //-DL1.12 [250790]
        //ReturnFilters :=
        //  RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder,"Table Name","Table ID");
        ReturnFilters :=
          RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, CopyStr("Table Name", 1, 20), "Table ID");
        //+DL1.12 [250790]

        exit(true);
        //+DL1.11
    end;

    local procedure SetFiltersOnTable(Filters: Text; var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        OutStream: OutStream;
    begin
        //-DL1.11
        RecRef.Open("Table ID");

        if Filters = '' then
            exit(RecRef.FindSet);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(Filters);

        if not RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob) then
            exit(false);

        exit(RecRef.FindSet);
        //+DL1.11
    end;
}

