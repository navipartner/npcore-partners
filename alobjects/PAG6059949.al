page 6059949 "NaviDocs Entry Attachments"
{
    // NPR5.43/THRO/20180531 CASE 315958 Page created

    Caption = 'Attachments';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NaviDocs Entry Attachment";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                }
                field("File Extension"; "File Extension")
                {
                    ApplicationArea = All;
                }
                field(Data; Data.HasValue)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowOutput)
            {
                Caption = 'Open Attachment';
                Image = XMLFile;

                trigger OnAction()
                begin
                    ShowOutput;
                end;
            }
        }
    }
}

