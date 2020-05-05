table 6150677 "NPRE Kitchen Order"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Order';

    fields
    {
        field(1;"Order ID";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Order ID';
        }
        field(10;Status;Option)
        {
            Caption = 'Status';
            InitValue = Planned;
            OptionCaption = 'Active,Planned,Finished,Cancelled';
            OptionMembers = Active,Planned,Finished,Cancelled;
        }
        field(20;Priority;Integer)
        {
            Caption = 'Priority';
        }
        field(30;"Created Date-Time";DateTime)
        {
            Caption = 'Created Date-Time';
        }
        field(40;"On Hold";Boolean)
        {
            Caption = 'On Hold';
        }
        field(50;"Restaurant Code";Code[20])
        {
            Caption = 'Restaurant Code';
            TableRelation = "NPRE Restaurant";
        }
        field(500;"Kitchen Station Filter";Code[20])
        {
            Caption = 'Kitchen Station Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPRE Kitchen Station".Code WHERE ("Restaurant Code"=FIELD("Production Restaurant Filter"));
        }
        field(510;"Production Restaurant Filter";Code[20])
        {
            Caption = 'Production Restaurant Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPRE Restaurant";
        }
        field(600;"Applicable for Kitchen Station";Boolean)
        {
            CalcFormula = Exist("NPRE Kitchen Request Station" WHERE ("Order ID"=FIELD("Order ID"),
                                                                      "Production Restaurant Code"=FIELD("Production Restaurant Filter"),
                                                                      "Kitchen Station"=FIELD("Kitchen Station Filter")));
            Caption = 'Applicable for Kitchen Station';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Order ID")
        {
        }
        key(Key2;"Restaurant Code",Status,Priority,"Created Date-Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        KitchenOrderLine: Record "NPRE Kitchen Request";
    begin
        KitchenOrderLine.SetRange("Order ID","Order ID");
        if not KitchenOrderLine.IsEmpty then
          KitchenOrderLine.DeleteAll(true);
    end;
}

