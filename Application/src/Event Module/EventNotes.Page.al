page 6151575 "NPR Event Notes"
{
    Extensible = False;
    Caption = 'Event Notes';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "Record Link";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(URL1; Rec.URL1)
                {

                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    Caption = 'From User';
                    ToolTip = 'Specifies the value of the From User field';
                    ApplicationArea = NPRRetail;
                }
                field("To User ID"; Rec."To User ID")
                {

                    Caption = 'To User';
                    ToolTip = 'Specifies the value of the To User field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Caption = 'Note';
                    ToolTip = 'Specifies the value of the Note field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("View Event")
            {
                Caption = 'View Event';
                Image = View;
                RunPageMode = View;

                ToolTip = 'Executes the View Event action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EventCard: Page "NPR Event Card";
                    Job: Record Job;
                    RecRef: RecordRef;
                begin
                    if Rec."Link ID" = 0 then
                        exit;
                    RecRef.Get(Rec."Record ID");
                    RecRef.SetTable(Job);
                    Job.SetRecFilter();
                    EventCard.SetTableView(Job);
                    EventCard.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        MaxNoOfEvents := 10;
        CreateList();
    end;

    var
        MaxNoOfEvents: Integer;

    local procedure CreateList()
    var
        RecordLink: Record "Record Link";
        Job: Record Job;
        JobCount: Integer;
        NoteInStream: InStream;
        BufferText: Text;
        NoteInStreamText: Text;
        NoteText: BigText;
        LinkID: Integer;
    begin
        Job.SetRange("NPR Event", true);
        Job.SetFilter("Starting Date", '>=%1', WorkDate());
        if Job.FindSet() then
            repeat
                JobCount += 1;
                RecordLink.SetRange("Record ID", Job.RecordId);
                RecordLink.SetRange(Type, RecordLink.Type::Note);
                if RecordLink.FindSet() then
                    repeat
                        if RecordLink.Note.HasValue() then begin
                            Clear(NoteText);
                            Clear(NoteInStream);
                            RecordLink.CalcFields(Note);
                            RecordLink.Note.CreateInStream(NoteInStream);
                            BufferText := '';
                            NoteInStreamText := '';
                            while not NoteInStream.EOS do begin
                                NoteInStream.ReadText(BufferText);
                                NoteInStreamText := BufferText;
                            end;
                            NoteText.AddText(NoteInStreamText);
                            LinkID += 1;
                            Rec.Init();
                            Rec."Link ID" := LinkID;
                            Rec.URL1 := Job."No.";
                            Rec."Record ID" := RecordLink."Record ID";
                            Rec."User ID" := GetUserName(RecordLink."User ID");
                            Rec."To User ID" := GetUserName(RecordLink."To User ID");
                            Rec.Description := CopyStr(Format(NoteText), 1, MaxStrLen(Rec.Description));
                            Rec.Insert();
                        end;
                    until RecordLink.Next() = 0;
            until (Job.Next() = 0) or (JobCount = MaxNoOfEvents);
    end;

    local procedure GetUserName(UserID: Text): Text
    var
        User: Record User;
        EveryoneText: Label 'Everyone';
    begin
        User.SetRange("User Name", UserID);
        if User.FindFirst() and (User."Full Name" <> '') then
            exit(User."Full Name");
        if UserID = '' then
            exit(EveryoneText);
        exit(UserID);
    end;
}

