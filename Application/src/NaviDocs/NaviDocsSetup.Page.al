page 6059767 "NPR NaviDocs Setup"
{
    // NPR5.23/THRO/20160601 CASE 236043 Insert record if table is empty
    //                                   "Enable Posting Management", "Enable NAS" and "NAS Interval" removed
    // NPR5.26/THRO/20160808 CASE 248662 Removed "Enable Document Management"
    // NPR5.30/THRO/20170209 CASE 243998 Added Logging section with "Log to Activity Log" + "Keep Log for".
    //                                   Removed unused field "Auto Capture Payment"

    Caption = 'NaviDocs Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR NaviDocs Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable NaviDocs"; "Enable NaviDocs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable NaviDocs field';
                }
            }
            group(Processing)
            {
                Caption = 'Processing';
                field("Max Retry Qty"; "Max Retry Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Retry Qty field';
                }
                field("Send Warming E-mail"; "Send Warming E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Warming E-mail field';
                }
                field("Warning E-mail"; "Warning E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Warning E-mail field';
                }
            }
            group(Integration)
            {
                field("Pdf2Nav Send pdf"; "Pdf2Nav Send pdf")
                {
                    ApplicationArea = All;
                    Caption = 'Pdf2Nav send via NaviDocs';
                    ToolTip = 'Specifies the value of the Pdf2Nav send via NaviDocs field';
                }
                field("Pdf2Nav Table Filter"; "Pdf2Nav Table Filter")
                {
                    ApplicationArea = All;
                    Caption = 'Tablefilter';
                    ToolTip = 'Specifies the value of the Tablefilter field';
                }
            }
            group(Logging)
            {
                Caption = 'Logging';
                field("Log to Activity Log"; "Log to Activity Log")
                {
                    ApplicationArea = All;
                    Editable = ShowLogToActivityLog;
                    Visible = ShowLogToActivityLog;
                    ToolTip = 'Specifies the value of the Log to Activity Log field';
                }
                field("Keep Log for"; "Keep Log for")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Keep Log for field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        //-NPR5.23 [236043]
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
        //+NPR5.23 [236043]
        //-NPR5.30 [243998]
        ShowLogToActivityLog := not "Log to Activity Log";
        //+NPR5.30 [243998]
    end;

    var
        ShowLogToActivityLog: Boolean;
}

