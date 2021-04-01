table 6059767 "NPR NaviDocs Setup"
{
    Caption = 'NaviDocs Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Enable NaviDocs"; Boolean)
        {
            Caption = 'Enable NaviDocs';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NaviDocsManagement: Codeunit "NPR NaviDocs Management";
            begin
                if "Enable NaviDocs" then
                    NaviDocsManagement.CreateHandlingProfileLibrary;
            end;
        }
        field(20; "Auto Capture Payment"; Boolean)
        {
            Caption = 'Auto Capture Payment';
            DataClassification = CustomerContent;
        }
        field(50; "Log to Activity Log"; Boolean)
        {
            Caption = 'Log to Activity Log';
            InitValue = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NaviDocsManagement: Codeunit "NPR NaviDocs Management";
            begin
                if (not xRec."Log to Activity Log") and "Log to Activity Log" then
                    NaviDocsManagement.ConvertLog;
                if xRec."Log to Activity Log" then
                    "Log to Activity Log" := true;
            end;
        }
        field(60; "Keep Log for"; Duration)
        {
            Caption = 'Keep Log for';
            DataClassification = CustomerContent;
        }
        field(1000; "Enable NAS"; Boolean)
        {
            Caption = 'Enable NAS';
            DataClassification = CustomerContent;
        }
        field(1010; "Max Retry Qty"; Integer)
        {
            Caption = 'Max Retry Qty';
            InitValue = 3;
            DataClassification = CustomerContent;
        }
        field(1020; "NAS Interval"; Integer)
        {
            Caption = 'NAS Interval (Sec)';
            DataClassification = CustomerContent;
        }
        field(2000; "Send Warming E-mail"; Boolean)
        {
            Caption = 'Send Warming E-mail';
            DataClassification = CustomerContent;
        }
        field(2001; "Warning E-mail"; Text[250])
        {
            Caption = 'Warning E-mail';
            DataClassification = CustomerContent;
        }
        field(3000; "Pdf2Nav Send pdf"; Boolean)
        {
            Caption = 'Pdf2Nav Send pdf';
            DataClassification = CustomerContent;
        }
        field(3001; "Pdf2Nav Table Filter"; Text[100])
        {
            Caption = 'Pdf2Nav Table Filter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

