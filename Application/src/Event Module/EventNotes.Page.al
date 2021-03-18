page 6151575 "NPR Event Notes"
{
    Caption = 'Event Notes';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Record Link";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(URL1; URL1)
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    Caption = 'From User';
                    ToolTip = 'Specifies the value of the From User field';
                }
                field("To User ID"; "To User ID")
                {
                    ApplicationArea = All;
                    Caption = 'To User';
                    ToolTip = 'Specifies the value of the To User field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'Note';
                    ToolTip = 'Specifies the value of the Note field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the View Event action';

                trigger OnAction()
                var
                    EventCard: Page "NPR Event Card";
                    Job: Record Job;
                    RecRef: RecordRef;
                begin
                    if "Link ID" = 0 then
                        exit;
                    RecRef.Get("Record ID");
                    RecRef.SetTable(Job);
                    Job.SetRecFilter;
                    EventCard.SetTableView(Job);
                    EventCard.Run;
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
        Job.SetFilter("Starting Date", '>=%1', WorkDate);
        if Job.FindSet then
            repeat
                JobCount += 1;
                RecordLink.SetRange("Record ID", Job.RecordId);
                RecordLink.SetRange(Type, RecordLink.Type::Note);
                if RecordLink.FindSet then
                    repeat
                        if RecordLink.Note.HasValue then begin
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
                            Init;
                            "Link ID" := LinkID;
                            URL1 := Job."No.";
                            "Record ID" := RecordLink."Record ID";
                            "User ID" := GetUserName(RecordLink."User ID");
                            "To User ID" := GetUserName(RecordLink."To User ID");
                            Description := CopyStr(Format(NoteText), 1, MaxStrLen(Description));
                            Insert;
                        end;
                    until RecordLink.Next = 0;
            until (Job.Next = 0) or (JobCount = MaxNoOfEvents);
    end;

    local procedure GetUserName(UserID: Text): Text
    var
        User: Record User;
        EveryoneText: Label 'Everyone';
    begin
        User.SetRange("User Name", UserID);
        if User.FindFirst and (User."Full Name" <> '') then
            exit(User."Full Name");
        if UserID = '' then
            exit(EveryoneText);
        exit(UserID);
    end;
}

