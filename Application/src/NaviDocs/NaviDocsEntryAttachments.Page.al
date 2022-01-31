page 6059949 "NPR NaviDocs Entry Attachments"
{
    Extensible = False;

    Caption = 'Attachments';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NaviDocs Entry Attachment";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Type"; Rec."Data Type")
                {

                    ToolTip = 'Specifies the value of the Data Type field';
                    ApplicationArea = NPRRetail;
                }
                field("File Extension"; Rec."File Extension")
                {

                    ToolTip = 'Specifies the value of the File Extension field';
                    ApplicationArea = NPRRetail;
                }
                field(Data; Rec.Data.HasValue)
                {

                    Caption = 'Has Data';
                    ToolTip = 'Specifies the value of the Data.HasValue() field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Open Attachment action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowOutput();
                end;
            }
        }
    }
}

