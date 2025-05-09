table 6150858 "NPR TM POS Ticket Profile"
{
    Access = Internal;
    Caption = 'POS Ticket Profile';
    DataClassification = CustomerContent;
    LookupPageId = "NPR TM POS Ticket Profiles";
    DrillDownPageId = "NPR TM POS Ticket Profiles";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Print Ticket On Sale"; Boolean)
        {
            Caption = 'Print Ticket On Sale';
            DataClassification = CustomerContent;
        }

        field(20; EndOfSaleAdmitMethod; Enum "NPR TM AdmitTicketOnEoSMethod")
        {
            Caption = 'End-Of-Sale Admit Method';
            DataClassification = CustomerContent;
            InitValue = LEGACY;
        }
        field(21; ShowSpinnerDuringWorkflowAdmit; Boolean)
        {
            Caption = 'Show Spinner During Workflow Admit';
            DataClassification = CustomerContent;
        }
        field(22; ScannerIdForUnitAdmitOnEndSale; Code[10])
        {
            Caption = 'Scanner ID For Unit Admit On End Of Sale';
            FieldClass = FlowField;
            CalcFormula = lookup("NPR SG SpeedGate".ScannerId where(Id = field(ScannerIdForUnitAdmitEoSId)));
        }
        field(23; ScannerIdForUnitAdmitEoSId; Guid)
        {
            Caption = 'Scanner GUID For Unit Admit On End Of Sale';
            DataClassification = CustomerContent;
            TableRelation = "NPR SG SpeedGate".Id;
        }

    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}