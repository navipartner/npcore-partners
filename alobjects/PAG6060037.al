page 6060037 "GIM - WS Received Files"
{
    Caption = 'GIM - WS Received Files';
    Editable = false;
    PageType = List;
    SourceTable = "GIM - WS Received File";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Doc. Type Code";"Doc. Type Code")
                {
                }
                field("Sender ID";"Sender ID")
                {
                }
                field("File Name";"File Name")
                {
                }
                field("File Extension";"File Extension")
                {
                }
                field("File Processed";"File Processed")
                {
                }
                field("Received At";"Received At")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Process File")
            {
                Caption = 'Process File';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ProcessFile();
                end;
            }
        }
    }
}

