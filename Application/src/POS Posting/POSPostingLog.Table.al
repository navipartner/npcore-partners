table 6150635 "NPR POS Posting Log"
{
    Access = Internal;
    Caption = 'POS Posting Log';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Posting Log";
    LookupPageID = "NPR POS Posting Log";

    fields
    {
        field(10; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Posting Timestamp"; DateTime)
        {
            Caption = 'Posting Timestamp';
            DataClassification = CustomerContent;
        }
        field(21; "Posting Duration"; Duration)
        {
            Caption = 'Posting Duration';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(30; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(40; "With Error"; Boolean)
        {
            Caption = 'With Error';
            DataClassification = CustomerContent;
        }
        field(50; "Error Description"; Text[250])
        {
            Caption = 'Error Description';
            DataClassification = CustomerContent;
        }
        field(60; "POS Entry View"; Text[250])
        {
            Caption = 'POS Entry View';
            DataClassification = CustomerContent;
        }
        field(61; "Last POS Entry No. at Posting"; Integer)
        {
            Caption = 'Last POS Entry No. at Posting';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(90; "No. of POS Entries"; Integer)
        {
            CalcFormula = Count("NPR POS Entry" WHERE("POS Posting Log Entry No." = FIELD("Entry No.")));
            Caption = 'No. of POS Entries';
            Editable = false;
            FieldClass = FlowField;
        }
        field(95; "Posting Type"; Option)
        {
            Caption = 'Posting Type';
            DataClassification = CustomerContent;
            OptionMembers = Finance,Inventory;
            OptionCaption = 'Finance,Inventory';
            Editable = false;
        }
        field(96; "Posting Per"; Option)
        {
            Caption = 'Posting Per';
            DataClassification = CustomerContent;
            OptionMembers = " ","POS Period Register","POS Entry";
            OptionCaption = ' ,POS Period Register,POS Entry';
            Editable = false;
        }
        field(97; "Posting Per Entry No."; Integer)
        {
            Caption = 'Posting Per Entry No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Posting Per" = const("POS Entry")) "NPR POS Entry"
            else
            if ("Posting Per" = const("POS Period Register")) "NPR POS Period Register";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(200; "Parameter Posting Date"; Date)
        {
            Caption = 'Parameter Posting Date';
            DataClassification = CustomerContent;
        }
        field(201; "Parameter Replace Posting Date"; Boolean)
        {
            Caption = 'Parameter Replace Posting Date';
            DataClassification = CustomerContent;
        }
        field(202; "Parameter Replace Doc. Date"; Boolean)
        {
            Caption = 'Parameter Replace Doc. Date';
            DataClassification = CustomerContent;
        }
        field(205; "Parameter Post Item Entries"; Boolean)
        {
            Caption = 'Parameter Post Item Entries';
            DataClassification = CustomerContent;
        }
        field(206; "Parameter Post POS Entries"; Boolean)
        {
            Caption = 'Parameter Post POS Entries';
            DataClassification = CustomerContent;
        }
        field(207; "Parameter Post Compressed"; Boolean)
        {
            Caption = 'Parameter Post Compressed';
            DataClassification = CustomerContent;
        }
        field(208; "Parameter Stop On Error"; Boolean)
        {
            Caption = 'Parameter Stop On Error';
            DataClassification = CustomerContent;
        }
        field(209; "Parameter Post Sales Documents"; Boolean)
        {
            Caption = 'Parameter Post Sales Documents';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Posting Per Entry No.", "Posting Per", "Posting Type")
        {
            ObsoleteState = Removed;
            ObsoleteTag = '2023-08-28';
            ObsoleteReason = 'Use Key3 ["Posting Per Entry No.", "Posting Per", "Posting Type", "With Error"] instead';
            Enabled = false;
        }
        key(Key3; "Posting Per Entry No.", "Posting Per", "Posting Type", "With Error")
        {
        }
    }

    fieldgroups
    {
    }

    internal procedure OpenPOSPostingLog(POSEntry: Record "NPR POS Entry"; AllLogEntries: Boolean)
    var
        POSPostingLog: Record "NPR POS Posting Log";
        LogEntryNoFilter: Text;
    begin
        POSPostingLog.SetRange("Entry No.", POSEntry."POS Posting Log Entry No.");
        if POSPostingLog.FindLast() then
            LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");

        POSPostingLog.SetRange("Entry No.");
        if POSEntry."Post Item Entry Status" <> POSEntry."Post Item Entry Status"::Posted then begin
            POSPostingLog.SetRange("Posting Per", POSPostingLog."Posting Per"::"POS Entry");
            POSPostingLog.SetRange("Posting Per Entry No.", POSEntry."Entry No.");
            POSPostingLog.SetRange("Posting Type", POSPostingLog."Posting Type"::Inventory);
            if AllLogEntries then begin
                if POSPostingLog.FindSet() then
                    repeat
                        LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
                    until POSPostingLog.Next() = 0;
            end
            else begin
                if POSPostingLog.FindLast() then
                    LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
            end;
        end;

        if POSEntry."Post Entry Status" <> POSEntry."Post Entry Status"::Posted then begin
            if POSEntry."Post Item Entry Status" = POSEntry."Post Item Entry Status"::Posted then begin
                POSPostingLog.SetRange("Posting Per", POSPostingLog."Posting Per"::"POS Entry");
                POSPostingLog.SetRange("Posting Per Entry No.", POSEntry."Entry No.");
            end;
            POSPostingLog.SetRange("Posting Type", POSPostingLog."Posting Type"::Finance);
            if AllLogEntries then begin
                if POSPostingLog.FindSet() then
                    repeat
                        LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
                    until POSPostingLog.Next() = 0;
            end
            else begin
                if POSPostingLog.FindLast() then
                    LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
            end;
        end;

        POSPostingLog.SetRange("Posting Per", POSPostingLog."Posting Per"::"POS Period Register");
        POSPostingLog.SetRange("Posting Per Entry No.", POSEntry."POS Period Register No.");
        POSPostingLog.SetRange("Posting Type", POSPostingLog."Posting Type"::Finance);
        if AllLogEntries then begin
            if POSPostingLog.FindSet() then
                repeat
                    LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
                until POSPostingLog.Next() = 0;
        end
        else begin
            if POSPostingLog.FindLast() then
                LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
        end;

        POSPostingLog.SetRange("Posting Type", POSPostingLog."Posting Type"::Inventory);
        if AllLogEntries then begin
            if POSPostingLog.FindSet() then
                repeat
                    LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
                until POSPostingLog.Next() = 0;
        end
        else begin
            if POSPostingLog.FindLast() then
                LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
        end;

        if POSEntry."Post Sales Document Status" = POSEntry."Post Sales Document Status"::"Error while Posting" then begin
            POSPostingLog.SetRange("Posting Per", POSPostingLog."Posting Per"::"POS Entry");
            POSPostingLog.SetRange("Posting Per Entry No.", POSEntry."Entry No.");
            POSPostingLog.SetRange("Posting Type", POSPostingLog."Posting Type"::Finance);
            POSPostingLog.SetRange("With Error", true);
            if AllLogEntries then begin
                if POSPostingLog.FindSet() then
                    repeat
                        LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
                    until POSPostingLog.Next() = 0;
            end
            else begin
                if POSPostingLog.FindLast() then
                    LogEntryNoFilter += '|' + format(POSPostingLog."Entry No.");
            end;
        end;

        LogEntryNoFilter := DelChr(LogEntryNoFilter, '<', '|');
        POSPostingLog.Reset();
        POSPostingLog.SetFilter("Entry No.", LogEntryNoFilter);
        Page.Run(0, POSPostingLog);
    end;
}

