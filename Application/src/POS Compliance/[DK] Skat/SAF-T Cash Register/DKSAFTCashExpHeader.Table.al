table 6150748 "NPR DK SAF-T Cash Exp. Header"
{
    Access = Internal;
    Caption = 'SAF-T Cash Register Export Header';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR DK SAF-T Cash Export Card";
    LookupPageId = "NPR DK SAF-T Cash Export Card";

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Export Name Code"; Code[20])
        {
            Caption = 'Export Name Code';
            DataClassification = CustomerContent;
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(4; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(5; "Parallel Processing"; Boolean)
        {
            Caption = 'Parallel Processing';
            DataClassification = CustomerContent;
        }
        field(6; "Max No. Of Jobs"; Integer)
        {
            Caption = 'Max No. Of Jobs';
            DataClassification = CustomerContent;
            InitValue = 3;
            MinValue = 1;
        }
        field(7; "Split By Month"; Boolean)
        {
            Caption = 'Split By Month';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                if "Split By Month" then
                    "Split By Date" := false;
            end;
        }
        field(8; "Earliest Start Date/Time"; DateTime)
        {
            Caption = 'Earliest Start Date/Time';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                DateTimeDialog: Page "Date-Time Dialog";
            begin
                DateTimeDialog.SetDateTime(RoundDateTime("Earliest Start Date/Time", 1000));
                if DateTimeDialog.RunModal() = Action::OK then
                    "Earliest Start Date/Time" := DateTimeDialog.GetDateTime();
            end;
        }
        field(9; "Folder Path"; Text[1024])
        {
            Caption = 'Folder Path';
            DataClassification = CustomerContent;
        }
        field(10; Status; Enum "NPR DK SAF-T Cash Exp. Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Header Comment"; Text[18])
        {
            Caption = 'Header Comment';
            DataClassification = CustomerContent;
        }
        field(12; "Execution Start Date/Time"; DateTime)
        {
            Caption = 'Execution Start Date/Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Execution End Date/Time"; DateTime)
        {
            Caption = 'Execution End Date/Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(32; "Split By Date"; Boolean)
        {
            Caption = 'Split By Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Split By Date" then
                    "Split By Month" := false;
            end;
        }
        field(33; "Disable Zip File Generation"; Boolean)
        {
            Caption = 'Disable Zip File Generation';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Disable Zip File Generation" then
                    TestField("Folder Path");
                "Create Multiple Zip Files" := false;
            end;
        }
        field(34; "Create Multiple Zip Files"; Boolean)
        {
            Caption = 'Create Multiple Zip Files';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Create Multiple Zip Files" then
                    "Disable Zip File Generation" := false;
            end;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Parallel Processing" := TaskScheduler.CanCreateTask();
    end;

    trigger OnDelete()
    var
        SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
    begin
        SAFTExportMgt.DeleteExport(Rec);
    end;

    procedure AllowedToExportIntoFolder(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSaaS() then
            exit(false);
        exit("Folder Path" <> '');
    end;
}
