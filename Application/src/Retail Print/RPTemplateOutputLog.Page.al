page 6014513 "NPR RP Template Output Log"
{
    PageType = List;
    Caption = 'Template Output Log';
    Editable = false;
    SourceTable = "NPR RP Template Output Log";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(RepeaterGroup)
            {
                field("Entry No.";
                    "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Template Name";"Template Name")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Printed At";"Printed At")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DownloadOutput)
            {
                Caption = 'Download Output';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;
                trigger OnAction()
                var 
                    IStream:InStream;
                    ToFileName:Text;
                begin
                    Rec.CALCFIELDS(Output);
                    Rec.Output.CREATEINSTREAM(IStream);
                    ToFileName := 'Printjob';
                    DOWNLOADFROMSTREAM(IStream, 'Download print output', '', '', ToFileName);
                end;
            }
        }
    }
}
