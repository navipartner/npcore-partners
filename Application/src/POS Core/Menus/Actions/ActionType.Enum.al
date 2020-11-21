enum 6150750 "NPR Action Type" implements "NPR IAction"
{
    Extensible = true;

    value(0; SubMenu)
    {
        Caption = '';
        Implementation = "NPR IAction" = "NPR SubMenu Action";
    }

    value(1; PopupMenu)
    {
        Caption = 'Popup Menu';
        Implementation = "NPR IAction" = "NPR Popup Menu Action";
    }

    value(2; Action)
    {
        Caption = 'Action';
        Implementation = "NPR IAction" = "NPR Workflow Action";
    }

    value(4; Item)
    {
        Caption = 'Item';
        Implementation = "NPR IAction" = "NPR Item Action";
    }

    value(6; Customer)
    {
        Caption = 'Customer';
        Implementation = "NPR IAction" = "NPR Customer Action";
    }

    value(7; PaymentType)
    {
        Caption = 'Payment Type';
        Implementation = "NPR IAction" = "NPR Payment Action";
    }
}
