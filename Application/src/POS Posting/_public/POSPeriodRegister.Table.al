table 6150620 "NPR POS Period Register"
{
    Caption = 'POS Period Register';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Period Register List";
    LookupPageID = "NPR POS Period Register List";

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
            TableRelation = "NPR POS Store";

            trigger OnValidate()
            var
                POSStore: Record "NPR POS Store";
                POSPostingProfile: Record "NPR POS Posting Profile";
            begin
                if "POS Store Code" <> '' then begin
                    POSStore.Get("POS Store Code");
                    POSStore.GetProfile(POSPostingProfile);
                    Validate("Posting Compression", POSPostingProfile."Posting Compression");
                end;
            end;
        }
        field(3; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(6; "No. Series"; Code[20])
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
            TableRelation = "NPR POS Entry";
        }
        field(11; "Closing Entry No."; Integer)
        {
            Caption = 'To Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
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
            var
                POSEntry: Record "NPR POS Entry";
            begin
                POSEntry.SetCurrentKey("POS Store Code", "Post Entry Status");
                POSEntry.SetRange("POS Store Code", Rec."POS Store Code");
                POSEntry.SetFilter("Post Entry Status", '%1|%2',
                    POSEntry."Post Entry Status"::Unposted, POSEntry."Post Entry Status"::"Error while Posting");
                if not POSEntry.IsEmpty() then
                    Error(PostingCompressionErr,
                        Rec."POS Store Code", FieldCaption("Posting Compression"));

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

    var
        PostingCompressionErr: Label 'There are unposted entries in POS Entry table in POS Store %1. Please post then before updating %2.';

    trigger OnInsert()
    begin
        GenerateDocumentNo();
    end;

    trigger OnModify()
    begin
        if Status <> xRec.Status then
            UpdateTimeStamps();
    end;

    local procedure GenerateDocumentNo()
    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if ("Document No." <> '') then
            exit;
        TestField("POS Unit No.");
        POSUnit.Get("POS Unit No.");
        POSStore.get(POSUnit."POS Store Code");
        POSStore.GetProfile(POSPostingProfile);
        if POSPostingProfile."POS Period Register No. Series" <> '' then
            NoSeriesMgt.InitSeries(POSPostingProfile."POS Period Register No. Series", xRec."No. Series", WorkDate(), "Document No.", "No. Series");
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
