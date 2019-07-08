page 6060002 "GIM - Import Document Subpage"
{
    Caption = 'Document Log';
    Editable = false;
    PageType = ListPart;
    SourceTable = "GIM - Document Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("Process Code";"Process Code")
                {
                }
                field("Process Name";"Process Name")
                {
                }
                field("Started At";"Started At")
                {
                }
                field("Finished At";"Finished At")
                {
                }
                field(Description;Description)
                {
                }
                field(Status;Status)
                {
                }
                field(Notified;Notified)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Errors")
            {
                Caption = 'Show Errors';
                RunObject = Page "GIM - Error Logs";
                RunPageLink = "Document Log Entry No."=FIELD("Entry No."),
                              "Document No."=FIELD("Document No.");
            }
        }
    }

    procedure Notify()
    begin
        Notify("Process Code",true);
    end;
}

