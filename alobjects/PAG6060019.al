page 6060019 "GIM - Mail"
{
    Caption = 'GIM - Mail';
    PageType = Document;
    SourceTable = "GIM - Mail Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Sender ID";"Sender ID")
                {
                }
                field("Process Code";"Process Code")
                {
                }
                field(Description;Description)
                {
                }
                field(Status;Status)
                {
                    Editable = false;
                }
                field("To";"To")
                {
                }
                field(Cc;Cc)
                {
                }
                field(Subject;Subject)
                {
                }
            }
            part(Control11;"GIM - Mail Line Subpage")
            {
                SubPageLink = "Sender ID"=FIELD("Sender ID"),
                              "Process Code"=FIELD("Process Code");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Activate)
            {
                Caption = 'Activate';
                Image = ReleaseDoc;

                trigger OnAction()
                begin
                    StatusChanger(Status::Ready);
                end;
            }
            action(Deactivate)
            {
                Caption = 'Deactivate';
                Image = ReOpen;

                trigger OnAction()
                begin
                    StatusChanger(Status::" ");
                end;
            }
        }
    }
}

