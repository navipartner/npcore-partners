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
            ObsoleteState = Pending;
            ObsoleteTag = '2026-09-29';
            ObsoleteReason = 'Only one background job is created per export, because the export is always generated as one complete XML file.';
        }
        field(7; "Split By Month"; Boolean)
        {
            Caption = 'Split By Month';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Pending;
            ObsoleteTag = '2026-09-29';
            ObsoleteReason = 'The Danish SAF-T Cash Register export is always generated as one complete XML file.';
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
            ObsoleteState = Pending;
            ObsoleteTag = '2026-09-29';
            ObsoleteReason = 'Exporting SAF-T files into a server folder is not supported in Business Central SaaS.';
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
            ObsoleteState = Pending;
            ObsoleteTag = '2026-09-29';
            ObsoleteReason = 'The Danish SAF-T Cash Register export is always generated as one complete XML file.';
        }
        field(33; "Disable Zip File Generation"; Boolean)
        {
            Caption = 'Disable Zip File Generation';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2026-09-29';
            ObsoleteReason = 'The SAF-T file is delivered as one XML file, not as a ZIP archive.';
        }
        field(34; "Create Multiple Zip Files"; Boolean)
        {
            Caption = 'Create Multiple Zip Files';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2026-09-29';
            ObsoleteReason = 'The SAF-T file is delivered as one XML file, not as a ZIP archive.';
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
}
