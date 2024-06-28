table 6150791 "NPR AF Rec. Webhook Request"
{
    Access = Internal;

    Caption = 'Adyen Reconciliation Report';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'ID';
            AutoIncrement = true;
        }
        field(10; "Webhook Reference"; Text[80])
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Webhook Reference';
        }
        field(20; "Status Code"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Status Code';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
            ObsoleteReason = 'Not used.';
        }
        field(30; "Status Description"; Text[256])
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Status Description';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
            ObsoleteReason = 'Not used.';
        }
        field(40; Live; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'Live';
        }
        field(50; "Creation Date"; DateTime)
        {
            Editable = false;
            DataClassification = CustomerContent;
            Caption = 'Creation Date & Time';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
            ObsoleteReason = 'SystemCreatedAt field is used instead.';
        }
        field(60; "Report Download URL"; Text[2048])
        {
            Editable = false;
            DataClassification = CustomerContent;
            Caption = 'Report Download URL';
        }
        field(70; "Report Data"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Report Data';
        }
        field(80; "Report Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Report Name';

            trigger OnValidate()
            var
                AdyenManagement: Codeunit "NPR Adyen Management";
            begin
                if "Report Name" <> '' then
                    "Report Type" := AdyenManagement.DefineReportType("Report Name");
            end;
        }
        field(90; "PSP Reference"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'PSP Reference';
        }
        field(100; "Report Type"; Enum "NPR Adyen Report Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Report Type';
        }
        field(110; "Request Data"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Data';
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR35.0';
            ObsoleteReason = 'Not used.';
        }
        field(120; Processed; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed';
        }
        field(130; "Adyen Webhook Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Adyen Webhook Entry No.';
            TableRelation = "NPR Adyen Webhook"."Entry No.";
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
