table 6150683 "NPRE Kitchen Station Selection"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Station Selection';

    fields
    {
        field(10;"Restaurant Code";Code[20])
        {
            Caption = 'Restaurant Code';
            TableRelation = "NPRE Restaurant";
        }
        field(20;"Seating Location";Code[20])
        {
            Caption = 'Seating Location';
            TableRelation = "NPRE Seating Location".Code WHERE ("Restaurant Code"=FIELD("Restaurant Code"));
        }
        field(40;"Serving Step";Code[10])
        {
            Caption = 'Serving Step';
            TableRelation = "NPRE Flow Status".Code WHERE ("Status Object"=CONST(WaiterPadLineMealFlow));
        }
        field(50;"Print Category Code";Code[20])
        {
            Caption = 'Print Category Code';
            TableRelation = "NPRE Print/Prod. Category";
        }
        field(60;"Production Restaurant Code";Code[20])
        {
            Caption = 'Production Restaurant Code';
            TableRelation = "NPRE Restaurant";
        }
        field(70;"Kitchen Station";Code[20])
        {
            Caption = 'Kitchen Station';
            NotBlank = true;
            TableRelation = "NPRE Kitchen Station".Code WHERE ("Restaurant Code"=FIELD("Production Restaurant Code"));
        }
    }

    keys
    {
        key(Key1;"Restaurant Code","Seating Location","Serving Step","Print Category Code","Production Restaurant Code","Kitchen Station")
        {
        }
    }

    fieldgroups
    {
    }
}

