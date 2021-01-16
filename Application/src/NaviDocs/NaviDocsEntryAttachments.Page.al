page 6059949 "NPR NaviDocs Entry Attachments"
{
    // NPR5.43/THRO/20180531 CASE 315958 Page created

    Caption = 'Attachments';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NaviDocs Entry Attachment";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field("File Extension"; "File Extension")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Extension field';
                }
                field(Data; Data.HasValue)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data.HasValue field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Open Attachment action';

                trigger OnAction()
                begin
                    ShowOutput;
                end;
            }
        }
    }
}

