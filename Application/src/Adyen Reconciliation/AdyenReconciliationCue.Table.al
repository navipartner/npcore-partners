table 6150802 "NPR Adyen Reconciliation Cue"
{
    Access = Internal;

    Caption = 'NP Pay Reconciliation Cue';
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
            CalcFormula = count("NPR Adyen Reconciliation Hdr" where(Status = filter(Matched | Unmatched)));
            Caption = 'Unposted Documents';
            FieldClass = FlowField;
        }
        field(20; "Outstanding EFT Tr. Requests"; Integer)
        {
            CalcFormula = count("NPR EFT Transaction Request" where("Reconciled" = const(false),
                                                                    Finished = field("EFT Tr. Date Filter"),
                                                                    "Integration Type" = field("EFT Tr. Integr. Type Filter"),
                                                                    "Financial Impact" = const(true)));
            Caption = 'Outstanding EFT Transaction Requests';
            FieldClass = FlowField;
        }
        field(30; "EFT Tr. Date Filter"; DateTime)
        {
            Caption = 'EFT Tr. Date Filter';
            FieldClass = FlowFilter;
        }
        field(40; "Outstanding EC Payment Lines"; Integer)
        {
            CalcFormula = count("NPR Magento Payment Line" where("Reconciled" = const(false),
                                                                "Date Captured" = field("EC Payment Date Filter"),
                                                                "Payment Gateway Code" = field("EC PG Filter")));
            Caption = 'Outstanding E-commerce Payment Lines';
            FieldClass = FlowField;
        }
        field(50; "EC Payment Date Filter"; Date)
        {
            Caption = 'E-commerce Payment Date Filter';
            FieldClass = FlowFilter;
        }
        field(60; "EFT Tr. Integr. Type Filter"; Code[20])
        {
            Caption = 'EFT Transaction Integration Type Filter';
            FieldClass = FlowFilter;
        }
        field(70; "EC PG Filter"; Code[10])
        {
            Caption = 'E-Commerce Payment Gateway Filter';
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
