table 6059767 "NaviDocs Setup"
{
    // NPR5.26/THRO/20160809 CASE 248662 Removed Field 15 Enable Posting Management
    //                                   Removed Field 16 Enable Document Management
    //                                   Trigger update of Handling profiles when activating NaviDocs
    //                                   Added field 3000 PDF2NAV Send pdf + 3001 PDF2NAV Table Filter
    // NPR5.30/THRO/20170209 CASE 243998 Added field 50 Log to Activity Log
    //                                   Added field 60 Keep Log for

    Caption = 'NaviDocs Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Enable NaviDocs";Boolean)
        {
            Caption = 'Enable NaviDocs';

            trigger OnValidate()
            var
                NaviDocsManagement: Codeunit "NaviDocs Management";
            begin
                //-NPR5.26 [248662]
                if "Enable NaviDocs" then
                  NaviDocsManagement.CreateHandlingProfileLibrary;
                //+NPR5.26 [248662]
            end;
        }
        field(20;"Auto Capture Payment";Boolean)
        {
            Caption = 'Auto Capture Payment';
        }
        field(50;"Log to Activity Log";Boolean)
        {
            Caption = 'Log to Activity Log';
            InitValue = true;

            trigger OnValidate()
            var
                NaviDocsManagement: Codeunit "NaviDocs Management";
            begin
                //-NPR5.30 [243998]
                if (not xRec."Log to Activity Log") and "Log to Activity Log" then
                  NaviDocsManagement.ConvertLog;
                if xRec."Log to Activity Log" then
                  "Log to Activity Log" := true;
                //+NPR5.30 [243998]
            end;
        }
        field(60;"Keep Log for";Duration)
        {
            Caption = 'Keep Log for';
        }
        field(1000;"Enable NAS";Boolean)
        {
            Caption = 'Enable NAS';
        }
        field(1010;"Max Retry Qty";Integer)
        {
            Caption = 'Max Retry Qty';
            InitValue = 3;
        }
        field(1020;"NAS Interval";Integer)
        {
            Caption = 'NAS Interval (Sec)';
        }
        field(2000;"Send Warming E-mail";Boolean)
        {
            Caption = 'Send Warming E-mail';
        }
        field(2001;"Warning E-mail";Text[250])
        {
            Caption = 'Warning E-mail';
        }
        field(3000;"Pdf2Nav Send pdf";Boolean)
        {
            Caption = 'Pdf2Nav Send pdf';
        }
        field(3001;"Pdf2Nav Table Filter";Text[100])
        {
            Caption = 'Pdf2Nav Table Filter';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

