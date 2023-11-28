table 6059785 "NPR TM Ticket"
{
    Caption = 'Tickets';
    DrillDownPageID = "NPR TM Ticket List";
    LookupPageID = "NPR TM Ticket List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GetTicketType();
                    _NoSeriesMgt.TestManual(_TicketType."No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Ticket Type Code"; Code[10])
        {
            Caption = 'Ticket Type Code';
            TableRelation = "NPR TM Ticket Type";
            DataClassification = CustomerContent;
        }
        field(3; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(20; "Valid From Date"; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
        }
        field(21; "Valid From Time"; Time)
        {
            Caption = 'Valid From Time';
            DataClassification = CustomerContent;
        }
        field(22; "Valid To Date"; Date)
        {
            Caption = 'Valid To Date';
            DataClassification = CustomerContent;
        }
        field(23; "Valid To Time"; Time)
        {
            Caption = 'Valid To Time';
            DataClassification = CustomerContent;
        }
        field(30; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(31; "Blocked Date"; Date)
        {
            Caption = 'Blocked Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(40; "Printed Date"; Date)
        {
            Caption = 'Printed Date';
            DataClassification = CustomerContent;
        }
        field(50; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(58; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(59; "Source Code"; Code[20])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
        }
        field(60; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(61; "Sales Header Type"; Option)
        {
            Caption = 'Sales Header Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(62; "Sales Header No."; Code[20])
        {
            Caption = 'Sales Header No.';
            DataClassification = CustomerContent;
        }
        field(63; "Sales Receipt No."; Code[20])
        {
            Caption = 'POS Reciept No.';
            DataClassification = CustomerContent;
        }
        field(64; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(70; "Ticket Reservation Entry No."; Integer)
        {
            Caption = 'Ticket Reservation Entry No.';
            TableRelation = "NPR TM Ticket Reservation Req.";
            DataClassification = CustomerContent;
        }
        field(100; "External Member Card No."; Code[20])
        {
            Caption = 'External Member Card No.';
            DataClassification = CustomerContent;
        }
        field(101; "No. Of Access"; Decimal)
        {
            Caption = 'No. Of Access';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(102; "External Ticket No."; Code[30])
        {
            Caption = 'External Ticket No.';
            DataClassification = CustomerContent;
        }
        field(105; "Ticket No. for Printing"; Text[50])
        {
            Caption = 'Ticket No. for Printing';
            DataClassification = CustomerContent;
        }
        field(200; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(201; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(202; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Sales Receipt No.")
        {
        }
        key(Key3; "Sales Header Type", "Sales Header No.")
        {
        }
        key(Key4; "External Ticket No.")
        {
        }
        key(Key5; "Ticket No. for Printing")
        {
        }
        key(Key6; "Ticket Reservation Entry No.")
        {
        }
        key(Key7; "External Member Card No.", "Item No.", "Variant Code", "Document Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        NotUnique: Label 'External Ticket No. must be unique [%1 - %2].';
        GenerateNumberCount: Integer;
    begin
        GetTicketType();

        if ("No." = '') then
            _NoSeriesMgt.InitSeries(_TicketType."No. Series", xRec."No. Series", Today, Rec."No.", Rec."No. Series");

        Rec."Last Date Modified" := Today();

        GenerateNumberCount := 0;
        if (Rec."External Ticket No." = '') then begin

            Rec."External Ticket No." := _TicketMgt.GenerateNumberPattern(_TicketType."External Ticket Pattern", Rec."No.");
            if (not CheckIsUnique(Rec."External Ticket No.")) then begin
                repeat
                    Rec."External Ticket No." := _TicketMgt.GenerateNumberPattern(_TicketType."External Ticket Pattern", Rec."No.");
                    GenerateNumberCount += 1;
                until ((CheckIsUnique(Rec."External Ticket No.")) or (GenerateNumberCount >= 10));

                ReportTicketNumberPattern(Rec."No.", _TicketType."External Ticket Pattern", Rec."Ticket Type Code", GenerateNumberCount, GenerateNumberCount < 10);
            end;

        end else begin
            if (not CheckIsUnique(Rec."External Ticket No.")) then
                Error(NotUnique, Rec."No.", Rec."External Ticket No.");
        end;

    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today();
    end;

    var
        _TicketType: Record "NPR TM Ticket Type";
        _NoSeriesMgt: Codeunit NoSeriesManagement;
        _TicketMgt: Codeunit "NPR TM Ticket Management";

    internal procedure GetTicketType()
    begin
        if (_TicketType.Code = Rec."Ticket Type Code") and (_TicketType.Code <> '') then
            exit;

        _TicketType.Get(Rec."Ticket Type Code");
    end;

    local procedure CheckIsUnique(ExternalTicketNumber: Code[30]): Boolean
    var
        Ticket: Record "NPR TM Ticket";
    begin
        //with RT11 -> Ticket.ReadIsolation(ReadIsolation::ReadUncommitted);
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNumber);
        exit(Ticket.IsEmpty());
    end;

    local procedure ReportTicketNumberPattern(TicketNumber: Code[20]; Pattern: Code[30]; TicketTypeCode: Code[10]; NumberOfAttempts: Integer; Warning: Boolean)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());

        CustomDimensions.Add('NPR_TicketNumber', TicketNumber);
        CustomDimensions.Add('NPR_TicketPattern', Pattern);
        CustomDimensions.Add('NPR_TicketTypeCode', TicketTypeCode);
        CustomDimensions.Add('NPR_Attempts', Format(NumberOfAttempts, 0, 9));

        if (Warning) then
            Session.LogMessage('NPR_ExternalTicketPatternNotUnique', 'Ticket External Number Generation Failure.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);

        if (not Warning) then
            Session.LogMessage('NPR_ExternalTicketPatternNotUnique', 'Ticket External Number Generation Failure.', Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

}


