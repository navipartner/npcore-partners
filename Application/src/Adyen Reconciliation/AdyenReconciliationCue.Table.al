table 6150802 "NPR Adyen Reconciliation Cue"
{
    Access = Internal;

    Caption = 'Adyen Reconciliation Cue';
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; "Unposted Documents"; Integer)
        {
            CalcFormula = count("NPR Adyen Reconciliation Hdr" where(Posted = const(false)));
            Caption = 'Unposted Documents';
            FieldClass = FlowField;
        }
        field(20; "Outstanding EFT Tr. Requests"; Integer)
        {
            CalcFormula = count("NPR EFT Transaction Request" where("Reconciled" = const(false),
            Finished = field("EFT Tr. Date Filter"),
            "Financial Impact" = const(true)));
            Caption = 'Outstanding EFT Transaction Requests';
            FieldClass = FlowField;
        }
        field(30; "EFT Tr. Date Filter"; DateTime)
        {
            Caption = ' EFT Tr. Date Filter';
            FieldClass = FlowFilter;
        }

    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
