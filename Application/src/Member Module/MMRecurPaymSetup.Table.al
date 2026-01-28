table 6060093 "NPR MM Recur. Paym. Setup"
{
    Access = Internal;
    Caption = 'Recurring Payment Setup';
    DataClassification = CustomerContent;
    LookupPageId = "NPR MM Recurring Payments";
    DrillDownPageId = "NPR MM Recurring Payments";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Payment Service Provider Code"; Code[20])
        {
            Caption = 'Payment Service Provider Code';
            DataClassification = CustomerContent;
        }
        field(15; "PSP Recurring Plan ID"; Text[30])
        {
            Caption = 'PSP Recurring Plan ID';
            DataClassification = CustomerContent;
        }
        field(20; "Document No. Series"; Code[20])
        {
            Caption = 'Document No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50; "Revenue Account"; Code[20])
        {
            Caption = 'Revenue Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(55; "Payment Terms Code"; Code[10])
        {
            Caption = 'Payment Terms Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Terms";
        }
        field(100; "Period Alignment"; Option)
        {
            Caption = 'Period Alignment';
            DataClassification = CustomerContent;
            OptionCaption = 'Current Period,Today,Back-to-Back';
            OptionMembers = CURRENT_PERIOD,TODAY,BACK_TO_BACK;
        }
        field(105; "Period Size"; DateFormula)
        {
            Caption = 'Period Size';
            DataClassification = CustomerContent;
        }
        field(110; "Subscr. Auto-Renewal On"; Enum "NPR MM Subscr. Auto-Renewal")
        {
            Caption = 'Subscr. Auto-Renewal On';
            DataClassification = CustomerContent;
        }
        field(115; "First Attempt Offset (Days)"; Integer)
        {
            Caption = 'First Attempt Offset (Days)';
            DataClassification = CustomerContent;
        }
        field(120; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code".Code;

            trigger OnValidate()
            begin
                CheckSourceCodeIsValid();
            end;
        }
        field(200; "Gen. Journal Template Name"; Code[10])
        {
            Caption = 'Gen. Journal Template Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Gen. Journal Template".Name;
        }
        field(209; "Gen. Journal Batch Name"; Code[10])
        {
            Caption = 'Gen. Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Gen. Journal Template Name"));
        }
        field(6; "Max. Pay. Process Try Count"; Integer)
        {
            Caption = 'Max. Payment Process Try Count';
            DataClassification = CustomerContent;
            InitValue = 5;
        }
        field(3; SubscriptionCommitmentPeriod; DateFormula)
        {
            Caption = 'Subscription Commitment Period';
            DataClassification = CustomerContent;
        }
        field(4; SubscriptionCommitStartDate; Option)
        {
            Caption = 'Subscription Commitment Start Date';
            DataClassification = CustomerContent;
            OptionMembers = WORK_DATE,SUBS_VALID_FROM;
            OptionCaption = 'Work Date,Subscription Valid From';
        }
        field(5; TerminationPeriod; DateFormula)
        {
            Caption = 'Termination Period';
            DataClassification = CustomerContent;
        }
        field(7; EnforceTerminationPeriod; Boolean)
        {
            Caption = 'Enforce Termination Period';
            DataClassification = CustomerContent;
        }
        field(9; "Subscr Auto-Renewal Sched Code"; Code[20])
        {
            Caption = 'Subscr. Auto-Renew Schedule Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Renewal Sched Hdr".Code;
        }
        field(130; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(131; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnInsert()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.UpdateDefaultDim(Database::"NPR MM Recur. Paym. Setup", Code, "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnDelete()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.DeleteDefaultDim(Database::"NPR MM Recur. Paym. Setup", Code);
    end;

    internal procedure CheckSourceCodeIsValid()
    var
        SourceCodeSetup: Record "Source Code Setup";
        JournalsSourceCodesList: List of [Code[10]];
        InValidSourceCodeErr: Label 'The source code %1 is already in use for general, sales or purchase journal postings. Please select a different value for the recurring payment source code.';
    begin
        SourceCodeSetup.Get();
        JournalsSourceCodesList.Add(SourceCodeSetup."General Journal");
        JournalsSourceCodesList.Add(SourceCodeSetup."Purchase Journal");
        JournalsSourceCodesList.Add(SourceCodeSetup."Sales Journal");
        if JournalsSourceCodesList.Contains("Source Code") then
            Error(InValidSourceCodeErr, "Source Code");
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary() then begin
            DimMgt.SaveDefaultDim(Database::"NPR MM Recur. Paym. Setup", Code, FieldNumber, ShortcutDimCode);
            Modify();
        end;
    end;
}
