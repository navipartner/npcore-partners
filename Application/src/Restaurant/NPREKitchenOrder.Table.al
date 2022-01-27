table 6150677 "NPR NPRE Kitchen Order"
{
    Access = Internal;
    Caption = 'Kitchen Order';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Order ID"; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Order ID';
            DataClassification = CustomerContent;
        }
        field(10; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            InitValue = Planned;
            OptionCaption = 'Active,Planned,Finished,Cancelled';
            OptionMembers = Active,Planned,Finished,Cancelled;
        }
        field(20; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(30; "Created Date-Time"; DateTime)
        {
            Caption = 'Created Date-Time';
            DataClassification = CustomerContent;
        }
        field(40; "On Hold"; Boolean)
        {
            Caption = 'On Hold';
            DataClassification = CustomerContent;
        }
        field(50; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(500; "Kitchen Station Filter"; Code[20])
        {
            Caption = 'Kitchen Station Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Kitchen Station".Code WHERE("Restaurant Code" = FIELD("Production Restaurant Filter"));
        }
        field(510; "Production Restaurant Filter"; Code[20])
        {
            Caption = 'Production Restaurant Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(600; "Applicable for Kitchen Station"; Boolean)
        {
            CalcFormula = Exist("NPR NPRE Kitchen Req. Station" WHERE("Order ID" = FIELD("Order ID"),
                                                                      "Production Restaurant Code" = FIELD("Production Restaurant Filter"),
                                                                      "Kitchen Station" = FIELD("Kitchen Station Filter")));
            Caption = 'Applicable for Kitchen Station';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Order ID")
        {
        }
        key(Key2; "Restaurant Code", Status, Priority, "Created Date-Time")
        {
        }
    }

    trigger OnDelete()
    var
        KitchenOrderLine: Record "NPR NPRE Kitchen Request";
    begin
        KitchenOrderLine.SetRange("Order ID", "Order ID");
        if not KitchenOrderLine.IsEmpty then
            KitchenOrderLine.DeleteAll(true);
    end;
}
