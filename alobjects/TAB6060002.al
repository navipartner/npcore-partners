table 6060002 "GIM - Document Log"
{
    // NPR5.32/TJ  /20170328 CASE 269797 Removed unused .NET variable

    Caption = 'GIM - Document Log';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(20;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Error,Message';
            OptionMembers = " ",Error,Message;
        }
        field(30;"Started At";DateTime)
        {
            Caption = 'Started At';
        }
        field(40;"Finished At";DateTime)
        {
            Caption = 'Finished At';
        }
        field(50;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(60;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Success,Error,Finished,Paused,Cancelled';
            OptionMembers = Success,Error,Finished,Paused,Cancelled;
        }
        field(70;"Process Code";Code[20])
        {
            Caption = 'Process Code';
            TableRelation = "GIM - Process Flow";
        }
        field(71;"Process Name";Text[50])
        {
            CalcFormula = Lookup("GIM - Process Flow".Description WHERE (Code=FIELD("Process Code")));
            Caption = 'Process Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80;Notified;Boolean)
        {
            Caption = 'Notified';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Started At")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GIMProcessFlow: Record "GIM - Process Flow";
        GIMImportDoc: Record "GIM - Import Document";
        GIMDocType: Record "GIM - Document Type";
        GIMSetup: Record "GIM - Setup";
        GIMImpBufferDetail: Record "GIM - Import Buffer Detail";
        Text001: Label 'Table: %1, Field: %2, Value: %3, Reason: %4';
        ErrLog: Record "GIM - Error Log";

    procedure InsertLine(DocNo: Code[20];TypeHere: Integer;StartAt: DateTime;EndAt: DateTime;Desc: Text[250];StatusHere: Integer;ProcessStage: Code[20])
    var
        DocumentLog: Record "GIM - Document Log";
        EntryNo: Integer;
    begin
        if DocumentLog.FindLast then
          EntryNo := DocumentLog."Entry No." + 1
        else
          EntryNo := 1;

        Init;
        "Entry No." := EntryNo;
        "Document No." := DocNo;
        Type := TypeHere;
        "Started At" := StartAt;
        "Finished At" := EndAt;
        Description := Desc;
        Status := StatusHere;
        "Process Code" := ProcessStage;
        Insert;

        ErrLog.SetRange("Document No.",DocNo);
        ErrLog.SetRange("Document Log Entry No.",0);
        ErrLog.ModifyAll("Started At",StartAt);
        ErrLog.ModifyAll("Finished At",EndAt);
        ErrLog.ModifyAll("Document Log Entry No.",EntryNo);

        Notify(ProcessStage,false);
    end;

    procedure Notify(ProcessCodeHere: Code[10];Manual: Boolean)
    begin
        GIMProcessFlow.Get(ProcessCodeHere);
        if not Manual and (GIMProcessFlow."Notify When" = GIMProcessFlow."Notify When"::"When Error") and (Status <> Status::Error) then
          exit;
        GIMImportDoc.Get("Document No.");
        GIMDocType.Get(GIMImportDoc."Document Type",GIMImportDoc."Sender ID");
        case GIMDocType."Default Notification Method" of
          GIMDocType."Default Notification Method"::File:;
          GIMDocType."Default Notification Method"::"E-mail":
            SendMail(ProcessCodeHere);
          GIMDocType."Default Notification Method"::Gambit:;
        end;
    end;

    local procedure SendMail(ProcessCodeHere: Code[10])
    var
        MailHeader: Record "GIM - Mail Header";
        MailLine: Record "GIM - Mail Line";
        RecRef: RecordRef;
        MailTaskStatus: Codeunit "Mail Task Status";
        EmailMgt: Codeunit "E-mail Management";
        EmailTemplateHeader: Record "E-mail Template Header";
        SMTPMailSetup: Record "SMTP Mail Setup";
    begin
        GIMSetup.Get();
        case GIMSetup."Mailing Templates" of
          GIMSetup."Mailing Templates"::GIM:
            begin
              SMTPMailSetup.Get();
              MailHeader.SetRange("Sender ID",GIMImportDoc."Sender ID");
              MailHeader.SetRange("Process Code",ProcessCodeHere);
              MailHeader.SetRange(Status,MailHeader.Status::Ready);
              if MailHeader.FindFirst then begin
        //        MailTaskStatus.CreateMessage(0,'GIM',GIMSetup."Sender E-mail",MailHeader."To",MailHeader.Subject,'');
                MailTaskStatus.CreateMessage(0,'GIM',SMTPMailSetup."User ID",MailHeader."To",MailHeader.Subject,'');
                if MailHeader.Cc <> '' then
                  MailTaskStatus.AddRecipientCC(MailHeader.Cc);
                MailLine.SetRange("Sender ID",MailHeader."Sender ID");
                MailLine.SetRange("Process Code",MailHeader."Process Code");
                if MailLine.FindSet then
                  repeat
                    if MailLine."Line Type" = MailLine."Line Type"::Details then begin
                      GIMImpBufferDetail.SetRange("Document No.","Document No.");
                      GIMImpBufferDetail.SetFilter("Fail Reason",'<>%1','');
                      if GIMImpBufferDetail.FindSet then
                        repeat
                          GIMImpBufferDetail.CalcFields("Table Caption","Field Caption");
                          MailTaskStatus.AppendHTML(StrSubstNo(Text001,
                                                    GIMImpBufferDetail."Table Caption",
                                                    GIMImpBufferDetail."Field Caption",
                                                    GIMImpBufferDetail."Formatted Value",
                                                    GIMImpBufferDetail."Fail Reason"));
                        until GIMImpBufferDetail.Next = 0
                      else
                        MailTaskStatus.AppendHTML(Description);
                    end else
                      MailTaskStatus.AppendHTML(MailLine.Description);
                  until MailLine.Next = 0;
                Notified := MailTaskStatus.Send();
                Modify;
              end;
            end;
          GIMSetup."Mailing Templates"::NAVI:
            begin
              RecRef.GetTable(Rec);
              EmailMgt.SetupEmailTemplate(RecRef,GIMDocType."Recipient E-mail",true,EmailTemplateHeader);
              EmailMgt.CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader,RecRef,0); //last parameter is not used in this function
              if EmailMgt.SendEmail(RecRef,GIMDocType."Recipient E-mail",true) = '' then begin
                Notified := true;
                Modify;
              end;
            end;
        end;
    end;
}

