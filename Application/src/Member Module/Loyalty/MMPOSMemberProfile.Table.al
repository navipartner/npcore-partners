table 6150851 "NPR MM POS Member Profile"
{
    Access = Internal;
    Caption = 'POS Member Profile';
    DataClassification = CustomerContent;
    LookupPageId = "NPR MM POS Member Profiles";
    DrillDownPageId = "NPR MM POS Member Profiles";
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
        field(4; "Print Membership On Sale"; Boolean)
        {
            Caption = 'Print Membership On Sale';
            DataClassification = CustomerContent;
        }
        field(5; "Send Notification On Sale"; Boolean)
        {
            Caption = 'Send Notification On Sale';
            DataClassification = CustomerContent;
        }
        field(6; "Alteration Group"; Code[10])
        {
            Caption = 'Alteration Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Members. Alter. Group";
        }

        field(20; EndOfSaleAdmitMethod; Enum "NPR MM AdmitMemberOnEoSMethod")
        {
            Caption = 'End-Of-Sale Admit Method';
            DataClassification = CustomerContent;
            InitValue = LEGACY;
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