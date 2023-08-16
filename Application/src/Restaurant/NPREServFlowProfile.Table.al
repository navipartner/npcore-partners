table 6150673 "NPR NPRE Serv.Flow Profile"
{
    Access = Internal;
    Caption = 'Rest. Service Flow Profile';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Service Flow Profiles";
    LookupPageID = "NPR NPRE Service Flow Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Close Waiter Pad On"; Enum "NPR NPRE Serv.Flow Close W/Pad")
        {
            Caption = 'Close Waiter Pad On';
            DataClassification = CustomerContent;
            InitValue = Payment;

            trigger OnValidate()
            begin
                if "Close Waiter Pad On" in ["Close Waiter Pad On"::"Pre-Receipt if Served", "Close Waiter Pad On"::"Payment if Served"] then
                    Message(AvailableWithKDS);
                if "Close Waiter Pad On" = "Close Waiter Pad On"::"Pre-Receipt" then
                    if "Clear Seating On" = "Clear Seating On"::"Pre-Receipt if Served" then
                        "Clear Seating On" := "Clear Seating On"::"Pre-Receipt";
                if "Close Waiter Pad On" in ["Close Waiter Pad On"::"Pre-Receipt", "Close Waiter Pad On"::"Pre-Receipt if Served"] then
                    "Set W/Pad Ready for Pmt. On" := "Set W/Pad Ready for Pmt. On"::Manual;
            end;
        }
        field(30; "Seating Status after Clearing"; Code[10])
        {
            Caption = 'Seating Status after Clearing';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(40; "Clear Seating On"; Enum "NPR NPRE Serv.Flow Clear Seat.")
        {
            Caption = 'Clear Seating On';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Clear Seating On" = "Clear Seating On"::"Pre-Receipt if Served" then begin
                    if "Close Waiter Pad On" = "Close Waiter Pad On"::"Pre-Receipt" then
                        FieldError("Close Waiter Pad On");
                    Message(AvailableWithKDS);
                end;
            end;
        }
        field(50; "Only if Fully Paid"; Boolean)
        {
            Caption = 'Only if Fully Paid';
            DataClassification = CustomerContent;
        }
        field(60; "W/Pad Ready for Pmt. Status"; Code[10])
        {
            Caption = 'W/Pad Ready for Pmt. Status';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPad));
        }
        field(70; "Set W/Pad Ready for Pmt. On"; Enum "NPR NPRE W/Pad Status Pmt. On")
        {
            Caption = 'Set W/Pad Ready for Pmt. On';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Set W/Pad Ready for Pmt. On" = "Set W/Pad Ready for Pmt. On"::Manual then
                    exit;
                if "Close Waiter Pad On" in ["Close Waiter Pad On"::"Pre-Receipt", "Close Waiter Pad On"::"Pre-Receipt if Served"] then
                    FieldError("Close Waiter Pad On");
                if "Set W/Pad Ready for Pmt. On" = "Set W/Pad Ready for Pmt. On"::"Pre-Receipt if Served" then
                    Message(AvailableWithKDS);
            end;
        }
    }

    keys
    {
        key(Key1; "Code") { }
    }

    var
        AvailableWithKDS: Label 'The option is only available in KDS enabled environments. Please make sure you have KDS installed and enabled.';
}
