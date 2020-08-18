table 6150673 "NPRE Service Flow Profile"
{
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Rest. Service Flow Profile';
    DrillDownPageID = "NPRE Service Flow Profiles";
    LookupPageID = "NPRE Service Flow Profiles";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Close Waiter Pad On";Option)
        {
            Caption = 'Close Waiter Pad On';
            InitValue = Payment;
            OptionCaption = 'Manual,Pre-Receipt,Payment,Pre-Receipt if Served,Payment if Served';
            OptionMembers = Manual,"Pre-Receipt",Payment,"Pre-Receipt if Served","Payment if Served";

            trigger OnValidate()
            begin
                if "Close Waiter Pad On" in ["Close Waiter Pad On"::"Pre-Receipt if Served", "Close Waiter Pad On"::"Payment if Served"] then
                  Message(AvailableWithKDS);
                if "Close Waiter Pad On" = "Close Waiter Pad On"::"Pre-Receipt" then
                  if "Clear Seating On" = "Clear Seating On"::"Pre-Receipt if Served" then
                    "Clear Seating On" := "Clear Seating On"::"Pre-Receipt";
            end;
        }
        field(30;"Seating Status after Clearing";Code[10])
        {
            Caption = 'Seating Status after Clearing';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=CONST(Seating));
        }
        field(40;"Clear Seating On";Option)
        {
            Caption = 'Clear Seating On';
            OptionMembers = "Waiter Pad Close","Pre-Receipt","Pre-Receipt if Served";

            trigger OnValidate()
            begin
                if "Clear Seating On" = "Clear Seating On"::"Pre-Receipt if Served" then begin
                  if "Close Waiter Pad On" = "Close Waiter Pad On"::"Pre-Receipt" then
                    FieldError("Close Waiter Pad On");
                  Message(AvailableWithKDS);
                end;
            end;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        AvailableWithKDS: Label 'The option is only available in KDS enabled environments. Please make sure you have KDS installed and enabled.';
}

