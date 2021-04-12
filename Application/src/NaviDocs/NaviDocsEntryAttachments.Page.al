page 6059949 "NPR NaviDocs Entry Attachments"
{

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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Data Type"; Rec."Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field("File Extension"; Rec."File Extension")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Extension field';
                }
                field(Data; Data.HasValue)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data.HasValue() field';
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
                    Rec.ShowOutput;
                end;
            }
        }
    }
}

