page 6059944 "NPR SMS Send Message"
{
    Caption = 'SMS Send Message';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    UsageCategory = Administration;
    SourceTable = "NPR SMS Template Header";

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
                        ToolTip = 'Specifies the value of the Phone No field';
                    }
                    field(SenderText; SenderText)
                    {
                        ApplicationArea = All;
                        Caption = 'Sender';
                        ToolTip = 'Specifies the value of the Sender field';
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
                        ToolTip = 'Specifies the value of the Record field';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if SelectedRecordRef.Number <> 0 then
                                SelectedRecordRef.Close;
                            if SelectRecord(Rec, SelectedRecordRef) then begin
                                Text := Format(SelectedRecordRef.RecordId);
                                SMSMessageText := SMSManagement.MakeMessage(Rec, SelectedRecordRef);
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
                        ToolTip = 'Specifies the value of the InfoText field';
                    }
                }
                group("Message")
                {
                    Caption = 'Message';
                    field(SMSMessageText; SMSMessageText)
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the SMSMessageText field';
                    }
                }
                group(Control6150621)
                {
                    ShowCaption = false;
                    field(SendingOption; SendingOption)
                    {
                        ApplicationArea = All;
                        Caption = 'Sending Option';
                        ToolTip = 'Specifies the value of the Sending Option field';

                        trigger OnValidate()
                        var
                            SMSManagement: Codeunit "NPR SMS Management";
                        begin
                            if SendingOption = SendingOption::"Through NaviDocs" then
                                SMSManagement.IsNaviDocsAvailable(true);
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
                            ToolTip = 'Specifies the value of the Delay Until field';
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
        ShowRecordSelection := ("Table No." <> 0) and ShowRecordSelection and (Mode < Mode::Batch);
        SMSMessageText := SMSManagement.MakeMessage(Rec, SelectedRecordRef);
    end;

    trigger OnInit()
    begin
        ShowRecordSelection := true;
    end;

    trigger OnOpenPage()
    begin
        ShowRecordSelection := IsRecRefEmpty(SelectedRecordRef) and (Mode < Mode::Batch);
    end;

    var
        SMSManagement: Codeunit "NPR SMS Management";
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
        PhoneNo := ReceiverPhoneNo;
        SelectedRecordRef := RecRef;
        SenderText := Sender;
        Mode := DialogMode;
        InfoText := RecordSelectionText;
    end;

    procedure GetData(var ReceiverPhoneNo: Text; var RecRef: RecordRef; var SMSBodyText: Text; var Sender: Text; var SendOption: Option; var SendDelayUntil: DateTime)
    begin
        ReceiverPhoneNo := PhoneNo;
        RecRef := SelectedRecordRef;
        SMSBodyText := SMSMessageText;
        Sender := SenderText;
        SendOption := SendingOption;
        SendDelayUntil := DelayUntil;
    end;

    local procedure SelectRecord(Template: Record "NPR SMS Template Header"; var RecRef: RecordRef): Boolean
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
        if RecRef.Number = 0 then
            exit(true);
        EmptyRecRef.Open(RecRef.Number);
        if RecRef.RecordId = EmptyRecRef.RecordId then
            exit(true);
        exit(RecRef.IsEmpty);
    end;
}

