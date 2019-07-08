page 6060023 "GIM - Import Document List"
{
    Caption = 'GIM - Import Document List';
    CardPageID = "GIM - Import Document";
    Editable = false;
    PageType = List;
    SourceTable = "GIM - Import Document";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Sender ID";"Sender ID")
                {
                }
                field(Process;Process)
                {
                }
                field("Data Source";"Data Source")
                {
                }
                field("Paused at Process Code";"Paused at Process Code")
                {
                }
                field("Process Name";"Process Name")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Preview Data Creation")
            {
                Caption = 'Preview Data Creation';
                Image = PreviewChecks;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    PreviewData();
                end;
            }
            action("Preview File Data")
            {
                Caption = 'Preview File Data';
                Image = PreviewChecks;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    PreviewFileData();
                end;
            }
        }
    }

    var
        TestRunner: Codeunit "GIM - Data Create Test Runner";
}

