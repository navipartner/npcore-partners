enum 6014474 "NPR Replication EndPoint Meth" implements "NPR Replication IEndpoint Meth"
{
    Extensible = true;

    value(0; "Get Item Categories")
    {
        Caption = 'Get Item Categories';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Item Categories";
    }
    value(1; "Get Items")
    {
        Caption = 'Get Items';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Item";
    }

    value(2; "Get Variety Groups")
    {
        Caption = 'Get Variety Groups';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Variety Groups";
    }

    value(3; "Get Varieties")
    {
        Caption = 'Get Varieties';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Varieties";
    }

    value(4; "Get Variety Tables")
    {
        Caption = 'Get Variety Tables';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Variety Tables";
    }

    value(5; "Get Variety Values")
    {
        Caption = 'Get Variety Values';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Variety Values";
    }

    value(10; "Get Item Variants")
    {
        Caption = 'Get Item Variants';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Item Variants";
    }

    value(15; "Get Item References")
    {
        Caption = 'Get Item References';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Item References";
    }

    value(20; "Get Units of Measure")
    {
        Caption = 'Get Units of Measure';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Units Of Measure";
    }

    value(25; "Get Items Units of Measure")
    {
        Caption = 'Get Items Units of Measure';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Item UOM";
    }

    value(30; "Get Customers")
    {
        Caption = 'Get Customers';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Customers";
    }

    value(40; "Get Price List Headers")
    {
        Caption = 'Get Price List Headers';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Price List Headers";
    }

    value(41; "Get Price List Lines")
    {
        Caption = 'Get Price List Lines';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Price List Lines";
    }

    value(50; "Get Periodic Discounts")
    {
        Caption = 'Get Periodic Discounts';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Periodic Disc.";
    }

    value(55; "Get Mixed Discounts")
    {
        Caption = 'Get Mixed Discounts';
        Implementation = "NPR Replication IEndpoint Meth" = "NPR Rep. Get Mixed Disc.";
    }

}
