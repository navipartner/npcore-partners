table 6151060 "NPR Customer GDPR SetUp"
{
    Access = Internal;
    Caption = 'Customer Data Anonymization Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary key"; Code[10])
        {
            Caption = 'Primary key';
            DataClassification = CustomerContent;
        }
        field(2; "Anonymize After"; DateFormula)
        {
            Caption = 'Anonymize After';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Customer: Record Customer;
                RecalcQst: Label 'Changing %1 will recalculate the %2 for all customers on the next run. Do you want to continue?', Comment = '%1 = Anonymize After field caption, %2 = Estimated Cleanup Date field caption';
                TooShortMsg: Label 'The %1 period ''%2'' is shorter than a year. Customers could be anonymized sooner than intended - a retention period is normally expressed in years.', Comment = '%1 = Anonymize After field caption, %2 = the entered period';
            begin
                if not GuiAllowed() then
                    exit;

                // Changing an existing period recomputes every customer's Estimated Cleanup Date on the next run - confirm first.
                if (Format(xRec."Anonymize After") <> '') and (Format(xRec."Anonymize After") <> Format(Rec."Anonymize After")) then
                    if not Confirm(RecalcQst, false, Rec.FieldCaption("Anonymize After"), Customer.FieldCaption("NPR Estimated Cleanup Date")) then
                        Error('');

                // Warn when the period is shorter than a year (e.g. a typo or a negative formula).
                if (Format(Rec."Anonymize After") <> '') and ((CalcDate(Rec."Anonymize After", Today()) - Today()) < 365) then
                    Message(TooShortMsg, Rec.FieldCaption("Anonymize After"), Format(Rec."Anonymize After"));
            end;
        }
        field(3; "Customer Posting Group Filter"; Text[250])
        {
            Caption = 'Customer Posting Group Filter';
            DataClassification = CustomerContent;
        }
        field(4; "No of Customers"; Integer)
        {
            CalcFormula = Count("NPR Customers to Anonymize");
            Caption = 'No of Customers';
            FieldClass = FlowField;
        }
        field(5; "Gen. Bus. Posting Group Filter"; Text[250])
        {
            Caption = 'Gen. Bus. Posting Group Filter';
            DataClassification = CustomerContent;
        }
        field(6; "Enable Job Queue"; Boolean)
        {
            Caption = 'Enable Job Queue';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                GDPRMgt: Codeunit "NPR NP GDPR Management";
            begin
                GDPRMgt.EnqueueJobEntries(Rec);
            end;
        }
    }

    keys
    {
        key(Key1; "Primary key")
        {
        }
    }

    fieldgroups
    {
    }
}

