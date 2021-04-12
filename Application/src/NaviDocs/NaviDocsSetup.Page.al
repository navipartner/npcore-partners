page 6059767 "NPR NaviDocs Setup"
{
    Caption = 'NaviDocs Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR NaviDocs Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable NaviDocs"; Rec."Enable NaviDocs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable NaviDocs field';
                }
            }
            group(Processing)
            {
                Caption = 'Processing';
                field("Max Retry Qty"; Rec."Max Retry Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Retry Qty field';
                }
                field("Send Warming E-mail"; Rec."Send Warming E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Warming E-mail field';
                }
                field("Warning E-mail"; Rec."Warning E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Warning E-mail field';
                }
            }
            group(Integration)
            {
                field("Pdf2Nav Send pdf"; Rec."Pdf2Nav Send pdf")
                {
                    ApplicationArea = All;
                    Caption = 'Pdf2Nav send via NaviDocs';
                    ToolTip = 'Specifies the value of the Pdf2Nav send via NaviDocs field';
                }
                field("Pdf2Nav Table Filter"; Rec."Pdf2Nav Table Filter")
                {
                    ApplicationArea = All;
                    Caption = 'Tablefilter';
                    ToolTip = 'Specifies the value of the Tablefilter field';
                }
            }
            group(Logging)
            {
                Caption = 'Logging';
                field("Log to Activity Log"; Rec."Log to Activity Log")
                {
                    ApplicationArea = All;
                    Editable = ShowLogToActivityLog;
                    Visible = ShowLogToActivityLog;
                    ToolTip = 'Specifies the value of the Log to Activity Log field';
                }
                field("Keep Log for"; Rec."Keep Log for")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Keep Log for field';
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

