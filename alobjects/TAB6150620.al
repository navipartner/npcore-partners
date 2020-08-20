table 6150620 "POS Period Register"
{
    // NPR5.29/AP /20170126 CASE 262628 Recreated ENU-captions
    // NPR5.30/AP /20170209 CASE 261728 Renamed field "Store Code" -> "POS Store Code"
    //                                  Renamed field "POS No." -> "POS Unit No."
    // NPR5.32/AP /20172504 CASE 262628 Renamed table "POS Posting Register" -> "POS Ledger Register"
    //                                  Renamed field "From Entry No." -> "Opening Entry No."
    //                                  Renamed field "To Entry No." -> "Closing Entry No."
    // NPR5.36/TSA/20170630 CASE 282251 Added field Status to capture the state if register entries within the open/close range
    // NPR5.36/AP /20170717 CASE 262628 Renamed field "Entry No." -> "No."
    // NPR5.36/BR /20170718 CASE 279552 Generate Document No. from No. Series
    // NPR5.36/AP /20170725 CASE 279547 Added key POS Unit No.
    // NPR5.37/BR /20171012 CASE 293227 Changed Compression option
    // NPR5.38/BR /20171214 CASE 299888 Renamed from POS Ledger Register to POS Period Register (incl. Captions)
    // NPR5.38/BR /20180125 CASE 302803 Get Posting Compression from POS Store
    // NPR5.39/BR /20180214 CASE 295007 Added Fields "From External Source","External Source Name","External Source Entry No."

    Caption = 'POS Period Register';
    DataClassification = CustomerContent;
    DrillDownPageID = "POS Period Register List";
    LookupPageID = "POS Period Register List";

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Store";

            trigger OnValidate()
            var
                POSStore: Record "POS Store";
            begin
                //-NPR5.38 [302803]
                if "POS Store Code" <> '' then begin
                    POSStore.Get("POS Store Code");
                    Validate("Posting Compression", POSStore."Posting Compression");
                end;
                //+NPR5.38 [302803]
            end;
        }
        field(3; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Unit";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(10; "Opening Entry No."; Integer)
        {
            Caption = 'From Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Entry";
        }
        field(11; "Closing Entry No."; Integer)
        {
            Caption = 'To Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Entry";
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Open,End of Day,Closed';
            OptionMembers = NEW,OPEN,EOD,CLOSED;
        }
        field(21; "Posting Compression"; Option)
        {
            Caption = 'Posting Compression';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            InitValue = "Per POS Entry";
            OptionCaption = 'Uncompressed,Per POS Entry,Per POS Period';
            OptionMembers = Uncompressed,"Per POS Entry","Per POS Period";

            trigger OnValidate()
            begin
                if "Posting Compression" > "Posting Compression"::"Per POS Entry" then
                    TestField("Document No.");
            end;
        }
        field(30; "Opened Date"; DateTime)
        {
            Caption = 'Opened Date';
            DataClassification = CustomerContent;
        }
        field(31; "End of Day Date"; DateTime)
        {
            Caption = 'End of Day Date';
            DataClassification = CustomerContent;
        }
        field(210; "From External Source"; Boolean)
        {
            Caption = 'From External Source';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
        }
        field(211; "External Source Name"; Text[50])
        {
            Caption = 'External Source Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
        }
        field(212; "External Source Entry No."; Integer)
        {
            Caption = 'External Source Entry No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "POS Unit No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        GenerateDocumentNo;
    end;

    trigger OnModify()
    begin
        if Status <> xRec.Status then
            UpdateTimeStamps;
    end;

    local procedure GenerateDocumentNo()
    var
        POSStore: Record "POS Store";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if ("Document No." <> '') then
            exit;
        TestField("POS Store Code");
        POSStore.Get("POS Store Code");
        if POSStore."POS Period Register No. Series" <> '' then
            NoSeriesMgt.InitSeries(POSStore."POS Period Register No. Series", xRec."No. Series", WorkDate, "Document No.", "No. Series");
    end;

    local procedure UpdateTimeStamps()
    begin
        case Status of
            Status::OPEN:
                begin
                    "Opened Date" := CurrentDateTime;
                end;
            Status::EOD:
                begin
                    "End of Day Date" := CurrentDateTime;
                end;
        end;
    end;
}

