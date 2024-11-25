table 6150920 "NPR MM Member Payment Method"
{
    Access = Internal;
    Caption = 'Member Payment Method';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(3; "BC Record ID"; RecordId)
        {
            Caption = 'BC Record ID';
            DataClassification = CustomerContent;
        }
        field(10; PSP; Enum "NPR MM Subscription PSP")
        {
            Caption = 'PSP';
            DataClassification = CustomerContent;
        }
        field(20; Status; Enum "NPR MM Payment Method Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (Status = Status::Archived) and Default then
                    Default := false;
            end;
        }
        field(30; "Payment Instrument Type"; Text[30])
        {
            Caption = 'Payment Instrument Type';
            DataClassification = CustomerContent;
        }
        field(40; "Payment Brand"; Text[30])
        {
            Caption = 'Payment Brand';
            DataClassification = CustomerContent;
        }
        field(50; "PAN Last 4 Digits"; Text[4])
        {
            Caption = 'PAN Last 4 Digits';
            DataClassification = CustomerContent;
        }
        field(60; "Expiry Date"; Date)
        {
            Caption = 'Expiry Date';
            DataClassification = CustomerContent;
        }
        field(70; "Payment Token"; Text[64])
        {
            Caption = 'Payment Token';
            DataClassification = CustomerContent;
        }
        field(80; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MemberPaymentMethod: Record "NPR MM Member Payment Method";
            begin
                if Default then begin
                    MemberPaymentMethod.SetRange("Table No.", "Table No.");
                    MemberPaymentMethod.SetRange("BC Record ID", "BC Record ID");
                    MemberPaymentMethod.SetRange(Default, true);
                    MemberPaymentMethod.SetFilter("Entry No.", '<>%1', "Entry No.");
                    if not MemberPaymentMethod.IsEmpty() then
                        MemberPaymentMethod.ModifyAll(Default, false);
                end;
            end;
        }
        field(90; "Shopper Reference"; Text[50])
        {
            Caption = 'Shopper Reference';
            DataClassification = CustomerContent;
        }
        field(100; "Created from System Id"; Guid)
        {
            Caption = 'Created from System Id';
            DataClassification = CustomerContent;
        }
        field(110; "Payment Method Alias"; Text[80])
        {
            Caption = 'Payment Method Alias';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}