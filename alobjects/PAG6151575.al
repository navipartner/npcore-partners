page 6151575 "Event Notes"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.32/TJ  /20170523 CASE 277397 View Event action will only open an event if note exists
    //                                   Added Image property to action View Event

    Caption = 'Event Notes';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Record Link";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(URL1;URL1)
                {
                    Caption = 'No.';
                }
                field(URL2;URL2)
                {
                    Caption = 'Description';
                }
                field("User ID";"User ID")
                {
                    Caption = 'From User';
                }
                field("To User ID";"To User ID")
                {
                    Caption = 'To User';
                }
                field(Description;Description)
                {
                    Caption = 'Note';
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

                trigger OnAction()
                var
                    EventCard: Page "Event Card";
                    Job: Record Job;
                    RecRef: RecordRef;
                begin
                    //-NPR5.32 [277397]
                    if "Link ID" = 0 then
                      exit;
                    //+NPR5.32 [277397]
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
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        NoteText: BigText;
        LinkID: Integer;
    begin
        Job.SetRange("Event",true);
        Job.SetFilter("Starting Date",'>=%1',WorkDate);
        if Job.FindSet then
          repeat
            JobCount += 1;
            RecordLink.SetRange("Record ID",Job.RecordId);
            RecordLink.SetRange(Type,RecordLink.Type::Note);
            if RecordLink.FindSet then
              repeat
                if RecordLink.Note.HasValue then begin
                  Clear(NoteText);
                  Clear(NoteInStream);
                  RecordLink.CalcFields(Note);
                  RecordLink.Note.CreateInStream(NoteInStream);
                  MemoryStream := MemoryStream.MemoryStream;
                  MemoryStream := NoteInStream;
                  BinaryReader := BinaryReader.BinaryReader(MemoryStream);
                  NoteText.AddText(BinaryReader.ReadString);
                  LinkID += 1;
                  Init;
                  "Link ID" := LinkID;
                  URL1 := Job."No.";
                  URL2 := Job.Description;
                  "Record ID" := RecordLink."Record ID";
                  "User ID" := GetUserName(RecordLink."User ID");
                  "To User ID" := GetUserName(RecordLink."To User ID");
                  Description := CopyStr(Format(NoteText),1,MaxStrLen(Description));
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
        User.SetRange("User Name",UserID);
        if User.FindFirst and (User."Full Name" <> '') then
          exit(User."Full Name");
        if UserID = '' then
          exit(EveryoneText);
        exit(UserID);
    end;
}

