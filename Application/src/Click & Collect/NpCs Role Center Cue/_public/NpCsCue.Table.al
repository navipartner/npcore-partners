table 6150841 "NPR NpCs Cue"
{
    Access = Public;
    DataClassification = CustomerContent;
    Caption = 'Collect in Store Cue';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(10; "CiS Orders - Pending"; Integer)
        {
            Caption = 'Pending Collect Orders';
            FieldClass = FlowField;
            CalcFormula = count("NPR NpCs Document" where(Type = const("Collect in Store"), "Document Type" = filter(Order | "Posted Invoice"), "Processing Status" = const(Pending)));
            Editable = false;
        }
        field(15; "CiS Orders - Confirmed"; Integer)
        {
            Caption = 'Confirmed Collect Orders';
            FieldClass = FlowField;
            CalcFormula = count("NPR NpCs Document" where(Type = const("Collect in Store"), "Document Type" = filter(Order | "Posted Invoice"), "Processing Status" = const(Confirmed), "Delivery Status" = const(Ready)));
            Editable = false;
        }
        field(20; "CiS Orders - Finished"; Integer)
        {
            Caption = 'Finished Collect Orders';
            FieldClass = FlowField;
            CalcFormula = count("NPR NpCs Document" where(Type = const("Collect in Store"), "Document Type" = filter(Order | "Posted Invoice"), "Processing Status" = const(Confirmed), "Delivery Status" = const(Delivered)));
            Editable = false;
        }
#if not BC17
        field(25; "Spfy CC Orders - Unprocessed"; Integer)
        {
            Caption = 'Unprocessed Shopify CC Orders';
            FieldClass = FlowField;
            CalcFormula = count("NPR Spfy C&C Order" where(Status = const(Error)));
            Editable = false;
            ObsoleteState = Pending;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'Moved to a PTE as it was a customization for a specific customer.';
        }
#endif
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}