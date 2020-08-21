page 6059944 "SMS Send Message"
{
    // NPR5.26/THRO/20160908 CASE 244114 SMS Module
    // NPR5.30/THRO/20170203 CASE 263182 Show sms message text
    //                                   Changed Name and Caption of page
    // NPR5.38/THRO/20180108 CASE 301396 Added option to send through NaviDocs with Delay Until

    Caption = 'SMS Send Message';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "SMS Template Header";

    layout
    {
        area(content)
        {
            group("Test SMS Data")
            {
                group(Control6150625)
                {
                    ShowCaption = false;
                    Visible = Mode < 2;
                    field(PhoneNo; PhoneNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Phone No';
                    }
                    field(SenderText; SenderText)
                    {
                        ApplicationArea = All;
                        Caption = 'Sender';
                    }
                }
                group("Merge Template with")
                {
                    Caption = 'Merge Template with';
                    Visible = ShowRecordSelection;
                    field(RecordInfo; RecordInfo)
                    {
                        ApplicationArea = All;
                        Caption = 'Record';
                        Visible = ShowRecordSelection;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if SelectedRecordRef.Number <> 0 then
                                SelectedRecordRef.Close;
                            if SelectRecord(Rec, SelectedRecordRef) then begin
                                Text := Format(SelectedRecordRef.RecordId);
                                //-NPR5.30 [263182]
                                SMSMessageText := SMSManagement.MakeMessage(Rec, SelectedRecordRef);
                                //+NPR5.30 [263182]
                                exit(true);
                            end else
                                Text := '';
                        end;
                    }
                }
                group(Control6150626)
                {
                    Editable = false;
                    ShowCaption = false;
                    Visible = InfoText <> '';
                    field(InfoText; InfoText)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Style = Strong;
                        StyleExpr = TRUE;
                    }
                }
                group(Message)
                {
                    Caption = 'Message';
                    field(SMSMessageText; SMSMessageText)
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
                group(Control6150621)
                {
                    ShowCaption = false;
                    field(SendingOption; SendingOption)
                    {
                        ApplicationArea = All;
                        Caption = 'Sending Option';

                        trigger OnValidate()
                        var
                            SMSManagement: Codeunit "SMS Management";
                        begin
                            //-NPR5.38 [301396]
                            if SendingOption = SendingOption::"Through NaviDocs" then
                                SMSManagement.IsNaviDocsAvailable(true);
                            //+NPR5.38 [301396]
                        end;
                    }
                    group(Control6150623)
                    {
                        ShowCaption = false;
                        Visible = SendingOption = 1;
                        field(DelayUntil; DelayUntil)
                        {
                            ApplicationArea = All;
                            Caption = 'Delay Until';
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NPR5.30 [263182]
        //-NPR5.38 [301396]
        ShowRecordSelection := ("Table No." <> 0) and ShowRecordSelection and (Mode < Mode::Batch);
        //+NPR5.38 [301396]
        SMSMessageText := SMSManagement.MakeMessage(Rec, SelectedRecordRef);
        //+NPR5.30 [263182]
    end;

    trigger OnInit()
    begin
        ShowRecordSelection := true;
    end;

    trigger OnOpenPage()
    begin
        //-NPR5.30 [263182]
        //-NPR5.38 [301396]
        ShowRecordSelection := IsRecRefEmpty(SelectedRecordRef) and (Mode < Mode::Batch);
        //+NPR5.38 [301396]
        //+NPR5.30 [263182]
    end;

    var
        SMSManagement: Codeunit "SMS Management";
        [InDataSet]
        ShowRecordSelection: Boolean;
        SelectedRecordRef: RecordRef;
        PhoneNo: Text;
        RecordInfo: Text;
        Text001: Label 'No records in %1 within the filters.';
        SMSMessageText: Text;
        SenderText: Text;
        InfoText: Text;
        SendingOption: Option Directly,"Through NaviDocs";
        DelayUntil: DateTime;
        Mode: Option Test,SingleRecord,Batch;

    procedure SetData(ReceiverPhoneNo: Text; RecRef: RecordRef; Sender: Text; DialogMode: Option Test,SingleRecord,Batch; RecordSelectionText: Text)
    begin
        //-NPR5.30 [263182]
        PhoneNo := ReceiverPhoneNo;
        SelectedRecordRef := RecRef;
        SenderText := Sender;
        //+NPR5.30 [263182]
        //-NPR5.38 [301396]
        Mode := DialogMode;
        InfoText := RecordSelectionText;
        //+NPR5.38 [301396]
    end;

    procedure GetData(var ReceiverPhoneNo: Text; var RecRef: RecordRef; var SMSBodyText: Text; var Sender: Text; var SendOption: Option; var SendDelayUntil: DateTime)
    begin
        ReceiverPhoneNo := PhoneNo;
        RecRef := SelectedRecordRef;
        //-NPR5.30 [263182]
        SMSBodyText := SMSMessageText;
        Sender := SenderText;
        //+NPR5.30 [263182]
        //-NPR5.38 [301396]
        SendOption := SendingOption;
        SendDelayUntil := DelayUntil;
        //+NPR5.38 [301396]
    end;

    local procedure SelectRecord(Template: Record "SMS Template Header"; var RecRef: RecordRef): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        PageManagement: Codeunit "Page Management";
        DataTypeManagement: Codeunit "Data Type Management";
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        RecVariant: Variant;
        PageID: Integer;
    begin
        PageID := PageManagement.GetDefaultLookupPageID(Template."Table No.");
        if PageID <> 0 then begin
            RecRef.Open(Template."Table No.");
            if Template."Table Filters".HasValue then begin
                Template.CalcFields("Table Filters");
                Clear(TempBlob);
                TempBlob.FromRecord(Template, Template.FieldNo("Table Filters"));
                RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob);
            end;
            RecVariant := RecRef;
            if RecRef.IsEmpty then
                Message(Text001, RecRef.Caption);
            if PAGE.RunModal(PageID, RecVariant) = ACTION::LookupOK then begin
                DataTypeManagement.GetRecordRef(RecVariant, RecRef);
                exit(true);
            end;
        end;
    end;

    local procedure IsRecRefEmpty(var RecRef: RecordRef): Boolean
    var
        EmptyRecRef: RecordRef;
    begin
        //-NPR5.30 [263182]
        if RecRef.Number = 0 then
            exit(true);
        EmptyRecRef.Open(RecRef.Number);
        if RecRef.RecordId = EmptyRecRef.RecordId then
            exit(true);
        exit(RecRef.IsEmpty);
        //+NPR5.30 [263182]
    end;
}

