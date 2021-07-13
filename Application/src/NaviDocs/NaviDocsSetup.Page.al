page 6059767 "NPR NaviDocs Setup"
{
    Caption = 'NaviDocs Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR NaviDocs Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable NaviDocs"; Rec."Enable NaviDocs")
                {

                    ToolTip = 'Specifies the value of the Enable NaviDocs field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Processing)
            {
                Caption = 'Processing';
                field("Max Retry Qty"; Rec."Max Retry Qty")
                {

                    ToolTip = 'Specifies the value of the Max Retry Qty field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Warming E-mail"; Rec."Send Warming E-mail")
                {

                    ToolTip = 'Specifies the value of the Send Warming E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Warning E-mail"; Rec."Warning E-mail")
                {

                    ToolTip = 'Specifies the value of the Warning E-mail field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Integration)
            {
                field("Pdf2Nav Send pdf"; Rec."Pdf2Nav Send pdf")
                {

                    Caption = 'Pdf2Nav send via NaviDocs';
                    ToolTip = 'Specifies the value of the Pdf2Nav send via NaviDocs field';
                    ApplicationArea = NPRRetail;
                }
                field("Pdf2Nav Table Filter"; Rec."Pdf2Nav Table Filter")
                {

                    Caption = 'Tablefilter';
                    ToolTip = 'Specifies the value of the Tablefilter field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Logging)
            {
                Caption = 'Logging';
                field("Log to Activity Log"; Rec."Log to Activity Log")
                {

                    Editable = ShowLogToActivityLog;
                    Visible = ShowLogToActivityLog;
                    ToolTip = 'Specifies the value of the Log to Activity Log field';
                    ApplicationArea = NPRRetail;
                }
                field("Keep Log for"; Rec."Keep Log for")
                {

                    ToolTip = 'Specifies the value of the Keep Log for field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }


    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        ShowLogToActivityLog := not Rec."Log to Activity Log";
    end;

    var
        ShowLogToActivityLog: Boolean;
}

