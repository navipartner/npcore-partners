page 6014513 "NPR RP Template Output Log"
{
    Extensible = False;
    UsageCategory = None;
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
                Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Name"; Rec."Template Name")
                {

                    ToolTip = 'Specifies the value of the Template Name field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Printed At"; Rec."Printed At")
                {

                    ToolTip = 'Specifies the value of the Printed At field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Download Output action';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    IStream: InStream;
                    ToFileName: Text;
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
